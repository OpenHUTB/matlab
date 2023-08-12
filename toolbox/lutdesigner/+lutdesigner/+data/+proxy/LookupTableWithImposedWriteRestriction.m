classdef LookupTableWithImposedWriteRestriction < lutdesigner.data.proxy.LookupTableProxyDecorator

properties ( SetAccess = immutable, GetAccess = private )
ImposedWriteRestriction
end 

methods 
function this = LookupTableWithImposedWriteRestriction( lookupTableProxy, writeRestriction )
R36
lookupTableProxy
writeRestriction( 1, 1 )lutdesigner.data.restriction.WriteRestriction
end 
this = this@lutdesigner.data.proxy.LookupTableProxyDecorator( lookupTableProxy );
this.ImposedWriteRestriction = writeRestriction;
end 
end 

methods ( Access = protected )
function restrictions = getNumDimsWriteRestrictionsImpl( this )
restrictions = [ 
getNumDimsWriteRestrictionsImpl@lutdesigner.data.proxy.LookupTableProxyDecorator( this );
this.ImposedWriteRestriction
 ];
end 

function axisProxy = getAxisProxyImpl( this, dimensionIndex )
import lutdesigner.data.proxy.MatrixParameterWithImposedWriteRestriction

axisProxy = MatrixParameterWithImposedWriteRestriction(  ...
getAxisProxyImpl@lutdesigner.data.proxy.LookupTableProxyDecorator( this, dimensionIndex ),  ...
this.ImposedWriteRestriction );
end 

function tableProxy = getTableProxyImpl( this )
import lutdesigner.data.proxy.MatrixParameterWithImposedWriteRestriction

tableProxy = MatrixParameterWithImposedWriteRestriction(  ...
getTableProxyImpl@lutdesigner.data.proxy.LookupTableProxyDecorator( this ),  ...
this.ImposedWriteRestriction );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpPRFCZa.p.
% Please follow local copyright laws when handling this file.

