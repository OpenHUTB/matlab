function codegenOptions = DeepLearningCodegenOptions( nvps )

arguments
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


