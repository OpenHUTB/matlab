classdef A2LUpdater<handle







    properties(SetAccess=immutable,GetAccess=private)


        BuildInProgress(1,1)logical=false;

        IFDataXCPInfo asam.mcd2mc.ifdata.xcp.IFDataXCPInfo=asam.mcd2mc.ifdata.xcp.IFDataXCPInfo.empty;
        MergeModelRefs(1,1)logical=true;
        SetAddress(1,1)logical=true;
        InputFile(1,:)char='';
        OutputFile(1,:)char='';


        BuildDir(1,:)char='';
        BuildInfo RTW.BuildInfo=RTW.BuildInfo.empty;
        ComponentInterface;
        CodeGenFolder(1,:)char='';
        ModelName(1,:)char='';
        SavedConfigSet;
        IsAutosarAdaptive=false;
    end

    properties(Access=private,Constant)

        DefaultSlaveSuffix='_CoderXCPSlave';
    end

    methods
        function obj=A2LUpdater(codeGenFolder,buildInfo,componentInterface,configSet,buildInProgress,ifDataXcp,mergeModelRefs,setAddress,inputFile,outputFile)







            [checkoutSuccess,errmsg]=license('checkout','rtw_embedded_coder');
            if~checkoutSuccess
                DAStudio.error('coder_xcp:a2l:RequiresEmbeddedCoder',errmsg);
            end


            obj.BuildInProgress=buildInProgress;
            obj.IFDataXCPInfo=ifDataXcp;
            obj.MergeModelRefs=mergeModelRefs;
            obj.SetAddress=setAddress;
            obj.InputFile=inputFile;
            obj.OutputFile=outputFile;


            obj.CodeGenFolder=codeGenFolder;
            obj.BuildInfo=buildInfo;
            obj.ComponentInterface=componentInterface;
            obj.SavedConfigSet=configSet;

            obj.IsAutosarAdaptive=strcmp(get_param(obj.SavedConfigSet,'AutosarCompliant'),'on')&&...
            strcmp(get_param(obj.SavedConfigSet,'CodeInterfacePackaging'),'C++ class');


            if obj.MergeModelRefs&&~isempty(obj.InputFile)
                DAStudio.error('coder_xcp:a2l:MergeMdlRefsAndInputFileNotSupported')
            end



            isASAP2Enabled=strcmp(get_param(obj.SavedConfigSet,'GenerateASAP2'),'on');
            if~isASAP2Enabled&&~obj.IsAutosarAdaptive
                DAStudio.error('coder_xcp:a2l:ASAP2GenerationNotEnabled',obj.BuildInfo.ModelName);
            end

            obj.ModelName=obj.BuildInfo.ModelName;

            if isempty(obj.InputFile)
                rtwBuildDir=RTW.getBuildDir(obj.ModelName);
                obj.InputFile=fullfile(rtwBuildDir.BuildDirectory,[obj.ModelName,'.a2l']);
            end
        end

        function outputFile=write(obj)






            a2lContents=obj.getMergedA2LContents();
            if isempty(obj.IFDataXCPInfo)


                ifDataXcp=...
                coder.internal.xcp.a2l.slcoderslave.createIFDataXCPInfo(...
                obj.ModelName,...
                obj.BuildInfo,...
                obj.CodeGenFolder,...
                obj.SavedConfigSet,...
                obj.ComponentInterface);
            else

                ifDataXcp=obj.IFDataXCPInfo;
            end
            if isempty(obj.OutputFile)

                outputFile=fullfile(obj.CodeGenFolder,[obj.ModelName,obj.DefaultSlaveSuffix,'.a2l']);
            else

                outputFile=obj.OutputFile;
            end

            coder.internal.xcp.a2l.writeA2LFileWithIFDataXCP(outputFile,a2lContents,ifDataXcp,'OriginalFileName',obj.InputFile);
        end
    end

    methods(Access=private)
        function a2lContents=getMergedA2LContents(obj)




            cFileGenControl=obj.setFileGenControlCodeGenAndCacheFolder(obj.CodeGenFolder);


            [tempFolder,cTempFolder]=obj.getTempFolder();


            mergedFileFullPath=fullfile(tempFolder,[obj.ModelName,'_merged.a2l']);
            if obj.MergeModelRefs
                rtw.asap2MergeMdlRefs(obj.ModelName,mergedFileFullPath);
            else




                copyfile(obj.InputFile,mergedFileFullPath);
            end

            if obj.SetAddress
                debugFullFileName=obj.getDebugFullFileName();
                obj.callRtwAsap2SetAddress(mergedFileFullPath,debugFullFileName);
            end


            cFileGenControl.delete;


            a2lContents=fileread(mergedFileFullPath);


            cTempFolder.delete;
        end

        function debugFullFileName=getDebugFullFileName(obj)

            extModeMexArgs=get_param(obj.SavedConfigSet,'ExtModeMexArgs');
            transport=obj.getTransport();
            xcpExtModeArgs=coder.internal.xcp.parseExtModeArgs(extModeMexArgs,...
            transport,...
            obj.ModelName,...
            obj.CodeGenFolder);
            debugFile=xcpExtModeArgs.symbolsFileName;


            if isempty(debugFile)

                debugFullFileName=coder.internal.xcp.getDefaultSymbolsFileName(obj.ModelName);
            else

                isAbsolute=~isempty(regexp(debugFile,'^[a-zA-Z]:\\|/','match','once'));
                if isAbsolute
                    debugFullFileName=debugFile;
                else

                    fileRelativeToCodeGenFolder=fullfile(obj.CodeGenFolder,debugFile);
                    isRelativeToCodeGenFolder=isfile(fileRelativeToCodeGenFolder);
                    if isRelativeToCodeGenFolder
                        debugFullFileName=fileRelativeToCodeGenFolder;
                    else

                        debugFullFileName=debugFile;
                    end
                end
            end
        end

        function transport=getTransport(obj)

            index=get_param(obj.SavedConfigSet,'ExtModeTransport');
            transport=Simulink.ExtMode.Transports.getExtModeTransport(obj.SavedConfigSet,index);
        end

        function cleanupObj=setFileGenControlCodeGenAndCacheFolder(obj,codeGenFolder)




            if obj.BuildInProgress


                cleanupObj=onCleanup(@()[]);
            else
                originalCfg=Simulink.fileGenControl('getInternalConfig');
                cleanupObj=onCleanup(@()...
                Simulink.fileGenControl('setconfig','config',originalCfg));
                Simulink.fileGenControl('set','CodeGenFolder',codeGenFolder);
                Simulink.fileGenControl('set','CacheFolder',codeGenFolder);
            end
        end

    end

    methods(Access=private,Static)
        function[folder,cleanupObj]=getTempFolder()



            folder=tempname;
            mkdir(folder)
            cleanupObj=onCleanup(@()rmdir(folder,'s'));
        end

        function callRtwAsap2SetAddress(mergedFileFullPath,debugFullFileName)



            debugSymbolFileFound=isfile(debugFullFileName);
            if debugSymbolFileFound





                try
                    rtw.asap2SetAddress(mergedFileFullPath,debugFullFileName);
                catch ME
                    MSLDiagnostic('coder_xcp:a2l:RTWAsap2SetAddressFailed',...
                    ME.message).reportAsWarning;
                end
            else





                [~,a2lFile,a2lFileExt]=fileparts(mergedFileFullPath);
                a2lFileWithExt=[a2lFile,a2lFileExt];
                MSLDiagnostic('coder_xcp:a2l:CouldNotFindSymbolsFile',debugFullFileName,a2lFileWithExt).reportAsWarning;
            end
        end
    end
end
