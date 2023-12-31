function simRFV2TestbenchCallbackFcn( block, action )


top_sys = bdroot( block );
if strcmpi( get_param( top_sys, 'BlockDiagramType' ), 'library' )
return ;
end 


idxMaskNames = simrfV2getblockmaskparamsindex( block );
MaskVisibilities = get_param( block, 'MaskVisibilities' );
MaskEnables = get_param( block, 'MaskEnables' );

ModeStrLong = get_param( block, 'ModeStrLong' );
ModeStrShort = get_param( block, 'ModeStrShort' );
uncheckedNoise = ~strcmp( get_param( block, 'SimNoise' ), 'on' );
isVisLong = strcmp( MaskVisibilities{ idxMaskNames.ModeStrLong }, 'on' );
if ( isVisLong )
CurrentModeStr = ModeStrLong;
else 
CurrentModeStr = ModeStrShort;
end 



if ( ~any( strcmpi( get_param( top_sys, 'SimulationStatus' ),  ...
{ 'running', 'paused' } ) ) )
switch action
case 'NoiseboxCallback'
if ( ( uncheckedNoise ) && ( isVisLong ) )


set_param( [ block, '/Configuration' ], 'AddNoise', 'off' )
set_param( block, 'ModeStrShort', ModeStrLong )

MaskVisibilities{ idxMaskNames.ModeStrLong } = 'off';
MaskVisibilities{ idxMaskNames.ModeStrShort } = 'on';
set_param( block, 'MaskVisibilities', MaskVisibilities )
set_param( block, 'ModeStrShort', ModeStrLong )
set_param( block, 'ModeStrLong', ModeStrLong )
elseif ( ( ~uncheckedNoise ) && ( ~isVisLong ) )



set_param( [ block, '/Configuration' ], 'AddNoise', 'on' )
set_param( block, 'ModeStrLong', ModeStrShort )

MaskVisibilities{ idxMaskNames.ModeStrLong } = 'on';
MaskVisibilities{ idxMaskNames.ModeStrShort } = 'off';
set_param( block, 'MaskVisibilities', MaskVisibilities )
set_param( block, 'ModeStrLong', ModeStrShort )
set_param( block, 'ModeStrShort', ModeStrShort )
end 
case 'LongPulldownModeCallback'
if strcmp( get_param( block, 'ModeStrLong' ), 'NF' )
MaskEnables{ idxMaskNames.SimNoise } = 'off';
else 
MaskEnables{ idxMaskNames.SimNoise } = 'on';
end 
set_param( block, 'MaskEnables', MaskEnables )
end 
end 


fullTypeOpts = { 'Gain', 'NF', 'OIP3', 'IIP3' };
ModeNum = strcmp( fullTypeOpts, CurrentModeStr ) * [ 1, 2, 3, 4 ]';
set_param( block, 'Mode', num2str( ModeNum ) )


maskObj = get_param( block, 'MaskObject' );
EmptyText6 = maskObj.getDialogControl( 'EmptyText6' );
EmptyText7 = maskObj.getDialogControl( 'EmptyText7' );
ResetContainer = maskObj.getDialogControl( 'ResetContainer' );
MaskVisibilities = get_param( block, 'MaskVisibilities' );
InstText = maskObj.getDialogControl( 'InstText' );


if any( strcmpi( get_param( bdroot( block ), 'SimulationStatus' ),  ...
{ 'running', 'paused' } ) )
suggestionStr1 = 'stop the simulation, ';
suggestionStr1IP3 = 'stop the simulation, and ';
suggestionStr2 = ', and run the simulation again';
suggestionStr2IP3 = '. Then run the simulation again';
else 
suggestionStr1 = '';
suggestionStr1IP3 = '';
suggestionStr2 = '';
suggestionStr2IP3 = '';
end 


