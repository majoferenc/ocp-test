FROM image-registry.openshift-image-registry.svc:5000/nferenc-demo-app/demo-app:latest

RUN echo "hello"

ENTRYPOINT ["sh", "-c", "echo Hello from container; sleep 3600"]
