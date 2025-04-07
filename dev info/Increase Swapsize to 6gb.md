To increase your system's swap space to 6 GB on FreeBSD 14.1, you can either resize the existing swap file or create an additional swap file. Since resizing an active swap file involves disabling it—which can strain system resources—adding a new swap file is a safer approach. This method allows you to incrementally increase swap space without disrupting system operations.

**Steps to Add an Additional 4 GB Swap File:**

1. **Create a New Swap File:**
   Open a terminal and execute the following command to create a 4 GB swap file named `/swapfile1`:
   ```sh
   sudo dd if=/dev/zero of=/swapfile1 bs=1M count=4096
   ```

   This command generates a 4 GB file filled with zeros.

2. **Set Appropriate Permissions:**
   Restrict access to the swap file to enhance security:
   ```sh
   sudo chmod 0600 /swapfile1
   ```


3. **Associate the Swap File with a Memory Disk:**
   Use `mdconfig` to link the swap file to a virtual memory disk:
   ```sh
   sudo mdconfig -a -t vnode -f /swapfile1 -u 1
   ```

   This command associates `/swapfile1` with the device `/dev/md1`.

4. **Enable the New Swap Space:**
   Activate the newly created swap space:
   ```sh
   sudo swapon /dev/md1
   ```


5. **Verify the Swap Space:**
   Confirm that the additional swap space is active:
   ```sh
   swapinfo
   ```

   You should see both `/dev/md0` (your existing 2 GB swap) and `/dev/md1` (the new 4 GB swap), totaling 6 GB of swap space.

6. **Configure Automatic Mounting at Boot:**
   To ensure the new swap file is activated on system startup, add the following line to your `/etc/fstab`:
   ```
   md1 none swap sw,file=/swapfile1,late 0 0
   ```

   This entry directs the system to set up the additional swap file during the boot process.

**Alternative Approach: Recreate a Single 6 GB Swap File**

If you prefer to have a single swap file totaling 6 GB, follow these steps:

1. **Disable the Existing Swap File:**
   ```sh
   sudo swapoff /dev/md0
   ```


2. **Delete the Memory Disk Association:**
   ```sh
   sudo mdconfig -d -u 0
   ```


3. **Remove the Existing Swap File:**
   ```sh
   sudo rm /swapfile
   ```


4. **Create a New 6 GB Swap File:**
   ```sh
   sudo dd if=/dev/zero of=/swapfile bs=1M count=6144
   ```


5. **Set Permissions and Configure Memory Disk:**
   ```sh
   sudo chmod 0600 /swapfile
   sudo mdconfig -a -t vnode -f /swapfile -u 0
   ```


6. **Enable the New Swap Space and Verify:**
   ```sh
   sudo swapon /dev/md0
   swapinfo
   ```


7. **Update `/etc/fstab` for Automatic Mounting:**
   Ensure the existing entry in `/etc/fstab` reflects the new swap file size. If you've previously configured automatic mounting as described in earlier steps, no further changes are necessary.

**Additional Considerations:**

- **System Resources:** Ensure your system has sufficient disk space for the new swap file.

- **Performance Monitoring:** Regularly monitor swap usage to assess system performance and make adjustments as needed.

By following these steps, you can safely increase your system's swap space to 6 GB on FreeBSD 14.1. 