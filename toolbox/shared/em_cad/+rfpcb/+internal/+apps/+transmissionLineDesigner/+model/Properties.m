classdef Properties < rfpcb.internal.apps.transmissionLineDesigner.model.Analysis





properties ( Constant = true, Hidden )



PropertyExceptions = struct(  ...
'Name',  ...
struct( 'AddNewControl',  ...
struct( 'Label', 'Catalog',  ...
'Graphics',  ...
{ { @uidropdown, 'popupmenu' } },  ...
'Callback', '@(src, evt) obj.chooseCatalogCallback(src, evt)' ),  ...
'Tooltip', '',  ...
'Graphics', { { @uieditfield, 'edit' } } ),  ...
'DoNotExport', { { 'Catalog', 'Element' } },  ...
'Catalog',  ...
struct( 'Graphics',  ...
{ { @uidropdown, 'popupmenu' } },  ...
'Callback', '@(src, evt) obj.chooseCatalogCallback(src, evt)' ) );
end 

properties ( Dependent )
MainObject
end 

methods 
function obj = Properties( TransmissionLine, Logger )


R36
TransmissionLine{ mustBeA( TransmissionLine, [ "rfpcb.TxLine", "double" ] ) } = microstripLine;
Logger( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Logger = rfpcb.internal.apps.transmissionLineDesigner.model.Logger;
end 
obj@rfpcb.internal.apps.transmissionLineDesigner.model.Analysis( Logger );
obj.TransmissionLine = TransmissionLine;

log( obj.Logger, '% Properties model object created.' )
end 



function rtn = get.MainObject( obj )
rtn = obj.TransmissionLine;
end 

function rtn = getPropertyTable( obj, InputObject )








R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Properties{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.model.Properties;
InputObject = obj.TransmissionLine;
end 
propertyTable = rfpcb.internal.apps.getPropertyTable( InputObject );


storeIdx = [  ];
newRowCell = {  };
for i = 1:length( propertyTable( :, 1 ) )
if any( strcmpi( fieldnames( obj.PropertyExceptions ), propertyTable{ i, 1 } ) )
exceptionInfo = obj.PropertyExceptions.( propertyTable{ i, 1 } );
if any( strcmpi( fieldnames( exceptionInfo ), 'AddNewControl' ) )

newRow = { exceptionInfo.AddNewControl.Label, '',  ...
propertyTable{ i, 3 }, propertyTable{ i, 4 },  ...
propertyTable{ i, 5 }, propertyTable{ i, 6 } };
newRow = [ newRow, exceptionInfo.AddNewControl.Graphics ];
newRowCell = [ newRowCell;newRow ];
storeIdx = [ storeIdx, i ];

propertyTable( i, end  - 1:end  ) = exceptionInfo.Graphics;
else 
if isprop( obj.Model, 'IsConformalArray' )
if ~isConformalArray( obj )

propertyTable( i, end  - 1:end  ) = exceptionInfo.Graphics;
else 
if ~strcmpi( propertyTable{ i, 1 }, 'Element' )
propertyTable( i, end  - 1:end  ) = exceptionInfo.Graphics;
end 
end 
else 
propertyTable( i, end  - 1:end  ) = exceptionInfo.Graphics;
end 
end 
end 
end 
if ~isempty( storeIdx )
if isscalar( storeIdx )
propertyTable = insertRow( obj, newRow, storeIdx, propertyTable );
else 
for m = 2:numel( storeIdx )
storeIdx( m ) = storeIdx( m ) + numel( storeIdx( 1:m - 1 ) );
end 
for m = 1:numel( storeIdx )
propertyTable = insertRow( obj, newRowCell( m, : ), storeIdx( m ), propertyTable );
end 
end 
end 
rtn = propertyTable;
end 



function update( obj )


R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Results{ mustBeNonempty }
end 


log( obj.Logger, '% Properties updated.' )
end 



function propertyTable = insertRow( ~, row, idx, propertyTable )
propertyTable = [ propertyTable( 1:idx - 1, : );row;propertyTable( idx:end , : ) ];
end 

function rtn = rearrange( ~, inputCell )
order = { '',  ...
'Exciter',  ...
'Exciter.Exciter',  ...
'Element',  ...
'Element.Exciter',  ...
'Element.Exciter.Exciter',  ...
'Element.Substrate' };
newCell = {  };
for o = 1:numel( order )
categoryBlock = inputCell( strcmp( inputCell( :, 5 ), order{ o } ), : );
if ~isempty( categoryBlock )
newCell = [ newCell;categoryBlock ];%#ok<AGROW>
end 
end 
rtn = newCell;
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpBtg6qW.p.
% Please follow local copyright laws when handling this file.

