classdef ROIAnnotationStruct < vision.internal.labeler.annotation.AnnotationStruct

properties ( Access = protected )
FrameHasAnnotations
IsPixelLabelChanged
SignalType
end 

properties ( Constant )

ATTRIB_NS = 'RESERVED_NAMESPACE_4_ATTRIB7623';
end 

properties ( Access = private )
LabelSet
SublabelSet
AttributeSet
end 

methods 
function this = ROIAnnotationStruct( signalName, numImages, labelSet, sublabelSet, attributeSet, signalType )

this = this@vision.internal.labeler.annotation.AnnotationStruct( signalName, numImages );
this.LabelSet = labelSet;
this.SublabelSet = sublabelSet;
this.AttributeSet = attributeSet;

createDefaultAnnotationStruct( this );
this.SignalType = signalType;
end 
function tf = isPointCloudSignal( this )
tf = ( this.SignalType == vision.labeler.loading.SignalType.PointCloud );
end 

















function repeatHasAnnotationField( this, numImages )

oldNumImages = this.NumImages;


if oldNumImages > 0
numNewImages = numImages - oldNumImages;
if numNewImages > 0
this.FrameHasAnnotations( oldNumImages + 1:oldNumImages + numNewImages ) = false( numNewImages, 1 );
end 
end 
end 

function repeatLastAnnotationStruct( this, numImages, defaultValue )

repeatLastAnnotationStruct@vision.internal.labeler.annotation.AnnotationStruct( this, numImages, defaultValue );

numberToAppend = numImages - this.NumImages;
isPixelLabelChangedTemp = false( numberToAppend, 1 );
this.IsPixelLabelChanged = [ this.IsPixelLabelChanged;isPixelLabelChangedTemp ];
end 

function resetFrameHasAnnotations( this )
this.FrameHasAnnotations = false( this.NumImages, 1 );
end 

function replaceFrameHasAnnotations( this, frameHasAnnotations )
this.FrameHasAnnotations = frameHasAnnotations;
end 

function resetIsPixelLabelChanged( this )
this.IsPixelLabelChanged = false( this.NumImages, 1 );
end 

function setIsPixelLabelChanged( this )
this.IsPixelLabelChanged = true( this.NumImages, 1 );
end 

function setIsPixelLabelChangedByIdx( this, idx )
this.IsPixelLabelChanged( idx ) = true;
end 

function flagV = getIsPixelLabelChanged( this )
flagV = this.IsPixelLabelChanged;
end 
end 

methods 

function [ positions, labelNames, sublabelNames, selfUIDs, parentUIDs, colors, shapes, roiOrder, roiVisibility ] =  ...
queryAnnotation( this, frameIdx )



frameIdx = max( frameIdx, 1 );

positions = {  };
labelNames = {  };
sublabelNames = {  };
colors = {  };
selfUIDs = {  };
parentUIDs = {  };
shapes = labelType( [  ] );
roiOrder = {  };
roiVisibility = {  };



s = getAnnotationStructPerFrame( this, frameIdx );

if isempty( s ) || isempty( fieldnames( s ) )
return ;
end 

labelSet = this.LabelSet;


allLabelNames = fieldnames( s );

for lInx = 1:numel( allLabelNames )
label = allLabelNames{ lInx };
if ~strcmp( label, 'PixelLabelData' )
if isfield( s.( label ), 'Position' )
numLabelROIs = getNumLabelROIsInAnnotation( s, label );

for i = 1:numLabelROIs
allSublabelNames = getSublabelNames( this, s.( label )( i ) );
roiPos_label_i = s.( label )( i ).Position;
roiUIDs_label_i = s.( label )( i ).LabelUIDs;
if isfield( s.( label ), 'ROIOrder' )
roiOrder_label_i = s.( label )( i ).ROIOrder;
else 
roiOrder_label_i = [  ];
end 


positions{ end  + 1 } = roiPos_label_i;%#ok<AGROW>
labelNames{ end  + 1 } = label;%#ok<AGROW>
sublabelNames{ end  + 1 } = '';%#ok<AGROW>
selfUIDs{ end  + 1 } = roiUIDs_label_i;%#ok<AGROW>
parentUIDs{ end  + 1 } = '';%#ok<AGROW> % labels don't have a parent

labelID = labelSet.labelNameToID( label );
labelColor = labelSet.queryLabelColor( labelID );
colors{ end  + 1 } = labelColor;%#ok<AGROW>

labelShape = labelSet.queryLabelShape( labelID );
shapes( end  + 1 ) = labelShape;%#ok<AGROW>
roiOrder( end  + 1 ) = { roiOrder_label_i };%#ok<AGROW>

isROIVisible = labelSet.queryROIVisible( labelID );
roiVisibility{ end  + 1 } = isROIVisible;%#ok<AGROW>




for slInx = 1:numel( allSublabelNames )
sublabel = allSublabelNames{ slInx };
numSublabelROIs = getNumSublabelROIsInAnnotation( s, label, sublabel, i );

sublabelID = this.SublabelSet.sublabelNameToID( label, sublabel );
sublabelShape = this.SublabelSet.querySublabelShape( sublabelID );

for k = 1:numSublabelROIs

roiPos_sublabel_ik = s.( label )( i ).( sublabel )( k ).Position;
roiUIDs_sublabel_ik = s.( label )( i ).( sublabel )( k ).SublabelUIDs;

parentLabelUIDs = roiUIDs_label_i;

positions{ end  + 1 } = roiPos_sublabel_ik;%#ok<AGROW>
labelNames{ end  + 1 } = label;%#ok<AGROW>
sublabelNames{ end  + 1 } = sublabel;%#ok<AGROW>
selfUIDs{ end  + 1 } = roiUIDs_sublabel_ik;%#ok<AGROW>
parentUIDs{ end  + 1 } = parentLabelUIDs;%#ok<AGROW> % labels don't have a parent
roiOrder( end  + 1 ) = {  - 1 };%#ok<AGROW> % Sublabels don't support ordering/stacking


colors{ end  + 1 } = this.SublabelSet.querySublabelColor( sublabelID );%#ok<AGROW>


shapes( end  + 1 ) = sublabelShape;%#ok<AGROW>
roiVisibility{ end  + 1 } = this.SublabelSet.querySublabelROIVisible( sublabelID );
end 
end 
end 
end 
end 
end 
end 


function addAnnotation( this, frameIdx, doAppend, isPixelLabel,  ...
labelNames, sublabelNames, labelUIDs, sublabelUIDs, positions )


frameIdx = max( frameIdx, 1 );

if isPixelLabel

if ~isfield( this.AnnotationStruct_, 'PixelLabelData' )

this.AnnotationStruct_( end  ).PixelLabelData = '';
end 

s = this.AnnotationStruct_( frameIdx );
s.PixelLabelData = positions{ 1 };
else 
numRois = numel( labelNames );


s = this.AnnotationStruct_( frameIdx );
hasAttributeDef = isfield( s, this.ATTRIB_NS );

if ~doAppend
s = resetAnnotationStruct( this, s );
end 

if isfield( this.AnnotationStruct_, 'PixelLabelData' )
labelMatrixValue = this.AnnotationStruct_( frameIdx ).PixelLabelData;
s.PixelLabelData = labelMatrixValue;
end 

isLabels = cellfun( @isempty, sublabelNames );

for n = 1:numRois
roiPos = positions{ n };
if ~isempty( roiPos )
if isLabels( n )


s = appendLabelToStruct( this, s, labelNames{ n }, labelUIDs{ n }, positions{ n }, n );
if hasAttributeDef
s = updateAttributeOfLabelIfNotYetSet( this, s, labelNames{ n }, labelUIDs{ n } );
end 
end 
end 
end 

for n = 1:numRois
roiPos = positions{ n };
if ~isempty( roiPos )
if ~isLabels( n )
s = appendSublabelToStruct( this, s, labelNames{ n }, sublabelNames{ n }, labelUIDs{ n }, sublabelUIDs{ n }, positions{ n } );
s = updateAttributeOfSubabelIfNotYetSet( this, s, labelNames{ n }, sublabelNames{ n }, sublabelUIDs{ n } );
end 
end 
end 

if numRois > 0
this.FrameHasAnnotations( frameIdx ) = true;
else 
this.FrameHasAnnotations( frameIdx ) = false;
end 
end 


this.AnnotationStruct_( frameIdx ) = s;

end 

function changeLabel( this, oldLabelName, newLabelName )

ATTRIB_NAME_SPACE = this.ATTRIB_NS;


numImages = this.NumImages;






if isfield( this.AnnotationStruct_, oldLabelName )


for i = 1:numImages
this.AnnotationStruct_( i ).( newLabelName ) = this.AnnotationStruct_( i ).( oldLabelName );
end 

this.AnnotationStruct_ = rmfield( this.AnnotationStruct_, oldLabelName );


hasAttrib = isfield( this.AnnotationStruct_, ATTRIB_NAME_SPACE );
if hasAttrib
for i = 1:numImages
hasThisAttrib = isfield( this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ), oldLabelName ) &&  ...
isstruct( this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ).( oldLabelName ) );

if hasThisAttrib
this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ).( newLabelName ) =  ...
this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ).( oldLabelName );
this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ) =  ...
rmfield( this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ), oldLabelName );
end 
end 
end 
end 
end 

function addSublabel( this, labelName, sublabelName )

numImages = this.NumImages;






for i = 1:numImages
numAnnotations = max( numel( this.AnnotationStruct_( i ).( labelName ) ), 1 );
for j = 1:numAnnotations
this.AnnotationStruct_( i ).( labelName )( j ).( sublabelName ) = [  ];
end 
end 
end 



function removeSublabel( this, labelName, sublabelName )








