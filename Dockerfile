FROM ubi8/openjdk-8:1.18-2

RUN echo "hello"

ENTRYPOINT ["sh", "-c", "echo Hello from container; sleep 3600"]