switch ModeNum
case 1
EmptyText6.Visible = 'off';
MaskVisibilities{ idxMaskNames.F_tone_over_Base_bw } = 'off';
EmptyText7.Visible = 'off';
if ( strcmp( get_param( block, 'SimNoise' ), 'on' ) )
string_out{ 1 } = [ '1. For accurate gain measurement, please ' ...
, suggestionStr1, 'uncheck the ''Simulate noise'' checkbox' ...
, suggestionStr2, '.\n\n' ];
else 
string_out{ 1 } = [ '1. To account for noise in the gain ' ...
, 'measurement, please ', suggestionStr1, 'check the ' ...
, '''Simulate noise'' checkbox', suggestionStr2, '.\n\n' ];
end 
string_out{ 2 } = [ '2. For high input power, the measured gain ' ...
, 'may be affected by nonlinearities of the Device Under ' ...
, 'Test (DUT) and differ from the gain calculated in the RF ' ...
, 'budget app. In this case, use the knob to reduce the ' ...
, 'input power amplitude value until the resulting gain ' ...
, 'value settles down.\n\n' ];
string_out{ 3 } = [ '3. Other discrepancies between the measured ' ...
, 'gain and that calculated in the RF budget app may ' ...
, 'originate from the more realistic account of the DUT ' ...
, 'performance obtained using the SimRF simulation. In this ' ...
, 'case, verify that the DUT performance is evaluated ' ...
, 'correctly using RF budget calculations. For more ' ...
, 'details, see the RF budget app documentation.' ];
string_out{ 4 } = '';
case 2
ResetContainer.Visible = 'on';
EmptyText6.Visible = 'off';
MaskVisibilities{ idxMaskNames.F_tone_over_Base_bw } = 'off';
EmptyText7.Visible = 'off';
string_out{ 1 } = [ '1. Correct calculation of the spot noise ' ...
, 'figure (NF) assumes a frequency-independent system ' ...
, 'within the given bandwidth. Please ', suggestionStr1 ...
, 'reduce the Baseband bandwidth until this condition is ' ...
, 'fulfilled', suggestionStr2, '. In common RF systems, the ' ...
, 'bandwidth should be reduced below 1 KHz for NF testing.\n\n' ];
string_out{ 2 } = [ '2. For high input power, the measured NF ' ...
, 'may be affected by nonlinearities of the Device Under ' ...
, 'Test (DUT) and differ from the NF calculated in the RF ' ...
, 'budget app. In this case, use the knob to reduce the ' ...
, 'input power amplitude value until the resulting NF value ' ...
, 'settles down. Bear in mind that for a too low input ' ...
, 'signal power, the measured NF may become inaccurate or ' ...
, 'fail to converge since the signal is close or below the ' ...
, 'noise floor of the system. \n\n' ];
string_out{ 3 } = [ '3. Other discrepancies between the ' ...
, 'measured NF and that calculated in the RF budget app may ' ...
, 'originate from the more realistic account of the DUT ' ...
, 'performance obtained using the SimRF simulation. In this ' ...
, 'case, verify that the DUT performance is evaluated ' ...
, 'correctly using RF budget calculations. For more ' ...
, 'details, see the RF budget app documentation.' ];
string_out{ 4 } = '';
case 3
ResetContainer.Visible = 'off';
EmptyText6.Visible = 'on';
MaskVisibilities{ idxMaskNames.F_tone_over_Base_bw } = 'on';
EmptyText7.Visible = 'on';
if ( strcmp( get_param( block, 'SimNoise' ), 'on' ) )
string_out{ 1 } = [ '1. For accurate OIP3 measurement, please ' ...
, suggestionStr1, 'uncheck the ''Simulate noise'' checkbox' ...
, suggestionStr2, '.\n\n' ];
else 
string_out{ 1 } = [ '1. To account for noise in the OIP3 ' ...
, 'measurement, please ', suggestionStr1, 'check the ' ...
, '''Simulate noise'' checkbox', suggestionStr2, '.\n\n' ];
end 
string_out{ 2 } = [ '2. Correct calculation of the OIP3 assumes ' ...
, 'a frequency-independent system in the frequencies ' ...
, 'surrounding the test tones. Please ', suggestionStr1IP3 ...
, 'either reduce the frequency separation between the test ' ...
, 'tones (by reducing the ''Ratio of test tone frequency to ' ...
, 'baseband bandwidth''), or reduce the Baseband ' ...
, 'bandwidth itself until this condition is fulfilled' ...
, suggestionStr2IP3, '. In common RF systems, the bandwidth ' ...
, 'should be reduced below 1 KHz for OIP3 testing.\n\n' ];
string_out{ 3 } = [ '3. For high input power, the measured OIP3 ' ...
, 'may be affected by high-order nonlinearities of the ' ...
, 'Device Under Test (DUT) and differ from the OIP3 ' ...
, 'calculated in the RF budget app. In this case, use the ' ...
, 'knob to reduce the input power amplitude value until the ' ...
, 'resulting OIP3 value settles down.\n\n' ];
string_out{ 4 } = [ '4. Other discrepancies between the ' ...
, 'measured OIP3 and that calculated in the RF budget app ' ...
, 'may originate from the more realistic account of the DUT ' ...
, 'performance obtained using the SimRF simulation. In this ' ...
, 'case, verify that the DUT performance is evaluated ' ...
, 'correctly using RF budget calculations. For more ' ...
, 'details, see the RF budget app documentation.' ];
case 4
ResetContainer.Visible = 'off';
EmptyText6.Visible = 'on';
MaskVisibilities{ idxMaskNames.F_tone_over_Base_bw } = 'on';
EmptyText7.Visible = 'on';
if ( strcmp( get_param( block, 'SimNoise' ), 'on' ) )
string_out{ 1 } = [ '1. For accurate IIP3 measurement, please ' ...
, suggestionStr1, 'uncheck the ''Simulate noise'' checkbox' ...
, suggestionStr2, '.\n\n' ];
else 
string_out{ 1 } = [ '1. To account for noise in the IIP3 ' ...
, 'measurement, please ', suggestionStr1, 'check the ' ...
, '''Simulate noise'' checkbox', suggestionStr2, '.\n\n' ];
end 
string_out{ 2 } = [ '2. Correct calculation of the IIP3 assumes ' ...
, 'a frequency-independent system in the frequencies ' ...
, 'surrounding the test tones. Please ', suggestionStr1IP3 ...
, 'either reduce the frequency separation between the test ' ...
, 'tones (by reducing the ''Ratio of test tone frequency to ' ...
, 'baseband bandwidth''), or reduce the Baseband ' ...
, 'bandwidth itself until this condition is fulfilled' ...
, suggestionStr2IP3, '. In common RF systems, the bandwidth ' ...
, 'should be reduced below 1 KHz for IIP3 testing.\n\n' ];
string_out{ 3 } = [ '3. For high input power, the measured IIP3 ' ...
, 'may be affected by high-order nonlinearities of the ' ...
, 'Device Under Test (DUT) and differ from the IIP3 ' ...
, 'inferred from the calculations in RF budget app. In this ' ...
, 'case, use the knob to reduce the input power amplitude ' ...
, 'value until the resulting IIP3 value settles down.\n\n' ];
string_out{ 4 } = [ '4. Other discrepancies between the ' ...
, 'measured IIP3 and that inferred from the calculations ' ...
, 'in the RF budget app may originate from the more ' ...
, 'realistic account of the DUT performance obtained using ' ...
, 'the SimRF simulation. In this case, verify that the DUT ' ...
, 'performance is evaluated correctly using RF budget ' ...
, 'calculations. For more details, see the RF budget app ' ...
, 'documentation.' ];
end 


InstText.Prompt = sprintf( cell2mat( string_out ) );
set_param( block, 'MaskVisibilities', MaskVisibilities )
% Decoded using De-pcode utility v1.2 from file /tmp/tmpubdfF0.p.
% Please follow local copyright laws when handling this file.