numImages = this.NumImages;

if isfield( this.AnnotationStruct_( 1 ), labelName )
for frameIdx = 1:numImages
if isfield( this.AnnotationStruct_( frameIdx ).( labelName ), sublabelName )
this.AnnotationStruct_( frameIdx ).( labelName ) = rmfield( this.AnnotationStruct_( frameIdx ).( labelName ), sublabelName );




if isempty( fieldnames( this.AnnotationStruct_( frameIdx ).( labelName ) ) )
this.AnnotationStruct_( frameIdx ).( labelName ) = [  ];
end 
end 
end 
end 
end 

function changeSublabel( this, labelName, oldSublabelName, newSublabelName )

ATTRIB_NAME_SPACE = this.ATTRIB_NS;

numImages = this.NumImages;
if isfield( this.AnnotationStruct_, labelName )


for i = 1:numImages
numAnnotations = max( numel( this.AnnotationStruct_( i ).( labelName ) ), 1 );
if isfield( this.AnnotationStruct_( i ).( labelName ), oldSublabelName )
for j = 1:numAnnotations
this.AnnotationStruct_( i ).( labelName )( j ).( newSublabelName ) =  ...
this.AnnotationStruct_( i ).( labelName )( j ).( oldSublabelName );
end 
this.AnnotationStruct_( i ).( labelName ) = rmfield( this.AnnotationStruct_( i ).( labelName ), oldSublabelName );
end 
end 


hasAttrib = isfield( this.AnnotationStruct_, ATTRIB_NAME_SPACE );
if hasAttrib
for i = 1:numImages
hasThisAttrib = isfield( this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ), labelName ) &&  ...
isfield( this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ).( labelName ), oldSublabelName ) &&  ...
isstruct( this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ).( labelName ).( oldSublabelName ) );

if hasThisAttrib
this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ).( labelName ).( newSublabelName ) =  ...
this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ).( labelName ).( oldSublabelName );

this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ).( labelName ) =  ...
rmfield( this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ).( labelName ), oldSublabelName );
end 
end 
end 
end 
end 

function addAttribute( this, labelName, sublabelName, attributeName )





numImages = this.NumImages;







ATTRIB_NAME_SPACE = this.ATTRIB_NS;

if isempty( sublabelName )
for i = 1:numImages
this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ).( labelName ).( attributeName ) = [  ];
end 
else 
for i = 1:numImages
this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ).( labelName ).( sublabelName ).( attributeName ) = {  };
end 
end 
end 

function removeAttribute( this, labelName, sublabelName, attributeName )

ATTRIB_NAME_SPACE = this.ATTRIB_NS;
numImages = this.NumImages;

if isempty( sublabelName )
if ( numImages > 0 ) &&  ...
isfield( this.AnnotationStruct_( 1 ), labelName ) &&  ...
isfield( this.AnnotationStruct_( 1 ), ATTRIB_NAME_SPACE )

for i = 1:numImages
if isfield( this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ), labelName ) &&  ...
isfield( this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ).( labelName ), attributeName )
this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ).( labelName ) =  ...
rmfield( this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ).( labelName ), attributeName );




if isempty( fieldnames( this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ).( labelName ) ) )
this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ) =  ...
rmfield( this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ), labelName );
end 
end 
end 
end 
else 

if ( numImages > 0 ) &&  ...
isfield( this.AnnotationStruct_( 1 ), labelName ) &&  ...
isfield( this.AnnotationStruct_( 1 ).( labelName ), sublabelName ) &&  ...
isfield( this.AnnotationStruct_( 1 ), ATTRIB_NAME_SPACE )

for i = 1:numImages
if isfield( this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ), labelName ) &&  ...
isfield( this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ).( labelName ), sublabelName ) &&  ...
isfield( this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ).( labelName ).( sublabelName ), attributeName )
this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ).( labelName ).( sublabelName ) =  ...
rmfield( this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ).( labelName ).( sublabelName ), attributeName );
end 
if isempty( fieldnames( this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ).( labelName ).( sublabelName ) ) )
this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ).( labelName ) =  ...
rmfield( this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ).( labelName ), sublabelName );
end 




if isempty( fieldnames( this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ).( labelName ) ) )
this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ) =  ...
rmfield( this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ), labelName );
end 
end 
end 
end 



if isfield( this.AnnotationStruct_( 1 ), ATTRIB_NAME_SPACE ) &&  ...
isempty( fieldnames( this.AnnotationStruct_( 1 ).( ATTRIB_NAME_SPACE ) ) )
this.AnnotationStruct_ = rmfield( this.AnnotationStruct_, ATTRIB_NAME_SPACE );
end 
end 


function changeAttribute( this, labelName, sublabelName, oldAttribName, newAttribName )
ATTRIB_NAME_SPACE = this.ATTRIB_NS;





numImages = this.NumImages;

if isempty( sublabelName )

if ( numImages > 0 ) &&  ...
isfield( this.AnnotationStruct_( 1 ), labelName ) &&  ...
isfield( this.AnnotationStruct_( 1 ), ATTRIB_NAME_SPACE )

for i = 1:numImages
if isfield( this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ), labelName ) &&  ...
isfield( this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ).( labelName ), oldAttribName )
this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ).( labelName ).( newAttribName ) =  ...
this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ).( labelName ).( oldAttribName );
this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ).( labelName ) =  ...
rmfield( this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ).( labelName ), oldAttribName );
end 
end 
end 
else 
if ( numImages > 0 ) &&  ...
isfield( this.AnnotationStruct_( 1 ), labelName ) &&  ...
isfield( this.AnnotationStruct_( 1 ).( labelName ), sublabelName ) &&  ...
isfield( this.AnnotationStruct_( 1 ), ATTRIB_NAME_SPACE )

for i = 1:numImages
if isfield( this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ), labelName ) &&  ...
isfield( this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ).( labelName ), sublabelName ) &&  ...
isfield( this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ).( labelName ).( sublabelName ), oldAttribName )

this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ).( labelName ).( sublabelName ).( newAttribName ) =  ...
this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ).( labelName ).( sublabelName ).( oldAttribName );

this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ).( labelName ).( sublabelName ) =  ...
rmfield( this.AnnotationStruct_( i ).( ATTRIB_NAME_SPACE ).( labelName ).( sublabelName ), oldAttribName );
end 
end 
end 
end 
end 


function updateAttribAnnotationAtAttribCreation( this, attribData )

labelName = attribData.LabelName;
sublabelName = attribData.SublabelName;
attribName = attribData.Name;
attribValue = getAttributeDefaultValue( this, attribData );
ATTRIB_NAME_SPACE = this.ATTRIB_NS;

numImages = length( this.AnnotationStruct_ );
if isempty( sublabelName )


for frameIdx = 1:numImages
s = this.AnnotationStruct_( frameIdx );
if isfield( s, labelName )
thisLabelS = s.( labelName );
for lbl = 1:numel( thisLabelS )
if isfield( thisLabelS( lbl ), 'LabelUIDs' )
roiUID = thisLabelS( lbl ).LabelUIDs;
if isfield( this.AnnotationStruct_( frameIdx ).( ATTRIB_NAME_SPACE ).( labelName ), attribName )
endIdx = numel( this.AnnotationStruct_( frameIdx ).( ATTRIB_NAME_SPACE ).( labelName ).( attribName ) );
else 
endIdx = 0;
end 
this.AnnotationStruct_( frameIdx ).( ATTRIB_NAME_SPACE ).( labelName ).( attribName )( endIdx + 1 ).AttributeValues = attribValue;
this.AnnotationStruct_( frameIdx ).( ATTRIB_NAME_SPACE ).( labelName ).( attribName )( endIdx + 1 ).LabelUIDs = roiUID;
end 
end 
end 
end 
else 
for frameIdx = 1:numImages
s = this.AnnotationStruct_( frameIdx );
if isfield( s, labelName )
thisLabelS = s.( labelName );
for lbl = 1:numel( thisLabelS )
if isfield( thisLabelS( lbl ), 'LabelUIDs' )
if isfield( s.( labelName )( lbl ), sublabelName )
thisSublabelS = s.( labelName )( lbl ).( sublabelName );
for slbl = 1:numel( thisSublabelS )
if isfield( thisSublabelS( slbl ), 'SublabelUIDs' )
roiUID = thisSublabelS( slbl ).SublabelUIDs;
if isfield( this.AnnotationStruct_( frameIdx ).( ATTRIB_NAME_SPACE ).( labelName ).( sublabelName ), attribName )
endIdx = numel( this.AnnotationStruct_( frameIdx ).( ATTRIB_NAME_SPACE ).( labelName ).( sublabelName ).( attribName ) );
else 
endIdx = 0;
end 
this.AnnotationStruct_( frameIdx ).( ATTRIB_NAME_SPACE ).( labelName ).( sublabelName ).( attribName )( endIdx + 1 ).AttributeValues = attribValue;
this.AnnotationStruct_( frameIdx ).( ATTRIB_NAME_SPACE ).( labelName ).( sublabelName ).( attribName )( endIdx + 1 ).SublabelUIDs = roiUID;
end 
end 
end 
end 
end 
end 
end 
end 
end 

function attribInstanceData = getAttributeInstanceValue( this, frameIdx, roiUID, attribDefData )

ATTRIB_NAME_SPACE = this.ATTRIB_NS;
attribInstanceData = attribDefData;
s = this.AnnotationStruct_( frameIdx );


for n = 1:length( attribDefData )
labelName = attribDefData{ n }.LabelName;
sublabelName = attribDefData{ n }.SublabelName;
attributeName = attribDefData{ n }.Name;

if isempty( sublabelName )
if isfield( s, ATTRIB_NAME_SPACE ) && isfield( s.( ATTRIB_NAME_SPACE ), labelName ) &&  ...
isfield( s.( ATTRIB_NAME_SPACE ).( labelName ), attributeName )

