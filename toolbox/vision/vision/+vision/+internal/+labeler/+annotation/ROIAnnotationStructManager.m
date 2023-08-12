classdef ROIAnnotationStructManager < vision.internal.labeler.annotation.AnnotationStructManager






























































































methods 

function cache( this, signalNames )
signalNames = cellstr( signalNames );
for i = 1:numel( signalNames )
signalName = signalNames{ i };

thisAnnotationStructObj = getAnnotationStruct( this, signalName );
thisAnnotationStructObj.cache(  );
end 
end 

function uncache( this, signalNames )
signalNames = cellstr( signalNames );
for i = 1:numel( signalNames )
signalName = signalNames{ i };

thisAnnotationStructObj = getAnnotationStruct( this, signalName );
thisAnnotationStructObj.uncache(  );
end 
end 


function updateAttributeAnnotation( this, signalName, frameIdx, roiUID, labelName, sublabelName, attribData )

thisAnnotationStruct = getAnnotationStruct( this, signalName );
updateAttributeAnnotation( thisAnnotationStruct, frameIdx, roiUID, labelName, sublabelName, attribData );
end 


function [ positions, labelNames, sublabelNames, selfUIDs, parentUIDs, colors, shapes, order, roiVisibility ] =  ...
queryAnnotationByReaderId( this, readerIdx, frameIdx )
thisAnnotationStructObj = getAnnotationStructFromIdNoCheck( this, readerIdx );
[ positions, labelNames, sublabelNames, selfUIDs, parentUIDs, colors, shapes, order, roiVisibility ] =  ...
thisAnnotationStructObj.queryAnnotation( frameIdx );
end 


function [ positions, labelNames, sublabelNames, selfUIDs, parentUIDs, colors, shapes ] =  ...
queryAnnotation( this, signalName, frameIdx )
thisAnnotationStructObj = getAnnotationStruct( this, signalName );
[ positions, labelNames, sublabelNames, selfUIDs, parentUIDs, colors, shapes ] =  ...
thisAnnotationStructObj.queryAnnotation( frameIdx );
end 


function addAnnotation( this, signalName, frameIdx, doAppend, isPixelLabel,  ...
labelNames, sublabelNames, labelUIDs, sublabelUIDs, positions )

thisAnnotationStructObj = getAnnotationStruct( this, signalName );
addAnnotation( thisAnnotationStructObj, frameIdx, doAppend, isPixelLabel,  ...
labelNames, sublabelNames, labelUIDs, sublabelUIDs, positions );
end 





function LabelUID = getParentLabelUID( this, signalName, frameIdx, labelName, sublabelName, sublabelUID )
thisAnnotationStructObj = getAnnotationStruct( this, signalName );
LabelUID = getParentLabelUID( thisAnnotationStructObj, frameIdx, labelName, sublabelName, sublabelUID );
end 














function addSublabel( this, labelName, sublabelName )
for i = 1:this.NumAnnotationStructs
thisAnnotationStructObj = this.AnnotationStructs{ i };
thisAnnotationStructObj.addSublabel( labelName, sublabelName );
end 
end 

function removeSublabel( this, labelName, sublabelName )
for i = 1:this.NumAnnotationStructs
thisAnnotationStructObj = this.AnnotationStructs{ i };
thisAnnotationStructObj.removeSublabel( labelName, sublabelName );
end 
end 

function changeSublabel( this, labelName, oldSublabelName, newSublabelName )
for i = 1:this.NumAnnotationStructs
thisAnnotationStructObj = this.AnnotationStructs{ i };
thisAnnotationStructObj.changeSublabel( labelName, oldSublabelName, newSublabelName );
end 
end 

function addAttribute( this, labelName, sublabelName, attributeName )
for i = 1:this.NumAnnotationStructs
thisAnnotationStructObj = this.AnnotationStructs{ i };
thisAnnotationStructObj.addAttribute( labelName, sublabelName, attributeName );
end 
end 

function removeAttribute( this, labelName, sublabelName, attributeName )
for i = 1:this.NumAnnotationStructs
thisAnnotationStructObj = this.AnnotationStructs{ i };

thisAnnotationStructObj.removeAttribute( labelName, sublabelName, attributeName );
end 
end 

