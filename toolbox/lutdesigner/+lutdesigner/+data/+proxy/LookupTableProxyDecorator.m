classdef ( Abstract )LookupTableProxyDecorator < lutdesigner.data.proxy.LookupTableProxy

properties ( SetAccess = immutable, GetAccess = private )
LookupTableProxy
end 

methods 
function this = LookupTableProxyDecorator( lookupTableProxy )
R36
lookupTableProxy( 1, 1 )lutdesigner.data.proxy.LookupTableProxy
end 
this.LookupTableProxy = lookupTableProxy;
end 
end 

methods ( Access = protected )
function dataUsage = listDataUsageImpl( this )
dataUsage = this.LookupTableProxy.listDataUsageImpl(  );
end 

function restrictions = getNumDimsReadRestrictionsImpl( this )
restrictions = this.LookupTableProxy.getNumDimsReadRestrictionsImpl(  );
end 

function restrictions = getNumDimsWriteRestrictionsImpl( this )
restrictions = this.LookupTableProxy.getNumDimsWriteRestrictionsImpl(  );
end 

function numDims = getNumDimsImpl( this )
numDims = this.LookupTableProxy.getNumDimsImpl(  );
end 

function setNumDimsImpl( this, numDims )
this.LookupTableProxy.setNumDimsImpl( numDims );
end 

function bpProxy = getAxisProxyImpl( this, dimensionIndex )
bpProxy = this.LookupTableProxy.getAxisProxyImpl( dimensionIndex );
end 

function tableProxy = getTableProxyImpl( this )
tableProxy = this.LookupTableProxy.getTableProxyImpl(  );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpMKECPP.p.
% Please follow local copyright laws when handling this file.