matchingAttribCellID = getMatchingAttribCellID( this, s.( ATTRIB_NAME_SPACE ).( labelName ).( attributeName ), roiUID, true );
if ~isempty( matchingAttribCellID )
[ hasAttribValue, atribVal ] = getAttribValueInfo( this, matchingAttribCellID, s.( ATTRIB_NAME_SPACE ).( labelName ).( attributeName ) );
if hasAttribValue
attribInstanceData{ n }.Value = atribVal;
else 
attribInstanceData{ n }.Value = getDefaultValue( this, attribDefData{ n } );
end 
else 
attribInstanceData{ n }.Value = getDefaultValue( this, attribDefData{ n } );
end 
end 
else 

if isfield( s, ATTRIB_NAME_SPACE ) && ( isfield( s.( ATTRIB_NAME_SPACE ), labelName ) &&  ...
isfield( s.( ATTRIB_NAME_SPACE ).( labelName ), sublabelName ) &&  ...
isfield( s.( ATTRIB_NAME_SPACE ).( labelName ).( sublabelName ), attributeName ) )

matchingAttribCellID = getMatchingAttribCellID( this, s.( ATTRIB_NAME_SPACE ).( labelName ).( sublabelName ).( attributeName ), roiUID, false );

if ~isempty( matchingAttribCellID )
[ hasAttribValue, atribVal ] = getAttribValueInfo( this, matchingAttribCellID, s.( ATTRIB_NAME_SPACE ).( labelName ).( sublabelName ).( attributeName ) );
if hasAttribValue
attribInstanceData{ n }.Value = atribVal;
else 
attribInstanceData{ n }.Value = getDefaultValue( this, attribDefData{ n } );
end 
else 
attribInstanceData{ n }.Value = getDefaultValue( this, attribDefData{ n } );
end 
end 
end 
end 
end 


function num = queryNumSublabelInstances( this, frameIdx, labelName, labelUID, sublabelNames )

numSublabelNames = numel( sublabelNames );
num = zeros( 1, numSublabelNames );
s = this.AnnotationStruct_( frameIdx );
if isfield( s, labelName )
if isfield( s.( labelName ), 'LabelUIDs' )
labelUIDs = { s.( labelName ).LabelUIDs };
matchingLabelCellID = find( contains( labelUIDs, labelUID ) );
if ~isempty( matchingLabelCellID )
for i = 1:numSublabelNames
if ~isempty( s.( labelName ) ) &&  ...
isfield( s.( labelName )( matchingLabelCellID ), sublabelNames{ i } )
num( i ) = numel( s.( labelName )( matchingLabelCellID ).( sublabelNames{ i } ) );
end 
end 
end 
end 
end 

end 


function LabelUID = getParentLabelUID( this, frameIdx, labelName, sublabelName, sublabelUID )

LabelUID = '';
s = this.AnnotationStruct_( frameIdx );
if ( isfield( s, labelName ) && isfield( s.( labelName ), sublabelName ) )

numLabelROIs = getNumLabelROIsInAnnotation( s, labelName );

for lbl = 1:numLabelROIs
numSublabelROIs = getNumSublabelROIsInAnnotation( s, labelName, sublabelName, lbl );

for subLbl = 1:numSublabelROIs
sublabelUID4thisLabel = s.( labelName )( lbl ).( sublabelName )( subLbl ).SublabelUIDs;
if strcmp( sublabelUID4thisLabel, sublabelUID )
LabelUID = s.( labelName )( lbl ).LabelUIDs;
return ;
end 
end 
end 
end 
end 


function [ newS, hasAnyAttribDef ] = removeAttribFromAnnotationStruct( this )
hasAnyAttribDef = hasAnyAttribDefinition( this );
newS = this.AnnotationStruct_;
if hasAnyAttribDef
newS = rmfield( this.AnnotationStruct_, this.ATTRIB_NS );
end 
end 


function [ TF, attribNames, attribVals ] = getAttributeDataForThisLabelROI( this, labelName, roiUID, frameIdx )

TF = false;
attribNames = {  };
attribVals = {  };

if ~isfield( this.AnnotationStruct_( frameIdx ), this.ATTRIB_NS )

return 
end 

attribFrameS = this.AnnotationStruct_( frameIdx ).( this.ATTRIB_NS );
if isfield( attribFrameS, labelName )
attribLabelS = attribFrameS.( labelName );
f = fieldnames( attribLabelS );
for i = 1:numel( f )
thisAttribName = f{ i };
thisAttribS = attribLabelS.( thisAttribName );
for k = 1:numel( thisAttribS )
if isfield( thisAttribS( k ), 'LabelUIDs' ) && strcmp( thisAttribS( k ).LabelUIDs, roiUID )
attribNames{ end  + 1 } = thisAttribName;%#ok<AGROW>
attribVals{ end  + 1 } = thisAttribS( k ).AttributeValues;%#ok<AGROW>
TF = true;
end 
end 
end 
end 
end 


function [ TF, attribNames, attribVals ] = getAttributeDataForThisSublabelROI( this, labelName, sublabelName, roiUID, frameIdx )

TF = false;
attribNames = {  };
attribVals = {  };

if ~isfield( this.AnnotationStruct_( frameIdx ), this.ATTRIB_NS )

return 
end 

attribFrameS = this.AnnotationStruct_( frameIdx ).( this.ATTRIB_NS );
if isfield( attribFrameS, labelName ) && isfield( attribFrameS.( labelName ), sublabelName )
attribSublabelS = attribFrameS.( labelName ).( sublabelName );
f = fieldnames( attribSublabelS );
for i = 1:numel( f )
thisAttribName = f{ i };
thisAttribS = attribSublabelS.( thisAttribName );
for k = 1:numel( thisAttribS )
if isfield( thisAttribS( k ), 'SublabelUIDs' ) && strcmp( thisAttribS( k ).SublabelUIDs, roiUID )
attribNames{ end  + 1 } = thisAttribName;%#ok<AGROW>
attribVals{ end  + 1 } = thisAttribS( k ).AttributeValues;%#ok<AGROW>
TF = true;
end 
end 
end 
end 
end 



function updateAttributeAnnotation( this, frameIdx, roiUID, labelName, sublabelName, attribData )

ATTRIB_NAME_SPACE = this.ATTRIB_NS;



s = this.AnnotationStruct_( frameIdx );



if ~isempty( attribData ) && isfield( s, ATTRIB_NAME_SPACE )
attributeName = attribData.AttributeName;
attributeValue = attribData.AttributeValue;
if isempty( sublabelName )
matchingOrNextAttribCellID = getMatchingOrNextAttribCellID( this, s.( ATTRIB_NAME_SPACE ).( labelName ).( attributeName ), roiUID, true );
s.( ATTRIB_NAME_SPACE ).( labelName ).( attributeName )( matchingOrNextAttribCellID ).AttributeValues = attributeValue;
s.( ATTRIB_NAME_SPACE ).( labelName ).( attributeName )( matchingOrNextAttribCellID ).LabelUIDs = roiUID;
else 
matchingOrNextAttribCellID = getMatchingOrNextAttribCellID( this, s.( ATTRIB_NAME_SPACE ).( labelName ).( sublabelName ).( attributeName ), roiUID, false );
s.( ATTRIB_NAME_SPACE ).( labelName ).( sublabelName ).( attributeName )( matchingOrNextAttribCellID ).AttributeValues = attributeValue;
s.( ATTRIB_NAME_SPACE ).( labelName ).( sublabelName ).( attributeName )( matchingOrNextAttribCellID ).SublabelUIDs = roiUID;
end 
end 


this.AnnotationStruct_( frameIdx ) = s;
end 


function removeAnnotation( this, index, labelName, dataIndex )

index = max( index, 1 );


annotations = this.AnnotationStruct_( index ).( labelName ).Position;
annotations( dataIndex, : ) = [  ];


if isempty( annotations )
annotations = [  ];
end 
this.AnnotationStruct_( index ).( labelName ).Position = annotations;


resetHierarchyValues( this, index, labelName );

end 


function removeAllAnnotations( this, indices )
this.AnnotationStruct_( indices ) = [  ];
if isempty( this.AnnotationStruct_ )
this.AnnotationStruct_ = struct(  );
end 
this.NumImages = this.NumImages - numel( indices );
this.FrameHasAnnotations( indices ) = [  ];
this.IsPixelLabelChanged( indices ) = [  ];
end 


function [ allUIDs, allPositions, allNames, allColors, allShapes,  ...
allAttributes ] = queryAnnotationsInInterval( this, indices )

indices = max( indices, 1 );
allUIDs = repmat( { {  } }, size( indices ) );
allPositions = repmat( { {  } }, size( indices ) );
allNames = repmat( { {  } }, size( indices ) );
allColors = repmat( { {  } }, size( indices ) );
allShapes = repmat( { labelType( [  ] ) }, size( indices ) );
allAttributes = repmat( { {  } }, size( indices ) );


allS = this.AnnotationStruct_( indices );


allLabelNames = fieldnames( allS );
pixelLabelIndex = find( strcmpi( allLabelNames, 'PixelLabelData' ) );
attribNSIndex = find( strcmpi( allLabelNames, this.ATTRIB_NS ) );

if ~isempty( pixelLabelIndex )
allLabelNames( pixelLabelIndex ) = [  ];
end 

hasAttrib = false;
if ~isempty( attribNSIndex )
allLabelNames( attribNSIndex ) = [  ];
hasAttrib = true;


end 

