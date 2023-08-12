function cba = last_clicked_annotation( varargin )



persistent clickedAnnotation;
cba = clickedAnnotation;



if ( ~ishandle( cba ) )
cba = [  ];
end 

if ( nargin > 0 )
clickedAnnotation = varargin{ 1 };
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmps1qJUm.p.
% Please follow local copyright laws when handling this file.

