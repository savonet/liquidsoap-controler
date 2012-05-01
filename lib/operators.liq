%include "controler.liq"
%include "endpoints.liq"
%include "../config/params.liq"

# Enable controler
controler.http.json.register = http.json.enable_controler(port=controler.port)

# Pre-apply user and password
controler.http.json.register = controler.http.json.register(user=controler.user, password=controler.password)

# Load endpoints.
http.json.controler.fallback(register=controler.http.json.register)
http.json.controler.mksafe(register=controler.http.json.register)
http.json.controler.create.request.queue(register=controler.http.json.register)
http.json.controler.create.single(register=controler.http.json.register)
http.json.controler.output.ao(register=controler.http.json.register)

# Bug!
#http.json.controler.metadata.get(register=controler.http.json.register)
#http.json.controler.metadata.set(register=controler.http.json.register)
