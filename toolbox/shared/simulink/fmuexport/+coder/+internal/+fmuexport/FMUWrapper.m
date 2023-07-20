



classdef(Hidden=true)FMUWrapper<handle
    properties(SetAccess='private',GetAccess='private')
ModelName
ModelInfoUtils
FMUCInterfaceFile
FMUXMLInterfaceFile
    end


    methods(Access=public)
        function this=FMUWrapper(modelName,buildOpts,buildInfo)
            this.init(modelName,buildOpts,buildInfo);
        end

        function generateWrapper(this)
            this.build(@getWrapperWriterObject);
        end
        function generateXML(this,updatedBuildInfo)
            this.ModelInfoUtils.updateBuildInfoSourceCode(updatedBuildInfo);
            this.build(@getXMLWriterObject);
        end
        function generateDoc(this,updatedBuildInfo)
            this.ModelInfoUtils.updateBuildInfoSourceCode(updatedBuildInfo);
            this.build(@getDocWriterObject);
        end
    end

    methods(Access=private)
        function build(this,fHandle)
            interfaceBuilder=coder.internal.fmuexport.FMUInterfaceBuilder(this.ModelInfoUtils,this.FMUCInterfaceFile,this.FMUXMLInterfaceFile);

            writerObj=fHandle(interfaceBuilder);
            delete(writerObj);

        end

        function init(this,modelName,buildOpts,buildInfo)
            this.ModelName=modelName;
            this.FMUCInterfaceFile=this.getFMUCInterfaceFileName;
            this.FMUXMLInterfaceFile=this.getFMUXMLInterfaceFileName;


            codeInfoStruct=this.getCodeInfoStruct;


            fmuTargetDir=this.getFMUTargetDir;
            fmuInfoPath=fullfile(fmuTargetDir,'fmuInfo.mat');
            fmuInfoStruct=load(fmuInfoPath);



            codeDesc=coder.internal.getCodeDescriptorInternal(fmuTargetDir,247362);

            compInt=codeDesc.getFullComponentInterface();


            if Simulink.fmuexport.internal.ModelInfoUtilsBase.UseRefactorCode()
                this.ModelInfoUtils=coder.internal.fmuexport.ModelCGInfoUtils(codeInfoStruct.codeInfo,compInt,buildOpts,fmuInfoStruct.fmuInfo,fmuInfoStruct.cgModel_copy,buildInfo);
            else
                this.ModelInfoUtils=coder.internal.fmuexport.ModelInfoUtils(codeInfoStruct.codeInfo,compInt,buildOpts,fmuInfoStruct.fmuInfo,fmuInfoStruct.cgModel_copy,buildInfo);
            end



            if slsvTestingHook('FMUExportTestingMode')==2
                isInitialized=evalin('base','exist(''ModelInfoUtilInitialized'', ''var'')');
                if isInitialized==0
                    evalin('base','ModelInfoUtilInitialized = 1');
                else
                    error('ModelInfoUtil already initialized');
                end
            end
        end
    end

    methods(Access=public)
        function fileName=getFMUCInterfaceFileName(this)
            suffix=this.getFMUWrapperSuffix;
            ext='.c';
            fileName=[this.ModelName,suffix,ext];
        end

        function fileName=getFMUXMLInterfaceFileName(~)
            fileName='modelDescription.xml';
        end

        function fmuTargetDir=getFMUTargetDir(this)
            buildDir=RTW.getBuildDir(this.ModelName);
            fmuTargetDir=fullfile(buildDir.CodeGenFolder,buildDir.RelativeBuildDir);
        end

        function suffixStr=getFMUWrapperSuffix(~)
            suffixStr='_fmu';
        end

        function portInfo=getPortDataTypeInfo(this)

            inputDataTypeInfo=arrayfun(@(x)...
            struct('Name',x.GraphicalName,'Datatype',x.Type.Name),...
            this.ModelInfoUtils.codeInfo.Inports);

            outputDataTypeInfo=arrayfun(@(x)...
            struct('Name',x.GraphicalName,'Datatype',x.Type.Name),...
            this.ModelInfoUtils.codeInfo.Outports);

            portInfo=struct('Inports',inputDataTypeInfo,...
            'Outports',outputDataTypeInfo);
        end

        function codeInfoStruct=getCodeInfoStruct(this)

            fmuTargetDir=this.getFMUTargetDir;
            codeInfoPath=fullfile(fmuTargetDir,'codeInfo.mat');
            codeInfoStruct=rtw.pil.loadCodeInfo(codeInfoPath,false);
        end

        function modifySourceFiles(this,destinationFolder,fileNames)

            macrosHeaderFileName=[this.ModelName,'_macros.h'];
            h_src=fullfile(destinationFolder,macrosHeaderFileName);

            fId=fopen(h_src,'w+');
            cl=onCleanup(@()fclose(fId));
            if fId>0
                fwrite(fId,sprintf('%s','/* Define MACROS */'));


                buildInfoFile=cell2mat(fileNames(cellfun(@(x)contains(x,'buildInfo.mat'),fileNames)));
                buildInfo=coder.make.internal.loadBuildInfo(buildInfoFile);
                [~,macroNames,macroValues]=getDefines(buildInfo);

                for Count=1:length(macroNames)
                    fwrite(fId,sprintf('\n#ifndef %s',macroNames{Count}));
                    fwrite(fId,sprintf('\n#define %s %s',macroNames{Count},macroValues{Count}));
                    fwrite(fId,sprintf('\n#endif'));
                end

                clear cl


                sourceFileIndex=cellfun(@(x)...
                ismember(x(end-1:end),{'.c','.h'})&&...
                ~contains(x,{'fmi2Functions.h','fmi2FunctionTypes.h','fmi2TypesPlatform.h'}),fileNames);

                sourceFiles=fileNames(sourceFileIndex);



                cFileList=sourceFiles(cellfun(@(x)strcmpi(x(end-1:end),'.c'),sourceFiles));
                try
                    cellfun(@(x)insertHeaderInCFile(x,macrosHeaderFileName),cFileList);
                catch
                    assert(false,'Could not insert macro header in c files');
                end
            else
                assert(false,'Could not generate macro header file');
            end


            artifactsFiles=fileNames(~sourceFileIndex);
            cellfun(@(x)(fileattrib(x,'+w')),artifactsFiles)
            cellfun(@(x)(delete(x)),artifactsFiles)
        end
    end
end
function insertHeaderInCFile(fileName,headerFileToInclude)

    fileText=fileread(fileName);

    fileattrib(fileName,'+w');
    fId=fopen(fileName,'w+');
    if fId~=-1
        updatedTextWithHeader=sprintf('#include "%s"\n%s',headerFileToInclude,fileText);
        fwrite(fId,sprintf('%s',updatedTextWithHeader));
    end
    fclose(fId);
end

