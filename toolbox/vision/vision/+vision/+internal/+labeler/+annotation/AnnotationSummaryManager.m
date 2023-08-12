classdef AnnotationSummaryManager < handle

properties 
AnnotationSummaries
NumAnnotationSummaries
SignalNames
CurrentTime
SelectedSignalID
SignalValid
SignalType
end 

properties ( Access = private )
AnnotationSummaryFactoryObj
Session
ROILabelDefs
SceneLabelDefs
end 




methods 

function this = AnnotationSummaryManager( session, currentTime )


this.Session = session;




roiLabelDefs.Names = { session.ROILabelSet.DefinitionStruct.Name };
roiLabelDefs.Colors = { session.ROILabelSet.DefinitionStruct.Color };
roiLabelDefs.Type = { session.ROILabelSet.DefinitionStruct.Type };
this.ROILabelDefs = roiLabelDefs;

sceneLabelDefs.Names = { session.FrameLabelSet.DefinitionStruct.Name };
sceneLabelDefs.Colors = { session.FrameLabelSet.DefinitionStruct.Color };
this.SceneLabelDefs = sceneLabelDefs;
this.CurrentTime = currentTime;


end 

function num = get.NumAnnotationSummaries( this )
num = numel( this.AnnotationSummaries );
end 

function names = get.SignalNames( this )
names = cell( 1, this.NumAnnotationSummaries );
for i = 1:this.NumAnnotationSummaries
names{ i } = this.AnnotationSummaries{ i }.SignalName;
end 
end 

function newAnnotationSummary = createAndAddAnnotationSummary( this,  ...
annotationInfo, selectedSignalId, selectedSignalType,  ...
signalName, isValidRange )

newAnnotationSummary = [  ];

this.SelectedSignalID = selectedSignalId;
this.SignalType = selectedSignalType;
this.SignalValid = isValidRange;


if isNameUnused( this, signalName )
newAnnotationSummary = vision.internal.labeler.annotation.AnnotationSummary( signalName, selectedSignalType,  ...
annotationInfo );

this.AnnotationSummaries{ end  + 1 } = newAnnotationSummary;
end 
end 

end 





methods 




function annotationSummaryObj = getAnnotationSummaryFromId( this, id )
if ( id > 0 ) && ( id <= this.NumAnnotationSummaries )
annotationSummaryObj = this.AnnotationSummaries{ id };
else 
annotationSummaryObj = [  ];
end 
end 

function annotationSummaryObj = getAnnotationSummaryFromIdNoCheck( this, id )
annotationSummaryObj = this.AnnotationSummaries{ id };
end 

function annotationSummaryObj = getAnnotationSummaryFromName( this, signalName )
[ dispExists, dispIdx ] = doesNameExist( this, signalName );
if dispExists
annotationSummaryObj = this.AnnotationSummaries{ dispIdx };
else 
annotationSummaryObj = [  ];
end 
end 

function annotationSummaryObj = getAnnotationSummary( this, nameOrId )
if isnumeric( nameOrId )
dispIdx = nameOrId;
dispExists = ( dispIdx <= this.NumAnnotationSummaries );
else 
signalName = nameOrId;
[ dispExists, dispIdx ] = doesNameExist( this, signalName );
end 

if dispExists
annotationSummaryObj = this.AnnotationSummaries{ dispIdx };
else 
annotationSummaryObj = [  ];
end 
end 

function N = getNumImages( this, signalName )
thisAnnotationSummary = getAnnotationSummary( this, signalName );
N = thisAnnotationSummary.NumImages;
end 

end 

methods 

























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















function tf = isNameUnused( this, signalName )

tf = true;
for i = 1:this.NumAnnotationSummaries
if hasSameName( this.AnnotationSummaries{ i }, signalName )
tf = false;
return ;
end 
end 
end 

function [ tf, dispIdx ] = doesNameExist( this, signalName )

tf = false;
dispIdx = 0;
for i = 1:this.NumAnnotationSummaries
if hasSameName( this.AnnotationSummaries{ i }, signalName )
tf = true;
dispIdx = i;
return ;
end 
end 
end 

end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpCbSSMx.p.
% Please follow local copyright laws when handling this file.

