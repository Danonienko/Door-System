const DoorConstants = require(script.Parent.DoorConstants)
const DoorEnums = require(script.Parent.DoorEnums)
const DoorTypes = require(script.Parent.DoorTypes)
const t = require(script.Parent.t)

const Door = {}
const mt = {}
mt.__index = mt

const private = {}

const isValidAnimContainer = t.children({
	Open = t.instanceIsA("Animation"),
	Opening = t.instanceIsA("Animation"),
	Closed = t.instanceIsA("Animation"),
	Closing = t.instanceIsA("Animation"),
})

local function _setState(self: Door, state: DoorEnums.EnumDoorState): ()
	private[self].Model:SetAttribute(DoorConstants.STATE_ATTRIBUTE, state)
end

local function _open(self: Door): ()
	if self:GetState() == "Open" then
		return
	end

	const animations = private[self].Animations

	_setState(self, "Opening")
	animations.Closed:Stop()
	animations.Opening:Play()
	animations.Opening.Stopped:Wait()
	animations.Open:Play()
	_setState(self, "Open")
end

local function _close(self: Door): ()
	if self:GetState() == "Closed" then
		return
	end

	const animations = private[self].Animations

	_setState(self, "Closing")
	animations.Open:Stop()
	animations.Closing:Play()
	animations.Closing.Stopped:Wait()
	animations.Closed:Play()
	_setState(self, "Closed")
end

local function _loadAnimations(model: Model): DoorTypes.DoorAnimationTracks
	const animationController = model:FindFirstChildOfClass("AnimationController")
	assert(animationController, "A door instance must have an 'AnimationController'")

	const animator: Animator? = animationController:FindFirstChildOfClass("Animator")
	assert(animator, "An animation controller must have an animator")

	const attribute = model:GetAttribute(DoorConstants.ANIMATIONS_ATTRIBUTE)
	const animContainer = typeof(attribute) == "InstanceHandle" and attribute:Get() or nil
	assert(animContainer, "No animations container assigned")

	const isValid, error = isValidAnimContainer(animContainer)
	assert(isValid, `Invalid animations container: {error}`)

	const animations = animContainer :: DoorTypes.DoorAnimations

	const success, result = pcall(function(): DoorTypes.DoorAnimationTracks
		return {
			Open = animator:LoadAnimation(animations.Open),
			Opening = animator:LoadAnimation(animations.Opening),
			Closed = animator:LoadAnimation(animations.Closed),
			Closing = animator:LoadAnimation(animations.Closing),
		}
	end)

	assert(success, `Error loading animations: {result}`)

	return result
end

function Door.new(model: Model)
	const self = setmetatable({}, mt)

	private[self] = {
		Model = model,
		Animations = _loadAnimations(model),
	}

	_setState(self, "Closed")

	return self
end

function mt.Toggle(self: Door): ()
	const state = self:GetState()

	if state == "Open" then
		_close(self)
	end

	if state == "Closed" then
		_open(self)
	end
end

function mt.GetState(self: Door): DoorEnums.EnumDoorState
	const attribute = private[self].Model:GetAttribute(DoorConstants.STATE_ATTRIBUTE)
	return typeof(attribute) == "string" and attribute :: DoorEnums.EnumDoorState or DoorEnums.DoorState.None
end

function mt.Destroy(self: Door): ()
	table.clear(private[self])
	private[self] = nil
	table.clear(self)
	setmetatable(self, nil)
end

export type Door = typeof(Door.new(...))

return Door
