function modelsSupportingOnlyNormalMode=getModelsSupportingOnlyNormalMode(modelNames)







    modelsSupportingOnlyNormalMode={};



    for it=1:length(modelNames)

        opt=Simulink.ModelReference.ProtectedModel.getOptions(modelNames{it});
        subModels=opt.subModels;

        if Simulink.ModelReference.ProtectedModel.supportsNormalOnly(opt)

            for it2=1:length(subModels)
                modelsSupportingOnlyNormalMode{end+1}=subModels{it2};%#ok<AGROW>
            end
        end
    end
end

