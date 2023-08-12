classdef StructArrayList < handle






properties ( Access = private )
arrayList = struct( [  ] );
chunkFactor = 2;
endIndex = 0;
end 

methods 
function obj = StructArrayList( structArray )
if nargin > 0 && ~isempty( structArray )
obj.arrayList = structArray;
obj.endIndex = length( structArray );
end 
end 

function appendData( obj, dataToBeAppended )
currentListSize = length( obj.arrayList );


if ~isempty( dataToBeAppended )
additionalDataLength = length( dataToBeAppended );

if currentListSize == 0
obj.arrayList = dataToBeAppended;
obj.endIndex = additionalDataLength;
else 



availableSize = currentListSize - obj.endIndex;
if ( availableSize < additionalDataLength )
extendedSize = ( currentListSize + additionalDataLength ) * obj.chunkFactor;
obj.arrayList( extendedSize ) = dataToBeAppended( 1 );
end 
obj.arrayList( obj.endIndex + 1:obj.endIndex + additionalDataLength ) = dataToBeAppended;
obj.endIndex = obj.endIndex + additionalDataLength;
end 

end 
end 


function numElements = length( obj )
numElements = obj.endIndex;
end 


function empty = isempty( obj )
empty = obj.endIndex <= 0;
end 


function structArray = getData( obj )
if ( obj.endIndex <= length( obj.arrayList ) )
structArray = obj.arrayList( 1:obj.endIndex );
else 
structArray = struct( [  ] );
end 
end 



function varargout = subsref( obj, S )
type = S.type;

switch type
case '.'

[ varargout{ 1:nargout } ] = builtin( 'subsref', obj, S );
case '()'
index = S.subs;
index = index{ 1 };
if ~isempty( index ) && index( end  ) <= obj.endIndex
varargout{ 1 } = obj.arrayList( index );
else 
error( 'Index exceeds matrix dimensions' );
end 
case '{}'
error( 'Cell contents reference from a non-cell array object' );
end 
end 



function obj = subsasgn( obj, S, B )
type = S.type;

switch type
case '()'
index = [ S( 1 ).subs{ : } ];
assignEndIdx = index( end  );

if isempty( B )
if assignEndIdx <= obj.endIndex
obj.arrayList( S( 1 ).subs{ : } ) = [  ];
obj.endIndex = obj.endIndex - length( index );
else 
error( 'Matrix index is out of range for deletion.' );
end 
else 
obj.arrayList( S( 1 ).subs{ : } ) = B;
if assignEndIdx > obj.endIndex
obj.endIndex = assignEndIdx;
end 
end 
otherwise 
error( 'Invalid assignment' );
end 

end 


function clear( obj )
obj.arrayList = struct( [  ] );
obj.endIndex = 0;
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpDDcks7.p.
% Please follow local copyright laws when handling this file.

