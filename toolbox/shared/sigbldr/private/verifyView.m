function UD = verifyView( UD )




if UD.current.isVerificationVisible

set( UD.toolbar.verifyView, 'state', 'off' );
set( UD.menus.figmenu.GroupMenuVerification, 'Checked', 'off' );

if ~isempty( UD.verify.hg.component )
UD.verify.hg.component.setVisible( 0 );
set( UD.verify.hg.componentContainer, 'Visible', 'off' )
set( UD.verify.hg.splitter, 'Visible', 'off' );
end 

UD.current.axesExtent = UD.current.axesExtent +  ...
[ 0, 0, 1, 0 ] * UD.current.verifyWidth;



for i = 1:UD.numAxes
pos = calc_new_axes_position( UD.current.axesExtent, UD.geomConst, UD.numAxes, i );
set( UD.axes( i ).handle, 'Position', pos );
end 

scrollPos = get( UD.tlegend.scrollbar, 'Position' );
scrollPos = scrollPos + [ 0, 0, 1, 0 ] * UD.current.verifyWidth;
set( UD.tlegend.scrollbar, 'Position', scrollPos );
UD.current.isVerificationVisible = 0;
UD = set_dirty_flag( UD, true );
UD.verify.jVerifyPanel.setVisible( false );
UD.verify.jVerifyPanel.verificationEnabled = false;
else 
if isempty( UD.verify.hg.component )
try 
UD.verify.jVerifyPanel = vnv_panel_mgr( 'sbCreatePanel',  ...
UD.simulink.subsysH );
if isempty( UD.verify.jVerifyPanel.figH )
UD.verify.jVerifyPanel.setFigureHandle( UD.dialog );
end 
UD.verify.jPanel = UD.verify.jVerifyPanel.getPane;
catch ex %#ok<NASGU,CTCH>
UD.verify.jPanel = [  ];
end 
end 

if ~isempty( UD.verify.jPanel )
set( UD.toolbar.verifyView, 'state', 'on' );
set( UD.menus.figmenu.GroupMenuVerification, 'Checked', 'on' );


UD.current.axesExtent = UD.current.axesExtent -  ...
[ 0, 0, 1, 0 ] * UD.current.verifyWidth;
UD.current.isVerificationVisible = 1;
UD = set_dirty_flag( UD, true );

if isempty( UD.verify.hg.component )
pos = find_verify_position( UD.dialog, UD.current.axesExtent, UD.geomConst.figBuffer, UD.current.verifyWidth, UD.current.isVerificationVisible );
splitterPos = calc_splitter_pos( UD.current.axesExtent, UD.geomConst.figBuffer );
UD.verify.hg.splitter = uicontrol( 'Parent', UD.dialog,  ...
'Units', 'Points',  ...
'Position', splitterPos,  ...
'Visible', 'off',  ...
'Style', 'Text',  ...
'BackgroundColor', 'Black',  ...
'ButtonDownFcn', 'sigbuilder(''ButtonDown'',gcbf);',  ...
'ForegroundColor', 'Black' );
UD.verify.jVerifyPanel.show(  );
UD.verify.hg.componentContainer = UD.verify.jVerifyPanel.container.handle;
UD.verify.hg.component = UD.verify.jVerifyPanel.topPanel;
UD.verify.jVerifyPanel.setPosition( pos );
else 
pos = find_verify_position( UD.dialog, UD.current.axesExtent, UD.geomConst.figBuffer, UD.current.verifyWidth, UD.current.isVerificationVisible );
set( UD.verify.hg.componentContainer, 'Position', pos );
set( UD.verify.hg.componentContainer, 'Visible', 'on' );
drawnow;
UD.verify.hg.component.setVisible( 1 );
end 
UD.verify.jVerifyPanel.verificationEnabled = true;
UD.verify.jVerifyPanel.tree.repaint(  );
vnv_panel_mgr( 'sbGroupChange', UD.simulink.subsysH, UD.verify.jVerifyPanel );



for i = 1:UD.numAxes
pos = calc_new_axes_position( UD.current.axesExtent, UD.geomConst, UD.numAxes, i );
set( UD.axes( i ).handle, 'Position', pos );
end 

scrollPos = get( UD.tlegend.scrollbar, 'Position' );
scrollPos = scrollPos - [ 0, 0, 1, 0 ] * UD.current.verifyWidth;
set( UD.tlegend.scrollbar, 'Position', scrollPos );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp2lCHbD.p.
% Please follow local copyright laws when handling this file.

