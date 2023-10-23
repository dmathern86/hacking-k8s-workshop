# Pull policy and deploy it to your Kubernetes cluster

## Run the following commands on the victim VM

Now we need to pull the policy to our local datastore

```kwctl pull ghcr.io/kubewarden/policies/user-group-psp:v0.4.9```

We can check the pulled policies

```kwctl policies```

Then we will create a yaml file from that policy to modify the file and put some rules into it.

```
kwctl scaffold manifest -t AdmissionPolicy registry://ghcr.io/kubewarden/policies/user-group-psp:v0.4.9 > user-group-psp.yaml
```

We need to add the following configuration parameter into the `user-group-psp.yaml`.Open the yaml file with vi.

```vi user-group-psp.yaml```

Press `i` and copy the content into the file.

```ctr:
  settings:
    description: null
    run_as_group:
      rule: RunAsAny
    run_as_user:
      rule: MustRunAsNonRoot
    supplemental_groups:
      rule: RunAsAny
```

Press ESC and exit vi with `:x`

Now we can apply the policy to our kubernetes cluster

```kubectl apply -f user-group-psp.yaml```

Let us check if the policy is in place. The activation of the policy can take some seconds.

```kubectl get admissionpolicies```

Now we will delete the pod of the sample application to check the policy

```kubectl get pods | tail -n 1 | kubectl delete pod $(awk '{print $1}')```

We will see, that the pod can't be created

```kubectl get events```
