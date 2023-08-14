classdef ARAGenerator<handle











    properties(Access='private')
        M3iModel;
        M3IComponent;
        AllBuilders;
        AllWriters;
    end
    properties(SetAccess='private',GetAccess='public')

        ServiceInterfaceBuilder;
        TypeBuilder;
        ServiceInterfaceWriter;
        TypeWriter;
        ARAFilesLocation;
        ModelName;
        SchemaVersion;
    end

    properties(Constant)
        StaticARAHeaderPathContainer={
        fullfile('${MATLAB_ROOT}','toolbox','coder','ara','mw_ara','headers',computer('arch'),'$VER'),...
        fullfile('${MATLAB_ROOT}','toolbox','coder','ara','mw_ara','headers',computer('arch'),'ud_ipc'),...
        fullfile('${MATLAB_ROOT}','toolbox','coder','ara','mw_ara','headers',computer('arch'),'dds_util'),...
        fullfile('${MATLAB_ROOT}','toolbox','coder','ara','mw_ara','headers',computer('arch'),'com_factory'),...
        fullfile('${MATLAB_ROOT}','toolbox','coder','ara','mw_ara','headers',computer('arch'),'log_utils'),...
        fullfile('${MATLAB_ROOT}','toolbox','coder','ara','mw_ara','headers',computer('arch'),'manifest_utils'),...
        fullfile('${MATLAB_ROOT}','toolbox','coder','autosar','adaptive_deployment','include'),...
        fullfile('${MATLAB_ROOT}','toolbox','coder','simulinkcoder','src','executor')
        };
    end
    methods(Static)
        function addStaticARAHeaderFilesToBuildInfo(~)

        end

        function addStaticARAHeaderFilesToReport(~)

        end

        function araSubFolder=getARAFilesSubFolder()
            araSubFolder=fullfile('stub','aragen');
        end

        function araDir=getARAFilesFolder(buildDir)
            araDir=fullfile(buildDir,...
            autosar.mm.mm2ara.ARAGenerator.getARAFilesSubFolder);
        end
    end
    methods(Access='public')



        function this=ARAGenerator(m3iModel,araFilesLocation,modelName)

            adaptiveSchema=get_param(modelName,'AutosarSchemaVersion');
            if strcmp(adaptiveSchema,'R18-10')
                this.SchemaVersion='ARA_VER_18_10';
            elseif strcmp(adaptiveSchema,'R19-03')
                this.SchemaVersion='ARA_VER_19_03';
            elseif strcmp(adaptiveSchema,'R19-11')
                this.SchemaVersion='ARA_VER_19_11';
            elseif strcmp(adaptiveSchema,'R20-11')
                this.SchemaVersion='ARA_VER_20_11';
            else
                this.SchemaVersion='ARA_VER_19_11';
            end

            autosar.mm.util.validateM3iArg(m3iModel,...
            'Simulink.metamodel.foundation.Domain');
            autosar.mm.util.validateArg(araFilesLocation,'char');
            this.M3iModel=m3iModel;
            this.M3IComponent=autosar.api.Utils.m3iMappedComponent(modelName);
            this.ARAFilesLocation=araFilesLocation;
            this.AllBuilders={};
            this.AllWriters={};
            this.ModelName=modelName;
        end




        function createARAFiles(this,buildInfo,reportInfo)
            this.createBuilders;
            this.buildAll();
            this.createWriters(buildInfo);
            this.writeAll();

            this.addARAFilesToBuildInfo(buildInfo);

            this.addARAFilesToReport(reportInfo);
        end
    end
    methods(Access=private)







        function createBuilders(this)
            this.TypeBuilder=autosar.mm.mm2ara.TypeBuilder(this,this.M3IComponent);
            this.ServiceInterfaceBuilder=autosar.mm.mm2ara.ServiceInterfaceBuilder(this,this.M3IComponent,this.ModelName);
            this.AllBuilders={this.ServiceInterfaceBuilder,this.TypeBuilder};
        end





        function createWriters(this,buildInfo)
            this.ServiceInterfaceWriter=autosar.mm.mm2ara.ServiceInterfaceWriter(...
            this.ServiceInterfaceBuilder,this.SchemaVersion);
            this.TypeWriter=autosar.mm.mm2ara.TypeWriter(this.TypeBuilder,...
            this.SchemaVersion,...
            buildInfo.Settings.LocalAnchorDir);
            this.AllWriters={this.ServiceInterfaceWriter,this.TypeWriter};
        end



        function buildAll(this)
            for builderIdx=1:length(this.AllBuilders)
                builder=this.AllBuilders{builderIdx};
                builder.build;
            end
        end



        function writeAll(this)
            for writerIdx=1:length(this.AllWriters)
                this.AllWriters{writerIdx}.write;
            end
        end

        function addARAFilesToBuildInfo(this,buildInfo)

            autosar.mm.mm2ara.ARAGenerator.addStaticARAHeaderFilesToBuildInfo(buildInfo);
            this.addGeneratedARAFilesToBuildInfo(buildInfo);
        end

        function addGeneratedARAFilesToBuildInfo(this,buildInfo)


            for writerIdx=1:length(this.AllWriters)
                araFiles=this.AllWriters{writerIdx}.getWrittenFiles;
                for fileIdx=1:length(araFiles)
                    araFile=araFiles{fileIdx};
                    [filePath,fileName,fileExt]=fileparts(araFile);
                    araFileNoPath=[fileName,fileExt];
                    isHeader=strcmp(fileExt,'.h');
                    if isHeader

                        buildInfo.addIncludeFiles(araFileNoPath,filePath);
                    else

                        buildInfo.addSourceFiles(araFileNoPath,filePath);
                    end
                end
            end
            toolchain=get_param(this.ModelName,'Toolchain');

            if strcmp(toolchain,'AUTOSAR Adaptive | CMake')
                buildInfo.addIncludePaths(fullfile(matlabroot,'bin',computer('arch'),'fastrtps','include'));
            end
        end

        function addARAFilesToReport(this,reportInfo)

            autosar.mm.mm2ara.ARAGenerator.addStaticARAHeaderFilesToReport(reportInfo);
            this.addGeneratedARAFilesToReport(reportInfo);
        end

        function addGeneratedARAFilesToReport(this,reportInfo)

            araFiles=[];
            for writerIdx=1:length(this.AllWriters)
                araFiles=[araFiles,this.AllWriters{writerIdx}.getWrittenFiles];%#ok<AGROW>
            end


            for fileIdx=1:length(araFiles)
                araFile=araFiles{fileIdx};
                [p,f,e]=fileparts(araFile);
                if strcmp(e,'.h')
                    fileType='header';
                else
                    fileType='source';
                end



                groupName=autosarcore.getARAFilesReportGroupName;
                reportInfo.addFileInfo([f,e],groupName,fileType,p);
            end
        end
    end
end



