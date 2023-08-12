function processAgregatedInfo( this )






ati = this.aggregatedTestInfo;
if isempty( ati )
return ;
end 

this.aggInfoMap = containers.Map( 'KeyType', 'char', 'ValueType', 'any' );
this.traceMap = ati;


for idx = 1:numel( ati )
cati = ati( idx );
analyzedModel = cati.analyzedModel;

cati.isUnitTest = false;
if contains( analyzedModel, '/' )

fi = strfind( analyzedModel, '/' );
analyzedModel = analyzedModel( fi( 1 ):end  );
cati.isUnitTest = true;
end 
cati.analyzedModel = analyzedModel;
if this.aggInfoMap.isKey( analyzedModel )
ci = this.aggInfoMap( analyzedModel );
this.aggInfoMap( analyzedModel ) = [ ci, cati ];
else 
this.aggInfoMap( analyzedModel ) = cati;
end 
end 

allKeys = this.aggInfoMap.keys(  );
nextUnitIdx = 1;

for idx = 1:numel( allKeys )
modelName = allKeys{ idx };
needsDot = false;
cati = this.aggInfoMap( modelName );
if cati( 1 ).isUnitTest
prefix = [ 'U', num2str( nextUnitIdx ) ];
needsDot = numel( cati ) > 1;
nextUnitIdx = nextUnitIdx + 1;
else 
prefix = 'T';
end 
cati = addTraceLabel( this, cati, prefix, needsDot );
this.aggInfoMap( modelName ) = cati;
end 
end 

function aggInfo = addTraceLabel( this, aggInfo, prefix, needsDot )
if numel( aggInfo ) > 1
if needsDot
prefix = [ prefix, '.' ];
end 
for idx = 1:numel( aggInfo )
aggInfo( idx ).traceLabel = [ prefix, int2str( idx ) ];
updateTraceMap( this, aggInfo( idx ) );
end 
else 
aggInfo( 1 ).traceLabel = prefix;
updateTraceMap( this, aggInfo( 1 ) );
end 
end 


function updateTraceMap( this, aggInfo )

traceId = cv.internal.cvdata.getInternalTraceId( aggInfo.uniqueId, this.aggregatedTestInfo );
this.traceMap( traceId ).traceLabel = aggInfo.traceLabel;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpHTGleg.p.
% Please follow local copyright laws when handling this file.