function changeAttribute( this, labelName, sublabelName, oldAttribName, newAttribName )
for i = 1:this.NumAnnotationStructs
thisAnnotationStructObj = this.AnnotationStructs{ i };
thisAnnotationStructObj.changeAttribute( labelName, sublabelName, oldAttribName, newAttribName );
end 
end 

function attribInstanceData = getAttributeInstanceValue( this, signalName, frameIdx, roiUID, attribDefData )
thisAnnotationStructObj = getAnnotationStruct( this, signalName );
attribInstanceData = getAttributeInstanceValue( thisAnnotationStructObj, frameIdx, roiUID, attribDefData );
end 

function updateAttribAnnotationAtAttribCreation( this, attribData )
for i = 1:this.NumAnnotationStructs
thisAnnotationStructObj = this.AnnotationStructs{ i };
thisAnnotationStructObj.updateAttribAnnotationAtAttribCreation( attribData );
end 
end 


function removeAnnotation( this, signalName, index, labelName, dataIndex )

thisAnnotationStructObj = getAnnotationStruct( this, signalName );
removeAnnotation( thisAnnotationStructObj, index, labelName, dataIndex );
end 


function [ allUIDs, allPositions, allNames, allColors, allShapes,  ...
allAttributes ] = queryAnnotationsInInterval( this, signalName, indices )

thisAnnotationStructObj = getAnnotationStruct( this, signalName );
[ allUIDs, allPositions, allNames, allColors, allShapes,  ...
allAttributes ] = queryAnnotationsInInterval(  ...
thisAnnotationStructObj, indices );
end 


function numAnnotations = queryShapeSummary( this, signalName, labelName, indices )
thisAnnotationStructObj = getAnnotationStruct( this, signalName );
numAnnotations = queryShapeSummary( thisAnnotationStructObj, labelName, indices );
end 


function numAnnotations = queryPixelSummary( this, signalName, pixelLabelIndex, indices )
thisAnnotationStructObj = getAnnotationStruct( this, signalName );
numAnnotations = queryPixelSummary( thisAnnotationStructObj, pixelLabelIndex, indices );
end 


function num = queryNumSublabelInstances( this, signalName, frameIdx, labelName, labelUID, sublabelNames )
thisAnnotationStructObj = getAnnotationStruct( this, signalName );
num = queryNumSublabelInstances( thisAnnotationStructObj, frameIdx, labelName, labelUID, sublabelNames );
end 


function labelMatrixValue = getPixelLabelAnnotation( this, signalName, index )

thisAnnotationStructObj = getAnnotationStruct( this, signalName );
if isempty( thisAnnotationStructObj )
labelMatrixValue = [  ];

return ;
end 
labelMatrixValue = getPixelLabelAnnotation( thisAnnotationStructObj, index );
end 


function setPixelLabelAnnotation( this, signalName, index, labelPath )

thisAnnotationStructObj = getAnnotationStruct( this, signalName );
if isempty( thisAnnotationStructObj )


return ;
end 

setPixelLabelAnnotation( thisAnnotationStructObj, index, labelPath );
end 


function [ newS, hasAnyAttribDef ] = removeAttribFromAnnotationStruct( this, signalName )
thisAnnotationStructObj = getAnnotationStruct( this, signalName );
[ newS, hasAnyAttribDef ] = removeAttribFromAnnotationStruct( thisAnnotationStructObj );
end 


function [ TF, attribNames, attribVals ] = getAttributeDataForThisSublabelROI( this, signalName,  ...
labelName, sublabelName, roiUID, frameIdx )
thisAnnotationStructObj = getAnnotationStruct( this, signalName );
[ TF, attribNames, attribVals ] = getAttributeDataForThisSublabelROI( thisAnnotationStructObj,  ...
labelName, sublabelName, roiUID, frameIdx );

end 


function [ TF, attribNames, attribVals ] = getAttributeDataForThisLabelROI( this, signalName,  ...
labelName, roiUID, frameIdx )
thisAnnotationStructObj = getAnnotationStruct( this, signalName );
[ TF, attribNames, attribVals ] = getAttributeDataForThisLabelROI( thisAnnotationStructObj,  ...
labelName, roiUID, frameIdx );

end 


function labelDataTable = export2table( this, timeVectors, signalNames, maintainROIOrder )

if isempty( signalNames )
numSignals = this.NumAnnotationStructs;
queryByName = false;
else 
signalNames = cellstr( signalNames );
numSignals = numel( signalNames );
queryByName = true;
end 