numLabels = numel( allLabelNames );
labelIDs = cellfun( @( lname )this.LabelSet.labelNameToID( lname ), allLabelNames, 'UniformOutput', false );
labelColors = cellfun( @( lid )this.LabelSet.queryLabelColor( lid ), labelIDs, 'UniformOutput', false );
labelShapes = cellfun( @( lid )this.LabelSet.queryLabelShape( lid ), labelIDs, 'UniformOutput', false );
for n = 1:numel( indices )
s = allS( n );
if hasAttrib
sAttrib = s.( this.ATTRIB_NS );
end 

if isempty( s )
continue ;
end 

uids = allUIDs{ n };
positions = allPositions{ n };
names = allNames{ n };
colors = allColors{ n };
shapes = allShapes{ n };
attributes = allAttributes{ n };

for lInx = 1:numLabels
label = allLabelNames{ lInx };
if isfield( s.( label ), 'Position' )
roiPos = { s.( label ).Position };
selfUIDs = { s.( label ).LabelUIDs };
if hasAttrib && isfield( sAttrib, label )
attribs = sAttrib.( label );
end 
for i = 1:numel( selfUIDs )
if ~isempty( roiPos )
uids{ end  + 1 } = selfUIDs{ i };%#ok<AGROW>
positions{ end  + 1 } = roiPos{ i };%#ok<AGROW>
names{ end  + 1 } = label;%#ok<AGROW>
colors{ end  + 1 } = labelColors{ lInx };%#ok<AGROW>
shapes{ end  + 1 } = labelShapes{ lInx };%#ok<AGROW>

if hasAttrib && isfield( sAttrib, label )
[ attribNames, attribValues ] = getAttribInfoForLabels( this, attribs, selfUIDs{ i } );
attribS = [  ];
for j = 1:numel( attribNames )
attribS.( attribNames{ j } ) = attribValues{ j };
end 
attributes{ end  + 1 } = attribS;%#ok<AGROW>
else 
attributes{ end  + 1 } = [  ];%#ok<AGROW>
end 
end 
end 
end 
end 

allUIDs{ n } = uids;
allPositions{ n } = positions;
allNames{ n } = names;
allColors{ n } = colors;
allShapes{ n } = shapes;
allAttributes{ n } = attributes;
end 
end 


function numAnnotations = queryShapeSummary( this, labelName, indices )

indices = max( indices, 1 );
numAnnotations = zeros( size( indices ) );
idx = cellfun( @isstruct, { this.AnnotationStruct_( indices ).( labelName ) } );
for i = 1:numel( idx )
if idx( i )
for j = 1:numel( this.AnnotationStruct_( indices( i ) ).( labelName ) )
if isfield( this.AnnotationStruct_( indices( i ) ).( labelName )( j ), 'LabelUIDs' )
numAnnotations( i ) = numAnnotations( i ) + 1;
end 
end 
end 
end 
end 


function numAnnotations = queryPixelSummary( this, pixelLabelIndex, indices )


indices = max( indices, 1 );
numAnnotations = zeros( size( indices ) );
for i = 1:numel( indices )
idx = indices( i );
try 
img = imread( this.AnnotationStruct_( idx ).PixelLabelData );
numAnnotations( i ) = sum( img( : ) == pixelLabelIndex ) / numel( img );
catch 


numAnnotations( i ) = 0;
end 
end 
end 


function labelMatrixValue = getPixelLabelAnnotation( this, index )

if isfield( this.AnnotationStruct_, 'PixelLabelData' )
labelMatrixValue = this.AnnotationStruct_( index ).PixelLabelData;
else 
labelMatrixValue = '';
end 

end 


function setPixelLabelAnnotation( this, index, labelPath )

if ~isfield( this.AnnotationStruct_, 'PixelLabelData' )

this.AnnotationStruct_( end  ).PixelLabelData = '';
end 

s = this.AnnotationStruct_( index );
s.PixelLabelData = labelPath;
this.AnnotationStruct_( index ) = s;
end 


function newS = formatAnnotationStructForLabelOnly( this )

newS = this.AnnotationStruct_;
labelNames = fieldnames( this.AnnotationStruct_( 1 ) );
labelNames = excludePixelLabelData( labelNames );
[ labelNames, unsuppLabelNames ] = getSupportedLabelNamesForSignal( this, labelNames );

newS = rmfield( newS, unsuppLabelNames );

numImages = length( this.AnnotationStruct_ );

for frameIdx = 1:numImages
thisFramesOrigAnnoS = newS( frameIdx );


if ~this.FrameHasAnnotations( frameIdx )
continue ;
end 


for lbl = 1:numel( labelNames )
label_lbl = labelNames{ lbl };
thisFramesLabel_lbl = thisFramesOrigAnnoS.( label_lbl );
numROIs_label_lbl = numel( thisFramesLabel_lbl );
if numROIs_label_lbl == 0
roiValues = [  ];
else 
labelShape_lbl = queryLabelShapeFromName( this, label_lbl );


if ( labelShape_lbl == labelType.Rectangle ) &&  ...
this.SignalType == vision.labeler.loading.SignalType.Image
roiValues = zeros( numROIs_label_lbl, 4 );
for r = 1:numROIs_label_lbl
thisLabelInstanceS = thisFramesLabel_lbl( r );
roiValues( r, 1:4 ) = thisLabelInstanceS.Position;
end 
elseif ( labelShape_lbl == labelType.Line )
roiValues = cell( numROIs_label_lbl, 1 );
for r = 1:numROIs_label_lbl
thisLabelInstanceS = thisFramesLabel_lbl( r );
roiValues{ r } = thisLabelInstanceS.Position;
end 
elseif ( labelShape_lbl == labelType.Polygon )
roiValues = cell( numROIs_label_lbl, 1 );
for r = 1:numROIs_label_lbl
thisLabelInstanceS = thisFramesLabel_lbl( r );
roiValues{ r, 1 } = thisLabelInstanceS.Position;
roiValues{ r, 2 } = thisLabelInstanceS.ROIOrder;
end 
elseif ( labelShape_lbl == labelType.ProjectedCuboid )
roiValues = zeros( numROIs_label_lbl, 8 );
for r = 1:numROIs_label_lbl
thisLabelInstanceS = thisFramesLabel_lbl( r );
roiValues( r, 1:8 ) = thisLabelInstanceS.Position;
end 
elseif ( labelShape_lbl == labelType.Rectangle ) &&  ...
this.SignalType == vision.labeler.loading.SignalType.PointCloud
roiValues = zeros( numROIs_label_lbl, 9 );
for r = 1:numROIs_label_lbl
thisLabelInstanceS = thisFramesLabel_lbl( r );
roiValues( r, 1:9 ) = thisLabelInstanceS.Position;
end 
else 
assert( false, 'ROIAnnotationSet: unknown labelType.' );
end 
end 
thisFramesOrigAnnoS.( label_lbl ) = roiValues;
end 
newS( frameIdx ) = thisFramesOrigAnnoS;
end 
end 


function tf = hasPixelAnnotation( this )
tf = isfield( this.AnnotationStruct_, 'PixelLabelData' );
end 


function newS = formatAnnotationStruct( this )
if hasAnyAttribDefinition( this ) || hasSublabels( this )
newS = formatAnnotationStructForAll( this );
newS = convertCellToStruct( this, newS );
else 
newS = formatAnnotationStructForLabelOnly( this );
end 
end 







function replace( this, indices, varargin )



if nargin > 2
[ currentIndex, labelNames, sublabelNames,  ...
labelUIDs, sublabelUIDs, positions ] = deal( varargin{ : } );
assert( all( cellfun( @isempty, sublabelNames ) ) );
end 



fieldNames = fieldnames( this.AnnotationStruct_ );
annStruct = cell2struct( cell( size( fieldNames ) ), fieldNames, 1 );



hasAttribute = this.hasAttributeDef(  );
if hasAttribute
sAttrib = { this.AnnotationStruct_( indices ).( this.ATTRIB_NS ) };
end 






this.AnnotationStruct_( indices ) = repmat( annStruct, size( indices ) );
if hasAttribute
for i = 1:length( indices )
this.AnnotationStruct_( indices( i ) ).( this.ATTRIB_NS ) = sAttrib{ i };
end 
end 

if nargin > 2
if ~iscell( labelNames )
labelNames = { labelNames };
end 
if ~iscell( sublabelNames )
sublabelNames = { sublabelNames };
end 
if ~iscell( labelUIDs )
labelUIDs = { labelUIDs };
end 
if ~iscell( sublabelUIDs )
sublabelUIDs = { sublabelUIDs };
end 

doAppend = false;
isPixelLabel = ~isempty( positions ) && ( ischar( positions{ 1 } ) || isstring( positions{ 1 } ) );
addAnnotation( this, currentIndex, doAppend, isPixelLabel, labelNames, sublabelNames, labelUIDs, sublabelUIDs, positions );
end 
end 










function mergeWithCache( this, indices, varargin )

ATTRIB_NAME_SPACE = this.ATTRIB_NS;


newAnnotationsInterval = this.AnnotationStruct_( indices );

uncache( this );





hasAttribDef = isfield( this.AnnotationStruct_, this.ATTRIB_NS );
if hasAttribDef
for i = 1:numel( indices )
idx = indices( i );
this.AnnotationStruct_( idx ).( ATTRIB_NAME_SPACE ) = newAnnotationsInterval( i ).( ATTRIB_NAME_SPACE );
end 
end 







fieldNames = excludeAttribNameSpace( this, fieldnames( this.AnnotationStruct_ ) );

if nargin < 3


for idx = 1:numel( indices )

oldAnnotations = this.AnnotationStruct_( indices( idx ) );
newAnnotations = newAnnotationsInterval( idx );

for n = 1:numel( fieldNames )
fName = fieldNames{ n };
if ~strcmp( fName, 'PixelLabelData' )


