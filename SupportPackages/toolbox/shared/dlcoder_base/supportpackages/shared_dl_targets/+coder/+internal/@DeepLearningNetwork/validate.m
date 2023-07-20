%#codegen



function validate(obj)





    coder.allowpcode('plain');
    coder.inline('always');

    if~strcmp(obj.DLTargetLib,'none')

        coder.internal.assert(coder.internal.is_defined(obj.anchor),'dlcoder_spkg:cnncodegen:DLCoderInternalError');
    end



    coder.extrinsic('coder.internal.getDeepLearningConfig');
    coder.extrinsic('dlcoder_base.internal.checkQuantizedNetworkSimulink');
    coder.extrinsic('dlcoder_base.internal.checkSimulinkSupport');

    ctx=eml_option('CodegenBuildContext');

    coder.const(@dlcoder_base.internal.checkSimulinkSupport,obj.DLTargetLib,ctx);



    if coder.const(~strcmp(obj.DLTargetLib,'disabled'))
        dlConfig=coder.const(@coder.internal.getDeepLearningConfig,ctx,obj.DLTargetLib);
        coder.const(@feval,'coder.internal.coderNetworkUtils.callValidateNetworkImpl',obj.DLTNetwork,dlConfig,obj.NetworkInfo);
    end
    coder.const(@dlcoder_base.internal.checkQuantizedNetworkSimulink,obj.DLTNetwork,ctx);

end
