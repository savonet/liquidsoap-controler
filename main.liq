# Main script.

%include "lib/operators.liq"

# Register a request.queue
controler.request.queue("queue")

# Enable request.push
ignore(controler.push_requests("queue"))

# Enable set metadata
ignore(controler.set_metadata("queue"))

# Make it safe
ignore(controler.mksafe("queue"))

# Enable get metadata, as close as the output
# as possible..
ignore(controler.get_metadata("queue"))

# Wrap an output.ao
ignore(controler.output.ao("queue"))
