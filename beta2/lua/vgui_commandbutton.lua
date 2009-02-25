//Sorry Garry I stole it :3

local PANEL = {}

AccessorFunc( PANEL, "m_bAlt", 			"Alt" )
AccessorFunc( PANEL, "m_bSelected", 	"Selected" )

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Init()

	self:SetContentAlignment( 4 ) 
	self:SetTextInset( 5 )
	self:SetTall( 15 )
	
end

function PANEL:Paint()

	if ( !self:GetSelected() ) then
		if ( !self.m_bAlt ) then return end
		surface.SetDrawColor( 255, 255, 255, 10 )
	else
		surface.SetDrawColor( 50, 150, 255, 250 )
	end
	
	if self.CheckBoolean ~= nil and self.Checkbox ~= nil then
		if GetSelectedPlayer() == nil then
			self.Checkbox:SetValue( false )
		else
			self.Checkbox:SetValue( GetSelectedPlayer():GetNWBool( self.CheckBoolean ) )
		end
	end
	
	self:DrawFilledRect()
	
end

/*---------------------------------------------------------
   Name: OnMouseMoved
---------------------------------------------------------*/
function PANEL:OnCursorMoved(  )
	
	self:ResetFocus( self )
	
end

/*---------------------------------------------------------
   Name: OnMousePressed
---------------------------------------------------------*/
function PANEL:OnMousePressed(  )
	
	if GetSelectedPlayer() == nil then return  end
	if self.CheckBoolean == nil or !self.Checkbox:GetChecked() then
		RunConsoleCommand( "say", "!" .. string.Replace( self.OnCommand, "[PLAYER]", tostring(GetSelectedPlayer():EntIndex()) ) )
	else
		RunConsoleCommand( "say", "!" .. string.Replace( self.OffCommand, "[PLAYER]", tostring(GetSelectedPlayer():EntIndex()) ) )
	end
	
end

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:OnSelect()

	// Override
	
end

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:PerformLayout()

	if ( self.Checkbox ) then
	
		self.Checkbox:AlignRight( 4 )
		self.Checkbox:CenterVertical()
	
	end
	
end

function PANEL:AddCheckBox()

	if ( !self.Checkbox ) then 
		self.Checkbox = vgui.Create( "DCheckBox", self )
		self.Checkbox.OnMousePressed = function() self:OnMousePressed() end
	end
	
	self:InvalidateLayout()

end

function PANEL:ResetFocus()
	for _, v in pairs(PlayerMenuItems) do
		if v.Control ~= self then
			v.Control:SetSelected( false )
		else
			v.Control:SetSelected( true )
		end
	end
end

function PANEL:GetSelfItem()
	for _, v in pairs(PlayerMenuItems) do
		if v.Control == self then
			return v
		end
	end
end

vgui.Register( "CommandButton", PANEL, "DButton" )