classdef MatrixParameterWithImposedWriteRestriction < lutdesigner.data.proxy.MatrixParameterProxyDecorator

properties ( SetAccess = immutable, GetAccess = private )
ImposedWriteRestriction
end 

methods 
function this = MatrixParameterWithImposedWriteRestriction( matrixParameterProxy, writeRestriction )
R36
matrixParameterProxy
writeRestriction( 1, 1 )lutdesigner.data.restriction.WriteRestriction
end 
this = this@lutdesigner.data.proxy.MatrixParameterProxyDecorator( matrixParameterProxy );
this.ImposedWriteRestriction = writeRestriction;
end 
end 

methods ( Access = protected )
function restrictions = getValueWriteRestrictionsImpl( this )
restrictions = [ 
getValueWriteRestrictionsImpl@lutdesigner.data.proxy.MatrixParameterProxyDecorator( this );
this.ImposedWriteRestriction
 ];
end 

function restrictions = getMinWriteRestrictionsImpl( this )
restrictions = [ 
getMinWriteRestrictionsImpl@lutdesigner.data.proxy.MatrixParameterProxyDecorator( this );
this.ImposedWriteRestriction
 ];
end 

function restrictions = getMaxWriteRestrictionsImpl( this )
restrictions = [ 
getMaxWriteRestrictionsImpl@lutdesigner.data.proxy.MatrixParameterProxyDecorator( this );
this.ImposedWriteRestriction
 ];
end 

function restrictions = getUnitWriteRestrictionsImpl( this )
restrictions = [ 
getUnitWriteRestrictionsImpl@lutdesigner.data.proxy.MatrixParameterProxyDecorator( this );
this.ImposedWriteRestriction
 ];
end 

function restrictions = getFieldNameWriteRestrictionsImpl( this )
restrictions = [ 
getFieldNameWriteRestrictionsImpl@lutdesigner.data.proxy.MatrixParameterProxyDecorator( this );
this.ImposedWriteRestriction
 ];
end 

function restrictions = getDescriptionWriteRestrictionsImpl( this )
restrictions = [ 
getDescriptionWriteRestrictionsImpl@lutdesigner.data.proxy.MatrixParameterProxyDecorator( this );
this.ImposedWriteRestriction
 ];
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpESUbIE.p.
% Please follow local copyright laws when handling this file.

