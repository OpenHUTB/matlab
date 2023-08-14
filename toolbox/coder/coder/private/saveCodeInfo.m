function saveCodeInfo(bldParams)




    try
        bldMode=coder.internal.BuildMode.Normal;
        buildDir=emcGetBuildDirectory(bldParams.buildInfo,bldMode);
        bldParams.noECTestingMode=isSILTestingOn(bldParams.project.FeatureControl);
        save(fullfile(buildDir,'codeInfo.mat'),...
        '-struct','bldParams',...
        'codeInfo',...
        'configInfo',...
        'typesMap',...
        'designRanges',...
        'xilEntryPoints',...
        'noECTestingMode');
        if bldParams.project.FeatureControl.GenerateMF0CodeDescriptorForMATLABCoder
            model=mf.zero.Model;
            txn=model.beginTransaction;
            componentInterface=bldParams.codeInfo.serializeMF0(model);
            txn.commit;
            mfdatasource.attachDMRDataSource(fullfile(buildDir,'codedescriptor.dmr'),model,...
            mfdatasource.ToModelSync.None,mfdatasource.ToDataSourceSync.AllElements);
            if shouldSerializeCoderAssumptions(bldParams)






                codeDescModel=coder.descriptor.Model.findModel(model);
            else


                codeDescModel=coder.descriptor.Model(model);
            end
            codeDescModel.componentInterface=componentInterface;
        end
    catch
    end
end


function out=shouldSerializeCoderAssumptions(bldParams)
    out=isa(bldParams.configInfo,'coder.EmbeddedCodeConfig')||...
    (isa(bldParams.configInfo,'coder.CodeConfig')&&...
    isSILTestingOn(bldParams.project.FeatureControl));
end
