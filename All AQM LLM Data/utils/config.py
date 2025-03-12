

SAVE_FORMATS = ['png', 'eps', 'pdf']  # Formats to save graphs
SAVE_FORMATS = ['png']  # Formats to save graphs
DPI = 500

# # Color, marker, and linestyle options

# colors = ['red','black', 'g', 'm', 'y', 'k']
# markers = ['o', 's', 'D', '^', 'v', 'p', '*', 'x']         # Add more markers as needed
# linestyles = ['-', '--', '-.', ':']                         # Add more linestyles as needed


colors = ['red','black', 'g', 'm', 'y', 'k']
markers = ['', '', '', '']         # Add more markers as needed
linestyles = ['-', '-', '-', '']                         # Add more linestyles as needed


bar_width = 0.3

figsize = (8,6)

title_req = True


siftr_col = ['Direction', 
        'Time', 
        'LocalIP', 
        'LocalPort',
        'ForeignIP',
        'ForeignPort', 
        'SlowStartThreshold', 
        'CongestionWindow', 
        'BandwidthControlledWindow', 
        'SendingWindow', 
        'ReceiveWindow', 
        'SendingWindowScalingFactor', 
        'ReceiveWindowScalingFactor', 
        'TCPFiniteStateMachine',
        'MaximumSegmentSize', 
        'SmoothedRTT', 
        'SACKEnabled', 
        'TCPFlags', 
        'RetransmissionTimeout', 
        'SocketSendBufferSize', 
        'SocketSendBufferBytes', 
        'SocketReceiveBufferSize', 
        'SocketReceiveBufferBytes', 
        'UnacknowledgedBytes', 
        'ReassemblyQueue', 
        'Flowid', 
        'Flowtype']
