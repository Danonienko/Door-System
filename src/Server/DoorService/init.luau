const CollectionService = game:GetService("CollectionService")

const Door = require(script.Door)
const DoorConstants = require(script.DoorConstants)
const DoorService = {}
const mt = {}
mt.__index = mt

const private = {}

local function _handleInstanceAdded(self: DoorService, instance: Instance): ()
	if not instance:IsA("Model") then
		return
	end

	const success, result = pcall(function()
		private[self].DoorCollection[instance] = Door.new(instance)
		print(`Created a Door instance for {instance.Name}`)
	end)

	if not success then
		return warn(`Error creating a Door instance for {instance.Name}: {result}`)
	end
end

local function _handleInstanceRemoved(self: DoorService, instance: Instance): ()
	if not instance:IsA("Model") then
		return
	end

	const success, result = pcall(function()
		const door = private[self].DoorCollection[instance]
		if not door then
			warn(`Tried to destroy a Door instance for {instance.Name}, but it does not exist!`)
		end

		door:Destroy()
		private[self].DoorCollection[instance] = nil
	end)

	if not success then
		return warn(`Error destroying a Door instance for {instance.Name}: {result}`)
	end
end

function DoorService.new()
	const self = setmetatable({}, mt)

	private[self] = {
		DoorCollection = {},
	}

	const tag = DoorConstants.TAG

	for _, instance in CollectionService:GetTagged(tag) do
		_handleInstanceAdded(self, instance)
	end

	CollectionService:GetInstanceAddedSignal(tag):Connect(function(instance)
		_handleInstanceAdded(self, instance)
	end)

	CollectionService:GetInstanceRemovedSignal(tag):Connect(function(instance)
		_handleInstanceRemoved(self, instance)
	end)

	return self
end

function mt.GetDoorByModel(self: DoorService, model: Model): Door.Door?
	return private[self].DoorCollection[model]
end

export type DoorService = typeof(DoorService.new(...))

return DoorService.new()
