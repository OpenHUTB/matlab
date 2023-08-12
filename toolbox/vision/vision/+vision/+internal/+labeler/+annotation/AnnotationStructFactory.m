
classdef AnnotationStructFactory < handle

properties 

end 

methods ( Static )
function s = createAnnotationStruct( annotType, signalName, numImages, labelSet, varargin )

if ( annotType == annotationType.ROI )
assert( nargin == 7 );
sublabelSet = varargin{ 1 };
attributeSet = varargin{ 2 };
signalType = varargin{ 3 };
s = vision.internal.labeler.annotation.ROIAnnotationStruct( signalName, numImages, labelSet, sublabelSet, attributeSet, signalType );
elseif ( annotType == annotationType.Frame )
assert( nargin == 4 );
s = vision.internal.labeler.annotation.FrameAnnotationStruct( signalName, numImages, labelSet );
else 
s = [  ];
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpqr2c7o.p.
% Please follow local copyright laws when handling this file.

