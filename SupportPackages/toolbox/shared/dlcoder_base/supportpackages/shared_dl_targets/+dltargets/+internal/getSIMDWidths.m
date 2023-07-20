function simdWidths=getSIMDWidths(intrinsicName,intrinsicBaseType,buildContext,modelName)

















    persistent oldIntrinsicName oldIntrinsicBaseType oldCrlName oldInstructionSetExtension oldSimdWidths;


    crlName=getConfigProp(buildContext,'CodeReplacementLibrary');
    instructionSetExtension=getConfigProp(buildContext,'InstructionSetExtensions');

    if~isempty(oldIntrinsicName)&&...
        strcmp(oldIntrinsicName,intrinsicName)&&...
        strcmp(oldIntrinsicBaseType,intrinsicBaseType)&&...
        strcmp(oldCrlName,crlName)&&...
        strcmp(oldInstructionSetExtension,instructionSetExtension)


        simdWidths=oldSimdWidths;
        return;
    end


    if isa(buildContext.ConfigData,'Simulink.ConfigSet')
        if nargin<4
            modelName=bdroot(gcs);



        end
        tflControl=get_param(modelName,'TargetFcnLibHandle');
    else
        tflControl=emlcprivate('getEmlTflControl',crlName);
    end





    if~isempty(tflControl.LoadedLibrary)
        allIntrinsics=getSIMDInfo(tflControl);



        intrinsicWithAllTypes=allIntrinsics(strcmp({allIntrinsics.Intrinsic},intrinsicName));
        intrinsics=intrinsicWithAllTypes(strcmp({intrinsicWithAllTypes.BaseType},intrinsicBaseType));


        simdWidths=sort([intrinsics.SimdWidth],'ascend');
    else



        simdWidths=1;
    end

    oldSimdWidths=simdWidths;
    oldIntrinsicName=intrinsicName;
    oldIntrinsicBaseType=intrinsicBaseType;
    oldCrlName=crlName;
    oldInstructionSetExtension=instructionSetExtension;

end
