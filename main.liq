# Main script.

%include "./lib/controler.liq"
%include "./config/params.liq"

# Enable controler
controler.json.register = controler.enable_json(port=controler.port)

# Pre-apply user and password
controler.json.register = controler.json.register(user=controler.user, password=controler.password)

# Load endpoints.
controler.json.endpoints.enable_all(register=controler.json.register)

# FOR TESTING!
output.dummy(blank())
