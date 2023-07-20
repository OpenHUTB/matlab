


classdef PlanAheadTool<hdlturnkey.tool.XilinxEmbeddedTool


    properties


        ConstraintFiles={};

    end

    properties(Access=protected)


        ProjectFolder='pa_prj';

    end

    properties(Constant)

        DisplayName='Xilinx PlanAhead with Embedded Design';

        CreateProjTcl='pa_create_proj.tcl';
        BuildTcl='pa_build.tcl';

        TclCmdStr='planAhead -mode batch -source';
        GUICmdStr='planAhead';

        ConstraintFileName='pa_constraint.ucf';

        ProjectName='pa_prj';

    end


    methods

        function obj=PlanAheadTool(hETool)

            obj=obj@hdlturnkey.tool.XilinxEmbeddedTool(hETool);
        end

        function checkToolPath(obj)

            iseToolPath=obj.hETool.hIP.hD.hToolDriver.getToolPath;
            [xilinxInstallPath,~]=obj.getISEInstalltionPath(iseToolPath);
            obj.ToolPath=fullfile(xilinxInstallPath,'PlanAhead','bin');
            if~exist(obj.ToolPath,'dir')
                error(message('hdlcommon:workflow:ToolFileNotAvailable','PlanAhead',obj.ToolPath));
            end
        end

        function[status,result]=runCreateProject(obj)



            hRD=obj.hETool.getRDPlugin;


            obj.ConstraintFiles={};
            if~isempty(hRD.CustomConstraints)

                copyConstrainFiles(obj,hRD);
            end


            obj.generateConstraintFile;


            tclFilePath=obj.generateCreateProjTcl(hRD);


            [status,result]=obj.runTclFile(tclFilePath,obj.getTclCmdStrFull);

        end

        function[status,result]=runBuild(obj,runExtShell)

            if nargin<2
                runExtShell=false;
            end
            tclFilePath=generateBuildTcl(obj,runExtShell);

            [status,result]=obj.runTclFile(tclFilePath,obj.getTclCmdStrFull,runExtShell);
        end


        function name=getProjectName(obj)
            name=obj.ProjectName;
        end
        function name=getProjectFileName(obj)
            name=sprintf('%s.ppr',obj.ProjectName);
        end
        function path=getBitstreamPath(obj)

            path=fullfile(obj.getProjectFolder,...
            sprintf('%s.runs',obj.getProjectName),...
            'impl_1',sprintf('%s_stub.bit',obj.hETool.hEDK.getProjectName));
        end

    end

    methods(Access=protected)


        function generateConstraintFile(obj)

            hTurnkey=obj.hETool.getTurnkeyObject;
            [needConstraint,hIFCell]=...
            hdlturnkey.interface.InterfaceExternal.isExternalInterfaceAssigned(hTurnkey);
            if~needConstraint
                return;
            end


            ucfFilePath=fullfile(obj.getProjectFolder,obj.ConstraintFileName);




            pcoreSrcList=obj.hETool.hIP.hIPEmitter.IPCoreSrcFileList;
            for ii=1:length(pcoreSrcList)
                srcFileStruct=pcoreSrcList{ii};
                srcFile=srcFileStruct.FilePath;
                [~,~,extName]=fileparts(srcFile);
                if~strcmpi(extName,'.ucf')
                    continue;
                end
                sourcePath=srcFile;
                targetPath=ucfFilePath;

                targetFileFolder=fileparts(targetPath);
                downstream.tool.createDir(targetFileFolder);


                copyfile(sourcePath,targetPath,'f');
            end


            ucfStr=hTurnkey.file2str(ucfFilePath);

            for ii=1:length(hIFCell)
                hInterface=hIFCell{ii};

                if hInterface.isIPInterface&&hInterface.isIPExternalIOInterface

                    if hInterface.isINOUTInterface


                        portName=hInterface.InportNames{1};
                        pinName=obj.hETool.hEDK.hMHSEmitter.getIPCorePortExtPinName(portName);
                        ucfStr=obj.nameforRegexChange(ucfStr,portName,pinName);

                        portName=hInterface.OutportNames{1};
                        pinName=obj.hETool.hEDK.hMHSEmitter.getIPCorePortExtPinName(portName);
                        ucfStr=obj.nameforRegexChange(ucfStr,portName,pinName);
                    else

                        portName=hInterface.PortName;
                        pinName=obj.hETool.hEDK.hMHSEmitter.getIPCorePortExtPinName(portName);
                        ucfStr=obj.nameforRegexChange(ucfStr,portName,pinName);
                    end
                else



                    hTurnkey=obj.hETool.getTurnkeyObject;
                    dutPortNames=hTurnkey.hTable.hTableMap.getConnectedPortList(hInterface.InterfaceID);
                    for jj=1:length(dutPortNames)
                        dutPortName=dutPortNames{jj};


                        postCodeGenDutPortNames=hTurnkey.hElab.getCodegenPortNameList(dutPortName);
                        postCodeGenDutPortName=postCodeGenDutPortNames{1};

                        portName=postCodeGenDutPortName;
                        pinName=obj.hETool.hEDK.hMHSEmitter.getIPCorePortExtPinName(portName);
                        ucfStr=obj.nameforRegexChange(ucfStr,portName,pinName);
                    end
                end
            end


            hTurnkey.str2file(ucfStr,ucfFilePath);


            obj.ConstraintFiles{end+1}=obj.ConstraintFileName;
        end

        function ucfStr=nameforRegexChange(obj,ucfStr,portName,pinName)%#ok<INUSL>
            portNameTmp=['"',portName,'"'];
            if~isempty(regexp(ucfStr,portNameTmp,'once'))
                pinNameTmp=['"',pinName,'"'];
            else
                portNameTmp=['"',portName,'<'];
                pinNameTmp=['"',pinName,'<'];
            end
            ucfStr=regexprep(ucfStr,portNameTmp,pinNameTmp);
        end


        function tclFilePath=generateCreateProjTcl(obj,~)



            hBoard=obj.hETool.getBoardObject;
            partStr=sprintf('%s%s%s',hBoard.FPGADevice,...
            hBoard.FPGAPackage,hBoard.FPGASpeed);

            hCodeGen=obj.hETool.getCodeGenObject;
            if hCodeGen.isVHDL
                targetL='VHDL';
            else
                targetL='VERILOG';
            end


            paprjFolder=obj.getProjectFolder;
            downstream.tool.createDir(paprjFolder);


            edkprjFolder=obj.hETool.hEDK.getProjectFolder;
            relativeDir=obj.hETool.hIP.hD.hToolDriver.hEmitter.getRelativeFolderPath(paprjFolder,edkprjFolder);
            edkprjPathTemp=fullfile(relativeDir,obj.hETool.hEDK.getProjectFileName);
            edkprjPath=regexprep(edkprjPathTemp,'\\','/');


            tclFilePath=fullfile(paprjFolder,obj.CreateProjTcl);
            fid=downstream.tool.createTclFile(tclFilePath,obj.hETool.hIP.getCurrentDir);

            fprintf(fid,'# Create new project\n');
            fprintf(fid,'create_project -part %s -force %s\n',partStr,obj.getProjectName);
            fprintf(fid,'set_property target_language %s [current_project]\n',targetL);
            fprintf(fid,'add_files -norecurse %s\n',edkprjPath);
            fprintf(fid,'make_wrapper -files [get_files %s] -top -fileset [get_filesets sources_1] -import\n',edkprjPath);


            if~isempty(obj.ConstraintFiles)
                fprintf(fid,'add_files -fileset constrs_1');
                for ii=1:length(obj.ConstraintFiles)
                    constraintFile=obj.ConstraintFiles{ii};
                    ucfFilePathTemp=constraintFile;
                    ucfFilePath=regexprep(ucfFilePathTemp,'\\','/');
                    fprintf(fid,' %s',ucfFilePath);
                end
                fprintf(fid,'\n');
            end


            obj.hETool.hIP.hD.hToolDriver.hEmitter.printSetProjectObjective(fid);

            fprintf(fid,'close_project\n');
            fprintf(fid,'exit\n');
            fclose(fid);
        end

        function tclFilePath=generateBuildTcl(obj,runExtShell)


            tclFilePath=fullfile(obj.getProjectFolder,obj.BuildTcl);
            fid=downstream.tool.createTclFile(tclFilePath,obj.hETool.hIP.getCurrentDir);


            buildOption=obj.hETool.hIP.hD.getTclFileForSynthesisBuild;
            customBuildTclFile=obj.hETool.hIP.hD.getCustomBuildTclFile;
            RoutedDesignCheckpointFilePath=obj.hETool.hIP.hD.getRoutedDesignCheckpointFilePath;

            if(strcmp(buildOption,'Default'))
                fprintf(fid,'# Load project\n');
                fprintf(fid,'open_project %s\n',obj.getProjectFileName);
                fprintf(fid,'# Generate bitstream\n');
                fprintf(fid,'update_compile_order -fileset sources_1\n');
                fprintf(fid,'reset_run synth_1\n');
                fprintf(fid,'launch_runs synth_1\n');
                fprintf(fid,'wait_on_run synth_1\n');
                fprintf(fid,'launch_runs impl_1 -to_step Bitgen\n');
                fprintf(fid,'wait_on_run impl_1\n');
                fprintf(fid,'close_project\n');
                if runExtShell
                    fprintf(fid,'puts "------------------------------------"\n');
                    fprintf(fid,'puts "Embedded system build completed."\n');
                    fprintf(fid,'puts "You may close this shell."\n');
                    fprintf(fid,'puts "------------------------------------"\n');
                end
                fprintf(fid,'exit\n');
            else
                fprintf(fid,'open_project %s\n',obj.getProjectFileName);
                fprintf(fid,'%s',fileread(customBuildTclFile));
                fprintf(fid,'close_project\n');
                fprintf(fid,'exit\n');
            end
            fclose(fid);
        end

        function copyConstrainFiles(obj,hRD)

            fileList=hRD.CustomConstraints;
            for ii=1:length(fileList)
                afile=fileList{ii};
                if hRD.ExternalRD

                    sourcePath=fullfile(hRD.RDFolderPath,afile);
                else

                    sourcePath=fullfile(hRD.PluginPath,afile);
                end
                obj.checkRequiredFiles(sourcePath);

                fileNameStr=obj.getFileName(afile);
                targetPath=fullfile(obj.getProjectFolder,fileNameStr);
                obj.copyFile(sourcePath,targetPath);

                obj.ConstraintFiles{end+1}=fileNameStr;
            end
        end



    end

end



