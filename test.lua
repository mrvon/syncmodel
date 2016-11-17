local model = require "model"
local print_r = require "print_r"

local method = {}

function method.dec(obj, ti)
	obj.a = obj.a - 1
	assert(obj.a >= 0)

	print("Time =", ti)
	print("a = a - 1", obj.a)
end

function method.add(obj, ti, n)
	obj.a = obj.a + n

	print("Time =", ti)
	print("a = a + ", n, obj.a)
end

local client1 = model.new ({ a = 1 }, method)
local client2 = model.new ({ a = 1 }, method)
local server = model.new ({ a = 1 }, method)

-- Client 1 execute command
local command1_c1 = client1:queue_command(client1:timestamp(1,1000), "insert", "dec")
local command2_c1 = client1:queue_command(client1:timestamp(1,2000), "insert", "add", 2)
print("command1_c1 execute in client 1, id:", command1_c1)
print("command2_c1 execute in client 1, id:", command2_c1)

print("--------------------------------- Server execute command1_c1 from Client 1")
assert(server:apply_command(command1_c1, "unique", "dec"))
print("--------------------------------- Server execute command2_c1 from Client 1")
assert(server:apply_command(command2_c1, "unique", "add", 2))
print("--------------------------------- End")

print("--------------------------------- Client 1 Snapshot in times:3000")
print_r(client1:snapshot(client1:time(3000)))
print("--------------------------------- End")
print("--------------------------------- Current Server State")
local ti, state = server:current_state()
print("--- Server time:", ti)
print_r(state)
print("--------------------------------- End")

local command1_c2 = client2:queue_command(client2:timestamp(2,1000), "insert", "dec")
local command2_c2 = client2:queue_command(client2:timestamp(2,2000), "insert", "add", 2)
print("command1_c2 execute in client 2, id:", command1_c2)
print("command2_c2 execute in client 2, id:", command2_c2)

print("--------------------------------- Server execute command2_c1 from Client 1")
print("this command id is duplicate:", command2_c1)
assert(server:apply_command(command2_c1, "unique", "dec") == false)
print("--------------------------------- Server execute command2_c2 from Client 2")
assert(server:apply_command(command2_c2, "unique", "add", 2))
print("--------------------------------- End")

print("--------------------------------- Current Server State")
local ti, state = server:current_state()
print("--- Server time:", ti)
print_r(state)
print("--------------------------------- End")


client1:queue_command(command1_c2, "unique", "add", 2)
print("--- Client1 time:", client1:time(3000))
print_r(client1:snapshot(client1:time(3000)))


print("command1_c1 execute in client 2, id:",
client2:queue_command(command1_c1, "unique", "dec")
)
print("command2_c1 execute in client 2, id:",
client2:queue_command(command2_c1, "unique", "add", 2)
)

client2:remove_command(command1_c1)

print("--- Client2 time:", client2:time(3000))
print_r(client2:snapshot(client2:time(3000)))
