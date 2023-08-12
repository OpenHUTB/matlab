function dlgStruct = getDialogSchema( this, ~ )








lprompt = 1;
rprompt = 4;
ledit = rprompt + 1;
redit = 18;
lunit = redit + 1;
runit = 20;
number_grid = 20;


rs = 1;

impedanceType_prompt = simrfV2GetLeafWidgetBase( 'text',  ...
'Impedance type:', 'Impedance_type_prompt', 0 );
impedanceType_prompt.RowSpan = [ rs, rs ];
impedanceType_prompt.ColSpan = [ lprompt, rprompt ];

impedanceType = simrfV2GetLeafWidgetBase( 'combobox', '',  ...
'Impedance_type', this, 'Impedance_type' );
impedanceType.Entries = set( this, 'Impedance_type' )';
impedanceType.RowSpan = [ rs, rs ];
impedanceType.ColSpan = [ ledit, runit ];
impedanceType.DialogRefresh = 1;


rs = rs + 1;
impedanceprompt = simrfV2GetLeafWidgetBase( 'text',  ...
'Complex impedance (Ohm):', 'ImpedancePrompt', 0 );
impedanceprompt.RowSpan = [ rs, rs ];
impedanceprompt.ColSpan = [ lprompt, rprompt ];

impedance = simrfV2GetLeafWidgetBase( 'edit', '', 'Impedance', this,  ...
'Impedance' );
impedance.RowSpan = [ rs, rs ];
impedance.ColSpan = [ ledit, runit ];


rs = rs + 1;
Freq_prompt = simrfV2GetLeafWidgetBase( 'text', 'Frequency:',  ...
'Freqprompt', 0 );
Freq_prompt.RowSpan = [ rs, rs ];
Freq_prompt.ColSpan = [ lprompt, rprompt ];

Freq = simrfV2GetLeafWidgetBase( 'edit', '', 'Freq', this, 'Freq' );
Freq.RowSpan = [ rs, rs ];
Freq.ColSpan = [ ledit, runit ];

Freq_unit = simrfV2GetLeafWidgetBase( 'combobox', '',  ...
'Freq_unit', this, 'Freq_unit' );
Freq_unit.RowSpan = [ rs, rs ];
Freq_unit.ColSpan = [ lunit, runit ];


rs = rs + 1;
spacerMain = simrfV2GetLeafWidgetBase( 'text', ' ', '', 0 );
spacerMain.RowSpan = [ rs, rs ];
spacerMain.ColSpan = [ lprompt, runit ];

maxrows = spacerMain.RowSpan( 1 );


hBlk = get_param( this, 'Handle' );
idxMaskNames = simrfV2getblockmaskparamsindex( hBlk );
slBlkVis = get_param( hBlk, 'MaskVisibilities' );

impedanceType_prompt.Visible = 1;
impedanceType.Visible = 1;
impedanceprompt.Visible = 0;
impedance.Visible = 0;
Freq_prompt.Visible = 0;
Freq.Visible = 0;
Freq_unit.Visible = 0;

slBlkVis( [ idxMaskNames.Impedance, idxMaskNames.Freq ...
, idxMaskNames.Freq_unit ] ) = { 'off' };
slBlkVis( idxMaskNames.Impedance_type ) = { 'on' };

switch this.Impedance_type
case 'Frequency independent'
impedanceprompt.Visible = 1;
impedance.Visible = 1;
slBlkVis( idxMaskNames.Impedance ) = { 'on' };

case 'Frequency dependent'
impedanceprompt.Visible = 1;
impedance.Visible = 1;
Freq_prompt.Visible = 1;
Freq.Visible = 1;
Freq_unit.Visible = 1;
slBlkVis( [ idxMaskNames.Impedance, idxMaskNames.Freq ...
, idxMaskNames.Freq_unit ] ) = { 'on' };

end 

if ~strcmpi( get_param( bdroot( hBlk ), 'Lock' ), 'on' )
set_param( hBlk, 'MaskVisibilities', slBlkVis );
end 



mainParamsPanel.Type = 'group';
mainParamsPanel.Name = 'Parameters';
mainParamsPanel.Tag = 'mainParamsPanel';
mainParamsPanel.Items = { impedanceType_prompt, impedanceType,  ...
impedanceprompt, impedance, Freq_prompt, Freq, Freq_unit, spacerMain };
mainParamsPanel.LayoutGrid = [ maxrows, number_grid ];
mainParamsPanel.RowSpan = [ 2, 2 ];
mainParamsPanel.ColSpan = [ 1, 1 ];



dlgStruct = getBaseSchemaStruct( this, mainParamsPanel );


% Decoded using De-pcode utility v1.2 from file /tmp/tmpYpqZDO.p.
% Please follow local copyright laws when handling this file.

