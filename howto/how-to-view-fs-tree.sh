# ps -ef | grep 91610
root      91610  84305  0 May08 ?        00:00:00 /usr/bin/docker-containerd-shim-current 39429cb438b31c45fe529fe1a8cf9c6b08ce3111bfd06533555661fd19ba9526 /var/run/docker/libcontainerd/39429cb438b31c45fe529fe1a8cf9c6b08ce3111bfd06533555661fd19ba9526 /usr/libexec/docker/docker-runc-current
root      91633  91610  0 May08 ?        00:00:17 /usr/sbin/crond -n -m off
root      93870  91610  0 May08 ?        00:05:43 /usr/libexec/pcp/bin/pmcd -A

# nsenter -t 91610 -m findmnt -o TARGET,FSTYPE,PROPAGATION | grep c769b13124241578f4fb7e7e4
[nothing]

# nsenter -t 91633 -m findmnt -o TARGET,FSTYPE,PROPAGATION
TARGET                                                                                                                                                                 PROPAGATION
/                                                                                                                                                                      private
[snip]
├─/host                                                                                                                                                                private,slave
│ ├─/host/dev                                                                                                                                                          private,slave
│ │ ├─/host/dev/shm                                                                                                                                                    private,slave
│ │ ├─/host/dev/pts                                                                                                                                                    private,slave
│ │ ├─/host/dev/mqueue                                                                                                                                                 private,slave
│ │ └─/host/dev/hugepages                                                                                                                                              private,slave
│ ├─/host/proc                                                                                                                                                         private,slave
│ │ ├─/host/proc/sys/fs/binfmt_misc                                                                                                                                    private,slave
│ │ └─/host/proc/fs/nfsd                                                                                                                                               private,slave
│ ├─/host/sys                                                                                                                                                          private,slave
│ │ ├─/host/sys/kernel/security                                                                                                                                        private,slave
│ │ ├─/host/sys/fs/cgroup                                                                                                                                              private,slave
│ │ │ ├─/host/sys/fs/cgroup/systemd                                                                                                                                    private,slave
│ │ │ ├─/host/sys/fs/cgroup/cpu,cpuacct                                                                                                                                private,slave
│ │ │ ├─/host/sys/fs/cgroup/pids                                                                                                                                       private,slave
│ │ │ ├─/host/sys/fs/cgroup/hugetlb                                                                                                                                    private,slave
│ │ │ ├─/host/sys/fs/cgroup/memory                                                                                                                                     private,slave
│ │ │ ├─/host/sys/fs/cgroup/blkio                                                                                                                                      private,slave
│ │ │ ├─/host/sys/fs/cgroup/perf_event                                                                                                                                 private,slave
│ │ │ ├─/host/sys/fs/cgroup/cpuset                                                                                                                                     private,slave
│ │ │ ├─/host/sys/fs/cgroup/freezer                                                                                                                                    private,slave
│ │ │ ├─/host/sys/fs/cgroup/net_cls,net_prio                                                                                                                           private,slave
│ │ │ └─/host/sys/fs/cgroup/devices                                                                                                                                    private,slave
│ │ ├─/host/sys/fs/pstore                                                                                                                                              private,slave
│ │ ├─/host/sys/kernel/config                                                                                                                                          private,slave
│ │ ├─/host/sys/fs/selinux                                                                                                                                             private,slave
│ │ └─/host/sys/kernel/debug                                                                                                                                           private,slave
│ ├─/host/run                                                                                                                                                          private,slave
│ │ ├─/host/run/user/763                                                                                                                                               private,slave
│ │ ├─/host/run/docker/netns/default                                                                                                                                   private,slave
│ │ ├─/host/run/docker/netns/3fa48b388ff3                                                                                                                              private,slave
│ │ ├─/host/run/docker/netns/b8ff94764a43                                                                                                                              private,slave
│ │ ├─/host/run/docker/netns/c62eb108d8f1                                                                                                                              private,slave
│ │ ├─/host/run/docker/netns/8724a60fa2d9                                                                                                                              private,slave
│ │ ├─/host/run/docker/netns/468a03f57fa9                                                                                                                              private,slave
│ │ ├─/host/run/docker/netns/c47c279af13c                                                                                                                              private,slave
│ │ └─/host/run/docker/netns/6486ec1b465d                                                                                                                              private,slave
│ ├─/host/boot                                                                                                                                                         private,slave
│ └─/host/var                                                                                                                                                          private,slave
│   ├─/host/var/lib/origin/openshift.local.volumes/pods/ee3d2c61-34bb-11e7-8754-0eaa067b1713/volumes/kubernetes.io~secret/aggregated-logging-elasticsearch-token-6vtqk private,slave
│   ├─/host/var/lib/origin/openshift.local.volumes/pods/f960f0d6-34bb-11e7-8754-0eaa067b1713/volumes/kubernetes.io~secret/kibana-proxy                                 private,slave
│   ├─/host/var/lib/origin/openshift.local.volumes/pods/f54453aa-34bb-11e7-8754-0eaa067b1713/volumes/kubernetes.io~secret/hawkular-cassandra-secrets                   private,slave
│   ├─/host/var/lib/origin/openshift.local.volumes/pods/ee3d2c61-34bb-11e7-8754-0eaa067b1713/volumes/kubernetes.io~secret/elasticsearch                                private,slave
│   ├─/host/var/lib/origin/openshift.local.volumes/pods/fba0a04b-34bb-11e7-8754-0eaa067b1713/volumes/kubernetes.io~secret/hawkular-token-wvq1x                         private,slave
│   ├─/host/var/lib/origin/openshift.local.volumes/pods/eea6c43a-34bb-11e7-8754-0eaa067b1713/volumes/kubernetes.io~secret/aggregated-logging-kibana-token-m1jtx        private,slave
│   ├─/host/var/lib/origin/openshift.local.volumes/pods/eea6c43a-34bb-11e7-8754-0eaa067b1713/volumes/kubernetes.io~secret/kibana                                       private,slave
│   ├─/host/var/lib/origin/openshift.local.volumes/pods/f54453aa-34bb-11e7-8754-0eaa067b1713/volumes/kubernetes.io~secret/cassandra-token-16vcj                        private,slave
│   ├─/host/var/lib/origin/openshift.local.volumes/pods/f54453aa-34bb-11e7-8754-0eaa067b1713/volumes/kubernetes.io~aws-ebs/pvc-c1fe10ae-1e20-11e7-bee2-0ea1922a9381    private,slave
│   ├─/host/var/lib/origin/openshift.local.volumes/pods/a373c7a7-34bb-11e7-8754-0eaa067b1713/volumes/kubernetes.io~secret/registry-token-at20c                         private,slave
│   ├─/host/var/lib/origin/openshift.local.volumes/pods/a373c7a7-34bb-11e7-8754-0eaa067b1713/volumes/kubernetes.io~secret/dockersecrets                                private,slave
│   ├─/host/var/lib/origin/openshift.local.volumes/pods/a373c7a7-34bb-11e7-8754-0eaa067b1713/volumes/kubernetes.io~secret/dockercerts                                  private,slave
│   ├─/host/var/lib/origin/openshift.local.volumes/pods/eea6c43a-34bb-11e7-8754-0eaa067b1713/volumes/kubernetes.io~secret/kibana-proxy                                 private,slave
│   ├─/host/var/lib/origin/openshift.local.volumes/plugins/kubernetes.io/aws-ebs/mounts/aws/us-east-1c/vol-049d7a9316d0feee6                                           private,slave
│   ├─/host/var/lib/origin/openshift.local.volumes/pods/ee3d2c61-34bb-11e7-8754-0eaa067b1713/volumes/kubernetes.io~aws-ebs/pvc-4216403a-db50-11e6-a28c-0ea1922a9381    private,slave
│   ├─/host/var/lib/origin/openshift.local.volumes/pods/f960f0d6-34bb-11e7-8754-0eaa067b1713/volumes/kubernetes.io~secret/aggregated-logging-kibana-token-m1jtx        private,slave
│   ├─/host/var/lib/origin/openshift.local.volumes/pods/f960f0d6-34bb-11e7-8754-0eaa067b1713/volumes/kubernetes.io~secret/kibana                                       private,slave
│   ├─/host/var/lib/origin/openshift.local.volumes/pods/fba0a04b-34bb-11e7-8754-0eaa067b1713/volumes/kubernetes.io~secret/hawkular-metrics-secrets                     private,slave
│   ├─/host/var/lib/origin/openshift.local.volumes/pods/fba0a04b-34bb-11e7-8754-0eaa067b1713/volumes/kubernetes.io~secret/hawkular-metrics-client-secrets              private,slave
│   ├─/host/var/lib/nfs/rpc_pipefs                                                                                                                                     private,slave
│   ├─/host/var/lib/origin/openshift.local.volumes/pods/a16d5d28-2eb4-11e7-a9db-0eaa067b1713/volumes/kubernetes.io~secret/intercom-api-auth                            private,slave
│   ├─/host/var/lib/origin/openshift.local.volumes/pods/a16d5d28-2eb4-11e7-a9db-0eaa067b1713/volumes/kubernetes.io~secret/intercom-account-reconciler-token-ieus2      private,slave
│   ├─/host/var/lib/origin/openshift.local.volumes/pods/e5087dce-2eb4-11e7-a576-0ee251450653/volumes/kubernetes.io~secret/aggregated-logging-fluentd-token-jpdv1       private,slave
│   ├─/host/var/lib/origin/openshift.local.volumes/pods/e5087dce-2eb4-11e7-a576-0ee251450653/volumes/kubernetes.io~secret/certs                                        private,slave
│   ├─/host/var/lib/origin/openshift.local.volumes/pods/1a31d16e-2eb5-11e7-9452-0ea1922a9381/volumes/kubernetes.io~secret/heapster-secrets                             private,slave
│   ├─/host/var/lib/origin/openshift.local.volumes/pods/1a31d16e-2eb5-11e7-9452-0ea1922a9381/volumes/kubernetes.io~secret/hawkular-metrics-certificate                 private,slave
│   ├─/host/var/lib/origin/openshift.local.volumes/pods/1a31d16e-2eb5-11e7-9452-0ea1922a9381/volumes/kubernetes.io~secret/hawkular-metrics-account                     private,slave
│   ├─/host/var/lib/origin/openshift.local.volumes/pods/1a31d16e-2eb5-11e7-9452-0ea1922a9381/volumes/kubernetes.io~secret/heapster-token-k4bbq                         private,slave
│   ├─/host/var/lib/origin/openshift.local.volumes/plugins/kubernetes.io/aws-ebs/mounts/aws/us-east-1c/vol-0e5a313767d7bf160                                           private,slave
│   ├─/host/var/lib/docker/devicemapper                                                                                                                                private
│   │ ├─/host/var/lib/docker/devicemapper/mnt/8b12a2cd61ab9858ba387a87a53533626b8526a883e9af63c36c07495d26da4c                                                         private
│   │ ├─/host/var/lib/docker/devicemapper/mnt/cffcc7529f69cba901280b0bf708be62200551a2c20906a6d9852c60d832be3c                                                         private
│   │ ├─/host/var/lib/docker/devicemapper/mnt/0249eb425393428e728dcae02ac845fd592f9d9dfa04e02a72be76697c79bc4b                                                         private
│   │ ├─/host/var/lib/docker/devicemapper/mnt/5ef001a69d34eb72861d1961b9d9e2c2e26a5f7e3cbd9130afdcef2f2301649a                                                         private
│   │ ├─/host/var/lib/docker/devicemapper/mnt/c66873c5385aebbae026161415a24e8a91f3b2825da44d0bf961a7e3b1573b03                                                         private
│   │ ├─/host/var/lib/docker/devicemapper/mnt/1f9fac7876b3fc38dcd789c1bac03ddc29f17a356c63fafbe92a7b7cc9c4702c                                                         private
│   │ ├─/host/var/lib/docker/devicemapper/mnt/9ad31820c36291df278e83f55f0c8353062e27e7ce857ac352e79148db2b39ec                                                         private
│   │ ├─/host/var/lib/docker/devicemapper/mnt/19874f25575bee6c11dfbd936b0abf621ed2e94a9771123beb04863332ddf6a5                                                         private
│   │ ├─/host/var/lib/docker/devicemapper/mnt/c185928c7d1afd3f0202999ec19eac157572769195ed29417335a279e634e3c6                                                         private
│   │ ├─/host/var/lib/docker/devicemapper/mnt/986f24e8f415d798aa3d83380b2facd7f67d548f073608d2a9e029e720c28402                                                         private
│   │ ├─/host/var/lib/docker/devicemapper/mnt/0f84bc086382991be5714036c4de22ebc3e7624b0e154ba4f56344183842bd56                                                         private
│   │ ├─/host/var/lib/docker/devicemapper/mnt/72eba9b0da7f90c55e105c401d030628bb4d17bacea421211c755bbbdc2be91b                                                         private
│   │ ├─/host/var/lib/docker/devicemapper/mnt/33ef62ee5a982631f114825ecab5fd6d77f8de74265f9554516ecc2f4cfc83df                                                         private
│   │ ├─/host/var/lib/docker/devicemapper/mnt/9615836764baf3d14ac576edc5eacc0143a0694ebd94800cf4e2bbd6c77264ef                                                         private
│   │ ├─/host/var/lib/docker/devicemapper/mnt/c769b13124241578f4fb7e7e4f5c0e3c99fd73ecf92c2fefa9163b40231cd9bb                                                         private
│   │ ├─/host/var/lib/docker/devicemapper/mnt/73954d9ef7ad0b67d7b6b697a23e8784c731057796ca501f7bb569743bc87414                                                         private
│   │ └─/host/var/lib/docker/devicemapper/mnt/6b37df1d86aef17cbc866069997c60ac9a834bd6a352a84616233bebf281ae0d                                                         private
│   │   └─/host/var/lib/docker/devicemapper/mnt/6b37df1d86aef17cbc866069997c60ac9a834bd6a352a84616233bebf281ae0d/rootfs                                                private
│   │     ├─/host/var/lib/docker/devicemapper/mnt/6b37df1d86aef17cbc866069997c60ac9a834bd6a352a84616233bebf281ae0d/rootfs/proc                                         private
│   │     ├─/host/var/lib/docker/devicemapper/mnt/6b37df1d86aef17cbc866069997c60ac9a834bd6a352a84616233bebf281ae0d/rootfs/dev                                          private
│   │     │ ├─/host/var/lib/docker/devicemapper/mnt/6b37df1d86aef17cbc866069997c60ac9a834bd6a352a84616233bebf281ae0d/rootfs/dev/pts                                    private
│   │     │ └─/host/var/lib/docker/devicemapper/mnt/6b37df1d86aef17cbc866069997c60ac9a834bd6a352a84616233bebf281ae0d/rootfs/dev/mqueue                                 private
│   │     ├─/host/var/lib/docker/devicemapper/mnt/6b37df1d86aef17cbc866069997c60ac9a834bd6a352a84616233bebf281ae0d/rootfs/sys/fs/cgroup                                private
│   │     │ ├─/host/var/lib/docker/devicemapper/mnt/6b37df1d86aef17cbc866069997c60ac9a834bd6a352a84616233bebf281ae0d/rootfs/sys/fs/cgroup/systemd                      private,slave
│   │     │ ├─/host/var/lib/docker/devicemapper/mnt/6b37df1d86aef17cbc866069997c60ac9a834bd6a352a84616233bebf281ae0d/rootfs/sys/fs/cgroup/cpuacct,cpu                  private,slave
│   │     │ ├─/host/var/lib/docker/devicemapper/mnt/6b37df1d86aef17cbc866069997c60ac9a834bd6a352a84616233bebf281ae0d/rootfs/sys/fs/cgroup/pids                         private,slave
│   │     │ ├─/host/var/lib/docker/devicemapper/mnt/6b37df1d86aef17cbc866069997c60ac9a834bd6a352a84616233bebf281ae0d/rootfs/sys/fs/cgroup/hugetlb                      private,slave
│   │     │ ├─/host/var/lib/docker/devicemapper/mnt/6b37df1d86aef17cbc866069997c60ac9a834bd6a352a84616233bebf281ae0d/rootfs/sys/fs/cgroup/memory                       private,slave
│   │     │ ├─/host/var/lib/docker/devicemapper/mnt/6b37df1d86aef17cbc866069997c60ac9a834bd6a352a84616233bebf281ae0d/rootfs/sys/fs/cgroup/blkio                        private,slave
│   │     │ ├─/host/var/lib/docker/devicemapper/mnt/6b37df1d86aef17cbc866069997c60ac9a834bd6a352a84616233bebf281ae0d/rootfs/sys/fs/cgroup/perf_event                   private,slave
│   │     │ ├─/host/var/lib/docker/devicemapper/mnt/6b37df1d86aef17cbc866069997c60ac9a834bd6a352a84616233bebf281ae0d/rootfs/sys/fs/cgroup/cpuset                       private,slave
│   │     │ ├─/host/var/lib/docker/devicemapper/mnt/6b37df1d86aef17cbc866069997c60ac9a834bd6a352a84616233bebf281ae0d/rootfs/sys/fs/cgroup/freezer                      private,slave
│   │     │ ├─/host/var/lib/docker/devicemapper/mnt/6b37df1d86aef17cbc866069997c60ac9a834bd6a352a84616233bebf281ae0d/rootfs/sys/fs/cgroup/net_prio,net_cls             private,slave
│   │     │ └─/host/var/lib/docker/devicemapper/mnt/6b37df1d86aef17cbc866069997c60ac9a834bd6a352a84616233bebf281ae0d/rootfs/sys/fs/cgroup/devices                      private,slave
│   │     ├─/host/var/lib/docker/devicemapper/mnt/6b37df1d86aef17cbc866069997c60ac9a834bd6a352a84616233bebf281ae0d/rootfs/container_setup                              private
│   │     └─/host/var/lib/docker/devicemapper/mnt/6b37df1d86aef17cbc866069997c60ac9a834bd6a352a84616233bebf281ae0d/rootfs/sys                                          private
│   │       ├─/host/var/lib/docker/devicemapper/mnt/6b37df1d86aef17cbc866069997c60ac9a834bd6a352a84616233bebf281ae0d/rootfs/sys/kernel/security                        private
│   │       ├─/host/var/lib/docker/devicemapper/mnt/6b37df1d86aef17cbc866069997c60ac9a834bd6a352a84616233bebf281ae0d/rootfs/sys/fs/cgroup                              private
│   │       │ ├─/host/var/lib/docker/devicemapper/mnt/6b37df1d86aef17cbc866069997c60ac9a834bd6a352a84616233bebf281ae0d/rootfs/sys/fs/cgroup/systemd                    private
│   │       │ ├─/host/var/lib/docker/devicemapper/mnt/6b37df1d86aef17cbc866069997c60ac9a834bd6a352a84616233bebf281ae0d/rootfs/sys/fs/cgroup/cpu,cpuacct                private
│   │       │ ├─/host/var/lib/docker/devicemapper/mnt/6b37df1d86aef17cbc866069997c60ac9a834bd6a352a84616233bebf281ae0d/rootfs/sys/fs/cgroup/pids                       private
│   │       │ ├─/host/var/lib/docker/devicemapper/mnt/6b37df1d86aef17cbc866069997c60ac9a834bd6a352a84616233bebf281ae0d/rootfs/sys/fs/cgroup/hugetlb                    private
│   │       │ ├─/host/var/lib/docker/devicemapper/mnt/6b37df1d86aef17cbc866069997c60ac9a834bd6a352a84616233bebf281ae0d/rootfs/sys/fs/cgroup/memory                     private
│   │       │ ├─/host/var/lib/docker/devicemapper/mnt/6b37df1d86aef17cbc866069997c60ac9a834bd6a352a84616233bebf281ae0d/rootfs/sys/fs/cgroup/blkio                      private
│   │       │ ├─/host/var/lib/docker/devicemapper/mnt/6b37df1d86aef17cbc866069997c60ac9a834bd6a352a84616233bebf281ae0d/rootfs/sys/fs/cgroup/perf_event                 private
│   │       │ ├─/host/var/lib/docker/devicemapper/mnt/6b37df1d86aef17cbc866069997c60ac9a834bd6a352a84616233bebf281ae0d/rootfs/sys/fs/cgroup/cpuset                     private
│   │       │ ├─/host/var/lib/docker/devicemapper/mnt/6b37df1d86aef17cbc866069997c60ac9a834bd6a352a84616233bebf281ae0d/rootfs/sys/fs/cgroup/freezer                    private
│   │       │ ├─/host/var/lib/docker/devicemapper/mnt/6b37df1d86aef17cbc866069997c60ac9a834bd6a352a84616233bebf281ae0d/rootfs/sys/fs/cgroup/net_cls,net_prio           private
│   │       │ └─/host/var/lib/docker/devicemapper/mnt/6b37df1d86aef17cbc866069997c60ac9a834bd6a352a84616233bebf281ae0d/rootfs/sys/fs/cgroup/devices                    private
│   │       ├─/host/var/lib/docker/devicemapper/mnt/6b37df1d86aef17cbc866069997c60ac9a834bd6a352a84616233bebf281ae0d/rootfs/sys/fs/pstore                              private
│   │       ├─/host/var/lib/docker/devicemapper/mnt/6b37df1d86aef17cbc866069997c60ac9a834bd6a352a84616233bebf281ae0d/rootfs/sys/kernel/config                          private
│   │       ├─/host/var/lib/docker/devicemapper/mnt/6b37df1d86aef17cbc866069997c60ac9a834bd6a352a84616233bebf281ae0d/rootfs/sys/fs/selinux                             private
│   │       └─/host/var/lib/docker/devicemapper/mnt/6b37df1d86aef17cbc866069997c60ac9a834bd6a352a84616233bebf281ae0d/rootfs/sys/kernel/debug                           private
│   ├─/host/var/lib/docker/containers/0ed7611c66103b4304d50b86eebb3666e089e996ff22b73ac41b37dd28d7ca2c/shm                                                             private
│   ├─/host/var/lib/docker/containers/85b94fcf3366455ea1a52b9d8930161b16bf2668b15c4e7c074c0f6d19752818/shm                                                             private
│   ├─/host/var/lib/docker/containers/57110e64a742ef0e4f32493c71c6637ce9ad92dd9fcc914010996703a6e41808/shm                                                             private
│   ├─/host/var/lib/docker/containers/8ca045106dbe156cdb30b8a70451f37d14ad199ecb671801ff101c75889f5b2d/shm                                                             private
│   ├─/host/var/lib/docker/containers/0caba83962930a44f22d6a0c92743c78eb1b937ead6d9f2303edfa8a1d37f14d/shm                                                             private
│   ├─/host/var/lib/docker/containers/5125ba88fa08a511c7e98b35b6c4af317ad418953bc5dd2c8b15f56de031d314/shm                                                             private
│   ├─/host/var/lib/docker/containers/143901234b39bb1ff6649d55eea8165ebe4c0e8a13ee184358af91d324142f42/shm                                                             private
│   ├─/host/var/lib/docker/containers/b93217f44ddb4f03c3f0323dc53c6a3463988d10f4bc830862752c2d89ff8222/shm                                                             private
│   └─/host/var/cache/yum                                                                                                                                              private
[snip]