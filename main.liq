# Main script.

%include "./lib/controler.liq"
%include "./config/params.liq"

# Enable controler
x = controler.enable_json(port=controler.port)
controler.json.register = fst(x)
controler.json.remove    = snd(x)

# Pre-apply user and password
controler.json.register = controler.json.register(user=controler.user, password=controler.password)

# Load endpoints.
controler.json.endpoints.enable_all(register=controler.json.register, remove=controler.json.remove)

# FOR TESTING!
output.dummy(blank())
