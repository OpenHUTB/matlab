function HDLVAssertBlkInstanceInfo=getSIDOfAssertBlocksInModel(ModelName)






    [~,~,MdlRefGraph]=find_mdlrefs(ModelName,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
    A=Simulink.ModelReference.internal.GraphAnalysis.ModelRefGraphAnalyzer;
    MdlRefAndBlocksInfo=A.analyze(MdlRefGraph,'All');

    NumberOfRefModels=height(MdlRefAndBlocksInfo);
    clean_loaded_ref_models=cell(1,NumberOfRefModels);

    HDLVAssertBlkInfo=containers.Map;
    for idx=1:NumberOfRefModels
        ReferenceModel=MdlRefAndBlocksInfo.RefModel{idx};
        IsLoaded=MdlRefAndBlocksInfo.IsLoaded(idx);

        if~IsLoaded
            try
                load_system(ReferenceModel);
                clean_loaded_ref_models{idx}=onCleanup(@()bdclose(ReferenceModel));
            catch






                continue;
            end
        end




































        HDLVAssertionBlocks=find_system(ReferenceModel,...
        'LookUnderMasks','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'FollowLinks','on',...
        'BlockType','Assertion');

        for BlkPath=HDLVAssertionBlocks'
            BlkPathStr=BlkPath{1};






            if~strcmp(get_param(bdroot(BlkPathStr),'AssertControl'),'DisableAll')



                if strcmpi(get_param(BlkPathStr,'Enabled'),'on')||strcmp(get_param(bdroot,'AssertControl'),'EnableAll')

                    [sidPath,isDPIAssertion]=getBlockForHighlightInModel(BlkPathStr,ReferenceModel);

                    if isDPIAssertion
                        Severity_Arg=get_param(sidPath,'DPIAssertSeverity');
                        if strcmp(Severity_Arg,'custom')
                            Message_Arg=get_param(sidPath,'DPIAssertCustomCommand');
                        else
                            Message_Arg=get_param(sidPath,'DPIAssertFailMessage');
                        end
                    else
                        Severity_Arg='error';
                        Message_Arg='';
                    end

                    InputLength=getAssertBlockInputLenght(ModelName,BlkPathStr);
                    HDLVAssertBlkInfo(Simulink.ID.getSID(sidPath))=struct('Message',Message_Arg,...
                    'Severity',Severity_Arg,...
                    'NativeAssertionBlkSID',Simulink.ID.getSID(BlkPathStr),...
                    'IsTopModel',idx==1,...
                    'InputLength',InputLength);
                end
            end
        end
    end

    HDLVAssertBlkInstanceInfo=containers.Map;
    ParseMdlRefGraph(MdlRefGraph,MdlRefGraph.getInstanceTopVertexID(),'',HDLVAssertBlkInfo,HDLVAssertBlkInstanceInfo);



    HDLVAssertion_SIDKeys=keys(HDLVAssertBlkInstanceInfo);
    HDLVAssertion_InMdlRef=cellfun(@(x)~HDLVAssertBlkInstanceInfo(x).IsTopModel,HDLVAssertion_SIDKeys);

    if any(HDLVAssertion_InMdlRef)
        AssertBlksInMdlRef=sprintf(['\n',char(join(cellfun(@(x)Simulink.ID.getFullName(extractBefore(x,'@')),HDLVAssertion_SIDKeys(HDLVAssertion_InMdlRef),'UniformOutput',false),',\n')),'\n']);
        warning(message('HDLLink:DPIG:AssertionBlksInMdlRefNotSupported',AssertBlksInMdlRef));
    end

    HDLVAssertBlkInstanceInfo.remove(HDLVAssertion_SIDKeys(HDLVAssertion_InMdlRef));
end










function[sidPath,isDPIAssert]=getBlockForHighlightInModel(blkPath,ReferenceModel)
    parentBlk=get_param(blkPath,'Parent');
    if strcmp(parentBlk,ReferenceModel)
        maskType='';
    else
        maskType=get_param(parentBlk,'MaskType');
    end

    modelVerAsserts={'Checks_DGap','Checks_DRange','Checks_SGap','Checks_SRange','Checks_Gradient','Checks_DMin','Checks_DMax','Checks_Resolution','Checks_SMin','Checks_SMax'};
    dpiAsserts={'Assertion for DPI-C'};

    isModelVerAssert=any(strcmp(maskType,modelVerAsserts));
    isDPIAssert=any(strcmp(maskType,dpiAsserts));

    if isModelVerAssert||isDPIAssert
        sidPath=parentBlk;
    else
        sidPath=blkPath;
    end

end
