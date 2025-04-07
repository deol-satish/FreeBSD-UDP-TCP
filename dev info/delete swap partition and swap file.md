Nice work resizing the partition and converting from a swap partition to a swap file! Here's a step-by-step breakdown and a clean **instruction file** you can reuse or document for future systems, labeled as **"Convert swap partition to swap file using md(4) in FreeBSD"**:

---

### 🧾 **Instruction File: Convert Swap Partition to Swap File (FreeBSD)**

**Goal:** Replace a dedicated swap partition (e.g., `/dev/da0s1b`) with a swap file using `md(4)`.

---

#### 🛠️ 1. Disable and Delete Existing Swap Partition
```sh
swapoff /dev/da0s1b
gpart delete -i 2 da0s1
```

---

#### 🔧 2. Resize the Partition to Use Full Disk Space
Check the layout:
```sh
gpart show da0
```

Resize the slice:
```sh
gpart resize -i 1 da0
```

Resize the filesystem:
```sh
growfs /
```
> If it prompts:  
> `OK to grow filesystem on /dev/da0s1a, mounted on / ...`, type `yes`.

---

#### 📦 3. Create Swap File
```sh
dd if=/dev/zero of=/swapfile bs=1M count=2048   # 2GB swap file
chmod 0600 /swapfile
```

---

#### 🔌 4. Attach Swap File with `mdconfig` and Enable Swap
```sh
mdconfig -a -t vnode -f /swapfile -u 0
swapon /dev/md0
```

Check swap status:
```sh
swapinfo
```

---

#### 📝 5. Persist Swap File Across Reboots

Edit `/etc/fstab`:
```sh
vi /etc/fstab
```

Add this line at the end:
```
md    none    swap    sw,file=/swapfile,late    0    0
```

---

🎉 Done! You now have a flexible, easy-to-resize swap system without needing a dedicated partition.

---

Let me know if you want this saved to a text file or formatted as a Markdown doc.