oldAnnotations = mergeLabelInfoInAnnotationS( this, oldAnnotations, fName, newAnnotations.( fName ) );
end 
end 
this.AnnotationStruct_( indices( idx ) ) = oldAnnotations;
end 
else 
unimportedROIs = varargin{ 1 };


mergedAnnoS_i1 = this.AnnotationStruct_( indices( 1 ) );

for n = 1:numel( unimportedROIs )
labelID = unimportedROIs( n ).ID;
labelName = unimportedROIs( n ).Label;
labelPos = unimportedROIs( n ).Position;
parentUID = unimportedROIs( n ).ParentUID;

if isempty( parentUID )
S_loc_id.Position = labelPos;
S_loc_id.LabelUIDs = labelID;
mergedAnnoS_i1 = mergeLabelInfoInAnnotationS( this, mergedAnnoS_i1, labelName, S_loc_id );






else 


end 
end 



newAnnotations = newAnnotationsInterval( 1 );
for n = 1:numel( fieldNames )
labelName = fieldNames{ n };
if ~strcmp( labelName, 'PixelLabelData' )
mergedAnnoS_i1 = mergeLabelInfoInAnnotationS( this, mergedAnnoS_i1, labelName, newAnnotations.( labelName ) );



if ( isfield( mergedAnnoS_i1, labelName ) &&  ...
isfield( mergedAnnoS_i1.( labelName ), 'Position' ) )
this.FrameHasAnnotations( indices( 1 ) ) = true;
end 
end 
end 
this.AnnotationStruct_( indices( 1 ) ) = mergedAnnoS_i1;


for idx = 2:numel( indices )

mergedAnnoS_ii = this.AnnotationStruct_( indices( idx ) );
newAnnotations = newAnnotationsInterval( idx );

for n = 1:numel( fieldNames )
labelName = fieldNames{ n };
if ~strcmp( labelName, 'PixelLabelData' )
mergedAnnoS_ii = mergeLabelInfoInAnnotationS( this, mergedAnnoS_ii, labelName, newAnnotations.( labelName ) );



if ( isfield( mergedAnnoS_ii, labelName ) &&  ...
isfield( mergedAnnoS_ii.( labelName ), 'Position' ) )
this.FrameHasAnnotations( indices( idx ) ) = true;
end 




end 
end 
this.AnnotationStruct_( indices( idx ) ) = mergedAnnoS_ii;
end 

end 
end 


function structOut = labelStruct2OrderedROIStruct( this, structIn )

numStructs = numel( structIn );

for i = 1:numStructs
currentStruct = structIn( i );
currentFields = fields( currentStruct );

currentROILabelStruct.ROILabelData = [  ];

for j = 1:numel( currentFields )

if ( strcmp( currentFields{ j }, 'PixelLabelData' ) )
currentROILabelStruct.PixelLabelData = currentStruct.PixelLabelData;
continue ;
end 
currentType = this.queryLabelShapeFromName( currentFields{ j } );

roidata = currentStruct.( currentFields{ j } );

if ( isstruct( roidata ) )
roidata = roidata';
if ( isempty( roidata ) )
roidata = { roidata };
end 
end 
if ( ~iscell( roidata ) )
roidata = mat2cell( roidata, ones( 1, size( roidata, 1 ) ), size( roidata, 2 ) );
end 

outLabels = repmat( currentFields( j ), size( roidata, 1 ), 1 );
data = [ roidata, outLabels ];

switch currentType
case labelType.Rectangle
outFieldName = 'RectangleData';
case labelType.Line
outFieldName = 'LineData';
case labelType.Polygon
outFieldName = 'PolygonData';
case labelType.ProjectedCuboid
outFieldName = 'ProjCuboidData';
case labelType.Custom
outFieldName = 'CustomData';
otherwise 
assert( false, 'Unsupported Label Type' );
end 

if ( isfield( currentROILabelStruct.ROILabelData, outFieldName ) )
existingData = currentROILabelStruct.ROILabelData.( outFieldName );
currentROILabelStruct.ROILabelData.( outFieldName ) = [ existingData;data ];
else 
currentROILabelStruct.ROILabelData.( outFieldName ) = data;
end 
end 





if ( ~isempty( currentROILabelStruct.ROILabelData ) )
roiStructFieldNames = fieldnames( currentROILabelStruct.ROILabelData );

for fIdx = 1:numel( roiStructFieldNames )

data = currentROILabelStruct.ROILabelData.( roiStructFieldNames{ fIdx } );

if ( strcmp( roiStructFieldNames{ fIdx }, 'PolygonData' ) )
if ( ~isempty( data ) )

if ( ( this.hasAnyAttribDefinition ) || ( this.hasSublabels ) )
order = cellfun( @( x )getROIOrder( x ), data( :, 1 ), 'UniformOutput', false );
[ ~, Idx ] = sort( cell2mat( order ), 'descend' );
if ( ~isempty( Idx ) )
data = data( Idx, : );
end 
else 
rois = data( :, 1 );
order = data( :, 2 );
labels = data( :, 3 );

[ ~, Idx ] = sort( cell2mat( order ), 'descend' );
data = [ rois( Idx, : ), labels( Idx, : ) ];
end 

end 
end 

if ( ( this.hasAnyAttribDefinition ) || ( this.hasSublabels ) )
data( :, 1 ) = cellfun( @( x )rmfield( x, 'ROIOrder' ), data( :, 1 ), 'UniformOutput', false );
end 
currentROILabelStruct.ROILabelData.( roiStructFieldNames{ fIdx } ) = data;
end 
end 
structOut( i ) = currentROILabelStruct;%#ok<AGROW>
end 


function ord = getROIOrder( dataIn )
if ( isempty( dataIn ) )
ord =  - 1;
else 
ord = dataIn.ROIOrder;
end 
end 

end 


function structIn = dropPolygonROIOrder( this, structIn )

numStructs = numel( structIn );

for i = 1:numStructs
currentStruct = structIn( i );
currentFields = fields( currentStruct );



pixelIdx = cellfun( @( x )strcmp( x, 'PixelLabelData' ), currentFields );

currentFields( pixelIdx ) = [  ];
polygonType = cellfun( @( x )( this.queryLabelShapeFromName( x ) == labelType.Polygon ), currentFields );

for j = 1:numel( currentFields )

if ( isstruct( currentStruct.( currentFields{ j } ) ) )


if ( isfield( structIn( i ).( currentFields{ j } ), 'ROIOrder' ) )
structIn( i ).( currentFields{ j } ) =  ...
rmfield( structIn( i ).( currentFields{ j } ), 'ROIOrder' );
end 
else 


if ( polygonType( j ) )
if ( isempty( structIn( i ).( currentFields{ j } ) ) )
continue ;
end 
structIn( i ).( currentFields{ j } ) = structIn( i ).( currentFields{ j } )( :, 1 );
end 
end 
end 
end 
end 

end 

methods ( Access = protected )


function initialize( this, numImages )



labelSet = this.LabelSet;
subLabelSet = this.SublabelSet;
attributeSet = this.AttributeSet;


this.AnnotationStruct_ = struct(  );


for n = 1:labelSet.NumLabels
labelDef = labelSet.DefinitionStruct( n );
if labelDef.Type ~= labelType.PixelLabel
labelName = labelDef.Name;
this.AnnotationStruct_( end  ).( labelName ) = [  ];
end 
end 


for n = 1:subLabelSet.NumSublabels
sublabelDef = subLabelSet.DefinitionStruct( n );
if sublabelDef.Type ~= labelType.PixelLabel

labelName = sublabelDef.LabelName;
sublabelName = sublabelDef.Name;
this.AnnotationStruct_( end  ).( labelName ).( sublabelName ) = [  ];
end 
end 


ATTRIB_NAME_SPACE = this.ATTRIB_NS;
for n = 1:attributeSet.NumAttributes
attribDef = attributeSet.DefinitionStruct( n );
labelName = attribDef.LabelName;
sublabelName = attribDef.SublabelName;
attributeName = attribDef.Name;
if isempty( sublabelName )
this.AnnotationStruct_( end  ).( ATTRIB_NAME_SPACE ).( labelName ).( attributeName ) = [  ];
else 
this.AnnotationStruct_( end  ).( ATTRIB_NAME_SPACE ).( labelName ).( sublabelName ).( attributeName ) = [  ];
end 
end 

if nargin > 1
this.NumImages = numImages;
this.AnnotationStruct_ = repmat( this.AnnotationStruct_, numImages, 1 );
this.FrameHasAnnotations = false( numImages, 1 );
else 
this.NumImages = 0;
this.FrameHasAnnotations = false;
end 
end 
end 

methods ( Access = private )

function createDefaultAnnotationStruct( this )

ATTRIB_NAME_SPACE = this.ATTRIB_NS;

for n = 1:this.LabelSet.NumLabels
labelDef = this.LabelSet.DefinitionStruct( n );
if labelDef.Type ~= labelType.PixelLabel
labelName = labelDef.Name;
this.AnnotationStruct_( end  ).( labelName ) = [  ];
end 
end 


for n = 1:this.SublabelSet.NumSublabels
sublabelDef = this.SublabelSet.DefinitionStruct( n );
if sublabelDef.Type ~= labelType.PixelLabel

labelName = sublabelDef.LabelName;
sublabelName = sublabelDef.Name;
this.AnnotationStruct_( end  ).( labelName ).( sublabelName ) = [  ];
end 
end 


for n = 1:this.AttributeSet.NumAttributes
attribDef = this.AttributeSet.DefinitionStruct( n );
labelName = attribDef.LabelName;
sublabelName = attribDef.SublabelName;
attributeName = attribDef.Name;
if isempty( sublabelName )
this.AnnotationStruct_( end  ).( ATTRIB_NAME_SPACE ).( labelName ).( attributeName ) = [  ];
else 
this.AnnotationStruct_( end  ).( ATTRIB_NAME_SPACE ).( labelName ).( sublabelName ).( attributeName ) = [  ];
end 
end 


