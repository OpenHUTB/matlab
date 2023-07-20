


classdef QsysEmbeddedTool<hdlturnkey.tool.AlteraEmbeddedTool


    properties


        ConstraintFiles={};


        TclCmdStr='qsys-script';
        TclCmdStrQPro='qsys-script --quartus-project=../system';
        GUICmdStr='qsys-edit';

    end

    properties(Access=protected)


        ProjectFolder='';
        GenCmdStr='qsys-generate'


    end

    properties(Constant)
        DisplayName='Altera Qsys';

        CreateProjTcl='qsys_create_system.tcl';
        InsertIPTcl='qsys_insert_ip.tcl';
        UpdateProjTcl='qsys_update_system.tcl';
        CustomUpdateProjTcl='qsys_custom_update_system.tcl';
        GenerateProjTcl='qsys_generate_system.tcl';

        ProjectName='system_soc';
        ProjectFileExt='qsys';

        QsysFolder='qsys_prj';



        QsysGenDir='system_soc';
    end

    methods

        function obj=QsysEmbeddedTool(hETool)

            obj=obj@hdlturnkey.tool.AlteraEmbeddedTool(hETool);
            obj.ProjectFolder=obj.QsysFolder;
        end

    end


    methods

        function checkToolPath(obj)


            alteraToolPath=obj.hETool.hIP.hD.hToolDriver.getToolPath;


            obj.ToolPath=fullfile(fileparts(alteraToolPath),'sopc_builder','bin');

        end

    end


    methods

        function[status,result]=runCreateProject(obj)

            result='';


            hRD=obj.hETool.getRDPlugin;


            methodStr=hRD.IPInsertionMethod;
            if~strcmpi(methodStr,'Insert')&&~strcmpi(methodStr,'Replace')
                error(message('hdlcommon:workflow:IPInsertMethodInvalid'));
            end


            copyRequiredFiles(obj,hRD);


            tclFilePath=generateCreateProjTcl(obj,hRD);
            [status,result_tcl]=obj.runTclFile(tclFilePath,obj.getTclCmdStrFull);
            result=sprintf('%s%s',result,result_tcl);
            if~status
                return;
            end


            copyIPCoreToProjFolder(obj);


            tclFilePath=generateInsertIPTcl(obj,hRD);
            [status,result_tcl]=obj.runTclFile(tclFilePath,obj.getTclCmdStrFull);
            result=sprintf('%s%s',result,result_tcl);
            if~status
                return;
            end


            if~isempty(hRD.CustomUpdateQsysTcl)
                tclFilePath=generateUpdateProjTcl(obj,hRD);
                [status,result_tcl]=obj.runTclFile(tclFilePath,obj.getTclCmdStrFull);
                result=sprintf('%s%s',result,result_tcl);
            end
        end

        function[status,result]=runBuild(obj)



            hCodeGen=obj.hETool.getCodeGenObject;
            if hCodeGen.isVHDL
                targetL='VHDL';
            else
                targetL='VERILOG';
            end


            ipRepositoryPath=obj.hETool.hIP.getIPRepository;
            hDI=obj.hETool.hIP.hD;
            if~isempty(ipRepositoryPath)
                ipRepositoryFolder=obj.getQsysIPRepositoryFolder(ipRepositoryPath);
                cmdStr=downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Quartus.getCmdQsysGenerate',...
                obj.getCmdStrFull(obj.GenCmdStr),targetL,obj.QsysGenDir,obj.getProjectFileName,...
                ipRepositoryFolder);
            else
                cmdStr=downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Quartus.getCmdQsysGenerate',...
                obj.getCmdStrFull(obj.GenCmdStr),targetL,obj.QsysGenDir,obj.getProjectFileName,'');
            end

            currentDir=cd(obj.getProjectFolder);


            tic;
            errStr='Error: ip-generate failed';
            [status,resultSys]=obj.run_cmd(cmdStr,errStr,hDI.logDisplay);
            time=toc;
            result=sprintf('%s\nElapsed time is %s seconds.\n',resultSys,num2str(time));

            cd(currentDir);
        end


        function setProjectFolder(obj,folder)
            obj.ProjectFolder=fullfile(folder,obj.QsysFolder);
        end

        function qipfile=getQIPFilePath(obj)
            fpgaFamilystr=obj.getFPGAFamily;
            if alteratarget.isFamilyArria10OrLater(fpgaFamilystr)
                qipfile=fullfile(obj.getProjectFolder,obj.QsysGenDir,...
                [obj.getProjectName,'.qip']);
            else
                qipfile=fullfile(obj.getProjectFolder,obj.QsysGenDir,'synthesis',...
                [obj.getProjectName,'.qip']);
            end
        end

        function ipRepositoryFolder=getQsysIPRepositoryFolder(~,ipRepositoryPath)
            ipRepositoryFolder=downstream.tool.filterBackSlash(...
            downstream.tool.getAbsoluteFolderPath(ipRepositoryPath));
            ipRepositoryFolder=sprintf('"%s/**/*"',ipRepositoryFolder);
        end

    end

    methods(Access=protected)



        function tclFilePath=generateCreateProjTcl(obj,hRD)





            fpgaDevStr=obj.getFPGADeviceStr;

            fpgaFamilystr=obj.getFPGAFamily;


            tclFilePath=fullfile(obj.getProjectFolder,obj.CreateProjTcl);
            fid=downstream.tool.createTclFile(tclFilePath,obj.hETool.hIP.getCurrentDir);





            emitLoadProjTcl(obj,fid,hRD);


            fprintf(fid,'set_project_property deviceFamily "%s"\n',fpgaFamilystr);
            fprintf(fid,'set_project_property device "%s"\n',fpgaDevStr);


            emitSaveProjTcl(obj,fid);

            fclose(fid);
        end

        function tclFilePath=generateInsertIPTcl(obj,hRD)


            hDI=obj.hETool.hIP.hD;


            tclFilePath=fullfile(obj.getProjectFolder,obj.InsertIPTcl);
            fid=downstream.tool.createTclFile(tclFilePath,obj.hETool.hIP.getCurrentDir);





            emitLoadProjTcl(obj,fid,hRD);

            methodStr=hRD.IPInsertionMethod;
            if strcmpi(methodStr,'Replace')
                fprintf(fid,'remove_instance %s\n',hRD.ReplacedIPInstance);
            end


            fprintf(fid,'add_instance ${HDLCODERIPINST} %s %s\n',...
            obj.getIPCoreName,obj.hETool.hIP.getIPCoreVersion);


            hClockModule=hDI.getClockModule;
            hClockModule.generateQuartusTclConnectClockReset(hDI,fid);

            if~strcmpi(obj.hETool.hIP.hD.Tool.Value,'Intel Quartus Pro')

                hClockModule.generateQuartusTclSetClockFreq(hDI,fid);
            end


            obj.generateInsertIPInterfaceQsysTcl(fid);


            emitExternalPortTcl(obj,fid);


            emitSaveProjTcl(obj,fid);

            fclose(fid);
        end

        function generateInsertIPInterfaceQsysTcl(obj,fid)


            hTurnkey=obj.hETool.getTurnkeyObject;
            interfaceIDList=hTurnkey.getSupportedInterfaceIDList;

            for ii=1:length(interfaceIDList)
                interfaceID=interfaceIDList{ii};
                hInterface=hTurnkey.getInterface(interfaceID);


                if~hInterface.isIPInterface||...
                    ~hInterface.isInterfaceInUse(hTurnkey)
                    continue;
                end




                hInterface.generateRDInsertIPQsysTcl(fid,obj);
            end
        end

        function tclFilePath=generateUpdateProjTcl(obj,hRD)



            tclFilePath=fullfile(obj.getProjectFolder,obj.UpdateProjTcl);
            fid=downstream.tool.createTclFile(tclFilePath,obj.hETool.hIP.getCurrentDir);





            emitLoadProjTcl(obj,fid,hRD);

            obj.tclSourceFile(fid,obj.CustomUpdateProjTcl);


            emitSaveProjTcl(obj,fid);

            fclose(fid);
        end

        function emitLoadProjTcl(obj,fid,hRD)

            fprintf(fid,'package require -exact qsys %s\n',obj.APIVer);

            fprintf(fid,'load_system %s\n',obj.getProjectFileName);
            fprintf(fid,'set HDLCODERIPINST %s\n',obj.getIPCoreInstanceName);


            obj.generateRDParameterTcl(fid,hRD);
        end

        function emitSaveProjTcl(obj,fid)

            fprintf(fid,'validate_system\n');

            fprintf(fid,'save_system %s\n',obj.getProjectFileName);
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
                    obj.emitExternalPortTclCmd(fid,portName);


                    portName=hInterface.OutportNames{1};
                    obj.emitExternalPortTclCmd(fid,portName);
                else

                    portName=hInterface.PortName;
                    obj.emitExternalPortTclCmd(fid,portName);
                end
            else



                hTurnkey=obj.hETool.getTurnkeyObject;
                dutPortNames=hTurnkey.hTable.hTableMap.getConnectedPortList(hInterface.InterfaceID);
                for ii=1:length(dutPortNames)
                    dutPortName=dutPortNames{ii};


                    postCodeGenDutPortNames=hTurnkey.hElab.getCodegenPortNameList(dutPortName);
                    postCodeGenDutPortName=postCodeGenDutPortNames{1};




                    fpgaPin=hTurnkey.hTable.hTableMap.getBitRangeData(dutPortName);
                    if~isempty(fpgaPin)
                        obj.emitExternalPortTclCmd(fid,postCodeGenDutPortName);
                    end
                end
            end
        end

        function emitExternalPortTclCmd(~,fid,portName)


            conduitName=sprintf('${HDLCODERIPINST}_%s',portName);
            exportedName=sprintf('${HDLCODERIPINST}.%s',portName);


            propList={{'EXPORT_OF',exportedName}};
            portList={};

            hdlturnkey.tool.generateQsysTclInterfaceDefinition(fid,conduitName,hdlturnkey.IOType.IN,'conduit',propList,portList);

        end


        function copyRequiredFiles(obj,hRD)




            requiredFileList={...
            {hRD.CustomQsysPrjFile,obj.getProjectFileName}...
            };
            obj.copyFileList(requiredFileList,hRD);





            fileList={{hRD.CustomUpdateQsysTcl,obj.CustomUpdateProjTcl}...
            };
            obj.copyFileListOptional(fileList,hRD);


            obj.copyCustomFiles(hRD);


            obj.copyIPRepositories(hRD);
        end

        function copyIPCoreToProjFolder(obj)




            ipRepositoryPath=obj.hETool.hIP.getIPRepository;
            if~isempty(ipRepositoryPath)
                return;
            end

            sourcePath=obj.hETool.hIP.getIPCoreFolder;
            pcoreFolderName=obj.hETool.hIP.hIPEmitter.getIPCoreFolderName;
            targetPath=fullfile(obj.getProjectFolder,...
            obj.LocalIPFolder,pcoreFolderName);

            downstream.tool.createDir(fileparts(targetPath));
            copyfile(sourcePath,targetPath,'f');
        end


        function[status,result]=runTclFile(obj,tclFilePath,toolCmdStr)


            [tclFileFolder,tname,text]=fileparts(tclFilePath);
            tclFileName=sprintf('%s%s',tname,text);
            currentDir=cd(tclFileFolder);
            if~exist(tclFileName,'file')
                error(message('hdlcommon:workflow:NoTclFileWithName',tclFileName));
            end


            ipRepositoryPath=obj.hETool.hIP.getIPRepository;
            if~isempty(ipRepositoryPath)
                cd(currentDir);
                ipRepositoryFolder=obj.getQsysIPRepositoryFolder(ipRepositoryPath);
                cd(tclFileFolder);
                cmdStr=sprintf('%s --script=%s --search-path=%s,$',...
                toolCmdStr,tclFileName,ipRepositoryFolder);
            else
                cmdStr=sprintf('%s --script=%s',toolCmdStr,tclFileName);
            end


            hDI=obj.hETool.hIP.hD;

            tic;
            [status,resultSys]=obj.run_cmd(cmdStr,'',hDI.logDisplay);
            time=toc;
            result=sprintf('%s\nElapsed time is %s seconds.\n',resultSys,num2str(time));

            cd(currentDir);
        end

    end

end



