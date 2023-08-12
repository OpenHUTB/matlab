function varargout = extmodecallback( varargin )




action = lower( varargin{ 1 } );

switch ( action ), 

case 'extmode_checkbox_callback', 

DialogFig = varargin{ 2 };





obj0Tag = 'External mode_CheckboxTag';
obj0 = findobj( DialogFig, 'Tag', obj0Tag );
val0 = get( obj0, 'Value' );




obj1Tag = 'Transport_PopupFieldTag';
obj2Tag = 'Static memory allocation_CheckboxTag';
obj3Tag = 'Static memory buffer size_EditFieldTag';
obj1 = findobj( DialogFig, 'Tag', obj1Tag );
obj2 = findobj( DialogFig, 'Tag', obj2Tag );
obj3 = findobj( DialogFig, 'Tag', obj3Tag );





if val0 == 1;





set( obj1, 'Enable', sl( 'onoff', val0 ) );
set( obj2, 'Enable', sl( 'onoff', val0 ) );






val2 = get( obj2, 'Value' );
set( obj3, 'Enable', sl( 'onoff', val2 ) );
else ;





set( obj1, 'Enable', sl( 'onoff', val0 ) );
set( obj2, 'Enable', sl( 'onoff', val0 ) );
set( obj3, 'Enable', sl( 'onoff', val0 ) );
end ;


case 'staticmem_checkbox_opencallback', 

DialogFig = varargin{ 2 };





obj0Tag = 'External mode_CheckboxTag';
obj0 = findobj( DialogFig, 'Tag', obj0Tag );
val0 = get( obj0, 'Value' );





obj1Tag = 'Static memory allocation_CheckboxTag';
obj1 = findobj( DialogFig, 'Tag', obj1Tag );

set( obj1, 'Enable', sl( 'onoff', val0 ) );


case 'staticmem_checkbox_callback', 

DialogFig = varargin{ 2 };





obj0Tag = 'Static memory allocation_CheckboxTag';
obj0 = findobj( DialogFig, 'Tag', obj0Tag );
val0 = get( obj0, 'Value' );





obj1Tag = 'Static memory buffer size_EditFieldTag';
obj1 = findobj( DialogFig, 'Tag', obj1Tag );

set( obj1, 'Enable', sl( 'onoff', val0 ) );


case 'staticmemsize_edit_opencallback', 

DialogFig = varargin{ 2 };





obj0Tag = 'Static memory allocation_CheckboxTag';
obj0 = findobj( DialogFig, 'Tag', obj0Tag );
val0 = get( obj0, 'Value' );





obj1Tag = 'Static memory buffer size_EditFieldTag';
obj1 = findobj( DialogFig, 'Tag', obj1Tag );

set( obj1, 'Enable', sl( 'onoff', val0 ) );


case 'transport_popup_opencallback', 

model = varargin{ 2 };
DialogFig = varargin{ 3 };
ud = varargin{ 4 };
table = varargin{ 5 };





obj0Tag = 'External mode_CheckboxTag';
obj0 = findobj( DialogFig, 'Tag', obj0Tag );
val0 = get( obj0, 'Value' );





obj1Tag = 'Transport_PopupFieldTag';
obj1 = findobj( DialogFig, 'Tag', obj1Tag );
val1 = get( obj1, 'Value' );





set( obj1, 'Enable', sl( 'onoff', val0 ) );




[ rows, cols ] = size( table );
numTransports = rows;




mexfile = get_param( model, 'ExtModeMexFile' );




for extidx = 1:numTransports;
if val1 == extidx;





ud.ExtModeMex.transport = table{ extidx, 1 };








if ~strcmp( mexfile, table{ extidx, 2 } );
set_param( model, 'ExtModeMexFile', table{ extidx, 2 } );
set_param( model, 'ExtModeMexArgs', '' );
end ;
end ;
end ;

varargout{ 1 } = ud;


case 'transport_popup_closecallback', 

model = varargin{ 2 };
DialogFig = varargin{ 3 };
ud = varargin{ 4 };
table = varargin{ 5 };





obj0Tag = 'External mode_CheckboxTag';
obj0 = findobj( DialogFig, 'Tag', obj0Tag );
val0 = get( obj0, 'Value' );





obj1Tag = 'Transport_PopupFieldTag';
obj1 = findobj( DialogFig, 'Tag', obj1Tag );
val1 = get( obj1, 'Value' );





set( obj1, 'Enable', sl( 'onoff', val0 ) );




[ rows, cols ] = size( table );
numTransports = rows;




mexargs = get_param( model, 'ExtModeMexArgs' );





for extidx = 1:numTransports;
if strcmp( ud.ExtModeMex.transport, table{ extidx, 1 } );





eval( [ 'ud.ExtModeMex.', table{ extidx, 1 }, ' = mexargs;' ] );
end ;
end ;

mexargs = '';





for extidx = 1:numTransports;
if val1 == extidx;



mexfile = table{ extidx, 2 };






ud.ExtModeMex.transport = table{ extidx, 1 };






if isfield( ud.ExtModeMex, table{ extidx, 1 } );
mexargs = eval( [ 'ud.ExtModeMex.', table{ extidx, 1 }, ';' ] );
end ;
end ;
end ;





set_param( model, 'ExtModeMexFile', mexfile );
set_param( model, 'ExtModeMexArgs', mexargs );





Simulink.ExtMode.CtrlPanel.refreshExtModeCtrlPanelForModel( model );

varargout{ 1 } = ud;


case 'noextcomm', 

model = varargin{ 2 };

set_param( model, 'ExtModeMexFile', 'no_ext_comm' );
set_param( model, 'ExtModeMexArgs', '' );





Simulink.ExtMode.CtrlPanel.refreshExtModeCtrlPanelForModel( model );

varargout{ 1 } =  - 1;


otherwise , 
DAStudio.error( 'Simulink:tools:assertExtModeCallback' );

end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmp6AdB4y.p.
% Please follow local copyright laws when handling this file.

