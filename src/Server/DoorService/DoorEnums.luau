const EnumDoorState = table.freeze({
	None = "None" :: "None",
	Open = "Open" :: "Open",
	Opening = "Opening" :: "Opening",
	Closed = "Closed" :: "Closed",
	Closing = "Closing" :: "Closing",
})

const DoorEnums = table.freeze({
	DoorState = EnumDoorState,
})

type DoorEnums = typeof(DoorEnums)
export type EnumDoorState = keyof<typeof(EnumDoorState)>

return DoorEnums
