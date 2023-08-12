function updateIndustryStandardParams( this, modelName )






origPackSuffix = this.getParameter( 'package_suffix' );
starcPackValue = '_pac';
if ~strcmpi( starcPackValue, origPackSuffix )
this.setParameter( 'package_suffix', starcPackValue );
msg = message( 'hdlcommon:IndustryStandard:packagePostfix', starcPackValue, origPackSuffix );
hdlcodingstd.Report.add( modelName,  ...
struct( 'path', '', 'type', '', 'message', msg.getString,  ...
'level', 'Message', 'MessageID', 'STARCDominantModeWarning', 'RuleID', '1.1.4.1' ) );
end 




origResetName = this.getParameter( 'resetname' );

lowerResetName = lower( origResetName );
if strcmpi( hdlget_param( this.ModelName, 'ResetAssertedLevel' ), 'Active-low' )


rstList = { 'rstx', 'resetx', 'rst_x', 'reset_x', 'reset_n', 'RST_N' };
allowedStr1 = sprintf( '%s%s%s %s %s%s%s', '''', 'rst_x', '''', 'or', '''', 'reset_x', '''' );
allowedStr2 = sprintf( '%s%s%s %s %s%s%s', '''', 'rstx', '''', 'or', '''', 'resetx', '''' );
allowedStr3 = sprintf( '%s%s%s %s %s%s%s', '''', 'reset_n', '''', 'or', '''', 'RST_N', '''' );
allowedResetStr = sprintf( '%s %s %s %s %s', allowedStr1, 'or', allowedStr2, 'or', allowedStr3 );
else 

rstList = { 'rst', 'reset' };
allowedStr1 = sprintf( '%s%s%s %s %s%s%s', '''', 'rst', '''', 'or', '''', 'reset', '''' );
allowedResetStr = sprintf( '%s', allowedStr1 );
end 

if ~matches( lowerResetName, rstList )

msg = message( 'hdlcommon:IndustryStandard:clkOrEnableOrResetName',  ...
'reset', allowedResetStr );
hdlcodingstd.Report.add( modelName,  ...
struct( 'path', '', 'type', '', 'message', msg.getString,  ...
'level', 'Message', 'MessageID', 'STARCDominantModeWarning', 'RuleID', '1.1.5.2' ) );
end 



origClockName = this.getParameter( 'clockname' );

lowerClockName = lower( origClockName );

if strcmpi( hdlget_param( this.ModelName, 'clockedge' ), 'Falling' )
clkList = { 'clk_x', 'ck_x' };
allowedClkStr = sprintf( '%s%s%s %s %s%s%s', '''', string( clkList( 1 ) ), '''', 'or', '''', string( clkList( 2 ) ), '''' );
else 
clkList = { 'clk', 'ck' };
allowedClkStr = sprintf( '%s%s%s %s %s%s%s', '''', string( clkList( 1 ) ), '''', 'or', '''', string( clkList( 2 ) ), '''' );
end 
if ~matches( lowerClockName, clkList )



msg = message( 'hdlcommon:IndustryStandard:clkOrEnableOrResetName',  ...
'clock', allowedClkStr );
hdlcodingstd.Report.add( modelName,  ...
struct( 'path', '', 'type', '', 'message', msg.getString,  ...
'level', 'Message', 'MessageID', 'STARCDominantModeWarning', 'RuleID', '1.1.5.2a' ) );
end 



origClockEnName = this.getParameter( 'clockenablename' );

lowerClockEnName = lower( origClockEnName );

if ~contains( lowerClockEnName, 'en' )
msg = message( 'hdlcommon:IndustryStandard:clkOrEnableOrResetName',  ...
'clock enable', 'en' );
hdlcodingstd.Report.add( modelName,  ...
struct( 'path', '', 'type', '', 'message', msg.getString,  ...
'level', 'Message', 'MessageID', 'STARCDominantModeWarning', 'RuleID', '1.1.5.2' ) );
end 

cso = this.getParameter( 'HDLCodingStandardCustomizations' );
m_clockEnableCheck = cso.MinimizeClockEnableCheck.enable;
if m_clockEnableCheck
if ~this.getParameter( 'MinimizeClockEnables' )
msg = message( 'hdlcommon:IndustryStandard:MinimizeClockEnablesOff' );
hdlcodingstd.Report.add( modelName,  ...
struct( 'path', '', 'type', '', 'message', msg.getString,  ...
'level', 'Message', 'MessageID', 'STARCDominantModeWarning', 'RuleID', '2.3.3.4' ) );
this.setParameter( 'MinimizeClockEnables', true );
end 
end 

m_removeResetsCheck = cso.RemoveResetCheck.enable;
if m_removeResetsCheck
if ~this.getParameter( 'minimizeglobalresets' )
msg = message( 'hdlcommon:IndustryStandard:MinimizeGlobalResetsOff' );
hdlcodingstd.Report.add( modelName,  ...
struct( 'path', '', 'type', '', 'message', msg.getString,  ...
'level', 'Message', 'MessageID', 'STARCDominantModeWarning', 'RuleID', '2.3.3.5' ) );
this.setParameter( 'minimizeglobalresets', true );
end 
end 

m_asyncResetsCheck = cso.AsynchronousResetCheck.enable;
if m_asyncResetsCheck
if this.getParameter( 'async_reset' )
msg = message( 'hdlcommon:IndustryStandard:AsyncResetOn' );
hdlcodingstd.Report.add( modelName,  ...
struct( 'path', '', 'type', '', 'message', msg.getString,  ...
'level', 'Message', 'MessageID', 'STARCDominantModeWarning', 'RuleID', '2.3.3.6' ) );

end 
end 

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpAlAddM.p.
% Please follow local copyright laws when handling this file.

