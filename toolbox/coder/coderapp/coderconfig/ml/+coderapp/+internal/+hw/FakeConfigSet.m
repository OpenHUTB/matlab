classdef ( Hidden, Sealed )FakeConfigSet < handle



properties ( SetAccess = private, SetObservable )
Data( 1, 1 )struct
ModifiedStorageKeys cell = {  }
end 

properties ( SetAccess = ?coderapp.internal.hw.HardwareDialogHelper )
Record( 1, 1 )logical = false
end 

methods 
function this = FakeConfigSet( hardware, data )
R36
hardware = [  ]
data struct = struct.empty
end 

if isempty( data )
data = struct(  );
end 
data.UseCoderTarget = true;
if ~isempty( hardware )
if isa( hardware, 'coder.Hardware' )
hardware = hardware.Name;
end 
data.TargetHardware = hardware;
else 
data.TargetHardware = '';
end 
this.Data = data;
end 

function this = getComponent( this, compName )
R36
this
compName{ mustBeMember( compName, 'Coder Target' ) }%#ok<INUSA>
end 
end 

function this = getConfigSet( this )
end 

function this = getActiveConfigSet( this )
end 

function value = get_param( this, key )
switch key
case 'CoderTargetData'
value = coderapp.internal.hw.FakeStruct( this, this.Data );
case 'HardwareBoard'
value = this.Data.TargetHardware;
otherwise 
value = [  ];
end 
end 

function set_param( this, key, data )
R36
this
key{ mustBeMember( key, { 'CoderTargetData' } ) }%#ok<INUSA>
data( 1, 1 ){ mustBeA( data, [ "struct", "coderapp.internal.hw.FakeStruct" ] ) }
end 
if isa( data, 'coderapp.internal.hw.FakeStruct' )
data = data.Data_;
end 
this.Data = data;
end 

function valid = isValidParam( ~, key )
valid = strcmp( key, 'CoderTargetData' );
end 
end 

methods ( Access = ?coderapp.internal.hw.FakeStruct )
function onStorageModified( this, storage )
if this.Record && ~isempty( setdiff( storage, this.ModifiedStorageKeys ) )
this.ModifiedStorageKeys = unique( [ this.ModifiedStorageKeys, storage ] );
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpSREghE.p.
% Please follow local copyright laws when handling this file.

