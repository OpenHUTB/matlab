



function generateCode(sysToAnalyse)

    sysDirInfo=pslink.util.Helper.getConfigDirInfo(getfullname(sysToAnalyse),pslink.verifier.ec.Coder.CODER_ID);
    if isempty(sysDirInfo.SystemCodeGenDir)||~exist(sysDirInfo.SystemCodeGenDir,'dir')
        rtwbuild(sysToAnalyse);
    else

        codeInfo=[];
        codeInfoFile='codeInfo.mat';
        codeInfoPath=fullfile(sysDirInfo.SystemCodeGenDir,codeInfoFile);
        codeDescriptor=coder.internal.getCodeDescriptorInternal(codeInfoPath,247362);
        if~isempty(codeDescriptor)
            codeInfo=codeDescriptor.getComponentInterface();
        end
        if~isempty(codeInfo)

            codeChecksum=codeInfo.Checksum;
        end
        if strcmpi(get_param(sysToAnalyse,'Type'),'block_diagram')
            try


                [~,systemChecksum]=evalc('Simulink.BlockDiagram.getChecksum(bdroot(sysToAnalyse))');
            catch Me %#ok<NASGU> 
                systemChecksum=[];
            end
            if isempty(systemChecksum)||any(systemChecksum~=codeChecksum)

                rtwbuild(sysToAnalyse);
            end
        end
    end
