# Cleanup

First let's restart the Pod to clean up all the modifications we did in the container:

## Run the following commands on the victim VM.

```kubectl delete pod -n default -l app=sample-app```

To prevent the attack, we are going to install NeuVector and cert-manager to secure the NeuVector UI with TLS.
