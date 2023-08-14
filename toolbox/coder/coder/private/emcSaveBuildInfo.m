function bldParams=emcSaveBuildInfo(bldParams)




    try
        cfgSettings=bldParams.configInfo;
        if isa(cfgSettings,'coder.CodeConfig')
            bldMode=coder.internal.BuildMode.Normal;
            buildDir=emcGetBuildDirectory(bldParams.buildInfo,bldMode);
            bldParams.noECTestingMode=isSILTestingOn(bldParams.project.FeatureControl);
            flds={'-struct','bldParams',...
            'codeInfo',...
            'configInfo',...
            'typesMap',...
            'designRanges',...
            'xilEntryPoints',...
            'noECTestingMode'};

            if bldParams.project.FeatureControl.CodeInfoEntryPoints

                bldParams.entryPoints=bldParams.project.EntryPoints;
                flds{end+1}='entryPoints';
            end
            save(fullfile(buildDir,'codeInfo.mat'),flds{:});
            bldParams=writeCodeDescriptor(buildDir,bldParams);
        end
    catch
    end
end


function bldParams=writeCodeDescriptor(buildDir,bldParams)
    if~bldParams.canWriteCodeDescriptor
        bldParams=emcCantWriteCodeDescriptorWarning(bldParams);
        return
    end
    model=mf.zero.Model;
    txn=model.beginTransaction;
    componentInterface=bldParams.codeInfo.serializeMF0(model);
    txn.commit;
    outfile=fullfile(buildDir,'codedescriptor.dmr');
    mfdatasource.attachDMRDataSource(outfile,model,...
    mfdatasource.ToModelSync.None,mfdatasource.ToDataSourceSync.AllElements);
    if shouldSerializeCoderAssumptions(bldParams)






        codeDescModel=coder.descriptor.Model.findModel(model);
    else


        codeDescModel=coder.descriptor.Model(model);
    end
    codeDescModel.componentInterface=componentInterface;
end