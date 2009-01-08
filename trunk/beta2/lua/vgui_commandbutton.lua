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
	
	self:DrawFilledRect()
	
end

/*---------------------------------------------------------
   Name: OnMousePressed
---------------------------------------------------------*/
function PANEL:OnCursorMoved(  )
	
	ResetFocus( self )
	
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

function PANEL:AddCheckBox( strConVar )

	if ( !self.Checkbox ) then 
		self.Checkbox = vgui.Create( "DCheckBox", self )
	end
	
	self.Checkbox:SetConVar( strConVar )
	self:InvalidateLayout()

end

function ResetFocus( Except )
	for _, v in pairs(CommandButtons) do
		if v ~= Except then
			v:SetSelected( false )
		else
			v:SetSelected( true )
		end
	end
end

vgui.Register( "CommandButton", PANEL, "DButton" )