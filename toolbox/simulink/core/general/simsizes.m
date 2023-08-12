function sys = simsizes( sizesStruct )




























switch nargin, 

case 0, 
sys.NumContStates = 0;
sys.NumDiscStates = 0;
sys.NumOutputs = 0;
sys.NumInputs = 0;
sys.DirFeedthrough = 0;
sys.NumSampleTimes = 0;

case 1, 




if ~isstruct( sizesStruct ), 
sys = sizesStruct;




if length( sys ) < 6, 
DAStudio.error( 'Simulink:util:SimsizesArrayMinSize' );
end 

clear sizesStruct;
sizesStruct.NumContStates = sys( 1 );
sizesStruct.NumDiscStates = sys( 2 );
sizesStruct.NumOutputs = sys( 3 );
sizesStruct.NumInputs = sys( 4 );
sizesStruct.DirFeedthrough = sys( 6 );
if length( sys ) > 6, 
sizesStruct.NumSampleTimes = sys( 7 );
else 
sizesStruct.NumSampleTimes = 0;
end 

else 



sizesFields = fieldnames( sizesStruct );
for i = 1:length( sizesFields ), 
switch ( sizesFields{ i } )
case { 'NumContStates', 'NumDiscStates', 'NumOutputs',  ...
'NumInputs', 'DirFeedthrough', 'NumSampleTimes' }, 

otherwise , 
DAStudio.error( 'Simulink:util:InvalidFieldname', sizesFields{ i } );
end 
end 

sys = [  ...
sizesStruct.NumContStates,  ...
sizesStruct.NumDiscStates,  ...
sizesStruct.NumOutputs,  ...
sizesStruct.NumInputs,  ...
0,  ...
sizesStruct.DirFeedthrough,  ...
sizesStruct.NumSampleTimes ...
 ];
end 

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpfjBgWZ.p.
% Please follow local copyright laws when handling this file.

