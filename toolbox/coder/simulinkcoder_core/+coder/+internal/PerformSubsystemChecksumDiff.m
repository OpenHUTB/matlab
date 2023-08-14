






























classdef PerformSubsystemChecksumDiff<handle
    properties(Access=private)
        SS_A_path;
        SS_B_path;
ModelABuildType
ModelBBuildType
SerialializedMATFiles
loadedMdls
    end
    methods


        function this=PerformSubsystemChecksumDiff(firstSubsystemPath,firstBuildType,secondSubsystemPath,secondBuildType)
            assert(isequal(slsvTestingHook('PrintChecksumDiff'),1),'Turn on testing hook before starting diff');
            this.SS_A_path=firstSubsystemPath;
            this.SS_B_path=secondSubsystemPath;
            this.ModelABuildType=firstBuildType;
            this.ModelBBuildType=secondBuildType;
            this.SerialializedMATFiles={};
        end

        function this=run(this)
            csDetailsStructA=this.buildAndCollectCSDetails(this.SS_A_path,this.ModelABuildType);
            csDetailsStructB=this.buildAndCollectCSDetails(this.SS_B_path,this.ModelBBuildType);

            this.performDiff(csDetailsStructA,csDetailsStructB);

            this.showConfigSetDifferences();
        end

        function loadedMdls=getLoadedMdls(this)
            loadedMdls=this.loadedMdls;
        end

        function delete(this)
            for i=1:length(this.SerialializedMATFiles)
                fileName=this.SerialializedMATFiles{i};
                if(isfile(fileName))
                    delete(fileName);
                end
            end
            this.SerialializedMATFiles={};
            for i=1:length(this.loadedMdls)
                thisMdl=this.loadedMdls{i};
                close_system(thisMdl,0);
            end
        end

    end
    methods(Access='protected')

        function[model,cs]=getConfigSet(this,ssPath)
            model=this.loadModelHelper(ssPath);
            cs=getActiveConfigSet(model);
            if(isa(cs,'Simulink.ConfigSetRef'))
                cs=cs.getRefConfigSet();
            end
            assert(isa(cs,'Simulink.ConfigSet'));
        end

        function showConfigSetDifferences(this)
            [modelA,csA]=this.getConfigSet(this.SS_A_path);
            [modelB,csB]=this.getConfigSet(this.SS_B_path);

            if~strcmp(modelA,modelB)
                configset.internal.util.showDiff(csA,csB);
            end
        end

        function this=performDiff(this,csDetailsStructA,csDetailsStructB)
            fieldNames=fields(csDetailsStructA);
            assert(length(fields(csDetailsStructA))==length(fields(csDetailsStructB)));
            for i=1:length(fieldNames)
                fieldName=fieldNames{i};
                this.performDiffHelper(csDetailsStructA.(fieldName),csDetailsStructB.(fieldName),fieldName);
            end

        end

        function this=performDiffHelper(this,structA,structB,csType)

            if(isempty(structA)||isempty(structB))
                return;
            end
            s=coder.internal.SubsystemChecksumDiff(structA,...
            structB,...
            this.SS_A_path,...
            this.SS_B_path,...
            csType);
            s.compare();
        end

        function csDetailsStruct=getChecksumMATFilesHelper(this,subsystemName,buildDir)

            csDetailsStruct=struct('Parameter',[],'Structural',[],'Content',[],'Interface',[],'SharedFcn',[]);
            matFiles=dir([buildDir,filesep,'*.mat']);
            for i=1:length(matFiles)
                matFile=matFiles(i).name;


                if~(startsWith(matFile,subsystemName))
                    continue;
                end
                strWithoutSubsystemName=matFile(length(subsystemName)+1:end);
                csDetailsStr='csDetails';


                if~(startsWith(strWithoutSubsystemName,csDetailsStr))
                    continue;
                end
                dotMat='.mat';
                assert(endsWith(strWithoutSubsystemName,dotMat));
                csType=strWithoutSubsystemName(length(csDetailsStr)+1:end-length(dotMat));
                csData=load(fullfile(buildDir,matFile),"csDetails");
                csData=csData.csDetails;
                switch(csType)
                case('Parameter')
                    csDetailsStruct.Parameter=csData;
                case('Structural')
                    csDetailsStruct.Structural=csData;
                case('Contents')
                    csDetailsStruct.Content=csData;
                case('Interface')
                    csDetailsStruct.Interface=csData;
                case('SharedFcn')
                    csDetailsStruct.SharedFcn=csData;
                otherwise
                    assert(false,'Unknown checksum type');
                end

                this.SerialializedMATFiles{end+1}=matFile;
            end

            assert(~isempty(this.SerialializedMATFiles),'No checksum MAT file were serialized by model build process!');
        end

        function csDetailsStruct=buildAndCollectCSDetails(this,subsystem,buildType)


            model=this.loadModelHelper(subsystem);

            set_param(subsystem,'ActiveForDiff','on');
            c=onCleanup(@()set_param(subsystem,'ActiveForDiff','off'));
            buildDir=this.buildModelHelper(model,buildType);

            csDetailsStruct=this.getChecksumMATFilesHelper(get_param(subsystem,'Name'),buildDir);

        end

        function model=loadModelHelper(this,subsystemPath)


            sidDelim=':';
            if(contains(subsystemPath,sidDelim))
                model=strtok(subsystemPath,sidDelim);
            else
                model=Simulink.variant.utils.getModelNameFromPath(subsystemPath);
            end
            assert(~isempty(model));
            load_system(model);
            assert(strcmp(bdroot(subsystemPath),model));
            this.loadedMdls{end+1}=model;
        end



    end

    methods(Static)



        function buildDirStr=buildModelHelper(modelToBuild,buildType)
            buildDirStr=[];
            if strcmpi(buildType,"TopModel")
                try
                    rtwbuild(modelToBuild);
                catch
                    disp('==========Top model build failed! Proceeding with checksum diff==========');
                end
                buildDir=RTW.getBuildDir(modelToBuild);
                buildDirStr=fullfile(buildDir.CodeGenFolder,buildDir.RelativeBuildDir);

            elseif strcmpi(buildType,"ModelReference")
                try
                    slbuild(modelToBuild,'ModelReferenceCoderTarget');
                catch
                    disp('==========Referenced model build failed! Proceeding with checksum diff==========');
                end
                buildDir=RTW.getBuildDir(modelToBuild);
                buildDirStr=fullfile(buildDir.CodeGenFolder,buildDir.ModelRefRelativeBuildDir);

            else
                assert(false,'Build Type should be either TopModel or ModelReference')
            end


        end




    end
end
