%#codegen



function validate(obj)




    coder.allowpcode('plain');
    coder.inline('always');

    coder.internal.assert(~strcmp(obj.DLTargetLib,'cmsis-nn'),'dlcoder_spkg:cnncodegen:DLNetworkNotSupportedForCMSISNN');

    if~strcmp(obj.DLTargetLib,'none')

        coder.internal.assert(coder.internal.is_defined(obj.anchor),'dlcoder_spkg:cnncodegen:DLCoderInternalError');
    end


    coder.extrinsic('coder.internal.getDeepLearningConfig');
    coder.extrinsic('dlcoder_base.internal.checkQuantizedNetworkSimulink');

    ctx=eml_option('CodegenBuildContext');



    if coder.const(~strcmp(obj.DLTargetLib,'disabled'))
        dlConfig=coder.const(@coder.internal.getDeepLearningConfig,ctx,obj.DLTargetLib);
        coder.const(@feval,'coder.internal.coderNetworkUtils.callValidateNetworkImpl',obj.DLTNetwork,dlConfig,obj.NetworkInfo);
    end

    coder.const(@dlcoder_base.internal.checkQuantizedNetworkSimulink,obj.DLTNetwork,ctx);

end
