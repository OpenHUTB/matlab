



classdef TclEmitter<handle



    properties

        TclFileName='';


        CustomTclFileName='';


        tclNewProject='';
        tclAreaObjective={};
        tclSpeedObjective={};
        tclCompileObjective={};
        tclOpenProject='';
        tclCloseProject='';
        tclSetProject='';
        tclRemoveIOBuffer='';
        tclAddSourceFile='';
        tclAddSourceFileBegin='';
        tclAddSourceFileForPre='';
        tclAddSourceFileForPost='';
        tclAddSourceFileEnd='';
        tclPostFileAdd='';
        tclSourceTop='';

        rootModuleName='';
        tclSaveProject='';
        createSmartDesign='';
        generateComp='';
        instantiateModule='';
        connectPinPort='';

        tclAddSimFile='';
        tclAddSimFileBegin='';
        tclAddSimFileForPre='';
        tclAddSimFileForPost='';
        tclAddSimFileEnd='';
        tclPostSimFileAdd='';
        tclSimTop='';
        tclExternalSimScriptGen='';
        tclExternalSimScriptsPostFix='';
        tclRemoveSourceFile='';
        tclSourceExtTclFileBegin='';
        tclAddSDCFile='';
        tclAddXDCFile='';
        tclAddInternalTclFile='';
        tclCoeDir='';
        tclCoeDirSetName='';
        tclCreateCoeDir='';
        tclCreateLibrary='';
        tclAddLibrarySpec='';
        tclDoNotTrimUnconnected='';
    end

    properties(Access=protected,Hidden=true)

        hToolDriver=0;
    end

    methods

        function obj=TclEmitter(hToolDriver)

            obj.hToolDriver=hToolDriver;
        end




        function printSetProjectObjective(obj,fid)
            objective=obj.hToolDriver.hD.getObjectiveObject;
            if(objective~=hdlcoder.Objective.None)

                if~strcmpi(obj.hToolDriver.hTool.ToolName,'Microchip Libero SoC')
                    fprintf(fid,'# Set project objective\n');
                    switch(objective)
                    case hdlcoder.Objective.AreaOptimized
                        fprintf(fid,'%s\n',obj.tclAreaObjective{:});
                    case hdlcoder.Objective.SpeedOptimized
                        fprintf(fid,'%s\n',obj.tclSpeedObjective{:});
                    case hdlcoder.Objective.CompileOptimized
                        fprintf(fid,'%s\n',obj.tclCompileObjective{:});
                    end

                    fprintf(fid,'\n');
                end
            end
        end

        function updateCreateProjectTcl(obj)



            allSrcFileList=obj.hToolDriver.getFinalSrcFileList;


            for ii=1:length(allSrcFileList)
                checkSrcFilePath=allSrcFileList{ii};
                if~exist(checkSrcFilePath,'file')
                    error(message('hdlcommon:workflow:InvalidSrcFile',checkSrcFilePath));
                end
            end


            obj.createProjectDir;


            obj.tclAddSourceFile={};
            obj.tclAddSimFile={};


            subModelData=obj.hToolDriver.hD.hCodeGen.SubModelData;
            numSubModels=numel(subModelData);


            hdlcoderHandle=obj.hToolDriver.hD.hCodeGen.hCHandle;

            if strcmpi(obj.hToolDriver.hTool.ToolName,'Microchip Libero SoC')...
                &&(numSubModels>0)...
                &&strcmpi(hdlcoderHandle.getParameter('target_language'),'VHDL')


                error(message('hdlcommon:workflow:ModelRefUnsupportedLiberoSoC'));
            end

            startIdx=1;
            for ii=1:numSubModels

                if~strcmpi(obj.hToolDriver.hTool.ToolName,'Xilinx Vivado')


                    obj.tclAddSourceFile{end+1}=[obj.tclCreateLibrary,subModelData(ii).LibName];
                end
                stopIdx=startIdx+numel(subModelData(ii).FileNames)-1;

                obj.createTclFileList(allSrcFileList(startIdx:stopIdx),...
                subModelData(ii).LibName);
                startIdx=stopIdx+1;
            end


            if strcmpi(hdlcoderHandle.getParameter('target_language'),'VHDL')
                vhdlLibraryName=hdlcoderHandle.getParameter('vhdl_library_name');



                if strcmpi(vhdlLibraryName,'work')&&~hdlcoderHandle.getParameter('use_single_library')
                    vhdlLibraryName=[];
                else
                    if~strcmpi(obj.hToolDriver.hTool.ToolName,'Xilinx Vivado')


                        obj.tclAddSourceFile{end+1}=[obj.tclCreateLibrary,vhdlLibraryName];
                    end
                end
            else
                vhdlLibraryName=[];
            end

            obj.createTclFileList(allSrcFileList(startIdx:end),vhdlLibraryName);
        end

        function generateTcl(obj,stages)






            TclFilePath=fullfile(obj.hToolDriver.getProjectPath,...
            obj.TclFileName);
            fid=obj.createTclFile(TclFilePath);

            obj.printSetGlobalTcl(fid);


            if stages(1)~=obj.hToolDriver.hEngine.sidx.CreateProject
                obj.printOpenProjectTclNoIndent(fid);
            end

            for ii=1:length(stages)
                cstage=stages(ii);
                if cstage==obj.hToolDriver.hEngine.sidx.CreateProject
                    obj.printCreateProjectTcl(fid);
                else
                    obj.printWorkflowTcl(fid,cstage);
                end
            end

            obj.printCloseProjectTcl(fid);
            fclose(fid);
        end

        function generateCustomTcl(obj)



            obj.CustomTclFileName=[obj.hToolDriver.hD.hCodeGen.EntityTop,'_CustomTcl_run.tcl'];
            customTclFilePath=fullfile(obj.hToolDriver.getProjectPath,obj.CustomTclFileName);
            fid=obj.createTclFile(customTclFilePath);

            obj.printSetGlobalTcl(fid);


            obj.printOpenProjectTclNoIndent(fid);


            obj.printRunCustomTcl(fid);


            obj.printCloseProjectTcl(fid);
            fclose(fid);
        end

        function fid=createTclFile(obj,TclFilePath)


            currentDir=pwd;
            cd(obj.hToolDriver.hTool.CurrentDir);
            obj.createProjectDir;

            fid=fopen(TclFilePath,'w');
            if fid==-1
                error(message('hdlcommon:workflow:UnableCreateTclFile',TclFilePath));
            end
            cd(currentDir);
        end

        function createProjectDir(obj)

            projectDir=obj.hToolDriver.getProjectPath;
            downstream.tool.createDir(projectDir);
        end


        function relativePath=getRelativeFolderPath(obj,fromPath,targetPath,skipValidation)
            if nargin<4
                skipValidation=false;
            end






            relativePath='';


            absFromPath=obj.getAbsoluteFolderPath(fromPath,skipValidation);
            absTargetPath=obj.getAbsoluteFolderPath(targetPath,skipValidation);


            fromPathCell=regexp(absFromPath,filesep,'split');
            targetPathCell=regexp(absTargetPath,filesep,'split');


            fromPathCell(strcmp(fromPathCell,''))=[];
            targetPathCell(strcmp(targetPathCell,''))=[];


            if~isempty(fromPathCell)&&~isempty(targetPathCell)
                if~obj.comparePathStr(fromPathCell{1},targetPathCell{1})
                    relativePath=absTargetPath;
                    return;
                end
            end


            while~isempty(fromPathCell)&&~isempty(targetPathCell)
                if obj.comparePathStr(fromPathCell{1},targetPathCell{1})
                    fromPathCell(1)=[];
                    targetPathCell(1)=[];
                else
                    break;
                end
            end


            if isempty(fromPathCell)&&isempty(targetPathCell)
                relativePath=sprintf('%s.%s',relativePath,filesep);
            end


            for ii=1:length(fromPathCell)
                relativePath=sprintf('%s..%s',relativePath,filesep);
            end


            for ii=1:length(targetPathCell)
                relativePath=sprintf('%s%s%s',relativePath,targetPathCell{ii},filesep);
            end

            if~skipValidation

                currentPath=pwd;
                cd(absFromPath);
                if~isdir(relativePath)
                    relativePath=absTargetPath;
                end
                cd(currentPath);
            end
        end

    end

    methods(Access=protected)

        function isequal=comparePathStr(~,pathStr1,pathStr2)
            isequal=strcmp(pathStr1,pathStr2)||...
            (strcmpi(pathStr1,pathStr2)&&ispc);
        end

        function absolutePath=getAbsoluteFolderPath(~,folderPath,skipValidation)
            if nargin<3
                skipValidation=false;
            end





            if skipValidation
                absolutePath=fullfile(pwd,folderPath);
                return
            end

            currentPath=pwd;
            if isdir(folderPath)
                cd(folderPath);
                absolutePath=pwd;
                cd(currentPath);
            else
                error(message('hdlcommon:workflow:DownstreamInvalidDirectory',folderPath));
            end
        end


        function printSetGlobalTcl(obj,fid)
            fprintf(fid,'# HDL Coder Downstream Integration Tcl Script\n\n');
            fprintf(fid,'set myTool "%s"\n',[obj.hToolDriver.hD.get('Tool'),' ',obj.hToolDriver.getToolVersion]);
            fprintf(fid,'set myProject "%s"\n',obj.hToolDriver.hTool.ProjectName);
            fprintf(fid,'set myProjectFile "%s"\n',obj.hToolDriver.hTool.ProjectFileName);
            fprintf(fid,'set myTopLevelEntity "%s"\n',obj.hToolDriver.hD.hCodeGen.EntityTop);

            isLiberoSoc=obj.hToolDriver.hD.isLiberoSoc;
            liberoToolVersion=obj.hToolDriver.getToolVersion;
            if isLiberoSoc&&isequal(liberoToolVersion,'12.6')
                fprintf(fid,'set mySmartDesign "design_1" \n\n');
            end

            for ii=1:length(obj.hToolDriver.OptionList)
                hOption=obj.hToolDriver.OptionList{ii};
                optionID=hOption.OptionID;
                if~strcmp(optionID,'Tool')&&~strcmp(optionID,'Board')
                    fprintf(fid,'set %s "%s"\n',optionID,hOption.Value);
                end
            end
            fprintf(fid,'\n');
        end

        function printNewProjectTcl(obj,fid)
            fprintf(fid,'    # Create new project\n');
            if obj.hToolDriver.hD.hCodeGen.isMLHDLC
                fprintf(fid,'    puts "### Create new $myTool project <a href=\\"matlab:downstream.handle(''Model'',''%s'',''isMLHDLC'',''%d'').openTargetTool;\\">%s</a>"\n',...
                obj.hToolDriver.hD.hCodeGen.ModelName,obj.hToolDriver.hD.hCodeGen.isMLHDLC,obj.getProjectPathTcl);
            else
                fprintf(fid,'    puts "### Create new $myTool project <a href=\\"matlab:downstream.handle(''Model'',''%s'').openTargetTool;\\">%s</a>"\n',...
                obj.hToolDriver.hD.hCodeGen.ModelName,obj.getProjectPathTcl);
            end



            if strcmpi(obj.hToolDriver.hTool.ToolName,'Microchip Libero SoC')

                hdlcoderHandle=obj.hToolDriver.hD.hCodeGen.hCHandle;
                if obj.hToolDriver.hD.hCodeGen.isMLHDLC
                    projectDir=fullfile(obj.hToolDriver.getProjectPath);
                else
                    projectDir=fullfile(pwd,obj.hToolDriver.getProjectPath);
                end

                fprintf(fid,'    set HDL "%s"\n',hdlcoderHandle.getParameter('target_language'));
                fprintf(fid,'    set ProjectDir "%s"\n',strrep(projectDir,'\','\\'));
            end

            fprintf(fid,'    %s\n',obj.tclNewProject{:});
            fprintf(fid,'\n');
        end

        function printOpenProjectTcl(obj,fid)
            fprintf(fid,'    # Open existing project\n');

            if obj.hToolDriver.hD.hCodeGen.isMLHDLC
                fprintf(fid,'    puts "### Open existing $myTool project <a href=\\"matlab:downstream.handle(''Model'',''%s'',''isMLHDLC'',''%d'').openTargetTool;\\">%s</a>"\n',...
                obj.hToolDriver.hD.hCodeGen.ModelName,obj.hToolDriver.hD.hCodeGen.isMLHDLC,obj.getProjectPathTcl);
            else
                fprintf(fid,'    puts "### Open existing $myTool project <a href=\\"matlab:downstream.handle(''Model'',''%s'').openTargetTool;\\">%s</a>"\n',...
                obj.hToolDriver.hD.hCodeGen.ModelName,obj.getProjectPathTcl);
            end

            if strcmpi(obj.hToolDriver.hTool.ToolName,'Microchip Libero SoC')
                if obj.hToolDriver.hD.hCodeGen.isMLHDLC
                    projectDir=fullfile(obj.hToolDriver.getProjectPath);
                else
                    projectDir=fullfile(pwd,obj.hToolDriver.getProjectPath);
                end
                fprintf(fid,'    set ProjectDir "%s"\n',strrep(projectDir,'\','\\'));
            end

            fprintf(fid,'    %s\n',obj.tclOpenProject{:});
            fprintf(fid,'\n');
        end

        function projPathTcl=getProjectPathTcl(obj)
            isLiberoSoC=strcmpi(obj.hToolDriver.hTool.ToolName,'Microchip Libero SoC');

            if isLiberoSoC
                projPath=fullfile(obj.hToolDriver.hTool.ProjectDir,obj.hToolDriver.hTool.ProjectName,obj.hToolDriver.hTool.ProjectFileName);
            else
                projPath=fullfile(obj.hToolDriver.hTool.ProjectDir,obj.hToolDriver.hTool.ProjectFileName);
            end
            projPathTcl=strrep(projPath,'\','\\');
            projPathTcl=strrep(projPathTcl,'/','\/');
        end

        function printAddSourceFileTcl(obj,fid)




            isISE=strcmpi(obj.hToolDriver.hTool.ToolName,'Xilinx ISE');
            isVivado=strcmpi(obj.hToolDriver.hTool.ToolName,'Xilinx Vivado');
            isQuartus=strcmpi(obj.hToolDriver.hTool.ToolName,'Altera QUARTUS II');
            isLiberoSoC=strcmpi(obj.hToolDriver.hTool.ToolName,'Microchip Libero SoC');
            isIntelquartuspro=strcmpi(obj.hToolDriver.hTool.ToolName,'Intel Quartus Pro');


            fprintf(fid,'# Add HDL source files\n');
            fprintf(fid,'puts "### Update $myTool project with HDL source files"\n');


            if(isISE||isVivado||isQuartus||isLiberoSoC||isIntelquartuspro)
                projectDir=obj.hToolDriver.getProjectPath;
                codegenDir=obj.hToolDriver.hD.hCodeGen.CodegenDir;
                codegenDir=strrep(codegenDir,'\','/');
                srcFileRelativeFolder=obj.getRelativeFolderPath(projectDir,codegenDir);
                srcFileRelativeFolder=strrep(srcFileRelativeFolder,'\','/');






                cgInfoObj=obj.hToolDriver.hD.hCodeGen.getBackupCgInfo;
                if(isempty(cgInfoObj))
                    cgInfoObj=obj.hToolDriver.hD.hCodeGen.hCHandle.cgInfo;
                end

                if isIntelquartuspro
                    fprintf(fid,'%s\n',obj.tclAddSourceFile{:});
                elseif isQuartus
                    fprintf(fid,'%s\n',obj.tclAddSourceFile{:});

                    hdlSynthCmd=['set_global_assignment -name VHDL_FILE ',srcFileRelativeFolder,'%s\n'];

                    fprintf(fid,'%s',...
                    targetcodegen.alteradspbadriver.getDSPBASynthesisScripts(hdlSynthCmd,...
                    cgInfoObj));
                elseif(isISE)
                    fprintf(fid,'%s\n',obj.tclAddSourceFile{:});

                    hdlSynthCmd=['xfile add ',srcFileRelativeFolder,'%s\n'];
                    fprintf(fid,targetcodegen.xilinxutildriver.getTclScriptsToAddAllTargetFiles(hdlSynthCmd,cgInfoObj));


                    fprintf(fid,'%s',...
                    targetcodegen.xilinxisesysgendriver.getXSGSynthesisScripts(hdlSynthCmd,...
                    codegenDir,...
                    obj.hToolDriver.hD.hCodeGen.isVHDL,...
                    cgInfoObj));
                elseif(isVivado)
                    fprintf(fid,'%s\n',obj.tclAddSourceFile{:});


                    fprintf(fid,'%s',targetcodegen.xilinxvivadosysgendriver.getXSGSynthesisScripts(obj.hToolDriver.hD,...
                    obj.hToolDriver.getProjectPath,...
                    cgInfoObj));
                elseif(isLiberoSoC)
                    fprintf(fid,'%s\n',obj.tclAddSourceFile{:});

                    fprintf(fid,'%s\n',obj.tclSourceTop);
                    if(isequal(obj.hToolDriver.getToolVersion,'12.6'))
                        fprintf(fid,'%s\n',obj.createSmartDesign);

                        if obj.hToolDriver.hD.hCodeGen.isMLHDLC
                            hD=hdlcurrentdriver;
                            topNetwork=hD.getCurrentNetwork;
                            inputports=topNetwork.PirInputPorts;
                            outPutPorts=topNetwork.PirOutputPorts;
                        else
                            p=pir;
                            topNetwork=p.getTopNetwork;
                            inputports=topNetwork.PirInputPorts;
                            outPutPorts=topNetwork.PirOutputPorts;
                        end

                        if obj.hToolDriver.hD.hCodeGen.isVHDL
                            fileExtension='.vhd';
                        else
                            fileExtension='.v';
                        end

                        fprintf(fid,'%s\n',obj.tclSourceTop);
                        fprintf(fid,'save_project\n');
                        fprintf(fid,'%s %s',[obj.instantiateModule,obj.hToolDriver.hD.hCodeGen.EntityTop,fileExtension,'}']);
                        fprintf(fid,'\n');







                        for ii=1:1:length(inputports)
                            sigType=inputports(ii).Signal;
                            signalInputType=sigType.Type;
                            isVectorType=signalInputType.isArrayType;


                            if isVectorType
                                numVecElementsInput=signalInputType.Dimensions;
                                for jj=0:1:numVecElementsInput-1
                                    fprintf(fid,'%s %s%s%s',obj.connectPinPort,['{',obj.hToolDriver.hD.hCodeGen.EntityTop,'_0:',inputports(ii).Name,'[',num2str(jj),']','}']);
                                    fprintf(fid,'\n');
                                end
                            else
                                fprintf(fid,'%s %s%s',[obj.connectPinPort,'{',obj.hToolDriver.hD.hCodeGen.EntityTop,'_0:',inputports(ii).Name,'}']);
                                fprintf(fid,'\n');
                            end
                        end

                        for ii=1:1:length(outPutPorts)
                            sigType=outPutPorts(ii).Signal;
                            signalOutputType=sigType.Type;
                            isVectorType=signalOutputType.isArrayType;


                            if isVectorType
                                numVecElementsInput=signalOutputType.Dimensions;
                                for jj=0:1:numVecElementsInput-1
                                    fprintf(fid,'%s %s%s%s',obj.connectPinPort,['{',obj.hToolDriver.hD.hCodeGen.EntityTop,'_0:',outPutPorts(ii).Name,'[',num2str(jj),']','}']);
                                    fprintf(fid,'\n');
                                end
                            else
                                fprintf(fid,'%s %s%s',[obj.connectPinPort,'{',obj.hToolDriver.hD.hCodeGen.EntityTop,'_0:',outPutPorts(ii).Name,'}']);
                                fprintf(fid,'\n');
                            end
                        end

                        fprintf(fid,'%s \n',obj.rootModuleName);
                        fprintf(fid,'%s\n',obj.generateComp);
                        fprintf(fid,'%s\n',obj.tclSourceTop);
                    end
                end
            end
        end

        function printRemoveSourceFileTcl(obj,fid)
            fprintf(fid,'    # Remove Old HDL source files\n');
            fprintf(fid,'    %s\n',obj.tclRemoveSourceFile{:});
            fprintf(fid,'\n');
        end

        function printSetProjectTcl(obj,fid)
            if~strcmpi(obj.hToolDriver.hTool.ToolName,'Microchip Libero SoC')
                fprintf(fid,'# Set project properties\n');
                fprintf(fid,'puts "### Set $myTool project properties"\n');
                fprintf(fid,'%s\n',obj.tclSetProject{:});
                fprintf(fid,'\n');
            end
        end


        function printCreateProjectTcl(obj,fid)



            if~strcmpi(obj.hToolDriver.hTool.ToolName,'Microchip Libero SoC')
                fprintf(fid,'if { ! [ file exists $myProjectFile ] } {\n');
            else
                fprintf(fid,'if { ! [ file exists $myProject ] } {\n');
            end


            obj.printNewProjectTcl(fid);
            fprintf(fid,'} else {\n');

            obj.printOpenProjectTcl(fid);
            obj.printRemoveSourceFileTcl(fid);
            fprintf(fid,'}\n\n');

            obj.printSetProjectObjective(fid);
            obj.printSetProjectTcl(fid);
            obj.printAddSourceFileTcl(fid);
            obj.printPostSourceFileAddTcl(fid);
            obj.printQueryFlowSpecific(fid);
        end

        function printOpenProjectTclNoIndent(obj,fid)
            fprintf(fid,'# Open existing project\n');
            fprintf(fid,'puts "### Open existing $myTool project %s"\n',obj.getProjectPathTcl);

            if strcmpi(obj.hToolDriver.hTool.ToolName,'Microchip Libero SoC')
                if obj.hToolDriver.hD.hCodeGen.isMLHDLC
                    projectDir=fullfile(obj.hToolDriver.getProjectPath);
                else
                    projectDir=fullfile(pwd,obj.hToolDriver.getProjectPath);
                end
                fprintf(fid,'    set ProjectDir "%s"\n',strrep(projectDir,'\','\\'));
            end

            fprintf(fid,'%s\n',obj.tclOpenProject{:});
            fprintf(fid,'\n');
        end

        function printCloseProjectTcl(obj,fid)
            fprintf(fid,'# Close project\n');
            fprintf(fid,'puts "### Close $myTool project."\n');
            fprintf(fid,'%s\n',obj.tclCloseProject{:});
            fprintf(fid,'\n');
        end

        function printWorkflowTcl(obj,fid,stageIdx)

            workflowID=obj.hToolDriver.hEngine.getStageID(stageIdx);
            hWorkflow=obj.hToolDriver.hD.getWorkflow(workflowID);
            if~isempty(hWorkflow.TclTemplate)&&~hWorkflow.Skipped
                fprintf(fid,'# Running %s\n',workflowID);
                fprintf(fid,'puts "### Running %s in $myTool ..."\n',workflowID);
                if(strcmpi(workflowID,'PostMapTiming')&&obj.hToolDriver.hD.hCodeGen.hCHandle.getParameter('LatencyConstraint')~=0)

                    if(strcmpi(obj.hToolDriver.hTool.ToolName,'Xilinx ISE'))

                        fprintf(fid,'project set "Report Unconstrained Paths" 3 -process "Generate Post-Map Static Timing"\n');
                    end
                end
                fprintf(fid,'%s\n',hWorkflow.TclTemplate{:});
                fprintf(fid,'puts "### %s Complete."\n',workflowID);
                fprintf(fid,'\n');
            end
        end

        function printQueryFlowSpecific(obj,fid)
            if obj.hToolDriver.hD.queryFlowOnly==downstream.queryflowmodesenum.NONE
                return
            else
                obj.hToolDriver.hD.queryFlowOnly.driveTclEmitter(obj,fid);
            end
        end

        function printRunCustomTcl(obj,fid)

            fprintf(fid,'puts "### Run custom Tcl files"\n');
            customTclFiles=obj.hToolDriver.hTool.CustomTclFile;
            for ii=1:length(customTclFiles)
                tclFilePath=customTclFiles{ii};
                tclStr=fileread(tclFilePath);
                fprintf(fid,'%s',tclStr);
                fprintf(fid,'\n');
            end
        end

        function printPostSourceFileAddTcl(obj,fid)
            if~isempty(obj.tclPostFileAdd)
                fprintf(fid,'%s\n',obj.tclPostFileAdd{:});
                fprintf(fid,'\n');
            end

            if obj.hToolDriver.hD.hCodeGen.hCHandle.getParameter('backannotation')&&~isempty(obj.tclRemoveIOBuffer)
                fprintf(fid,'%s\n',obj.tclRemoveIOBuffer{:});
            else
                fc=obj.hToolDriver.hD.hCodeGen.hCHandle.getParameter('FloatingPointTargetConfiguration');
                if(isempty(fc))
                    mode='NONE';
                else
                    mode=fc.Library;
                end

                if strcmpi(mode,'XILINXLOGICORE')
                    fprintf(fid,'%s\n',obj.tclDoNotTrimUnconnected{:});
                end
            end


        end

        function printPostSimFileAddTcl(obj,fid)
            if~isempty(obj.tclPostSimFileAdd)&&~isempty(obj.tclAddSimFile)
                fprintf(fid,'%s\n',obj.tclPostSimFileAdd{:});
                fprintf(fid,'\n');
            end
        end


        function createTclSimFileList(obj,fileList)

            obj.tclAddSimFile=[obj.tclAddSimFile,generateTclSimFileList(obj,fileList)];
        end

        function createTclFileList(obj,fileList,libName)

            obj.tclAddSourceFile=[obj.tclAddSourceFile,generateTclFileList(obj,fileList,libName)];
        end
    end



    methods
        function tclAddSourceFile=generateTclFileList(obj,fileList,libName,fromDir,skipPathValidation)

            if nargin<5
                skipPathValidation=false;
            end

            if nargin<4

                fromDir=obj.hToolDriver.getProjectPath;
            end

            tclAddSourceFile={};
            genForAltera=strcmpi(obj.hToolDriver.hTool.ToolName,'Altera QUARTUS II');
            genForXilinx=strcmpi(obj.hToolDriver.hTool.ToolName,'Xilinx ISE');
            genForVivado=strcmpi(obj.hToolDriver.hTool.ToolName,'Xilinx Vivado');
            genForLiberoSoC=strcmpi(obj.hToolDriver.hTool.ToolName,'Microchip Libero SoC');
            genForIntelquartusPro=strcmpi(obj.hToolDriver.hTool.ToolName,'Intel Quartus Pro');

            list_of_files='';


            if((genForAltera||genForIntelquartusPro)&&~isempty(libName))
                postString=[' ',obj.tclAddLibrarySpec,libName];
            else
                postString=obj.tclAddSourceFileForPost;
            end


            tclAddSourceFile{end+1}=obj.tclAddSourceFileBegin;

            hCodeGen=obj.hToolDriver.hD.hCodeGen;

            for ii=1:numel(fileList)
                srcFilePath=fileList{ii};

                [srcFileFolder,srcFileName,srcFileExt]=fileparts(srcFilePath);
                if isempty(srcFileFolder)
                    srcFileFolder='.';
                end


                srcFileRelativeFolder=obj.getRelativeFolderPath(fromDir,srcFileFolder,skipPathValidation);
                srcFileRelativePath=fullfile(srcFileRelativeFolder,[srcFileName,srcFileExt]);

                if genForIntelquartusPro&&strcmpi(srcFileExt,'.vhd')
                    if contains(srcFileFolder,'altera_fp_functions')
                        [~,libName,~]=fileparts(srcFileFolder);
                        postString=sprintf(' -library %s',libName);
                    end
                end

                if strcmpi(srcFileExt,'.sdc')&&~isempty(obj.tclAddSDCFile)
                    tclAddSourceFile{end+1}=sprintf('%s"%s"%s',...
                    obj.tclAddSDCFile,...
                    strrep(srcFileRelativePath,'\','/'),...
                    postString);
                elseif strcmpi(srcFileExt,'.qsf')&&~isempty(obj.tclAddInternalTclFile)

                    tclAddSourceFile{end+1}=sprintf('%s"%s"',...
                    obj.tclAddInternalTclFile,...
                    strrep(srcFileRelativePath,'\','/'));

                else
                    if genForAltera||genForIntelquartusPro

                        if strcmpi(srcFileExt,hCodeGen.getVHDLExt)
                            hdlType='VHDL_FILE';
                        elseif strcmpi(srcFileExt,hCodeGen.getVerilogExt)
                            hdlType='VERILOG_FILE';
                        elseif strcmpi(srcFileExt,'.tcl')
                            hdlType='TCL_SCRIPT_FILE';
                        else
                            error(message('hdlcommon:workflow:UnsupportedFileExt',srcFilePath));
                        end
                        tclAddSourceFileForPreAltera=sprintf('%s%s ',obj.tclAddSourceFileForPre,hdlType);
                        tclAddSourceFile{end+1}=sprintf('%s"%s"%s',...
                        tclAddSourceFileForPreAltera,...
                        strrep(srcFileRelativePath,'\','/'),...
                        postString);
                    else
                        tt1=strrep(srcFileRelativePath,'\','/');

                        if genForVivado
                            if strcmpi(srcFileExt,'.xdc')
                                tclAddSourceFile{end+1}=sprintf('%s{%s}%s',...
                                obj.tclAddXDCFile,...
                                tt1,...
                                postString);
                            else
                                tclAddSourceFile{end+1}=sprintf('%s{%s}%s',...
                                obj.tclAddSourceFileForPre,...
                                tt1,...
                                postString);
                                list_of_files=[list_of_files,' ',tt1];
                            end
                        elseif(genForLiberoSoC)
                            if strcmpi(srcFileExt,'.sdc')
                                tclAddSourceFile{end+1}=sprintf('%s%s {%s}%s',...
                                obj.tclAddSourceFileForPre,...
                                '-sdc',...
                                tt1,...
                                postString);
                            elseif strcmpi(srcFileExt,'.pdc')
                                tclAddSourceFile{end+1}=sprintf('%s%s {%s}%s',...
                                obj.tclAddSourceFileForPre,...
                                '-io_pdc',...
                                tt1,...
                                postString);
                            elseif strcmpi(srcFileExt,hCodeGen.getVerilogExt)||strcmpi(srcFileExt,hCodeGen.getVHDLExt)
                                tclAddSourceFile{end+1}=sprintf('%s%s {%s}%s',...
                                obj.tclAddSourceFileForPre,...
                                '-hdl_source',...
                                tt1,...
                                postString);
                            end
                        else
                            tclAddSourceFile{end+1}=sprintf('%s"%s"%s',...
                            obj.tclAddSourceFileForPre,...
                            tt1,...
                            postString);
                        end
                    end
                end
            end


            if genForXilinx&&~isempty(libName)
                tclAddSourceFile{end+1}=sprintf('%s%s%s%s',...
                obj.tclAddSourceFileForPre,obj.tclAddLibrarySpec,...
                libName,obj.tclAddSourceFileForPost);
            end

            if genForXilinx||genForVivado||(genForAltera)||genForLiberoSoC||genForIntelquartusPro
                tclAddSourceFile{end+1}=obj.tclAddSourceFileEnd;
            end

            if genForVivado&&~isempty(libName)&&~isempty(list_of_files)
                files=strsplit(strtrim(list_of_files),' ');
                supportsLibrary=true;
                if numel(files)>0
                    [~,~,srcFileExt1]=fileparts(files{1});
                    if strcmpi(srcFileExt1,hCodeGen.getVerilogExt)
                        supportsLibrary=false;
                    end
                end
                if supportsLibrary==true
                    tclAddSourceFile{end+1}=['set_property library ',libName,' [get_files {',list_of_files,'}]'];
                end
            end
        end

        function tclAddSimFile=generateTclSimFileList(obj,fileList,fromDir)
            if nargin<3

                fromDir=obj.hToolDriver.getProjectPath;
            end
            tclAddSimFile={};

            genForVivado=strcmpi(obj.hToolDriver.hTool.ToolName,'Xilinx Vivado');
            if~genForVivado
                return
            end


            tclAddSimFile{end+1}=obj.tclAddSimFileBegin;



            for ii=1:numel(fileList)
                srcFilePath=fileList{ii};

                [srcFileFolder,srcFileName,srcFileExt]=fileparts(srcFilePath);
                if isempty(srcFileFolder)
                    srcFileFolder='.';
                end


                srcFileRelativeFolder=obj.getRelativeFolderPath(fromDir,srcFileFolder);
                srcFileRelativePath=fullfile(srcFileRelativeFolder,[srcFileName,srcFileExt]);

                tt1=strrep(srcFileRelativePath,'\','/');
                tclAddSimFile{end+1}=sprintf('%s"%s"%s',...
                obj.tclAddSimFileForPre,...
                tt1,...
                obj.tclAddSimFileForPost);


            end


            tclAddSimFile{end+1}=obj.tclAddSimFileEnd;
        end

        function tclSourceExtTclFile=generateSourceExtTclFileList(obj,fileList,fromDir)
            if nargin<4

                fromDir=obj.hToolDriver.getProjectPath;
            end
            tclSourceExtTclFile={};

            genForVivado=strcmpi(obj.hToolDriver.hTool.ToolName,'Xilinx Vivado');

            if~genForVivado
                return
            end


            for ii=1:numel(fileList)
                srcFilePath=fileList{ii};

                [srcFileFolder,srcFileName,srcFileExt]=fileparts(srcFilePath);
                if isempty(srcFileFolder)
                    srcFileFolder='.';
                end


                srcFileRelativeFolder=obj.getRelativeFolderPath(fromDir,srcFileFolder);
                srcFileRelativePath=fullfile(srcFileRelativeFolder,[srcFileName,srcFileExt]);

                tt1=strrep(srcFileRelativePath,'\','/');
                tclSourceExtTclFile{end+1}=sprintf('%s"%s"',...
                obj.tclSourceExtTclFileBegin,...
                tt1);
            end
        end

        function[tclCreateCoeDir,tclCoeDir,tclCoeDirSetName]=generateTclCreateCoeDir(obj)
            tclCreateCoeDir=sprintf('%s\n',obj.tclCreateCoeDir{:});
            tclCoeDirSetName=obj.tclCoeDirSetName;
            tclCoeDir=obj.tclCoeDir;
        end

        function printAddSimFileTcl(obj,fid)


            if(strcmpi(obj.hToolDriver.hTool.ToolName,'Xilinx Vivado'))
                codegenDir=obj.hToolDriver.hD.hCodeGen.CodegenDir;
                codegenDir=strrep(codegenDir,'\','/');






                cgInfoObj=obj.hToolDriver.hD.hCodeGen.getBackupCgInfo;
                if(isempty(cgInfoObj))
                    cgInfoObj=obj.hToolDriver.hD.hCodeGen.hCHandle.cgInfo;
                end

                if isfield(cgInfoObj,'hdlTbFiles')&&~isempty(cgInfoObj.hdlTbFiles)
                    hdlTbFilesFullPath=fullfile(codegenDir,cgInfoObj.hdlTbFiles);
                    obj.createTclSimFileList(hdlTbFilesFullPath);

                    fprintf(fid,'# Add HDL simulation source files\n');
                    fprintf(fid,'puts "### Update $myTool project with HDL simulation source files"\n');
                    fprintf(fid,'%s\n',obj.tclAddSimFile{:});
                    obj.printPostSimFileAddTcl(fid);
                end
            end
        end


        function printSetSourceTop(obj,fid)
            if strcmpi(obj.hToolDriver.hTool.ToolName,'Xilinx Vivado')
                fprintf(fid,'%s\n',obj.tclSourceTop);
            end
        end

        function printSetSimTop(obj,fid)
            if strcmpi(obj.hToolDriver.hTool.ToolName,'Xilinx Vivado')
                fprintf(fid,'%s\n',obj.tclSimTop);
            end
        end

        function printExternalSimScriptGen(obj,fid)
            if strcmpi(obj.hToolDriver.hTool.ToolName,'Xilinx Vivado')
                fprintf(fid,'%s\n',obj.tclExternalSimScriptGen{:});
            end
        end
    end
end



