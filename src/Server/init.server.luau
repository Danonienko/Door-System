--!nonstrict

for _, child in script:GetChildren() do
	if not child:IsA("ModuleScript") then
		continue
	end

	require(child)
end
