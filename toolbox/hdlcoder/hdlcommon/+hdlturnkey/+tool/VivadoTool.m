




classdef VivadoTool<hdlturnkey.tool.XilinxEmbeddedTool


    properties


        ConstraintFiles={};


        TclCmdStr='';
        GUICmdStr='';


    end

    properties(Access=protected)


        ProjectFolder='vivado_ip_prj';

        ipRepositoryFolder='';

        UseIPCache=false;

        BitStreamFileExt='bit';

    end

    properties(Constant)

        DisplayName='Xilinx Vivado with IP Integrator';

        CreateProjTcl='vivado_create_prj.tcl';
        CustomBlockDesignTcl='vivado_custom_block_design.tcl';
        InsertIPTcl='vivado_insert_ip.tcl';
        UpdateProjTcl='vivado_update_prj.tcl';
        CustomUpdateProjTcl='vivado_custom_update_prj.tcl';
        BuildTcl='vivado_build.tcl';

        ConstraintFileName='vivado_constraint.xdc';

        ProjectName='vivado_prj';

        LocalIPFolder='ipcore';
        TimingFailurePostfix='_timingfailure';
        BitstreamPathsubfolder='/impl_1';
        PhysicalConstraintExt='.xdc';

    end

    methods

        function obj=VivadoTool(hETool)

            obj=obj@hdlturnkey.tool.XilinxEmbeddedTool(hETool);


            hToolDriver=obj.hETool.getDIObject.hToolDriver;
            obj.TclCmdStr=hToolDriver.getCmdRunTclScript;
            obj.GUICmdStr=hToolDriver.getCmdOpenTargetTool;

            if obj.hETool.hIP.hD.hTurnkey.isVersalPlatform
                obj.BitStreamFileExt='pdi';
            end
        end

    end


    methods

        function checkToolPath(obj)


            vivadoToolPath=obj.hETool.hIP.hD.hToolDriver.getToolPath;
            obj.ToolPath=vivadoToolPath;
        end

    end


    methods

        function[status,result]=runCreateProjectOnly(obj)

            result='';


            hRD=obj.hETool.getRDPlugin;


            methodStr=hRD.IPInsertionMethod;
            if~strcmpi(methodStr,'Insert')&&~strcmpi(methodStr,'Replace')
                error(message('hdlcommon:workflow:IPInsertMethodInvalid'));
            end



            defaultIPRepositoryPath=fullfile(obj.getProjectFolder,obj.LocalIPFolder);
            downstream.tool.createDir(defaultIPRepositoryPath);


            copyRequiredFiles(obj,hRD);



            if obj.hETool.hIP.getUseIPCache
                hDI=obj.hETool.hIP.hD;
                downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.copyIPcacheFolder',obj,hRD);
            end


            tclFilePath=generateCreateProjTcl(obj,hRD);
            [status,result_run]=obj.runTclFile(tclFilePath,obj.getTclCmdStrFull);
            result=sprintf('%s%s',result,result_run);


        end

        function[status,result]=runCreateProject(obj)


            projectDirectory=obj.hETool.hIP.getCurrentDir;
            checkSpace=contains(projectDirectory,' ');
            if(checkSpace)
                error(message('hdlcommon:workflow:SpaceInPathError',projectDirectory));
            end

            hRD=obj.hETool.getRDPlugin;


            [status,result]=runCreateProjectOnly(obj);
            if~status

                return;
            end


            copyIPCoreToProjFolder(obj);


            copyInterfaceIPToProjFolder(obj);


            obj.ConstraintFiles={};
            if~isempty(hRD.CustomConstraints)

                copyConstrainFiles(obj,hRD);
            end


            obj.copyConstraintFiles(obj.PhysicalConstraintExt);


            tclFilePath=generateInsertIPTcl(obj,hRD);
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


            if exist(obj.getPrevBitstream,'file')
                delete(obj.getPrevBitstream);
            end
            if exist(obj.getPrevBitstreamWithTimingfail,'file')
                delete(obj.getPrevBitstreamWithTimingfail);
            end

            tclFilePath=generateBuildTcl(obj,runExtShell);
            [status,result]=obj.runTclFile(tclFilePath,obj.getTclCmdStrFull,runExtShell);




            if status

                captureError={'ERROR:[^\n]*'};




                filterErrorList={'Failed to install all user apps',...
                };
                for ii=1:length(captureError)
                    errorPattern=captureError{ii};
                    regMatchs=regexp(result,errorPattern,'match');

                    for jj=1:length(regMatchs)
                        searchText=regMatchs{jj};


                        matchFilterError=false;
                        for kk=1:length(filterErrorList)
                            filterError=filterErrorList{kk};
                            if~isempty(regexp(searchText,filterError,'once'))
                                matchFilterError=true;
                                break;
                            end
                        end

                        if matchFilterError
                            continue;
                        else

                            errorPatternDetectedStr='ERROR pattern is detected in the Vivado log, fail the current build.';
                            result=sprintf('%s\n%s\n',result,errorPatternDetectedStr);
                            status=0;
                            break;
                        end
                    end
                end
            end
        end

        function[status,result]=downloadBitstreamJTAG(obj)

            bitstreamPath=obj.getBitstreamPath;
            edkToolPath=obj.ToolPath;

            chainPosition=obj.hETool.hIP.hD.hTurnkey.hBoard.JTAGChainPosition;

            [status,result]=obj.downloadBit(bitstreamPath,edkToolPath,chainPosition);
        end


        function name=getProjectName(obj)
            name=obj.ProjectName;
        end
        function iprepo=getIpRepositoryFolder(obj)
            iprepo=obj.ipRepositoryFolder;
        end
        function name=getProjectFileName(obj)
            name=sprintf('%s.xpr',obj.ProjectName);
        end
        function path=getBitstreamPath(obj)

            path=fullfile(obj.getProjectFolder,obj.getBitstreamPathLocal);
        end
        function val=getUseIPCache(obj)
            val=obj.UseIPCache;
        end
        function setUseIPCache(obj,val)
            obj.UseIPCache=val;
        end

        function path=getBitstreamFolderPath(obj)
            pathtop=sprintf('%s.runs',obj.getProjectName);
            path=[pathtop,obj.BitstreamPathsubfolder];

        end

        function name=getbitstreamFileName(obj)
            hRD=obj.hETool.getRDPlugin;
            if isempty(hRD.CustomTopLevelHDL)
                name=sprintf('%s_wrapper',hRD.BlockDesignName);
            else
                [~,name,~]=fileparts(hRD.CustomTopLevelHDL);
            end
        end

        function path=getPrevBitstream(obj)
            path=[obj.getProjectFolder,'/',obj.getBitstreamFolderPath,'/',obj.getbitstreamFileName,'.',obj.BitStreamFileExt];
        end

        function path=getPrevBitstreamWithTimingfail(obj)
            path=[obj.getProjectFolder,'/',obj.getBitstreamFolderPath,'/',obj.getbitstreamFileName,obj.TimingFailurePostfix,'.',obj.BitStreamFileExt];
        end


    end

    methods(Access=protected)


        function tclFilePath=generateCreateProjTcl(obj,hRD)




            hDI=obj.hETool.hIP.hD;


            fpgaPartStr=obj.hETool.hIP.hIPEmitter.getFPGAPartStr;


            hCodeGen=obj.hETool.getCodeGenObject;
            if hCodeGen.isVHDL
                targetL='VHDL';
            else
                targetL='Verilog';
            end


            tclFilePath=fullfile(obj.getProjectFolder,obj.CreateProjTcl);
            fid=downstream.tool.createTclFile(tclFilePath,obj.hETool.hIP.getCurrentDir);


            fprintf(fid,'create_project %s {} -part %s -force\n',...
            obj.getProjectName,fpgaPartStr);


            if~isempty(hRD.VivadoBoardPart)
                fprintf(fid,'set_property board_part %s [current_project]\n',hRD.VivadoBoardPart);
            elseif~isempty(hRD.VivadoBoardName)

                fprintf(fid,'set_property board %s [current_project]\n',hRD.VivadoBoardName);
            end
            fprintf(fid,'set_property target_language %s [current_project]\n',targetL);


            defaultIPRepositoryFolder=sprintf('./%s',obj.LocalIPFolder);
            fprintf(fid,'set defaultRepoPath {%s}\n',defaultIPRepositoryFolder);
            fprintf(fid,'set_property ip_repo_paths $defaultRepoPath [current_fileset]\n');
            fprintf(fid,'update_ip_catalog\n');


            fprintf(fid,'set ipList [glob -nocomplain -directory $defaultRepoPath *.zip]\n');
            fprintf(fid,'foreach ipCore $ipList {\n');
            fprintf(fid,'  set folderList [glob -nocomplain -directory $defaultRepoPath -type d *]\n');
            fprintf(fid,'  if {[lsearch -exact $folderList [file rootname $ipCore]] == -1} {\n');
            fprintf(fid,'    catch {update_ip_catalog -add_ip $ipCore -repo_path $defaultRepoPath}\n');
            fprintf(fid,'  }\n');
            fprintf(fid,'}\n');
            fprintf(fid,'update_ip_catalog\n');




            obj.generateRDParameterTcl(fid,hRD);


            fprintf(fid,'source %s\n',obj.CustomBlockDesignTcl);


            if obj.getUseIPCache
                downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.getTclIPCacheOOC',fid,hRD.BlockDesignName);
            else
                downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.getTclSetGlobalSynth',fid,hRD.BlockDesignName);
            end





            hClockModule=hDI.getClockModule;
            hClockModule.generateVivadoTclSetClockFreq(hDI,fid);


            downstream.tool.runInPlugin(obj.hETool.hIP.hD,'Plugin_Tcl_Vivado.getValidateBd',fid);
            fprintf(fid,'save_bd_design\n');


            obj.hETool.hIP.hD.hToolDriver.hEmitter.printSetProjectObjective(fid);

            fprintf(fid,'close_project\n');
            fprintf(fid,'exit\n');
            fclose(fid);
        end

        function tclFilePath=generateInsertIPTcl(obj,hRD)


            hDI=obj.hETool.hIP.hD;


            hCodeGen=obj.hETool.getCodeGenObject;
            if hCodeGen.isVHDL
                hdlExt='vhd';
            else
                hdlExt='v';
            end


            ipRepositoryPath=obj.hETool.hIP.getIPRepository;
            if~isempty(ipRepositoryPath)

                obj.ipRepositoryFolder=downstream.tool.filterBackSlash(...
                downstream.tool.getAbsoluteFolderPath(ipRepositoryPath));
            else

                obj.ipRepositoryFolder=sprintf('./%s',obj.LocalIPFolder);
            end


            ipZipFileName=obj.hETool.hIP.hIPEmitter.IPPackageZipFileName;
            [~,ipFolderName]=fileparts(ipZipFileName);
            ipZipPath=downstream.tool.filterBackSlash(...
            fullfile(obj.ipRepositoryFolder,ipZipFileName));
            ipCompXMLPath=downstream.tool.filterBackSlash(...
            fullfile(obj.ipRepositoryFolder,ipFolderName,'component.xml'));


            tclFilePath=fullfile(obj.getProjectFolder,obj.InsertIPTcl);
            fid=downstream.tool.createTclFile(tclFilePath,obj.hETool.hIP.getCurrentDir);

            fprintf(fid,'open_project %s\n',obj.getProjectFileName);





            obj.generateRDParameterTcl(fid,hRD);


            if~isempty(ipRepositoryPath)
                fprintf(fid,'set lib_dirs [get_property ip_repo_paths [current_fileset]]\n');
                fprintf(fid,'lappend lib_dirs {%s}\n',obj.ipRepositoryFolder);
                fprintf(fid,'set_property ip_repo_paths $lib_dirs [current_fileset]\n');
                fprintf(fid,'update_ip_catalog\n');
            end


            fprintf(fid,'update_ip_catalog -delete_ip {%s} -repo_path {%s} -quiet\n',...
            ipCompXMLPath,obj.ipRepositoryFolder);


            fprintf(fid,'update_ip_catalog -add_ip {%s} -repo_path {%s}\n',...
            ipZipPath,obj.ipRepositoryFolder);
            fprintf(fid,'update_ip_catalog\n');


            obj.generateIPVarsTcl(fid,hRD);


            fprintf(fid,'open_bd_design $BDFILEPATH\n');


            methodStr=hRD.IPInsertionMethod;
            if strcmpi(methodStr,'Replace')
                fprintf(fid,'delete_bd_objs [get_bd_cells %s]\n',hRD.ReplacedIPInstance);
            end


            fprintf(fid,'create_bd_cell -type ip -vlnv $HDLCODERIPVLNV $HDLCODERIPINST\n');


            obj.generateIPInterfaceVivadoTcl(fid);


            hClockModule=hDI.getClockModule;
            hClockModule.generateVivadoTclConnectClockReset(hDI,fid);


            emitExternalPortTcl(obj,fid);


            if isempty(hRD.CustomTopLevelHDL)

                downstream.tool.runInPlugin(obj.hETool.hIP.hD,'Plugin_Tcl_Vivado.getTclVivadoMakeWrapper',fid,hRD.BlockDesignName,hdlExt);
            else

                fprintf(fid,'add_files -norecurse {%s}\n',...
                obj.toRelTclPath(hRD.CustomTopLevelHDL));
            end

            fprintf(fid,'update_compile_order -fileset sources_1\n');
            fprintf(fid,'validate_bd_design\n');
            fprintf(fid,'save_bd_design\n');


            if~isempty(obj.ConstraintFiles)
                fprintf(fid,'add_files -fileset constrs_1 -norecurse');
                for ii=1:length(obj.ConstraintFiles)
                    constraintFile=obj.ConstraintFiles{ii};
                    fprintf(fid,' %s',obj.toRelTclPath(constraintFile));
                end
                fprintf(fid,'\n');
            end

            fprintf(fid,'close_project\n');
            fprintf(fid,'exit\n');
            fclose(fid);




        end

        function generateRDParameterTcl(~,fid,hRD)

            paramStruct=hRD.getParameterStructFormat;
            if~isempty(paramStruct)
                paramIDCell=fieldnames(paramStruct);
                for ii=1:length(paramIDCell)
                    paramID=paramIDCell{ii};



                    if~strcmp(paramID,'HDLVerifierFDC')
                        fprintf(fid,'set %s {%s}\n',paramID,paramStruct.(paramID));
                    end
                end
            end
        end

        function generateIPVarsTcl(obj,fid,hRD)




            fprintf(fid,'set HDLCODERIPVLNV [get_property VLNV [get_ipdefs -filter {NAME==%s && VERSION==%s}]]\n',...
            obj.hETool.hIP.getIPCoreName,obj.hETool.hIP.getIPCoreVersion);

            fprintf(fid,'set HDLCODERIPINST %s_0\n',obj.hETool.hIP.getIPCoreName);

            fprintf(fid,'set BDFILEPATH [get_files -quiet %s.bd]\n',hRD.BlockDesignName);
        end

        function generateIPInterfaceVivadoTcl(obj,fid)


            hTurnkey=obj.hETool.getTurnkeyObject;
            interfaceIDList=hTurnkey.getSupportedInterfaceIDList;

            for ii=1:length(interfaceIDList)
                interfaceID=interfaceIDList{ii};
                hInterface=hTurnkey.getInterface(interfaceID);


                if~hInterface.isIPInterface
                    continue;
                end



                if(hInterface.isInterfaceInUse(hTurnkey))
                    hInterface.generateRDInsertIPVivadoTcl(fid,obj);
                else
                    hInterface.generateRDCleanUpIPVivadoTcl(fid);
                end
            end
        end

        function tclFilePath=generateUpdateProjTcl(obj,hRD)


            tclFilePath=fullfile(obj.getProjectFolder,obj.UpdateProjTcl);
            fid=downstream.tool.createTclFile(tclFilePath,obj.hETool.hIP.getCurrentDir);
            fprintf(fid,'open_project %s\n',obj.getProjectFileName);





            obj.generateRDParameterTcl(fid,hRD);


            obj.generateIPVarsTcl(fid,hRD);


            fprintf(fid,'source %s\n',obj.CustomUpdateProjTcl);

            fprintf(fid,'close_project\n');
            fprintf(fid,'exit\n');
            fclose(fid);
        end

        function tclFilePath=generateBuildTcl(obj,runExtShell)


            hRD=obj.hETool.getRDPlugin;
            tclFilePath=fullfile(obj.getProjectFolder,obj.BuildTcl);
            fid=downstream.tool.createTclFile(tclFilePath,obj.hETool.hIP.getCurrentDir);


            buildOption=obj.hETool.hIP.hD.getTclFileForSynthesisBuild;
            customBuildTclFile=obj.hETool.hIP.hD.getCustomBuildTclFile;
            routedDesignCheckpointEnable=obj.hETool.hIP.hD.getEnableDesignCheckpoint;
            designCheckpointOption=obj.hETool.hIP.hD.getDefaultCheckpointFile;
            routedDesignCheckpointFilePath=downstream.tool.getAbsoluteFilePath(obj.hETool.hIP.hD.getRoutedDesignCheckpointFilePath);
            maxNumOfCoresForBuild=obj.hETool.hIP.hD.getMaxNumOfCores;




            if obj.getUseIPCache
                try


                    numJobs=feature('numthreads');
                catch
                    numJobs=1;
                end
            end
            if(strcmp(buildOption,'Default'))
                fprintf(fid,'open_project %s\n',obj.getProjectFileName);
                fprintf(fid,'update_compile_order -fileset sources_1\n');
                fprintf(fid,'reset_run impl_1\n');
                fprintf(fid,'reset_run synth_1\n');

                if(~isempty(maxNumOfCoresForBuild)&&(~strcmp(maxNumOfCoresForBuild,'synthesis tool default')))
                    fprintf(fid,'set_param general.maxThreads %d\n',int8(str2double(maxNumOfCoresForBuild)));
                end

                if(routedDesignCheckpointEnable&&strcmp(designCheckpointOption,'Default'))
                    fprintf(fid,'set defaultDCPPath ../checkpoint/system_routed.dcp\n');
                    fprintf(fid,'if {[file exists ../checkpoint/system_routed.dcp] ==1} {\n');
                    fprintf(fid,'   set_property incremental_checkpoint $defaultDCPPath [get_runs impl_1]\n');
                    fprintf(fid,'}\n');

                elseif(routedDesignCheckpointEnable&&strcmp(designCheckpointOption,'Custom'))
                    fprintf(fid,'set customDCPPath {%s}\n',routedDesignCheckpointFilePath);
                    fprintf(fid,'if {[file exists $customDCPPath] ==1} {\n');
                    fprintf(fid,'   set_property incremental_checkpoint $customDCPPath [get_runs impl_1]\n');
                    fprintf(fid,'}\n');
                end
                if obj.getUseIPCache
                    downstream.tool.runInPlugin(obj.hETool.hIP.hD,'Plugin_Tcl_Vivado.getTclEnableUserIPCache',fid);
                    fprintf(fid,'launch_runs -jobs %d synth_1\n',numJobs);
                else
                    fprintf(fid,'launch_runs synth_1\n');
                end
                fprintf(fid,'wait_on_run synth_1\n');
                fprintf(fid,'launch_runs impl_1 -to_step write_bitstream\n');
                fprintf(fid,'wait_on_run impl_1\n');
                if(routedDesignCheckpointEnable&&strcmp(designCheckpointOption,'Default'))
                    fprintf(fid,'set dcp [glob ./vivado_prj.runs/impl_1/*_routed.dcp]\n');
                    fprintf(fid,'file mkdir ../checkpoint\n');
                    fprintf(fid,'file copy -force $dcp ../checkpoint/system_routed.dcp\n');

                elseif(routedDesignCheckpointEnable&&strcmp(designCheckpointOption,'Custom'))
                    fprintf(fid,'set dcp [glob ./vivado_prj.runs/impl_1/*_routed.dcp]\n');
                    fprintf(fid,'set customDCPPath2 [file dirname $customDCPPath]\n');
                    fprintf(fid,'file mkdir $customDCPPath2\n');
                    fprintf(fid,'file copy -force $dcp $customDCPPath2/system_routed.dcp\n');
                end

                if obj.hETool.reportTimingFailAsWarning
                    reportErrorOnTiming=0;
                else
                    reportErrorOnTiming=1;
                end


                if~obj.hETool.hIP.hD.isMLHDLC
                    downstream.tool.runInPlugin(obj.hETool.hIP.hD,'Plugin_Tcl_Vivado.getTclBuildStreamWithTimingCheck',fid,obj.getBitstreamFolderPath,obj.getbitstreamFileName,obj.TimingFailurePostfix,obj.BitStreamFileExt,reportErrorOnTiming,obj.hETool.hIP.getEmbeddedExternalBuild,obj.getSlackTolerance);
                end

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




                obj.generateRDParameterTcl(fid,hRD);


                obj.generateIPVarsTcl(fid,hRD);


                fprintf(fid,'%s',fileread(customBuildTclFile));
                fprintf(fid,'close_project\n');
                fprintf(fid,'exit\n');
            end

            fclose(fid);

        end

        function path=getBitstreamPathLocal(obj)

            hRD=obj.hETool.getRDPlugin;
            if isempty(hRD.CustomTopLevelHDL)

                bitstreamFileName=sprintf('%s_wrapper.%s',hRD.BlockDesignName,obj.BitStreamFileExt);
            else


                [~,filename]=fileparts(hRD.CustomTopLevelHDL);
                bitstreamFileName=sprintf('%s.%s',filename,obj.BitStreamFileExt);
            end
            path=fullfile(sprintf('%s.runs',obj.getProjectName),...
            'impl_1',bitstreamFileName);
        end


        function copyRequiredFiles(obj,hRD)



            requiredFileList={...
            {hRD.CustomBlockDesignTcl,obj.CustomBlockDesignTcl}...
            };
            obj.copyFileList(requiredFileList,hRD);


            optionalFileList={...
            {hRD.CustomUpdateProjTcl,obj.CustomUpdateProjTcl}...
            ,{hRD.CustomTopLevelHDL,hRD.CustomTopLevelHDL}...
            };
            obj.copyFileListOptional(optionalFileList,hRD);


            obj.copyCustomFiles(hRD);


            obj.copyIPRepositories(hRD);
        end

        function copyIPCoreToProjFolder(obj)




            ipRepositoryPath=obj.hETool.hIP.getIPRepository;
            if~isempty(ipRepositoryPath)
                return;
            end


            ipZipFileName=obj.hETool.hIP.hIPEmitter.IPPackageZipFileName;
            sourcePath=fullfile(obj.hETool.hIP.getIPCoreFolder,ipZipFileName);


            targetPath=fullfile(obj.getProjectFolder,...
            obj.LocalIPFolder,ipZipFileName);


            downstream.tool.createDir(fileparts(targetPath));
            copyfile(sourcePath,targetPath,'f');
        end

        function copyInterfaceIPToProjFolder(obj)


            hTurnkey=obj.hETool.getTurnkeyObject;
            interfaceIDList=hTurnkey.getSupportedInterfaceIDList;


            targetFolder=fullfile(obj.getProjectFolder,obj.LocalIPFolder);


            for ii=1:length(interfaceIDList)
                interfaceID=interfaceIDList{ii};
                hInterface=hTurnkey.getInterface(interfaceID);


                if~hInterface.isIPInterface||...
                    ~hInterface.isInterfaceInUse(hTurnkey)
                    continue;
                end

                hInterface.copyInterfaceIPToProjFolder(targetFolder);
            end
        end


        function emitExternalPortTcl(obj,fid)


            hTurnkey=obj.hETool.getTurnkeyObject;
            [isAssigned,hIFCell]=...
            hdlturnkey.interface.InterfaceExternal.isExternalInterfaceAssigned(hTurnkey);
            if isAssigned
                for ii=1:length(hIFCell)
                    hInterface=hIFCell{ii};
                    obj.emitExternalPortTclOnPort(fid,hInterface);
                end
            end
        end

        function emitExternalPortTclOnPort(obj,fid,hInterface)



            if hInterface.isIPInterface&&hInterface.isIPExternalIOInterface

                if hInterface.isINOUTInterface


                    portName=hInterface.InportNames{1};
                    portWidth=hInterface.InOutSplitInputPortWidth;
                    portType=hdlturnkey.IOType.IN;
                    hdlturnkey.tool.generateVivadoTclExternalPort(fid,portName,portWidth,portType);


                    portName=hInterface.OutportNames{1};
                    portWidth=hInterface.InOutSplitOutputPortWidth;
                    portType=hdlturnkey.IOType.OUT;
                    hdlturnkey.tool.generateVivadoTclExternalPort(fid,portName,portWidth,portType);
                else

                    portName=hInterface.PortName;
                    portWidth=hInterface.PortWidth;
                    portType=hInterface.InterfaceType;
                    pinName=hInterface.PinName;


                    if(hInterface.InterfaceType==hdlturnkey.IOType.INOUT)
                        if isempty(hInterface.DutInputPortList)
                            portType=hdlturnkey.IOType.OUT;
                        else
                            portType=hdlturnkey.IOType.IN;
                        end
                    end

                    hdlturnkey.tool.generateVivadoTclExternalPort(fid,portName,portWidth,portType,pinName);
                end
            else



                hTurnkey=obj.hETool.getTurnkeyObject;
                dutPortNames=hTurnkey.hTable.hTableMap.getConnectedPortList(hInterface.InterfaceID);
                for ii=1:length(dutPortNames)
                    dutPortName=dutPortNames{ii};
                    hIOPort=hTurnkey.hTable.hIOPortList.getIOPort(dutPortName);




                    postCodeGenDutPortNames=hTurnkey.hElab.getCodegenPortNameList(dutPortName);
                    postCodeGenDutPortName=postCodeGenDutPortNames{1};


                    portWidth=hIOPort.WordLength;
                    portDimension=hIOPort.Dimension;

                    hDUT=hTurnkey.hElab.hDUTLayer;
                    hCodeGenIOPort=hDUT.getCodegenIOPort(postCodeGenDutPortName);


                    if hCodeGenIOPort.Bidirectional
                        portType=hdlturnkey.IOType.INOUT;
                    else
                        portType=hIOPort.PortType;
                    end


                    fpgaPin=hTurnkey.hTable.hTableMap.getBitRangeData(dutPortName);
                    if~isempty(fpgaPin)
                        hdlturnkey.tool.generateVivadoTclExternalPort(fid,postCodeGenDutPortName,portWidth*portDimension,portType);
                    end
                end
            end
        end


        function status=checkForError(~,status,~)


        end

        function[status,result]=downloadBit(obj,bitstreamPath,toolPath,chainPosition)



            if nargin<3||isempty(chainPosition)
                chainPosition=2;
            end

            if nargin<2
                toolPath='';
            end

            if~exist(bitstreamPath,'file')
                error(message('hdlcommon:workflow:NoBitFileWithName',bitstreamPath));
            end


            downloadTclFileName='vivado_download.tcl';
            fid=downstream.tool.createTclFile(downloadTclFileName);


            hDI=obj.hETool.hIP.hD;
            downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.generateTclDownloadBitstreamJTAG',fid,bitstreamPath,chainPosition);


            fclose(fid);


            toolCmdPath=fullfile(toolPath,'vivado -mode batch -source');
            cmdStr=sprintf('%s %s',toolCmdPath,downloadTclFileName);
            [statusSys,result]=system(cmdStr);

            status=~statusSys;

        end

    end


end












