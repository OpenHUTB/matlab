classdef ( Abstract )MatrixParameterWithImposedMetaField < lutdesigner.data.proxy.MatrixParameterProxyDecorator

properties ( SetAccess = immutable, GetAccess = private )
ImposedMetaFieldName
ImposedMetaFieldSource
end 

methods 
function this = MatrixParameterWithImposedMetaField( matrixParameterProxy, field, source )
R36
matrixParameterProxy
field( 1, : )char{ mustBeMember( field, { 'Min', 'Max', 'Unit', 'FieldName', 'Description' } ) }
source( 1, 1 )lutdesigner.data.source.DataSource
end 
this = this@lutdesigner.data.proxy.MatrixParameterProxyDecorator( matrixParameterProxy );
this.ImposedMetaFieldName = field;
this.ImposedMetaFieldSource = source;
end 
end 

methods ( Access = protected )
function dataUsage = listDataUsageImpl( this )
import lutdesigner.data.proxy.DataUsage

dataUsage = [ 
listDataUsageImpl@lutdesigner.data.proxy.MatrixParameterProxyDecorator( this );
DataUsage( this.ImposedMetaFieldSource, [ '/', this.ImposedMetaFieldName ] )
 ];
[ ~, idx ] = unique( { dataUsage.UsedAs }, 'last' );
dataUsage = dataUsage( idx );
end 
end 

methods ( Access = { ?lutdesigner.data.proxy.MatrixParameterProxyDecorator, ?matlab.unittest.TestCase } )
function restrictions = getImposedMetaFieldReadRestrictions( this )
restrictions = this.ImposedMetaFieldSource.getReadRestrictions(  );
end 

function restrictions = getImposedMetaFieldWriteRestrictions( this )
restrictions = this.ImposedMetaFieldSource.getWriteRestrictions(  );
end 

function val = getImposedMetaField( this )
val = this.ImposedMetaFieldSource.read(  );
end 

function setImposedMetaField( this, val )
this.ImposedMetaFieldSource.write( val );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpBMwDBJ.p.
% Please follow local copyright laws when handling this file.

