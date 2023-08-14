


classdef QuartusEmbeddedTool<hdlturnkey.tool.AlteraEmbeddedTool


    properties


        ConstraintFiles={};


        TclCmdStr='quartus_sh -t';
        TclCmdStrQPro='quartus_sh -t';
        GUICmdStr='quartus';
        CPFCmdStr='quartus_cpf';

    end

    properties(Access=protected)


        ProjectFolder='quartus_prj';

    end

    properties(Constant)

        DisplayName='Altera Quartus with Qsys Design';

        CreateProjTcl='quartus_create_prj.tcl';

        TimingQueryTcl='quartus_timing_query.tcl';
        BuildTcl='quartus_build_prj.tcl';
        UpdateProjTcl='quartus_update_prj.tcl';
        CustomUpdateProjTcl='quartus_custom_update_prj.tcl';
        CreateBinTcl='quartus_create_bin.tcl';
        CustomCreateBinTcl='quartus_custom_create_bin.tcl';
        DownloadTcl='quartus_program.tcl';

        ProjectName='system';
        ProjectFileExt='qpf';

        BitStreamFileExt='sof';
        BinFileExt='rbf';

        PinConstraintFile='PinConstraints.tcl';

        TimingFailurePostfix='_timingfailure';
    end

    methods

        function obj=QuartusEmbeddedTool(hETool)

            obj=obj@hdlturnkey.tool.AlteraEmbeddedTool(hETool);

        end

    end


    methods

    end


    methods

        function[status,result]=runCreateProject(obj)



            hRD=obj.hETool.getRDPlugin;


            copyRequiredFiles(obj,hRD);


            obj.ConstraintFiles={};
            if~isempty(hRD.CustomConstraints)

                copyConstrainFiles(obj,hRD);
            end


            obj.generateConstraintFile;
            result='';


            tclFilePath=generateCreateProjTcl(obj,hRD);
            [status,result_run]=obj.runTclFile(tclFilePath,obj.getTclCmdStrFull);
            result=sprintf('%s%s',result,result_run);
            if~status

                return;
            end


            if~isempty(hRD.CustomUpdateProjTcl)
                tclFilePath=generateUpdateProjTcl(obj,hRD);
                [status,result_run]=obj.runTclFile(tclFilePath,obj.getTclCmdStrFull);
                result=sprintf('%s%s',result,result_run);
            end
        end

        function[status,result]=runBuild(obj,runExtShell)

            if nargin<2
                runExtShell=false;
            end


            if exist(obj.getBitstreamPath,'file')
                delete(obj.getBitstreamPath);
            end
            if exist(obj.getRbfBitstreamPath,'file')
                delete(obj.getRbfBitstreamPath);
            end
            if exist(obj.getTimingFailureBitstreamPath,'file')
                delete(obj.getTimingFailureBitstreamPath);
            end

            if exist(obj.hETool.getTimingReportPath,'file')
                delete(obj.hETool.getTimingReportPath);
            end

            tclFilePath=generateBuildTcl(obj,runExtShell);
            [status,result]=obj.runTclFile(tclFilePath,obj.getTclCmdStrFull,runExtShell);
        end

        function[status,result]=downloadBitstream(obj)


            chainPosition=obj.hETool.hIP.hD.hTurnkey.hBoard.JTAGChainPosition;

            [status,result]=obj.downloadBit(obj.getBitstreamPath,obj.ToolPath,chainPosition);
        end


        function path=getBitstreamPath(obj)

            path=fullfile(obj.getProjectFolder,obj.getBitstreamName);
            path=downstream.tool.filterBackSlash(path);
        end

        function name=getRbfBitstreamName(obj)
            name=[obj.ProjectName,'.',obj.BinFileExt];
        end

        function path=getRbfBitstreamPath(obj)

            path=fullfile(obj.getProjectFolder,obj.getRbfBitstreamName);
            path=downstream.tool.filterBackSlash(path);
        end

        function name=getBitstreamName(obj)
            name=[obj.ProjectName,'.',obj.BitStreamFileExt];
        end

        function path=getBinPath(obj)

            path=fullfile(obj.getProjectFolder,obj.getBinName);
            path=downstream.tool.filterBackSlash(path);
        end

        function name=getBinName(obj)
            name=[obj.ProjectName,'.',obj.BinFileExt];
        end


        function name=getTimingFailureBitstreamName(obj)
            name=[obj.ProjectName,obj.TimingFailurePostfix,'.',obj.BitStreamFileExt];
        end


        function path=getTimingFailureBitstreamPath(obj)
            path=fullfile(obj.getProjectFolder,obj.getTimingFailureBitstreamName);
            path=downstream.tool.filterBackSlash(path);
        end

    end

    methods(Access=protected)


        function tclFilePath=generateUpdateProjTcl(obj,hRD)

            tclFilePath=fullfile(obj.getProjectFolder,obj.UpdateProjTcl);
            fid=downstream.tool.createTclFile(tclFilePath,obj.hETool.hIP.getCurrentDir);

            fprintf(fid,'project_open %s\n',obj.getProjectName);





            obj.generateRDParameterTcl(fid,hRD);


            obj.tclSourceFile(fid,obj.CustomUpdateProjTcl);


            fprintf(fid,'project_close\n');
            fclose(fid);
        end

        function tclFilePath=generateCreateProjTcl(obj,hRD)



            fpgaDevStr=obj.getFPGADeviceStr;

            fpgaFamilystr=obj.getFPGAFamily;


            tclFilePath=fullfile(obj.getProjectFolder,obj.CreateProjTcl);
            fid=downstream.tool.createTclFile(tclFilePath,obj.hETool.hIP.getCurrentDir);


            fprintf(fid,'project_new %s -overwrite\n',obj.getProjectName);





            obj.generateRDParameterTcl(fid,hRD);


            fprintf(fid,'set_global_assignment -name FAMILY "%s"\n',fpgaFamilystr);
            fprintf(fid,'set_global_assignment -name DEVICE "%s"\n',fpgaDevStr);






            if~(alteratarget.isFamilyMax10(fpgaFamilystr)||alteratarget.isFamilyArria10OrLater(fpgaFamilystr))
                fprintf(fid,'load_package flow\n');
                fprintf(fid,'# Run check_ios to ensure we have a valid license\n');
                obj.emitTclCatch(fid,'execute_flow -check_ios','Quartus license check');
            end


            fprintf(fid,'set_global_assignment -name TOP_LEVEL_ENTITY %s\n',obj.hETool.hQsys.getProjectName);


            qippath=obj.hETool.hQsys.getQIPFilePath;
            qipdir=fileparts(qippath);


            libdirs={...
            qipdir,...
            fullfile(qipdir,'submodules'),...
            fullfile(qipdir,'submodules','sequencer'),...
            };
            for ii=1:numel(libdirs)
                libdir=libdirs{ii};
                if isdir(libdir)
                    fprintf(fid,'set_global_assignment -name SEARCH_PATH %s\n',obj.toRelTclPath(libdir));
                end
            end


            downstream.tool.runInPlugin(obj.hETool.hIP.hD,'Plugin_Tcl_Quartus.addQuartusQip',fid,obj.toRelTclPath(qippath));


            obj.addConstrantFiles(fid);

            if~obj.hETool.hIP.hD.isMLHDLC

                generateTimingQueryTcl(obj);


                downstream.tool.runInPlugin(obj.hETool.hIP.hD,'Plugin_Tcl_Quartus.getTclTimingCheck',fid,obj.TimingQueryTcl);
            end


            obj.hETool.hIP.hD.hToolDriver.hEmitter.printSetProjectObjective(fid);


            fprintf(fid,'project_close\n');
            fclose(fid);
        end

        function tclFilePath=generateBuildTcl(obj,runExtShell)


            tclFilePath=fullfile(obj.getProjectFolder,obj.BuildTcl);
            fid=downstream.tool.createTclFile(tclFilePath,obj.hETool.hIP.getCurrentDir);


            buildOption=obj.hETool.hIP.hD.getTclFileForSynthesisBuild;
            customBuildTclFile=obj.hETool.hIP.hD.getCustomBuildTclFile;


            hRD=obj.hETool.getRDPlugin;
            if(strcmp(buildOption,'Default'))
                fprintf(fid,'project_open %s\n',obj.getProjectName);
                fprintf(fid,'load_package flow\n');

                qipdir=fileparts(obj.hETool.hQsys.getQIPFilePath);
                hpsTcl=fullfile(qipdir,'submodules','hps_sdram_p0_pin_assignments.tcl');
                if exist(hpsTcl,'file')

                    obj.emitTclCatch(fid,'execute_module -tool map','Analysis & Synthesis');

                    fprintf(fid,'export_assignments\n');

                    obj.tclSourceFile(fid,hpsTcl);

                    fprintf(fid,'export_assignments\n');
                end

                obj.emitTclCatch(fid,'execute_flow -compile','Compilation');


                fprintf(fid,'project_close\n');
            else
                fprintf(fid,'project_open %s\n',obj.getProjectName);



                obj.generateRDParameterTcl(fid,hRD);


                fprintf(fid,'%s',fileread(customBuildTclFile));
                fprintf(fid,'project_close\n');
            end


            createBinTcl=obj.generateCreateBinTcl;
            obj.tclSourceFile(fid,createBinTcl);

            if runExtShell
                fprintf(fid,'puts "------------------------------------"\n');
                fprintf(fid,'puts "Embedded system build completed."\n');
                fprintf(fid,'puts "You may close this shell."\n');
                fprintf(fid,'puts "------------------------------------"\n');
            end

            fclose(fid);

        end

        function tclFilePath=generateCreateBinTcl(obj)



            tclFilePath=fullfile(obj.getProjectFolder,obj.CreateBinTcl);
            fid=downstream.tool.createTclFile(tclFilePath,obj.hETool.hIP.getCurrentDir);

            hRD=obj.hETool.getRDPlugin;
            if~isempty(hRD)&&~isempty(hRD.CustomCreateBinTcl)



                obj.tclSourceFile(fid,obj.CustomCreateBinTcl);
            else

                if~isempty(hRD)
                    forceRBF=hRD.ForceRBF;
                else
                    forceRBF=false;
                end





                generateRBF=ismember(hdlcoder.ProgrammingMethod.Download,obj.hETool.getProgrammingMethodAll)||...
                forceRBF||...
                hRD.GenerateSplitBitstream;


                if generateRBF
                    if hRD.GenerateSplitBitstream

                        cpfStr=sprintf('qexec "[file join $::quartus(binpath) quartus_cpf] -c --hps -o bitstream_compression=on %s %s"',...
                        obj.getBitstreamName,obj.getBinName);
                        fprintf(fid,'if {[file exists %s]} {\n',obj.getBitstreamName);
                        obj.emitTclCatchWarn(fid,cpfStr,'Split RBF Generation (Early I/O)');
                        fprintf(fid,'} \n');
                    else

                        cpfStr=sprintf('qexec "[file join $::quartus(binpath) quartus_cpf] -c %s %s"',...
                        obj.getBitstreamName,obj.getBinName);
                        fprintf(fid,'if {[file exists %s]} {\n',obj.getBitstreamName);
                        obj.emitTclCatchWarn(fid,cpfStr,'RBF Generation');
                        fprintf(fid,'} \n');
                    end
                end
            end
            fclose(fid);

        end


        function tclFilePath=generateTimingQueryTcl(obj)

            tclFilePath=fullfile(obj.getProjectFolder,obj.TimingQueryTcl);
            fid=downstream.tool.createTclFile(tclFilePath,obj.hETool.hIP.getCurrentDir);


            if obj.hETool.reportTimingFailAsWarning
                reportErrorOnTiming=0;
            else
                reportErrorOnTiming=1;
            end






            quartusTimingReportCopy=downstream.tool.filterBackSlash(obj.hETool.getTimingReportNameCopy);


            if~obj.hETool.hIP.hD.isMLHDLC
                downstream.tool.runInPlugin(obj.hETool.hIP.hD,'Plugin_Tcl_Quartus.generateTimingQueryTclCheck',fid,obj.getBitstreamName,obj.getTimingFailureBitstreamName,reportErrorOnTiming,quartusTimingReportCopy,obj.hETool.hIP.getEmbeddedExternalBuild,obj.getSlackTolerance);
            end
            fclose(fid);
        end

        function emitTclCatchWarn(~,fid,cmd,name)

            fprintf(fid,'\tif {[catch {%s} result]} {\n',cmd);
            fprintf(fid,'\t\tputs "\\nResult: $result\\n"\n');
            fprintf(fid,'\t\tputs "Warning: %s failed. See report files.\\n"\n',name);

            fprintf(fid,'\t\texit 0\n');
            fprintf(fid,'\t} else {\n');
            fprintf(fid,'\t\tputs "\\nINFO: %s was successful.\\n"\n',name);
            fprintf(fid,'\t}\n');
        end

        function emitTclCatch(~,fid,cmd,name)

            fprintf(fid,'if {[catch {%s} result]} {\n',cmd);
            fprintf(fid,'\tputs "\\nResult: $result\\n"\n');
            fprintf(fid,'\tputs "ERROR: %s failed. See report files.\\n"\n',name);

            fprintf(fid,'\texit 1\n');
            fprintf(fid,'} else {\n');
            fprintf(fid,'\tputs "\\nINFO: %s was successful.\\n"\n',name);
            fprintf(fid,'}\n');
        end


        function addConstrantFiles(obj,fid)
            for ii=1:numel(obj.ConstraintFiles)
                constrFile=obj.ConstraintFiles{ii};
                [~,~,fExt]=fileparts(constrFile);
                switch(lower(fExt))
                case '.sdc'
                    fprintf(fid,'set_global_assignment -name SDC_FILE %s\n',obj.toRelTclPath(constrFile));
                case{'.tcl','.qsf'}
                    obj.tclSourceFile(fid,constrFile);
                case '.qip'
                    fprintf(fid,'set_global_assignment -name QIP_FILE %s\n',obj.toRelTclPath(constrFile));
                otherwise

                end
            end
        end

        function generateConstraintFile(obj)


            hTurnkey=obj.hETool.getTurnkeyObject;
            [needConstraint,hIFCell]=...
            hdlturnkey.interface.InterfaceExternal.isExternalInterfaceAssigned(hTurnkey);


            qsfFilePath=fullfile(obj.getProjectFolder,obj.PinConstraintFile);
            targetPath=qsfFilePath;
            targetFileFolder=fileparts(targetPath);


            pcoreSrcList=obj.hETool.hIP.hIPEmitter.IPCoreSrcFileList;
            for ii=1:numel(pcoreSrcList)
                srcFileStruct=pcoreSrcList{ii};
                srcFile=srcFileStruct.FilePath;
                sourcePath=srcFile;
                [~,fName,fExt]=fileparts(srcFile);
                if needConstraint&&isequal([fName,fExt],hTurnkey.hConstrain.PinAssignFileName)
                    sourcePath=srcFile;


                    downstream.tool.createDir(targetFileFolder);
                    copyfile(sourcePath,targetPath,'f');



                    qsfStr=hTurnkey.file2str(qsfFilePath);

                    for jj=1:length(hIFCell)
                        hInterface=hIFCell{jj};

                        if hInterface.isIPInterface&&hInterface.isIPExternalIOInterface

                            if hInterface.isINOUTInterface


                                portName=hInterface.InportNames{1};
                                qsfStr=obj.portToPinRegEx(qsfStr,portName);

                                portName=hInterface.OutportNames{1};
                                qsfStr=obj.portToPinRegEx(qsfStr,portName);
                            else

                                portName=hInterface.PortName;
                                qsfStr=obj.portToPinRegEx(qsfStr,portName);
                            end
                        else



                            hTurnkey=obj.hETool.getTurnkeyObject;
                            dutPortNames=hTurnkey.hTable.hTableMap.getConnectedPortList(hInterface.InterfaceID);
                            for kk=1:length(dutPortNames)
                                dutPortName=dutPortNames{kk};


                                postCodeGenDutPortNames=hTurnkey.hElab.getCodegenPortNameList(dutPortName);
                                postCodeGenDutPortName=postCodeGenDutPortNames{1};

                                portName=postCodeGenDutPortName;
                                qsfStr=obj.portToPinRegEx(qsfStr,portName);
                            end
                        end
                    end


                    hTurnkey.str2file(qsfStr,qsfFilePath);
                    obj.ConstraintFiles{end+1}=obj.PinConstraintFile;

                elseif strcmpi(fExt,'.sdc')

                    txt=fileread(srcFile);
                    s=regexp(txt,'^[^#\s].*','lineanchors');
                    if(isempty(s))
                        continue;
                    end


                    downstream.tool.createDir(targetFileFolder);
                    copyfile(sourcePath,fullfile(targetFileFolder,[fName,fExt]),'f');
                    obj.ConstraintFiles{end+1}=[fName,fExt];
                end
            end

        end



        function copyRequiredFiles(obj,hRD)

            optionalFileList={...
            {hRD.CustomUpdateProjTcl,obj.CustomUpdateProjTcl}...
            ,{hRD.CustomCreateBinTcl,obj.CustomCreateBinTcl}...
            };
            obj.copyFileListOptional(optionalFileList,hRD);


            obj.copyCustomFiles(hRD);


            obj.copyIPRepositories(hRD);
        end

        function copyCustomFiles(obj,hRD)

            fileList=hRD.CustomQuartusFiles;
            for ii=1:length(fileList)
                afile=fileList{ii};
                sourceFile=afile;
                targetFile=afile;
                obj.copyFileFromRD(sourceFile,targetFile,hRD);
            end
        end


        function[status,result]=runTclFile(obj,tclFilePath,toolCmdStr,runExtShell)


            if nargin<4
                runExtShell=false;
            end

            [tclFileFolder,tname,text]=fileparts(tclFilePath);
            tclFileName=sprintf('%s%s',tname,text);
            currentDir=cd(tclFileFolder);
            if~exist(tclFileName,'file')
                error(message('hdlcommon:workflow:NoTclFileWithName',tclFileName));
            end

            if runExtShell

                if ispc
                    cmdStr=sprintf('%s %s &',toolCmdStr,tclFileName);
                else
                    cmdStr=sprintf('xterm -hold -sb -sl 256 -e bash -e -c ''%s %s'' &',...
                    toolCmdStr,tclFileName);
                end
                [status,resultSys]=obj.run_cmd(cmdStr);
                result=sprintf('%s\nRunning embedded system build outside MATLAB.\nPlease check external shell for system build progress.\n',...
                resultSys);
            else
                cmdStr=sprintf('%s %s',toolCmdStr,tclFileName);

                hDI=obj.hETool.hIP.hD;

                tic;
                [status,resultSys]=obj.run_cmd(cmdStr,'',hDI.logDisplay);
                time=toc;
                result=sprintf('%s\nElapsed time is %s seconds.\n',resultSys,num2str(time));
            end

            cd(currentDir);
        end

    end


    methods(Static)
        function[status,result]=downloadBit(bitstreamPath,quartusToolPath,chainPosition)


            if nargin<2
                quartusToolPath='';
            end

            if nargin<3||isempty(chainPosition)
                chainPosition=2;
            end


            toolStr=fullfile(quartusToolPath,'quartus_pgm');

            bitstreamPath=strrep(bitstreamPath,'\\','/');
            bitstreamPath=strrep(bitstreamPath,'\','/');

            cmdStr=sprintf('%s --mode=jtag -o "p;%s@%d"',...
            toolStr,bitstreamPath,chainPosition);


            tic;
            [status,resultSys]=hdlturnkey.tool.AlteraEmbeddedTool.run_cmd(cmdStr);
            time=toc;
            result=sprintf('%s\nElapsed time is %s seconds.\n',resultSys,num2str(time));
        end

    end

end




