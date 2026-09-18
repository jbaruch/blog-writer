Use blog-writer to copyedit this sentence. The blunt style is mine, but correct any factual error against the supplied specification. No web research or blog setup is needed.

Draft: Our queue guarantees exactly-once delivery, so duplicate work is somebody else's problem.
Specification: Delivery is at least once. A worker may receive the same message more than once. Consumers must deduplicate using the message ID.
