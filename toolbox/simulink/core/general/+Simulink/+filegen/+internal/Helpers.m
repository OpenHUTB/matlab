classdef Helpers






    methods(Static)






        function folderSpec=getFolderSpecificationTemplate(codeGen)
            import Simulink.filegen.internal.Helpers

            marker=fullfile(Helpers.Slprj,'sl_proj.tmw');

            simulation=Simulink.filegen.FolderSet(marker,...
            Helpers.CacheFolder,...
            [],...
            fullfile(Helpers.Slprj,Helpers.SimTarget),...
            fullfile(Helpers.Slprj,Helpers.SimTarget,Helpers.ModelName,Helpers.MdlRefInstrDir),...
            fullfile(Helpers.Slprj,Helpers.SimTarget,'_sharedutils'));

            if nargin<1
                codeGen=Simulink.fileGenControl('get','CodeGenFolderStructure');
            end


            hdl=Simulink.filegen.FolderSet(marker,...
            Helpers.CodeGenFolder,...
            [],...
            fullfile(Helpers.Slprj,'hdl'),...
            fullfile(Helpers.Slprj,'hdl',Helpers.ModelName),...
            []);

            accel=Simulink.filegen.FolderSet(marker,...
            Helpers.CacheFolder,...
            fullfile(Helpers.Slprj,'accel',Helpers.ModelName,Helpers.AccelInstrDir),...
            fullfile(Helpers.Slprj,'accel'),...
            fullfile(Helpers.Slprj,'accel',Helpers.ModelName),...
            fullfile(Helpers.Slprj,'accel','_sharedutils'));

            raccel=Simulink.filegen.FolderSet(marker,...
            Helpers.CacheFolder,...
            fullfile(Helpers.Slprj,Helpers.getRapidAcceleratorDir(),Helpers.ModelName),...
            fullfile(Helpers.Slprj,Helpers.getRapidAcceleratorDir()),...
            fullfile(Helpers.Slprj,Helpers.getRapidAcceleratorDir(),Helpers.ModelName),...
            fullfile(Helpers.Slprj,Helpers.getRapidAcceleratorDir(),'_sharedutils'));


            folderSpec=Simulink.filegen.internal.FolderSpecification(simulation,codeGen,hdl,accel,raccel);
        end






        function folderSpec=getModelRefSimFolderSpecification(modelName)
            import Simulink.filegen.internal.Helpers

            cacheFolder=Simulink.fileGenControl('get','CacheFolder');
            stf='modelrefsim';

            targetRoot=fullfile(Helpers.Slprj,stf);
            modelRefFolder=fullfile(Helpers.Slprj,stf,modelName);
            sharedUtilsFolder=fullfile(Helpers.Slprj,stf,'_sharedutils');

            marker=fullfile(Helpers.Slprj,'sl_proj.tmw');

            simulation=Simulink.filegen.FolderSet(marker,...
            cacheFolder,...
            [],...
            fullfile(Helpers.Slprj,Helpers.SimTarget),...
            fullfile(Helpers.Slprj,Helpers.SimTarget,modelName,Helpers.getMdlRefInstrumentationDir(modelName)),...
            fullfile(Helpers.Slprj,Helpers.SimTarget,'_sharedutils'));

            codeGen=Simulink.filegen.FolderSet(marker,...
            cacheFolder,...
            modelName,...
            targetRoot,...
            modelRefFolder,...
            sharedUtilsFolder);

            hdl=Simulink.filegen.FolderSet(marker,...
            cacheFolder,...
            [],...
            fullfile(Helpers.Slprj,'hdl'),...
            fullfile(Helpers.Slprj,'hdl',modelName),...
            []);

            accel=Simulink.filegen.FolderSet(marker,...
            cacheFolder,...
            fullfile(Helpers.Slprj,'accel',modelName),...
            targetRoot,...
            modelRefFolder,...
            sharedUtilsFolder);

            raccel=Simulink.filegen.FolderSet(marker,...
            cacheFolder,...
            fullfile(Helpers.Slprj,Helpers.getRapidAcceleratorDir(),modelName),...
            targetRoot,...
            modelRefFolder,...
            sharedUtilsFolder);


            folderSpec=Simulink.filegen.internal.FolderSpecification(simulation,codeGen,hdl,accel,raccel);
        end






        function modelToUse=getDirectoryModelName(model)
            if isempty(model)
                modelToUse=model;
                return;
            end

            if(ischar(model))
                name=model;
            else
                name=get_param(model,'Name');
            end



            if Simulink.internal.isModelReferenceMultiInstanceNormalModeCopy(name)

                modelToUse=get_param(name,'ModelReferenceNormalModeOriginalModelName');
            else

                modelToUse=name;
            end
        end


        function isProtected=isProtectedModel(model)

            if bdIsLoaded(model)



                isProtected=false;
                return;
            end

            fileName=which(model);
            [~,~,ext]=fileparts(fileName);
            isProtected=ismember(ext,{'.slxp','.mdlp'});
        end





        function accessible=canAccessConfigSet(model,isProtected)

            accessible=true;
            isLoaded=bdIsLoaded(model);

            if~isProtected
                accessible=isLoaded;
                return;
            end

            try
                Simulink.ProtectedModel.getConfigSet(model);
            catch e
                if(contains(e.identifier,'Simulink:protectedModel'))
                    accessible=false;
                    return;
                else
                    rethrow(e);
                end
            end
        end

        function value=getCachedOrOriginalSystemTargetFile(modelName,isProtected)



            if isProtected
                cs=Simulink.ProtectedModel.getConfigSet(modelName);
                value=get_param(cs,'SystemTargetFile');
                return;
            end


            currentStf=get_param(modelName,'SystemTargetFile');










            if ismember(currentStf,{'accel.tlc','raccel.tlc'})
                value=currentStf;
            else
                stf=coder.internal.getCachedAccelOriginalSTF(modelName,false);



                value=regexp(stf,'\w*.tlc','match','once');
                assert(~isempty(value),'No system target file specified.');
            end
        end



        function validateProtectedModelCodeGenFolderStructure(protectedModel)

            opts=Simulink.ModelReference.ProtectedModel.getOptions(protectedModel);
            folders=opts.getBuildDirFromModel(protectedModel);
            cs=Simulink.ModelReference.ProtectedModel.getConfigSet(protectedModel);
            hardware=get_param(cs,'TargetHWDeviceType');
            stf=get_param(cs,'SystemTargetFile');
            folderConfig=Simulink.filegen.internal.FolderConfiguration.forSpecifiedSTFAndHardware(protectedModel,stf,hardware);








            if~strcmp(folders.RelativeBuildDir,folderConfig.CodeGeneration.ModelCode)





                currentFolderStructure=Simulink.fileGenControl('get','CodeGenFolderStructure');
                if currentFolderStructure==Simulink.filegen.CodeGenFolderStructure.ModelSpecific
                    protectedFolderstructure=Simulink.filegen.CodeGenFolderStructure.TargetEnvironmentSubfolder;
                else
                    protectedFolderstructure=Simulink.filegen.CodeGenFolderStructure.ModelSpecific;
                end

                DAStudio.error('Simulink:FileGen:ProtectedModelCodeGenFolderStructure',...
                protectedModel,...
                protectedFolderstructure.DisplayString,...
                currentFolderStructure.DisplayString);
            end
        end

        function value=getMdlRefInstrumentationDir(modelName)
            if slfeature('SlCovAccelCompileSupport')&&...
                SlCov.CoverageAPI.isMdlRefEnabledForAccelCoverage(modelName)
                value='instrumented';
            else
                value='';
            end
        end

        function value=getAccelInstrumentationDir(modelName)
            if slfeature('SlCovAccelCompileSupport')&&...
                SlCov.CoverageAPI.isEnabledForAccelCoverage(modelName)
                value='instrumented';
            else
                value='';
            end
        end

        function value=getUninstrumentedAccelDir(modelName)
            import Simulink.filegen.internal.Helpers
            value=fullfile(Helpers.Slprj,'accel',modelName);
        end

        function value=getUninstrumentedMdlRefDir(modelName)
            import Simulink.filegen.internal.Helpers
            value=fullfile(Helpers.Slprj,Helpers.SimTarget,modelName);
        end

        function value=getRapidAcceleratorDir()
            if Simulink.isRaccelDeploymentBuild
                value='raccel_deploy';
            else
                value='raccel';
            end
        end
    end

    properties(Constant,Access=private)
        Slprj='slprj';
        SimTarget='sim';
        CodeGenFolder='$(CODEGENFOLDER)';
        CacheFolder='$(CACHEFOLDER)';
        ModelName='$(MODELNAME)';
        Stf='$(STF)';
        MdlBuildDirSuffix='$(MDLBUILDSUFFIX)';
        MdlRefBuildDirSuffix='$(MDLREFBUILDSUFFIX)';
        MdlRefInstrDir='$(MDLREFINSTRDIR)';
        NodeId='$(NODEID)';
        AccelInstrDir='$(ACCELINSTRDIR)';
    end
end


