classdef RTEGenerator<handle





    properties(Access='private')
        M3iModel;
        M3IComponent;
        AllBuilders;
        AllWriters;
        ModelHeaderFileName;
        AutosarMaxShortNameLength;
    end

    properties(SetAccess='private',GetAccess='public')

        ASWCBuilder;
        TypeBuilder;
        CfgBuilder;
        PbCfgBuilder;
        MemMapBuilder;

        ASWCWriter;
        TypeWriter;
        CfgWriter;
        PbCfgWriter;
        MemMapWriter;

        SchemaVer;
        RTEFilesLocation;

        ErrorStatusPortTable;
        SignalInvalidationPortTable;
    end

    properties(Constant)
        StaticRTEHeaderFiles={'Platform_Types.h','Std_Types.h','Compiler.h'};
        StaticRTEHeaderPath=fullfile(autosarroot,'rte');
    end

    methods
        function this=RTEGenerator(m3iModel,m3iComp,schemaVer,rteFilesLocation,...
            modelHeaderFileName,maxShortNameLength,...
            errorStatusPortTable,signalInvalidationPortTable)


            autosar.mm.util.validateM3iArg(m3iModel,...
            'Simulink.metamodel.foundation.Domain');
            autosar.mm.util.validateArg(schemaVer,'char');
            autosar.mm.util.validateArg(rteFilesLocation,'char');
            autosar.mm.util.validateArg(modelHeaderFileName,'char');

            autosar.mm.util.validateArg(maxShortNameLength,'double');
            autosar.mm.util.validateArg(errorStatusPortTable,'autosar.mm.mm2rte.ErrorStatusPortTable');
            autosar.mm.util.validateArg(signalInvalidationPortTable,'autosar.mm.mm2rte.SignalInvalidationPortTable');

            this.M3iModel=m3iModel;
            this.M3IComponent=m3iComp;
            this.SchemaVer=schemaVer;
            this.AutosarMaxShortNameLength=maxShortNameLength;
            this.ModelHeaderFileName=modelHeaderFileName;
            this.RTEFilesLocation=rteFilesLocation;
            this.ErrorStatusPortTable=errorStatusPortTable;
            this.SignalInvalidationPortTable=signalInvalidationPortTable;
            this.AllBuilders={};
            this.AllWriters={};
        end
    end

    methods(Access='public')
        function createRTEFiles(this,buildInfo,reportInfo)

            this.createBuilders(buildInfo.ComponentName);
            this.buildAll;


            this.createWriters;
            this.writeAll();


            this.addRTEFilesToBuildInfo(buildInfo);


            if~isempty(reportInfo)
                this.addRTEFilesToReport(reportInfo);
            end
        end
    end

    methods(Access='private')
        function createBuilders(this,modelName)

            this.TypeBuilder=autosar.mm.mm2rte.TypeBuilder(this,this.M3IComponent);
            this.ASWCBuilder=autosar.mm.mm2rte.ASWCBuilder(this,this.M3IComponent);
            this.CfgBuilder=autosar.mm.mm2rte.CfgBuilder(this,this.M3IComponent,modelName);
            this.PbCfgBuilder=autosar.mm.mm2rte.PbCfgBuilder(this,this.M3IComponent,modelName);
            this.MemMapBuilder=autosar.mm.mm2rte.MemMapBuilder(this,this.M3IComponent);
            this.AllBuilders={...
            this.ASWCBuilder...
            ,this.TypeBuilder...
            ,this.CfgBuilder...
            ,this.PbCfgBuilder...
            ,this.MemMapBuilder};
        end

        function createWriters(this)

            this.ASWCWriter=autosar.mm.mm2rte.ASWCWriter(this.ASWCBuilder,...
            this.ModelHeaderFileName);
            this.TypeWriter=autosar.mm.mm2rte.TypeWriter(this.TypeBuilder,...
            this.AutosarMaxShortNameLength);
            this.AllWriters={this.ASWCWriter,this.TypeWriter};



            if this.MemMapBuilder.hasRTEData
                this.MemMapWriter=autosar.mm.mm2rte.MemMapWriter(this.MemMapBuilder);
                this.AllWriters{end+1}=this.MemMapWriter;
            end

            if this.CfgBuilder.hasRTEData
                this.CfgWriter=autosar.mm.mm2rte.CfgWriter(this.CfgBuilder);
                this.AllWriters{end+1}=this.CfgWriter;
            end

            if this.PbCfgBuilder.hasRTEData
                this.ASWCWriter.RequiresPbCfg=true;
                this.PbCfgWriter=autosar.mm.mm2rte.PbCfgWriter(this.PbCfgBuilder);
                this.AllWriters{end+1}=this.PbCfgWriter;
            end
        end

        function buildAll(this)

            for builderIdx=1:length(this.AllBuilders)
                builder=this.AllBuilders{builderIdx};
                builder.build;
                builder.postBuild;
            end
        end

        function writeAll(this)

            for writerIdx=1:length(this.AllWriters)
                this.AllWriters{writerIdx}.write;
            end
        end

        function addRTEFilesToBuildInfo(this,buildInfo)

            autosar.mm.mm2rte.RTEGenerator.addStaticRTEHeaderFilesToBuildInfo(buildInfo);
            this.addGeneratedRTEFilesToBuildInfo(buildInfo);
        end

        function addGeneratedRTEFilesToBuildInfo(this,buildInfo)
            rteDir=this.RTEFilesLocation;
            buildInfo.addIncludePaths(rteDir);
            buildInfo.addSourcePaths(rteDir);



            for writerIdx=1:length(this.AllWriters)
                rteFiles=this.AllWriters{writerIdx}.getWrittenFiles;
                for fileIdx=1:length(rteFiles)
                    rteFile=rteFiles{fileIdx};
                    [~,fileName,fileExt]=fileparts(rteFile);
                    rteFileNoPath=[fileName,fileExt];
                    isHeader=strcmp(fileExt,'.h');
                    if isHeader

                        buildInfo.addIncludeFiles(rteFileNoPath,rteDir);
                    else

                        buildInfo.addSourceFiles(rteFileNoPath,rteDir);
                    end
                end
            end
        end

        function addRTEFilesToReport(this,reportInfo)

            autosar.mm.mm2rte.RTEGenerator.addStaticRTEHeaderFilesToReport(reportInfo);
            this.addGeneratedRTEFilesToReport(reportInfo);
        end

        function addGeneratedRTEFilesToReport(this,reportInfo)

            rteFiles=[];
            for writerIdx=1:length(this.AllWriters)
                rteFiles=[rteFiles,this.AllWriters{writerIdx}.getWrittenFiles];%#ok<AGROW>
            end


            for fileIdx=1:length(rteFiles)
                rteFile=rteFiles{fileIdx};
                [p,f,e]=fileparts(rteFile);
                if strcmp(e,'.h')
                    fileType='header';
                else
                    fileType='source';
                end



                groupName=autosarcore.getRTEFilesReportGroupName;
                reportInfo.addFileInfo([f,e],groupName,fileType,p);
            end
        end
    end

    methods(Static)

        function addStaticRTEHeaderFilesToBuildInfo(buildInfo)

            staticRTEHeaderPath=autosar.mm.mm2rte.RTEGenerator.StaticRTEHeaderPath;
            staticRTEHeaderFiles=autosar.mm.mm2rte.RTEGenerator.StaticRTEHeaderFiles;

            buildInfo.addIncludePaths(staticRTEHeaderPath);
            for fIdx=1:length(staticRTEHeaderFiles)
                buildInfo.addIncludeFiles(staticRTEHeaderFiles{fIdx},staticRTEHeaderPath);
            end
        end

        function addStaticRTEHeaderFilesToReport(reportInfo)

            staticRTEHeaderPath=autosar.mm.mm2rte.RTEGenerator.StaticRTEHeaderPath;
            staticRTEHeaderFiles=autosar.mm.mm2rte.RTEGenerator.StaticRTEHeaderFiles;
            rteFiles=cellfun(@(x)fullfile(staticRTEHeaderPath,x),...
            staticRTEHeaderFiles,'UniformOutput',false);


            for fileIdx=1:length(rteFiles)
                [p,f,e]=fileparts(rteFiles{fileIdx});
                fileType='header';
                groupName=autosarcore.getRTEFilesReportGroupName;
                reportInfo.addFileInfo([f,e],groupName,fileType,p);
            end
        end

        function rteSubFolder=getRTEFilesSubFolder()
            rteSubFolder='stub';
        end

        function rteDir=getRTEFilesFolder(buildDir)
            rteDir=fullfile(buildDir,...
            autosar.mm.mm2rte.RTEGenerator.getRTEFilesSubFolder);
        end

        function rteDir=createRTEFilesFolder(buildDir)


            rteDir=autosar.mm.mm2rte.RTEGenerator.getRTEFilesFolder(buildDir);
            if(exist(rteDir,'dir')==7)

                files=dir(fullfile(rteDir,'*.h'));
                for fileIdx=1:length(files)
                    rtw_delete_file(fullfile(rteDir,files(fileIdx).name));
                end
                files=dir(fullfile(rteDir,'*.c'));
                for fileIdx=1:length(files)
                    rtw_delete_file(fullfile(rteDir,files(fileIdx).name));
                end
            else
                mkdir(rteDir);
            end
        end

        function addGeneratedRTEIncludePathToSubModels...
            (buildInfo,topModelBuildDir,m3iCompName)

            rteDir=autosar.mm.mm2rte.RTEGenerator.getRTEFilesFolder(topModelBuildDir);




            addIncludePaths(buildInfo,rteDir);




            macroName='-DRTE_COMPONENT_HEADER';
            headerName=strcat('\"Rte_',m3iCompName,'.h\"');
            addDefines(buildInfo,strcat(macroName,'=',headerName),'');
            addDefines(buildInfo,'-DINCLUDE_RTE_HEADER=1','');
        end
    end
end


