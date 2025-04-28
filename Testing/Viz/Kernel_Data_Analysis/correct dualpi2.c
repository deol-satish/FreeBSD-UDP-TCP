 /*
 * Enqueue a packet in q, subject to space and L4S queue management policy
 * (whose parameters are in q->fs).
 * Update stats for the queue and the scheduler.
 * Return 0 on success, 1 on drop. The packet is consumed anyways.
 */
static int
pie_enqueue(struct l4s_flow *q, struct mbuf* m, struct l4s_si *si)
{
	uint64_t len;
	struct pie_status *pst;
	struct dn_aqm_pie_parms *pprms;
	int t;

	len = m->m_pkthdr.len;
	pst  = &q->pst;
	pprms = pst->parms;
	t = ENQUE;
	uint32_t local_l_prob ;
	uint8_t coupling_factor = 2;
	local_l_prob  = (pst->drop_prob > q->c_base_drop_prob * coupling_factor) ? pst->drop_prob : q->c_base_drop_prob * coupling_factor;
	bool overload = local_l_prob > PIE_MAX_PROB;
	// Output the boolean value using %s
    // printf("Overload: %s\n", overload ? "true" : "false");
	int dequeue_action = ENQUE;	
	
	if (q->queue_type == CLASSIC_QUEUE)
		dequeue_action = cqueue_drop_early(pst, q->stats.len_bytes);
	else if (q->queue_type == L4S_QUEUE)
		dequeue_action = lqueue_drop_early(pst, q->stats.len_bytes, local_l_prob, overload);

	// printf("dequeue_action: %d \n", dequeue_action);

	
	/* drop/mark the packet when PIE is active and burst time elapsed */
	if (pst->sflags & PIE_ACTIVE && pst->burst_allowance == 0
		&& dequeue_action == DROP) {
			/* 
			 * if drop_prob over ECN threshold, drop the packet 
			 * otherwise mark and enqueue it.
			 */
			// printf("Dequeue Action: DROP \n");
			if (pprms->flags & PIE_ECN_ENABLED && pst->drop_prob < 
				(pprms->max_ecnth << (PIE_PROB_BITS - PIE_FIX_POINT_BITS)))
				{
					if (ecn_mark(m))
					{
						t = ENQUE;
						dequeue_action = MARKECN;
						//printf("Dequeue Action: MARKECN \n");
					}
						
					else
					{
						// printf("Dequeue Action: DROP BECAUSE ECN DISABLED \n");
						t = DROP;
						dequeue_action = DROP;
					}
				}		
			else if (q->queue_type == CLASSIC_QUEUE || q->queue_type == L4S_QUEUE)
			{
				// printf("Dequeue Action: DROP BECAUSE drop probabbility is greater than threshold \n");
				t = DROP;
				dequeue_action = DROP;
			}
				
	}


	printf("l4s_ecn_marking-start,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%lu,%u,%u,%u,%u,%lu,%lu,%u,%u,%u,%lu,%d,end \n",q->queue_type,pprms->qdelay_ref,pprms->tupdate,
	pprms->max_burst,pprms->max_ecnth,pprms->alpha,pprms->beta,pprms->flags,
	pst->burst_allowance,pst->drop_prob,pst->current_qdelay,pst->qdelay_old,pst->accu_prob,
	pst->measurement_start,pst->avg_dq_time,pst->dq_count,pst->sflags,q->stats.tot_pkts,q->stats.tot_bytes,q->stats.length,
	q->stats.len_bytes,q->stats.drops,len,dequeue_action);

	/* Turn PIE on when 1/3 of the queue is full */ 
	if (!(pst->sflags & PIE_ACTIVE) && q->stats.len_bytes >= 
		pst->one_third_q_size) {
		fq_activate_pie(q);
	}

	/*  reset burst tolerance and optinally turn PIE off*/
	if (pst->drop_prob == 0 && pst->current_qdelay < (pprms->qdelay_ref >> 1)
		&& pst->qdelay_old < (pprms->qdelay_ref >> 1)) {
			
			pst->burst_allowance = pprms->max_burst;
		if (pprms->flags & PIE_ON_OFF_MODE_ENABLED && q->stats.len_bytes<=0)
			fq_deactivate_pie(pst);
	}

	/* Use timestamp if Departure Rate Estimation mode is disabled */
	if (t != DROP && !(pprms->flags & PIE_DEPRATEEST_ENABLED)) {
		/* Add TS to mbuf as a TAG */
		struct m_tag *mtag;
		mtag = m_tag_locate(m, MTAG_ABI_COMPAT, DN_AQM_MTAG_TS, NULL);
		if (mtag == NULL)
			mtag = m_tag_alloc(MTAG_ABI_COMPAT, DN_AQM_MTAG_TS,
				sizeof(aqm_time_t), M_NOWAIT);
		if (mtag == NULL) {
			t = DROP;
		} else {
			*(aqm_time_t *)(mtag + 1) = AQM_UNOW;
			m_tag_prepend(m, mtag);
		}
	}

	if (t != DROP) {
		mq_append(&q->mq, m);
		fq_update_stats(q, si, len, 0);
		return 0;
	} else {
		fq_update_stats(q, si, len, 1);
		pst->accu_prob = 0;
		FREE_PKT(m);
		return 1;
	}

	return 0;
}