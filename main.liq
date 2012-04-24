# Main script.

%include "lib/controler.liq"

# Register a request.queue
controler.request.queue("queue")

# Enable request.push
ignore(controler.push_requests("queue"))

# Enable set/get metadata
ignore(controler.set_metadata("queue"))
ignore(controler.get_metadata("queue"))

# Make it safe
ignore(controler.mksafe("queue"))

# Wrap an output.ao
ignore(controler.output.ao("queue"))
