classdef XILSfunction







    methods(Static)
        function buildForModel(lXilComponent,lRtwCodeWasUptodate,lParBDir_tmpDir,masterAnchorFolder,...
            lTopOfBuildModel,lTopModelAccelWithProfiling,isSILAndPws,hasSIL,hasPIL,...
            lDefaultCompInfo)

            lRTWBuildDir=RTW.getBuildDir(lXilComponent);
            lModelRefRelativeBuildDir=lRTWBuildDir.ModelRefRelativeBuildDir;
            if isempty(lParBDir_tmpDir)
                lAnchorDir=lRTWBuildDir.CodeGenFolder;
                lSfunctionBinWriteDir=lAnchorDir;
            elseif lRtwCodeWasUptodate



                lAnchorDir=masterAnchorFolder;




                lSfunctionBinWriteDir=lParBDir_tmpDir;
            else


                lAnchorDir=lParBDir_tmpDir;
                lSfunctionBinWriteDir=lAnchorDir;
            end
            isProtected=false;


            if hasSIL
                isSIL=true;
                Simulink.ModelReference.internal.XILSfunction.buildIfNecessary(lXilComponent,...
                lTopOfBuildModel,...
                lAnchorDir,...
                lSfunctionBinWriteDir,...
                lModelRefRelativeBuildDir,...
                lRtwCodeWasUptodate,...
                isProtected,...
                lTopModelAccelWithProfiling,...
                isSIL,...
                isSILAndPws,...
                lDefaultCompInfo);
            end



            if hasPIL
                isSIL=false;
                Simulink.ModelReference.internal.XILSfunction.buildIfNecessary(lXilComponent,...
                lTopOfBuildModel,...
                lAnchorDir,...
                lSfunctionBinWriteDir,...
                lModelRefRelativeBuildDir,...
                lRtwCodeWasUptodate,...
                isProtected,...
                lTopModelAccelWithProfiling,...
                isSIL,...
                isSILAndPws,...
                lDefaultCompInfo);
            end
        end


        function buildForProtectedModels...
            (lTopOfBuildModel,lTopModelAccelWithProfiling,...
            isSILAndPws,protectedModelsToPrepareForXIL,...
            protectedModelsToPrepareForXILIsSIL,...
            lDefaultCompInfo)




            for kProtectedModel=1:numel(protectedModelsToPrepareForXIL)
                lXilComponent=protectedModelsToPrepareForXIL{kProtectedModel};
                lRTWBuildDir=RTW.getBuildDir(lXilComponent);
                lAnchorDir=lRTWBuildDir.CodeGenFolder;
                lModelRefRelativeBuildDir=lRTWBuildDir.ModelRefRelativeBuildDir;
                isSIL=protectedModelsToPrepareForXILIsSIL(kProtectedModel);
                isProtected=true;
                Simulink.ModelReference.internal.XILSfunction.doBuild(lXilComponent,...
                lTopOfBuildModel,lAnchorDir,lAnchorDir,lModelRefRelativeBuildDir,...
                isProtected,lTopModelAccelWithProfiling,isSIL,isSILAndPws,...
                lDefaultCompInfo);
            end
        end
    end

    methods(Static,Access=private)
        function buildIfNecessary(lXilComponent,lTopOfBuildModel,...
            lAnchorDir,lSfunctionBinWriteDir,lModelRefRelativeBuildDir,rtwCodeWasUptodate,...
            isProtected,lTopModelAccelWithProfiling,isSIL,isSILAndPws,...
            lDefaultCompInfo)




            lXILSfcnWasUptodate=...
            Simulink.ModelReference.internal.XILSfunction.isXILSfcnUpToDate(...
            lXilComponent,lAnchorDir,lModelRefRelativeBuildDir,isSIL);

            buildXILSFunction=...
            ~rtwCodeWasUptodate||...
            ~lXILSfcnWasUptodate;

            if buildXILSFunction
                Simulink.ModelReference.internal.XILSfunction.doBuild(...
                lXilComponent,...
                lTopOfBuildModel,...
                lAnchorDir,...
                lSfunctionBinWriteDir,...
                lModelRefRelativeBuildDir,...
                isProtected,...
                lTopModelAccelWithProfiling,...
                isSIL,...
                isSILAndPws,...
                lDefaultCompInfo);
            end
        end


        function doBuild(lXilComponent,lTopOfBuildModel,lAnchorDir,lSfunctionBinWriteDir,...
            lModelRefRelativeBuildDir,isProtected,lTopModelAccelWithProfiling,...
            isSIL,isSILAndPws,lDefaultCompInfo)



            clientInterface=coder.connectivity.SimulinkInterface.forUpdateModelReferenceTargets;
            lMdlRefTgtType='RTW';
            if lTopModelAccelWithProfiling
                lTopModelOriginalParams=containers.Map('KeyType','char','ValueType','any');
                lTopModelOriginalParams('CodeExecutionProfiling')='on';



                lTopModelOriginalParams('CodeProfilingSaveOptions')='SummaryOnly';
            else
                lTopModelOriginalParams=[];
            end

            if~isProtected

                lModelsToClose=slprivate('load_model',lXilComponent);
                cModels=onCleanup(@()slprivate('close_models',lModelsToClose));
            else
                cModels=onCleanup(@()[]);
            end

            codeDir=fullfile(lAnchorDir,lModelRefRelativeBuildDir);
            lParallelBuildCodeDir=fullfile(lSfunctionBinWriteDir,lModelRefRelativeBuildDir);
            binfoMATFile=coderprivate.getBinfoMATFileAndCodeName(codeDir);
            loadConfigSet=true;
            savedInfoStruct=coder.internal.infoMATFileMgr(...
            'loadPostBuild','binfo',lXilComponent,lMdlRefTgtType,...
            binfoMATFile,loadConfigSet);

            configInterface=clientInterface.createConfigInterfaceFromInfoStruct(...
            savedInfoStruct,lXilComponent);



            lXilCompInfo=coder.internal.utils.XilCompInfo...
            .slCreateXilCompInfo(savedInfoStruct.configSet,lDefaultCompInfo,isSILAndPws);

            options=coder.connectivity.VerificationOptions(isSIL);
            options.SILDebuggingOverride=strcmp(configInterface.getParam('SILDebugging'),'on');
            [targetServices,errorMessage]=coder.connectivity.createTargetServices(configInterface,options,lXilCompInfo.XilMexCompInfo);
            if~isempty(errorMessage)
                options.IsSIL=true;
                targetServices=coder.connectivity.createTargetServices(configInterface,options,lXilCompInfo.XilMexCompInfo);
            end

            inTheLoopType=rtw.pil.InTheLoopType.ModelBlock;














            lSuppressIsSILAndPWS=~isSILAndPws;

            pilInterface=rtw.pil.SILPILInterface(lAnchorDir,...
            codeDir,...
            inTheLoopType,...
            clientInterface,...
            targetServices,...
            lXilCompInfo,...
            isSIL,...
            'TopModel',lTopOfBuildModel,...
            'TopModelOriginalParams',lTopModelOriginalParams,...
            'IsUpdateModelReferenceTargets',true,...
            'SuppressIsSILAndPWS',lSuppressIsSILAndPWS,...
            'SfunctionBinDir',lSfunctionBinWriteDir,...
            'ParallelBuildCodeDir',lParallelBuildCodeDir,...
            'VerboseOutput',strcmp(get_param(lTopOfBuildModel,'SILPILVerbosity'),'on'));


            isPILBlockConfigure=false;
            buildSFunctionOnly=pilInterface.IsUpdateModelReferenceTargets;
            buildWrapper(pilInterface,isPILBlockConfigure,buildSFunctionOnly,...
            lXilCompInfo,lDefaultCompInfo.DefaultMexCompilerKey)
            cModels.delete;
        end


        function lXILSfcnWasUptodate=isXILSfcnUpToDate(lXilComponent,lAnchorDir,lModelRefRelativeBuildDir,isSIL)






            lCodeInfoPath=fullfile(lAnchorDir,...
            lModelRefRelativeBuildDir,...
            [lXilComponent,'_mr_codeInfo.mat']);
            lCodeInfoDirStruct=dir(lCodeInfoPath);

            lXILSfcnName=Simulink.ModelReference.internal.XILSfunction.getXILSfcnName(lXilComponent,isSIL);
            lXILSfcnDirStruct=dir(fullfile(lAnchorDir,lXILSfcnName));
            if isempty(lXILSfcnDirStruct)
                lXILSfcnWasUptodate=false;
            else
                if isempty(lCodeInfoDirStruct)




                    lXILSfcnWasUptodate=false;
                else
                    lXILSfcnWasUptodate=...
                    (lXILSfcnDirStruct.datenum>=lCodeInfoDirStruct.datenum);
                end
            end
        end


        function lXILSfcnName=getXILSfcnName(lXilComponent,isSIL)





            if isSIL
                lXILSfcnName=[lXilComponent,'_ssf.',mexext];
            else
                lXILSfcnName=[lXilComponent,'_psf.',mexext];
            end
        end
    end
end