this.AnnotationStruct_ = repmat( this.AnnotationStruct_, this.NumImages, 1 );
this.FrameHasAnnotations = false( this.NumImages, 1 );
end 


function s = resetAnnotationStruct( this, s )
allLabelNames = fieldnames( s );
for lInx = 1:numel( allLabelNames )
label = allLabelNames{ lInx };
if ~strcmp( label, 'PixelLabelData' )
if isfield( s.( label ), 'Position' )
allSublabelNames = getSublabelNames( this, s.( label )( 1 ) );
s.( label ) = [  ];
s.( label ) = [  ];
for slInx = 1:numel( allSublabelNames )
sublabel = allSublabelNames{ slInx };
s.( label ).( sublabel ) = [  ];
end 
end 
end 
end 
end 


function sublabelNames = getSublabelNames( ~, labelAnnoStrct )







sublabelNames = {  };
field_names = fieldnames( labelAnnoStrct );
for i = 1:length( field_names )
thisField = field_names{ i };
if isfield( labelAnnoStrct.( thisField ), 'Position' )
sublabelNames{ end  + 1 } = thisField;%#ok<AGROW>
end 
end 
end 



function s = appendLabelToStruct( this, s, labelName, labelUID, labelPos, labelOrder )

labelSet = this.LabelSet;

labelID = labelSet.labelNameToID( labelName );
labelShape = labelSet.queryLabelShape( labelID );

numLabelROIs = getNumLabelROIsInAnnotation( s, labelName );

order = getNumROIsInAnnotation( s ) + 1;
idx = numLabelROIs + 1;
switch labelShape
case { labelType.Line, labelType.Rectangle, labelType.Polygon, labelType.ProjectedCuboid }
if iscell( labelPos )
labelPos = labelPos{ 1 };
end 
s.( labelName )( idx ).Position = labelPos;
s.( labelName )( idx ).LabelUIDs = labelUID;
s.( labelName )( idx ).ROIOrder = order;
case labelType.PixelLabel

otherwise 
error( 'Unhandled Case' );
end 
end 


function defVal = getAttributeDefaultValue( ~, attribData )
if ( attribData.Type == attributeType.List )
defVal = attribData.Value{ 1 };
else 
defVal = attribData.Value;
end 
end 


function s = updateAttributeOfLabelIfNotYetSet( this, s, labelName, roiUID )

attributeSet = this.AttributeSet;
roiAttributeFamily = attributeSet.queryAttributeFamily( labelName, '' );
ATTRIB_NAME_SPACE = this.ATTRIB_NS;

for i = 1:numel( roiAttributeFamily )
attributeName = roiAttributeFamily{ i }.Name;
if isempty( s.( ATTRIB_NAME_SPACE ) ) ||  ...
~isfield( s.( ATTRIB_NAME_SPACE ), labelName ) ||  ...
isempty( s.( ATTRIB_NAME_SPACE ).( labelName ) ) ||  ...
~( isfield( s.( ATTRIB_NAME_SPACE ).( labelName ), attributeName ) )
matchingAttribCellID = [  ];
nextAttribCellID = 1;
else 
matchingAttribCellID = getMatchingAttribCellID( this, s.( ATTRIB_NAME_SPACE ).( labelName ).( attributeName ), roiUID, true );
nextAttribCellID = numel( s.( ATTRIB_NAME_SPACE ).( labelName ).( attributeName ) ) + 1;
end 
if isempty( matchingAttribCellID )
attributeDefValue = getAttributeDefaultValue( this, roiAttributeFamily{ i } );
s.( ATTRIB_NAME_SPACE ).( labelName ).( attributeName )( nextAttribCellID ).AttributeValues = attributeDefValue;
s.( ATTRIB_NAME_SPACE ).( labelName ).( attributeName )( nextAttribCellID ).LabelUIDs = roiUID;
end 
end 
end 


function s = appendSublabelToStruct( this, s, labelName, sublabelName, labelUID, sublabelUID, sublabelPos )



sublabelID = this.SublabelSet.sublabelNameToID( labelName, sublabelName );
sublabelShape = this.SublabelSet.querySublabelShape( sublabelID );

matchingLabelCellID = getMatchingLabelCellID( this, s, labelName, labelUID );
numSublabelROIs = getNumSublabelROIsInAnnotation( s, labelName, sublabelName, matchingLabelCellID );
idx = numSublabelROIs + 1;
switch sublabelShape
case { labelType.Rectangle, labelType.Line, labelType.ProjectedCuboid, labelType.Polygon }





if iscell( sublabelUID )
error( 'Unhandled Case' );
end 

if ( ( matchingLabelCellID > 0 ) && ( numel( s.( labelName ) ) >= matchingLabelCellID ) )
s.( labelName )( matchingLabelCellID ).( sublabelName )( idx ).Position = sublabelPos;
s.( labelName )( matchingLabelCellID ).( sublabelName )( idx ).SublabelUIDs = sublabelUID;
else 
error( 'Unhandled Case' );
end 

case labelType.PixelLabel

otherwise 
error( 'Unhandled Case' );
end 
end 


function s = updateAttributeOfSubabelIfNotYetSet( this, s, labelName, sublabelName, roiUID )

attributeSet = this.AttributeSet;
roiAttributeFamily = attributeSet.queryAttributeFamily( labelName, sublabelName );
ATTRIB_NAME_SPACE = this.ATTRIB_NS;

for i = 1:numel( roiAttributeFamily )
attributeName = roiAttributeFamily{ i }.Name;
matchingAttribCellID = getMatchingAttribCellID( this, s.( ATTRIB_NAME_SPACE ).( labelName ).( sublabelName ).( attributeName ), roiUID, false );
if isempty( matchingAttribCellID )
nextAttribCellID = numel( s.( ATTRIB_NAME_SPACE ).( labelName ).( sublabelName ).( attributeName ) ) + 1;
attributeDefValue = getAttributeDefaultValue( this, roiAttributeFamily{ i } );
s.( ATTRIB_NAME_SPACE ).( labelName ).( sublabelName ).( attributeName )( nextAttribCellID ).AttributeValues = attributeDefValue;
s.( ATTRIB_NAME_SPACE ).( labelName ).( sublabelName ).( attributeName )( nextAttribCellID ).SublabelUIDs = roiUID;
end 
end 
end 


function matchingAttribCellID = getMatchingAttribCellID( ~, labelSublabelAttribStruct, roiUID, isLabel )

matchingAttribCellID = [  ];
for i = 1:numel( labelSublabelAttribStruct )
if isLabel
thisROIUID = labelSublabelAttribStruct( i ).LabelUIDs;
else 
thisROIUID = labelSublabelAttribStruct( i ).SublabelUIDs;
end 
if ~isempty( thisROIUID ) && ( strcmp( thisROIUID, roiUID ) )
matchingAttribCellID = i;
return ;
end 
end 
end 



function [ hasAttribValue, atribVal ] = getAttribValueInfo( ~, matchingAttribCellID, labelSublabelAttribStruct )
hasAttribValue = false;
atribVal = [  ];
if ~isempty( labelSublabelAttribStruct )
hasAttribValue = true;
atribVal = labelSublabelAttribStruct( matchingAttribCellID ).AttributeValues;
end 

end 


function defVal = getDefaultValue( ~, attribDefData )
if attribDefData.Type == attributeType.List
defVal = 1;
else 
defVal = attribDefData.Value;
end 
end 


function matchingLabelCellID = getMatchingLabelCellID( ~, s, labelName, parentUID )

numLabelROIs = getNumLabelROIsInAnnotation( s, labelName );
labelS = s.( labelName );

for i = 1:numLabelROIs
if strcmp( labelS( i ).LabelUIDs, parentUID )
matchingLabelCellID = i;
return ;
end 
end 
matchingLabelCellID =  - 1;
end 


function matchingOrNextAttribCellID = getMatchingOrNextAttribCellID( this, labelSublabelAttribStruct, roiUID, isLabel )

matchingOrNextAttribCellID = getMatchingAttribCellID( this, labelSublabelAttribStruct, roiUID, isLabel );
if isempty( matchingOrNextAttribCellID )
matchingOrNextAttribCellID = numel( labelSublabelAttribStruct ) + 1;
end 
end 


function [ attribNames, attribValues ] = getAttribInfoForLabels( ~, attribs, labelUID )
f = fieldnames( attribs );
attribNames = {  };
attribValues = {  };

for i = 1:numel( f )
thisF = f{ i };
if isfield( attribs.( thisF ), 'AttributeValues' ) && isfield( attribs.( thisF ), 'LabelUIDs' )
attribNames{ end  + 1 } = thisF;%#ok<AGROW>
labelUIDs4Attrib = { attribs.( thisF ).LabelUIDs };
matchIdx = find( contains( labelUIDs4Attrib, labelUID ) );
if isempty( matchIdx )
attribValues{ end  + 1 } = [  ];%#ok<AGROW>
else 
attribValues{ end  + 1 } = attribs.( thisF )( matchIdx ).AttributeValues;%#ok<AGROW>
end 
end 
end 
end 


function resetHierarchyValues( this, index, labelName )
fieldNames = fields( this.AnnotationStruct_( index ).( labelName ) );

for i = 1:length( fieldNames )

if ~isValueField( fieldNames )
this.AnnotationStruct_( index ).( labelName ).Position = [  ];
end 
end 
end 



function TF = hasSublabels( this )
TF = this.SublabelSet.hasSublabels(  );
end 


