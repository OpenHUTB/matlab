





function codegenOptions = DeepLearningCodegenOptions( nvps )

R36
nvps.TargetLibrary( 1, 1 )string
end 

targetLib = lower( nvps.TargetLibrary );


switch targetLib
case 'tensorrt'
codegenOptions = coder.internal.TensorRTDeepLearningCodegenOptions( targetLib );
otherwise 

assert( false );
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpqJ8itS.p.
% Please follow local copyright laws when handling this file.

