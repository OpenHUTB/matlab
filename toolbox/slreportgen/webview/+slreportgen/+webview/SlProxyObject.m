classdef ( Hidden )SlProxyObject < handle





































properties ( Dependent, SetAccess = private )

Handle


Id
end 

properties ( SetAccess = private )

SID = '';


ClassName = ''


SuperClassNames = {  }
end 

properties ( Constant, Access = private )
SLROOT = slroot(  )
end 

properties ( Access = private )

RawHandle = [  ]



IsStateflow = false


SlLineID



ConfigSysFullName
end 

methods 
function this = SlProxyObject( obj )
R36
obj = [  ];
end 

try 
if ~isempty( obj )
objH = slreportgen.utils.getSlSfHandle( obj );
if this.SLROOT.isValidSlObject( objH )
objH = get_param( objH, 'Object' );
this.resolveSimulink( objH );
elseif isa( objH, 'Simulink.Object' )



this.resolveSimulink( objH );
elseif isa( objH, 'Stateflow.Object' )
this.resolveStateflow( objH );
end 
end 
catch ME
try 
resolveLineID( this, obj );
catch 
rethrow( ME );
end 
end 
end 

function id = get.Id( this )

id = this.getId(  );
end 

function out = get.Handle( this )

out = this.getHandle(  );
end 

function name = getName( this )





objH = getHandle( this );
try 
name = get( objH, 'Name' );
catch 
name = '';
end 
name = regexprep( name, '\s', ' ' );
end 

function displayLabel = getDisplayLabel( this )





obj = this.getHandle(  );
displayLabel = regexprep( obj.getDisplayLabel(  ), '\s', ' ' );
end 

function id = getId( this )






if ~isempty( this.SID )
id = this.SID;
elseif ~isempty( this.SlLineID )
id = this.SlLineID;
else 
id = '';
end 
end 

function out = getHandle( this )





if ishandle( this.RawHandle )
out = this.RawHandle;
elseif isempty( this.RawHandle )
out = [  ];
else 

if isempty( this.SID )
this.resolveLineID( this.SlLineID );
else 
try 
slsfH = slreportgen.utils.getSlSfHandle( this.SID );
catch ME
if ~isempty( this.ConfigSysFullName )

slsfH = slreportgen.utils.getSlSfHandle( this.ConfigSysFullName );
this.SID = Simulink.ID.getSID( slsfH );
else 
rethrow( ME );
end 
end 
if this.SLROOT.isValidSlObject( slsfH )
if this.IsStateflow



chartId = sf( 'Private', 'block2chart', slsfH );
objH = this.SLROOT.idToHandle( chartId );
else 
objH = get_param( slsfH, 'Object' );
end 
this.RawHandle = objH;
end 
this.RawHandle = objH;
end 
out = this.RawHandle;
end 
end 

function tf = isValid( this )




tf = ~isempty( ( this.getHandle(  ) ) );
end 

function tf = eq( this, other )
tf = ( this.getHandle(  ) == other.getHandle(  ) );

if isempty( tf )
tf = false;
end 
end 

function tf = ne( this, other )
tf = ( this.getHandle(  ) ~= other.getHandle(  ) );

if isempty( tf )
tf = true;
end 
end 
end 

methods ( Access = private )
function resolveLineID( this, lineID )

hashIdx = strfind( lineID, '#' );
srcBlockSID = lineID( 1:hashIdx - 1 );


portURL = lineID( hashIdx + 1:end  );
colonIdx = strfind( portURL, ':' );
portNum = str2double( portURL( colonIdx + 1:end  ) );


srcBlockName = get_param( srcBlockSID, 'Name' );
srcPort = sprintf( '%s:%d', srcBlockName, portNum );


parentBlock = get_param( srcBlockSID, 'Parent' );
parentObj = get_param( parentBlock, 'Object' );
lineObjH = parentObj.find(  ...
'-depth', 1,  ...
'-isa', 'Simulink.Line',  ...
'SourcePort', srcPort );

this.RawHandle = lineObjH;
this.SID = '';
this.ConfigSysFullName = '';
this.SuperClassNames = { 'Simulink.Object' };
this.ClassName = 'Simulink.Line';
this.IsStateflow = false;
end 

function resolveSimulink( this, objH )
objFullName = '';
sid = '';
if isa( objH, 'Simulink.Block' )
sid = Simulink.ID.getSID( objH );
if isa( objH, 'Simulink.SubSystem' )
objFullName = getfullname( objH.Handle );
if ( strcmp( objH.Mask, 'on' ) && ~isempty( objH.MaskType ) )

superClassNames = {  ...
'Simulink.SubSystem',  ...
'Simulink.Block',  ...
'Simulink.Object' };
className = strtrim( objH.MaskType );
else 

superClassNames = { 'Simulink.Block', 'Simulink.Object' };
className = class( objH );
end 
else 
superClassNames = { 'Simulink.Block', 'Simulink.Object' };
className = class( objH );
end 
else 
if ~ishandle( objH.Handle )







this.SlLineID = createSlLineID( objH );
else 
sid = Simulink.ID.getSID( objH );
end 

superClassNames = { 'Simulink.Object' };
className = class( objH );
end 

this.RawHandle = objH;
this.ConfigSysFullName = objFullName;
this.SID = sid;
this.SuperClassNames = superClassNames;
this.ClassName = className;
this.IsStateflow = false;
end 

function resolveStateflow( this, objH )
this.RawHandle = objH;
this.SID = Simulink.ID.getSID( objH );
this.ConfigSysFullName = '';
this.SuperClassNames = { 'Stateflow.Object' };
this.ClassName = class( objH );
this.IsStateflow = true;
end 
end 
end 

function lineID = createSlLineID( lineobj )
portObj = lineobj.getSourcePort(  );
if ~isempty( portObj )
switch portObj.PortType
case 'outport'
portType = 'out';
case 'inport'
portType = 'in';
case 'state'
portType = 'state';
otherwise 
portType = 'error';
end 

parent = get_param( portObj.Handle, 'Parent' );
parentSID = Simulink.ID.getSID( parent );
portURL = Simulink.URL.PortURL( parentSID,  ...
portType,  ...
portObj.PortNumber );
lineID = char( portURL );
else 
lineID = '';
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmphEZ9Wq.p.
% Please follow local copyright laws when handling this file.