function TF = hasAnyAttribDefinition( this )
TF = isfield( this.AnnotationStruct_, this.ATTRIB_NS );
end 


function outS = convertCellToStruct( this, inS )

emptyS = createEmptyStructWithDefault( this );
outS = copyCellStructToNonCell( this, inS, emptyS );
end 


function outStruct = copyCellStructToNonCell( this, inStruct, emptyStruct )

outStruct = emptyStruct;


if isfield( inStruct, 'PixelLabelData' )
for frameIdx = 1:numel( inStruct )
outStruct( frameIdx ).PixelLabelData = inStruct( frameIdx ).PixelLabelData;
end 
end 


labelDefs = getLabelDefInfo( this );
if this.isPointCloudSignal
[ labelNames, ~ ] = getSupportedLabelNamesForSignal( this, labelDefs.labelNames );
else 
labelNames = labelDefs.labelNames;
end 
isPixelLabelFlag = labelDefs.isPixelLabelFlag;
labelAttribList = labelDefs.labelAttribList;
sublabelList = labelDefs.sublabelList;
sublabelAttribList = labelDefs.sublabelAttribList;




numImages = this.NumImages;
for frameIdx = 1:numImages


if ~this.FrameHasAnnotations( frameIdx )
continue ;
end 

for labelIdx = 1:numel( labelNames )


if isPixelLabelFlag( labelIdx )
continue ;
end 

labelName = labelNames{ labelIdx };

labelInstanceID = numel( outStruct( frameIdx ).( labelName ) ) + 1;


if isfield( inStruct( frameIdx ), labelName ) &&  ...
( numel( inStruct( frameIdx ).( labelName ) ) >= labelInstanceID ) &&  ...
isfield( inStruct( frameIdx ).( labelName ){ labelInstanceID }, 'Position' )

for labelInstanceIdx = 1:numel( inStruct( frameIdx ).( labelName ) )

assert( isfield( inStruct( frameIdx ).( labelName ){ labelInstanceIdx }, 'Position' ) );


outStruct( frameIdx ).( labelName )( labelInstanceID ).Position = inStruct( frameIdx ).( labelName ){ labelInstanceIdx }.Position;
if ( isfield( inStruct( frameIdx ).( labelName ){ labelInstanceIdx }, 'ROIOrder' ) )
outStruct( frameIdx ).( labelName )( labelInstanceID ).ROIOrder = inStruct( frameIdx ).( labelName ){ labelInstanceIdx }.ROIOrder;
end 

labelAttribs = labelAttribList{ labelIdx };

for attribIdx = 1:numel( labelAttribs )
attributeName = labelAttribs{ attribIdx }.Name;
if isfield( inStruct( frameIdx ).( labelName ){ labelInstanceIdx }, attributeName )
attribInstanceVal = inStruct( frameIdx ).( labelName ){ labelInstanceIdx }.( attributeName );
outStruct( frameIdx ).( labelName )( labelInstanceID ).( attributeName ) = attribInstanceVal;
end 
end 

sublabelNames = sublabelList{ labelIdx };

for sublabelIdx = 1:numel( sublabelNames )
sublabelName = sublabelNames{ sublabelIdx };


sublabelInstanceID = numel( outStruct( frameIdx ).( labelName )( labelInstanceID ).( sublabelName ) ) + 1;

if isfield( inStruct( frameIdx ).( labelName ){ labelInstanceID }, sublabelName ) &&  ...
numel( inStruct( frameIdx ).( labelName ){ labelInstanceID }.( sublabelName ) ) >= sublabelInstanceID &&  ...
isfield( inStruct( frameIdx ).( labelName ){ labelInstanceID }.( sublabelName ){ sublabelInstanceID }, 'Position' )

for sublabelInstanceIdx = 1:numel( inStruct( frameIdx ).( labelName ){ labelInstanceIdx }.( sublabelName ) )
assert( isfield( inStruct( frameIdx ).( labelName ){ labelInstanceIdx }.( sublabelName ){ sublabelInstanceIdx }, 'Position' ) );

outStruct( frameIdx ).( labelName )( labelInstanceID ).( sublabelName )( sublabelInstanceID ).Position =  ...
inStruct( frameIdx ).( labelName ){ labelInstanceIdx }.( sublabelName ){ sublabelInstanceIdx }.Position;

sublabelAttribs = sublabelAttribList{ labelIdx }{ sublabelIdx };
for sublabelAttrIdx = 1:numel( sublabelAttribs )
attributeName = sublabelAttribs{ sublabelAttrIdx }.Name;
if isfield( inStruct( frameIdx ).( labelName ){ labelInstanceIdx }.( sublabelName ){ sublabelInstanceIdx }, attributeName )
attribInstanceVal = inStruct( frameIdx ).( labelName ){ labelInstanceIdx }.( sublabelName ){ sublabelInstanceIdx }.( attributeName );
outStruct( frameIdx ).( labelName )( labelInstanceID ).( sublabelName )( sublabelInstanceID ).( attributeName ) = attribInstanceVal;
end 
end 
sublabelInstanceID = sublabelInstanceID + 1;
end 
else 


end 
end 
labelInstanceID = labelInstanceID + 1;
end 
end 
end 
end 
end 


function outStruct = createEmptyStructWithDefault( this )


labelDefs = getLabelDefInfo( this );
if this.isPointCloudSignal
[ labelNames, ~ ] = getSupportedLabelNamesForSignal( this, labelDefs.labelNames );
else 
labelNames = labelDefs.labelNames;
end 
isPixelLabelFlag = labelDefs.isPixelLabelFlag;
labelAttribList = labelDefs.labelAttribList;
sublabelList = labelDefs.sublabelList;
sublabelAttribList = labelDefs.sublabelAttribList;




numImages = this.NumImages;
structTemplate = struct(  );


for labelIdx = 1:numel( labelNames )


if isPixelLabelFlag( labelIdx )
continue ;
end 

thisLabelName = labelNames{ labelIdx };

labelStruct = [  ];
labelStruct.Position = [  ];
labelStruct.ROIOrder = [  ];


labelAttribs = labelAttribList{ labelIdx };
for attribIdx = 1:numel( labelAttribs )
attributeName = labelAttribs{ attribIdx }.Name;
labelStruct.( attributeName ) = getAttributeDefaultValue( this, labelAttribs{ attribIdx } );
end 


sublabelNames = sublabelList{ labelIdx };
for sublabelIdx = 1:numel( sublabelNames )
sublabelName = sublabelNames{ sublabelIdx };
labelStruct.( sublabelName ).Position = [  ];
sublabelAttribs = sublabelAttribList{ labelIdx }{ sublabelIdx };


for sublabelAttrIdx = 1:numel( sublabelAttribs )
attributeName = sublabelAttribs{ sublabelAttrIdx }.Name;
labelStruct.( sublabelName ).( attributeName ) = getAttributeDefaultValue( this, sublabelAttribs{ sublabelAttrIdx } );
end 
end 
structTemplate.( thisLabelName ) = repmat( labelStruct, [ 1, 0 ] );
end 


outStruct = repmat( structTemplate, [ 1, numImages ] );
end 


function labelDefs = getLabelDefInfo( this )

labelNames = queryLabelNamesFromDef( this );

isPixelLabelFlag = false( 1, numel( labelNames ) );
labelAttribList = cell( 1, numel( labelNames ) );
sublabelList = cell( 1, numel( labelNames ) );
sublabelAttribList = cell( 1, numel( labelNames ) );

for labelIdx = 1:numel( labelNames )
thisLabelName = labelNames{ labelIdx };

if isPixelLabel( this, thisLabelName )
isPixelLabelFlag( labelIdx ) = true;
else 

labelAttribList{ labelIdx } = queryLabelAttributesFromDef( this, thisLabelName );

sublabelList{ labelIdx } = querySublabelNamesFromDef( this, thisLabelName );

thisSublabelList = sublabelList{ labelIdx };
sublabelAttribList{ labelIdx } = cell( 1, numel( thisSublabelList ) );
for sublabelIdx = 1:numel( thisSublabelList )
sublabelAttribList{ labelIdx }{ sublabelIdx } =  ...
querySublabelAttributesFromDef( this, thisLabelName, thisSublabelList{ sublabelIdx } );
end 
end 
end 

labelDefs = struct(  );
labelDefs.labelNames = labelNames;
labelDefs.isPixelLabelFlag = isPixelLabelFlag;
labelDefs.labelAttribList = labelAttribList;
labelDefs.sublabelList = sublabelList;
labelDefs.sublabelAttribList = sublabelAttribList;
end 


function labelNames = queryLabelNamesFromDef( this )
labelNames = { this.LabelSet.DefinitionStruct.Name };
end 


function TF = isPixelLabel( this, labelName )
labelID = this.LabelSet.labelNameToID( labelName );
TF = this.LabelSet.isPixelLabel( labelID );
end 


function sublabelNames = querySublabelNamesFromDef( this, labelName )
sublabelNames = this.SublabelSet.querySublabelNames( labelName );
end 


function attribDefData = queryLabelAttributesFromDef( this, labelName )
attribDefData = this.AttributeSet.queryAttributeFamily( labelName, '' );
end 


function attribDefData = querySublabelAttributesFromDef( this, labelName, sublabelName )
attribDefData = this.AttributeSet.queryAttributeFamily( labelName, sublabelName );
end 


function newS = formatAnnotationStructForAll( this )

numImages = this.NumImages;
[ newS, hasAnyAttribDef ] = removeAttribFromAnnotationStruct( this );

labelNames = fieldnames( newS( 1 ) );
labelNames = excludePixelLabelData( labelNames );

[ labelNames, unsuppLabelNames ] = getSupportedLabelNamesForSignal( this, labelNames );