if ( isempty( maintainROIOrder ) )
maintainROIOrder = false;
end 

labelDataTable = cell( 1, numSignals );

for signalId = 1:numSignals

timeVector = seconds( timeVectors{ signalId } );

if size( timeVector, 2 ) ~= 1
timeVector = timeVector';
end 

if queryByName
thisAnnotationStructObj = getAnnotationStructFromName( this, signalNames{ signalId } );
else 
thisAnnotationStructObj = getAnnotationStructFromIdNoCheck( this, signalId );
end 
assert( isempty( timeVector ) || numel( timeVector ) == thisAnnotationStructObj.NumImages,  ...
'Expected timeVector and annotation set length to be consistent.' )

newS = formatAnnotationStruct( thisAnnotationStructObj );

if maintainROIOrder
newS = labelStruct2OrderedROIStruct( thisAnnotationStructObj, newS );
else 

newS = dropPolygonROIOrder( thisAnnotationStructObj, newS );
end 
T = struct2table( newS, 'AsArray', true );


if hasPixelAnnotation( thisAnnotationStructObj )
notChar = cellfun( @( x )~ischar( x ), T.PixelLabelData );
T.PixelLabelData( notChar ) = { '' };
end 

if ~isempty( timeVector )

numTimes = thisAnnotationStructObj.NumImages;
HoursMins = zeros( numTimes, 2 );
HoursMinsSecs = horzcat( HoursMins, timeVector );

maxTime = timeVector( end  );

displayFormat = vision.internal.labeler.getNiceDurationFormat( maxTime );
durationVector = duration( HoursMinsSecs, 'Format', displayFormat );


T = table2timetable( T, 'RowTimes', durationVector );
end 
labelDataTable{ signalId } = T;
end 
end 


function replace( this, signalName, indices, varargin )

thisAnnotationStructObj = getAnnotationStruct( this, signalName );
replace( thisAnnotationStructObj, indices, varargin{ : } );
end 











function mergeWithCache( this, signalName, indices, varargin )

thisAnnotationStructObj = getAnnotationStruct( this, signalName );
mergeWithCache( thisAnnotationStructObj, indices, varargin{ : } )
end 

end 
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
methods 

















function resetFrameHasAnnotations( this, signalName )
thisAnnotationStruct = getAnnotationStruct( this, signalName );
resetFrameHasAnnotations( thisAnnotationStruct );
end 

function replaceFrameHasAnnotations( this, signalName, frameHasAnnotations )
thisAnnotationStruct = getAnnotationStruct( this, signalName );
replaceFrameHasAnnotations( thisAnnotationStruct, frameHasAnnotations );
end 

function resetIsPixelLabelChangedAll( this )
for i = 1:this.NumAnnotationStructs
thisAnnotationStruct = getAnnotationStructFromIdNoCheck( this, i );
resetIsPixelLabelChanged( thisAnnotationStruct );
end 
end 

function resetIsPixelLabelChanged( this, signalName )
thisAnnotationStruct = getAnnotationStruct( this, signalName );
if ~isempty( thisAnnotationStruct )
resetIsPixelLabelChanged( thisAnnotationStruct );
end 
end 

function setIsPixelLabelChangedAll( this )
for i = 1:this.NumAnnotationStructs
thisAnnotationStruct = getAnnotationStructFromIdNoCheck( this, i );
setIsPixelLabelChanged( thisAnnotationStruct );
end 
end 

function setIsPixelLabelChanged( this, signalName )
thisAnnotationStruct = getAnnotationStruct( this, signalName );
if ~isempty( thisAnnotationStruct )
setIsPixelLabelChanged( thisAnnotationStruct );
end 
end 

function setIsPixelLabelChangedByIdx( this, signalName, idx )
thisAnnotationStruct = getAnnotationStruct( this, signalName );
if ~isempty( thisAnnotationStruct )
setIsPixelLabelChangedByIdx( thisAnnotationStruct, idx );
end 
end 

function flagV = getIsPixelLabelChanged( this, signalName )
thisAnnotationStruct = getAnnotationStruct( this, signalName );
flagV = false;
if ~isempty( thisAnnotationStruct )
flagV = getIsPixelLabelChanged( thisAnnotationStruct );
end 
end 
end 

 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...



methods ( Access = private )





































end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpZEGgqp.p.
% Please follow local copyright laws when handling this file.