newS = rmfield( newS, unsuppLabelNames );

for frameIdx = 1:numImages
thisFramesOrigAnnoS = newS( frameIdx );


if ~this.FrameHasAnnotations( frameIdx )
continue ;
end 

for lbl = 1:numel( labelNames )
label_lbl = labelNames{ lbl };
thisFramesLabel_lbl = thisFramesOrigAnnoS.( label_lbl );
numROIs_label_lbl = numel( thisFramesLabel_lbl );
thisLabelS = [  ];

for r = 1:numROIs_label_lbl
thisLabelInstanceS = thisFramesLabel_lbl( r );
thisLabelIntsanceS_orig = thisFramesLabel_lbl( r );
if ~isstruct( thisLabelInstanceS )

continue ;
end 
thisLabelInstanceS = appendAttributeToThisLabelInstance( this,  ...
thisLabelInstanceS, label_lbl, frameIdx,  ...
hasAnyAttribDef );

sublabelNames = fieldnames( thisFramesOrigAnnoS.( label_lbl ) );

for slbl = 1:numel( sublabelNames )
sublabel_slbl = sublabelNames{ slbl };
if ~isfield( thisLabelIntsanceS_orig, sublabel_slbl )
continue ;
end 

thisFramesSublabel_slbl = thisLabelIntsanceS_orig.( sublabel_slbl );
if ~isstruct( thisFramesSublabel_slbl )
continue ;
end 
numROIs_sublabel_slbl = numel( thisFramesSublabel_slbl );


for rr = 1:numROIs_sublabel_slbl
thisSublabelIntsanceS = thisFramesSublabel_slbl( rr );
if ~isstruct( thisSublabelIntsanceS )
continue ;
end 
thisSublabelIntsanceS = appendAttributeToThisSublabelInstance( this, thisSublabelIntsanceS, label_lbl, sublabel_slbl, frameIdx, hasAnyAttribDef );

if ~isfield( thisLabelInstanceS, sublabel_slbl ) || isempty( thisLabelInstanceS.( sublabel_slbl ) )
thisLabelInstanceS.( sublabel_slbl ){ 1 } = thisSublabelIntsanceS;
else 
thisLabelInstanceS.( sublabel_slbl ){ end  + 1 } = thisSublabelIntsanceS;
end 
end 
end 
if isempty( thisLabelS )
thisLabelS{ 1 } = thisLabelInstanceS;
else 
thisLabelS{ end  + 1 } = thisLabelInstanceS;%#ok<AGROW>
end 
end 

if iscell( thisLabelS ) && ( numel( thisLabelS ) == 1 ) && isempty( thisLabelS{ 1 } )
thisLabelS = [  ];
end 
thisFramesOrigAnnoS.( label_lbl ) = thisLabelS;
end 
newS( frameIdx ) = thisFramesOrigAnnoS;
end 

end 


function outLabelIntsanceS = appendAttributeToThisLabelInstance( this,  ...
thisLabelIntsanceS, labelName, frameIdx, hasAnyAttribDef )

if isfield( thisLabelIntsanceS, 'Position' )
outLabelIntsanceS.Position = thisLabelIntsanceS.Position;
if isfield( thisLabelIntsanceS, 'ROIOrder' )
outLabelIntsanceS.ROIOrder = thisLabelIntsanceS.ROIOrder;
end 
else 
outLabelIntsanceS = [  ];
end 
if hasAnyAttribDef
if isfield( thisLabelIntsanceS, 'LabelUIDs' )
roiUID = thisLabelIntsanceS.LabelUIDs;
else 
roiUID = '';
end 
[ hasThisAttrib, attribNames, attribVals ] = getAttributeDataForThisLabelROI(  ...
this, labelName, roiUID, frameIdx );
if hasThisAttrib
for i = 1:numel( attribNames )
outLabelIntsanceS.( attribNames{ i } ) = attribVals{ i };
end 
end 
end 
end 


function TF = hasAttributeDef( this )
s = this.AnnotationStruct_( 1 );
TF = isfield( s, this.ATTRIB_NS );
end 


function outCell = excludeAttribNameSpace( this, inCell )
outCell = inCell;
matchIdx = contains( inCell, this.ATTRIB_NS );
outCell( matchIdx ) = [  ];
end 



function matchingOrNextLabelCellID = getMatchingOrNextLabelCellID( ~, labelUIDs, labelUID )

matchingOrNextLabelCellID = find( contains( labelUIDs, labelUID ) );
if isempty( matchingOrNextLabelCellID )
matchingOrNextLabelCellID = numel( labelUIDs ) + 1;
end 
end 


function mergedAnnoS_ii = mergeLabelInfoInAnnotationS( this, mergedAnnoS_ii, labelName, S_loc_id )
for j = 1:numel( S_loc_id )
labelPos = S_loc_id( j ).Position;
labelID = S_loc_id( j ).LabelUIDs;
if ( isfield( mergedAnnoS_ii, labelName ) &&  ...
isfield( mergedAnnoS_ii.( labelName ), 'Position' ) )
matchingOrNextLabelCellID = getMatchingOrNextLabelCellID( this, { mergedAnnoS_ii.( labelName ).LabelUIDs }, labelID );
mergedAnnoS_ii.( labelName )( matchingOrNextLabelCellID ).Position = labelPos;
mergedAnnoS_ii.( labelName )( matchingOrNextLabelCellID ).LabelUIDs = labelID;
mergedAnnoS_ii.( labelName )( matchingOrNextLabelCellID ).ROIOrder =  - 1;
else 
mergedAnnoS_ii.( labelName ).Position = labelPos;
mergedAnnoS_ii.( labelName ).LabelUIDs = labelID;
mergedAnnoS_ii.( labelName ).ROIOrder =  - 1;

end 
end 
end 


function labelShape = queryLabelShapeFromName( this, labelName )
labelID = this.LabelSet.labelNameToID( labelName );
labelShape = this.LabelSet.queryLabelShape( labelID );
end 


function outSublabelIntsanceS = appendAttributeToThisSublabelInstance( this,  ...
thisSublabelIntsanceS, labelName, sublabelName,  ...
frameIdx, hasAnyAttribDef )

outSublabelIntsanceS.Position = thisSublabelIntsanceS.Position;
if hasAnyAttribDef
roiUID = thisSublabelIntsanceS.SublabelUIDs;
[ hasThisAttrib, attribNames, attribVals ] = getAttributeDataForThisSublabelROI(  ...
this, labelName, sublabelName, roiUID, frameIdx );
if hasThisAttrib
for i = 1:numel( attribNames )
outSublabelIntsanceS.( attribNames{ i } ) = attribVals{ i };
end 
end 
end 
end 


function [ supportedLabelNames, unsupportedLabelNames ] = getSupportedLabelNamesForSignal( this, inputLabelNames )
supportedLabelTypes = this.SignalType.getSupportedLabelTypes(  );

if any( supportedLabelTypes == labelType.Cuboid )
supportedLabelTypes( supportedLabelTypes == labelType.Cuboid ) = labelType.Rectangle;
end 

labelNamesInLabelSet = string( { this.LabelSet.DefinitionStruct.Name } );
labelNames = string( inputLabelNames );

indices = ismember( labelNamesInLabelSet, labelNames );
labelTypesInLabelSet = [ this.LabelSet.DefinitionStruct.Type ];

labelTypes = labelTypesInLabelSet( indices );

supportedLabelNames = inputLabelNames( ismember( labelTypes, supportedLabelTypes ) );
unsupportedLabelNames = inputLabelNames( ~ismember( labelTypes, supportedLabelTypes ) );

end 


















end 
end 



function numSublabelROIs = getNumSublabelROIsInAnnotation( s, labelName, sublabelName, matchingLabelCellID )
if isfield( s.( labelName )( matchingLabelCellID ), sublabelName ) &&  ...
isfield( s.( labelName )( matchingLabelCellID ).( sublabelName ), 'Position' )
numSublabelROIs = length( s.( labelName )( matchingLabelCellID ).( sublabelName ) );


if ( numSublabelROIs == 1 ) && isempty( s.( labelName )( matchingLabelCellID ).( sublabelName ).Position )
numSublabelROIs = 0;
else 


for i = 1:numSublabelROIs
assert( ~isempty( s.( labelName )( matchingLabelCellID ).( sublabelName )( i ).Position ) );
end 
end 
else 

numSublabelROIs = 0;
end 
end 


function numLabelROIs = getNumLabelROIsInAnnotation( s, labelName )
if isfield( s.( labelName ), 'Position' )
numLabelROIs = length( s.( labelName ) );

if ( numLabelROIs == 1 ) && isempty( s.( labelName ).Position )
numLabelROIs = 0;
else 


for i = 1:numLabelROIs
assert( ~isempty( s.( labelName )( i ).Position ) );
end 
end 
else 

numLabelROIs = 0;
end 
end 


function numROIs = getNumROIsInAnnotation( s )

fields = fieldnames( s );

numROIs = 0;

for i = 1:numel( fields )
labelName = fields{ i };
if isfield( s.( labelName ), 'Position' )
numLabelROIs = length( s.( labelName ) );

if ( numLabelROIs == 1 ) && isempty( s.( labelName ).Position )
numLabelROIs = 0;
else 


for j = 1:numLabelROIs
assert( ~isempty( s.( labelName )( j ).Position ) );
end 
end 
else 

numLabelROIs = 0;
end 
numROIs = numROIs + numLabelROIs;
end 
end 


function outList = excludePixelLabelData( inList )

idx = strcmp( inList, 'PixelLabelData' );
outList = inList;
outList( idx ) = [  ];

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp7bGWkm.p.
% Please follow local copyright laws when handling this file.

