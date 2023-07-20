




classdef Manager<handle

    methods(Static,Access=public)
        function i=instance()
            mlock;
            persistent singleton;
            if isempty(singleton)
                singleton=emlhdlcoder.WorkFlow.Manager();
            end

            assert(isvalid(singleton));
            i=singleton;
        end

        function AddWebBrowser(filenameforuser)

            mgr=emlhdlcoder.WorkFlow.Manager.instance();
            if(~isempty(mgr))
                mgr.addWebBrowser(filenameforuser);
            else
                warning(message('Coder:hdl:CannotFindManager'))
            end
        end
    end

    properties(Access=private)
        hdlState;
        workflowState;
        proposedTypesReport;
        projectFile;
        WebBrowserHandles;
    end


    methods


        function this=Manager()
            this.WebBrowserHandles=WebBrowserHandleCollector();
        end


        function delete(this)
            if(isvalid(this.WebBrowserHandles))
                delete(this.WebBrowserHandles);
            end
        end


        function closeAllWebBrowsers(this)

            this.WebBrowserHandles.closeAllWebBrowsers();
        end



        function addWebBrowser(this,filePath)

            this.WebBrowserHandles.addWebBrowser(filePath);
            return
        end


        function hs=setupHdlState(this)
            if isempty(this.hdlState)
                this.hdlState.oldDriver=hdlcurrentdriver;
                this.hdlState.oldMode=hdlcodegenmode;
                this.hdlState.currentDriver=slhdlcoder.HDLCoder;
                hdlcurrentdriver(this.hdlState.currentDriver);
                hdlcodegenmode('slcoder');
            end
            hs=this.hdlState;
        end


        function cleanupHdlState(this)
            if~isempty(this.hdlState)
                hdlcodegenmode(this.hdlState.oldMode);
                hdlcurrentdriver(this.hdlState.oldDriver);
            end
            isMatlabMode=false;
            hdlCfg=[];
            hdlismatlabmode(isMatlabMode,hdlCfg);
            this.hdlState=[];
        end


        function deleteDir(~,d)
            [status,attributes]=fileattrib(d);
            if status~=0
                if attributes.directory~=0
                    coder.make.internal.removeDir(d);
                else
                    delete(d);
                end
            end
        end


        function[dirInfo,defaultDirInfo]=getDirInfoFromPrjFile(this,prjRoot,prjName)

            this.projectFile=prjName;


            defaultDirInfo.workDir=prjRoot;
            workDir='';
            try





                workDirOpt=this.getPluginParam(prjName,'param.hdl.WorkingDirectory');
                switch workDirOpt
                case 'option.hdl.ProjectDirectory'
                    workDirOpt='option.WorkingFolder.Project';
                case 'option.hdl.CurrentDirectory'
                    workDirOpt='option.WorkingFolder.Current';
                otherwise
                    workDir=char(this.getPluginParam(prjName,'param.hdl.WorkingSpecifiedDirectory'));
                end
            catch
                workDirOpt=this.getPluginParam(prjName,'param.WorkingFolder');
            end

            if isempty(workDir)
                switch workDirOpt
                case 'option.WorkingFolder.Project'
                    workDir=defaultDirInfo.workDir;
                case 'option.WorkingFolder.Current'
                    workDir='';
                otherwise
                    workDir=this.getPluginParam(prjName,'param.SpecifiedWorkingFolder');
                    workDir=char(workDir);
                end
            end

            defaultDirInfo.bldDir=fullfile(prjRoot,'codegen',getDesignFcnNameFromProject(prjName),'hdlsrc');
            defaultDirInfo.fxpBldDir=fullfile(prjRoot,'codegen',getDesignFcnNameFromProject(prjName),'fixpt');
            defaultDirInfo.codegenFolder=fullfile(prjRoot,'codegen');


            try





                bldDirOpt=this.getPluginParam(prjName,'param.hdl.BuildDirectory');
                switch bldDirOpt
                case 'option.hdl.ProjectDirectory'
                    bldDirOpt='option.BuildFolder.Project';
                case 'option.hdl.CurrentDirectory'
                    bldDirOpt='option.BuildFolder.Current';
                otherwise
                    bldDirOpt='option.BuildFolder.Specified';
                    bldDir=char(this.getPluginParam(prjName,'param.hdl.BuildSpecifiedDirectory'));
                end
            catch
                bldDirOpt=this.getPluginParam(prjName,'param.BuildFolder');
            end

            switch bldDirOpt
            case 'option.BuildFolder.Project'
                bldDir=defaultDirInfo.bldDir;
                fxpBldDir=defaultDirInfo.fxpBldDir;
                codegenFolder=defaultDirInfo.codegenFolder;
            case 'option.BuildFolder.Current'
                bldDir='';
                fxpBldDir=pwd;
                codegenFolder='';
            otherwise
                if isempty(bldDir)
                    bldDir=this.getPluginParam(prjName,'param.SpecifiedBuildFolder');
                    bldDir=char(bldDir);
                end
                singDotPos=strfind(bldDir,'.');
                doubleDotPos=strfind(bldDir,'..');
                isRelativePath=isempty(strfind(bldDir,filesep))||(~isempty(doubleDotPos)&&doubleDotPos(1)==1)||(~isempty(singDotPos)&&singDotPos(1)==1);
                if(isRelativePath)
                    bldDir=fullfile(workDir,bldDir);
                end
                [status,mess]=fileattrib(bldDir);
                if(~status)
                    [s,mess,messid]=mkdir(bldDir);
                    if(s==0)
                        error(messid,mess);
                    end
                    [~,mess]=fileattrib(bldDir);
                end

                bldDir=mess.Name;
                codegenFolder=fullfile(bldDir);
                bldDir=fullfile(codegenFolder,getDesignFcnNameFromProject(prjName),'hdlsrc');
                fxpBldDir=fullfile(codegenFolder,getDesignFcnNameFromProject(prjName),'fixpt');
            end

            dirInfo.workDir=workDir;
            dirInfo.bldDir=bldDir;
            dirInfo.fxpBldDir=fxpBldDir;
            dirInfo.codegenFolder=codegenFolder;


            function[fcnName,fcnPath]=getDesignFcnNameFromProject(project)

                prjFile=strtrim(project);

                fcnName='';
                fcnPath='';
                if(~isempty(prjFile))
                    xDoc=xmlread(prjFile);
                    c=xDoc.getFirstChild;
                    entryPoints=c.getElementsByTagName('fileset.entrypoints');
                    if entryPoints.getLength==0
                        return;
                    end
                    entryPoint=entryPoints.item(0);
                    fileName=[];
                    for i=0:entryPoint.getChildNodes.getLength-1
                        node=entryPoint.getChildNodes.item(i);
                        if strcmp(node.getNodeName,'file')
                            fileName=node.getAttributes.getNamedItem('value').getNodeValue.toCharArray';
                            break;
                        end
                    end
                    if isempty(fileName)
                        return;
                    end
                    prjRoot=fileparts(prjFile);
                    fileName=strrep(fileName,'${PROJECT_ROOT}',prjRoot);
                    [fcnPath,fcnName,~]=fileparts(fileName);
                end
            end
        end


        function[inVals,outVals]=useTBToInferInputTypes(this,CC,isFixptDone)
            dName=CC.ConfigInfo.DesignFunctionName;
            tbNames=CC.ConfigInfo.TestBenchName;


            if ischar(tbNames)
                tbNames={tbNames};
            end

            if(~isempty(CC.Options.workDir))
                pathBak=path;
                addpath(CC.Options.workDir);
                cleanup=onCleanup(@()path(pathBak));
            end


            hdlCfg=CC.ConfigInfo;
            fixPtDone=hdlCfg.IsFixPtConversionDone;
            if~isempty(CC.FixptData)
                fxpCfg=CC.FixptData;
            end

            customerDesignFolderName=dName;
            if fixPtDone
                customerDesignFolderName=fxpCfg.DesignFunctionName;
            end
            actualDesignName=customerDesignFolderName;

            if(isfield(CC.HDLState,'codegenDir'))
                [fpcRootDir,codeGenFolderName,~]=fileparts(CC.HDLState.codegenDir);
                [~,outputFilesDir]=coder.internal.Float2FixedConverter.getWorkingAndOutputDir(fpcRootDir,codeGenFolderName,customerDesignFolderName);
            else
                [~,outputFilesDir]=coder.internal.Float2FixedConverter.getWorkingAndOutputDir([],[],customerDesignFolderName);
            end



            fxpDirExistsToBeginWith=true;
            d=dir(outputFilesDir);
            if isempty(d)
                fxpDirExistsToBeginWith=false;
            end

            if fixPtDone
                wrapperName=coder.internal.Float2FixedConverter.buildFixPtWrapperName(actualDesignName,fxpCfg.FixPtFileNameSuffix);

                tbNames=coder.internal.Float2FixedConverter.createFixPtTBsWithCallToWrappers(tbNames,outputFilesDir,actualDesignName,wrapperName,fxpCfg.FixPtFileNameSuffix);
            end

            if(isfield(CC.HDLState,'codegenDir'))
                [fpcRootDir,codeGenFolderName,~]=fileparts(CC.HDLState.codegenDir);


                fpc=coder.internal.Float2FixedConverter(dName,tbNames,customerDesignFolderName,fpcRootDir,codeGenFolderName);
            else
                fpc=coder.internal.Float2FixedConverter(dName,tbNames,customerDesignFolderName);
            end

            [inVals,outVals]=fpc.runTestBenchToLogData(fpc.fxpCfg.OutputFilesDirectory,dName,tbNames,true,false,isFixptDone);

            if~fxpDirExistsToBeginWith
                this.deleteDir(fpc.fxpCfg.OutputFilesDirectory);
            end
        end


        function paramVal=getPluginParam(this,prjFile,param)
            if this.isProjectLoaded(prjFile)
                dt=getDeployToolProjectInstance(this);
                paramVal=dt.getConfiguration().getParamAsObject(param);
            else
                paramVal=this.getStringProp(prjFile,param);
            end
        end


        function proj=getDeployToolProjectInstance(~)
            proj=[];
            dt=com.mathworks.project.impl.DeployTool.getInstance(false);
            if(~isempty(dt))
                proj=dt.getProject();
            end
        end


        function b=isProjectLoaded(this,~)
            currPrj=this.getDeployToolProjectInstance;
            b=~isempty(currPrj);
        end


        function prjName=getProjectFile(~)
            prjName='';
            dt=com.mathworks.project.impl.DeployTool.getInstance(false);
            if~isempty(dt)
                prj=dt.getProject();
                if~isempty(prj)
                    prjName=char(prj.getFile.toString);
                end
            end
        end


        function[fcnName,fcnPath]=getDesignFcnName(~,javaConfig)
            dataAdapter=com.mathworks.toolbox.coder.fixedpoint.FixedPointDataAdapterFactory.create(javaConfig);
            javaFile=dataAdapter.getEntryPoints().last();
            fcnName=char(javaFile.getName());
            fcnPath=char(javaFile.getPath());
        end


        function propVal=getStringProp(~,prjFileName,propName)

            propVal='';
            prjFileName=strtrim(prjFileName);
            prj=xmlread(prjFileName);
            doc=prj.getFirstChild();

            sf=doc.getElementsByTagName(propName);
            sfc=sf.item(0);
            if~isempty(sfc)
                propVal=strtrim(char(sfc.getTextContent()));
            end

        end


        function b=isInWorkFlowMode(this)
            b=false;
            if~isempty(this.workflowState)
                b=this.workflowState.inWorkFlowMode;
            end
        end


        function b=needsFixedPointConversion(this,project)
            if nargin<=1
                prjFile=this.projectFile;
            else
                prjFile=project;
            end
            if~isempty(prjFile)
                b=strcmp(this.getPluginParam(prjFile,'param.fixptconv.enum.needfixedpoint'),'option.fixptconv.enum.needfixedpoint.yes');
            else
                cfg=this.getDeployToolProjectInstance.getConfiguration();
                b=strcmp(cfg.getParamAsString('param.fixptconv.enum.needfixedpoint'),'option.fixptconv.enum.needfixedpoint.yes');
            end
        end


        function fpc=getFixedPointConverter(this)
            fpc=[];
            if~isempty(this.workflowState)
                fpc=this.workflowState.converterObj;
            end
        end


        function pluginOpenCallBack(this)

            getHDLToolInfo('reset');
            this.setupHdlState();
        end


        function pluginCloseCallBack(this)

            getHDLToolInfo('resetOnClose');
            this.cleanupHdlState();
            this.projectFile=[];
            this.workflowState=[];

            coder.internal.F2FGuiCallbackManager.resetAndClear();
            coderprivate.Float2FixedManager.instance.reset();
        end


        function resetCallBack(this,step)
            if(~isempty(step))
                if(strcmp(step,'category.workflow.analyzecode'))
                    this.workflowState=[];
                elseif(strcmp(step,'category.workflow.generatefixptcode'))
                    if(~isempty(this.workflowState))
                        this.workflowState.successful=false;
                    end
                    coder.internal.F2FGuiCallbackManager.getInstance.reset();
                elseif(strcmp(step,'category.workflow.proposefixpttypes'))
                    fpc=this.getFixedPointConverter();
                    if~isempty(fpc)
                        fpc.resetSimulationAndDerivedInfo();
                    end
                end
            end
        end


        function report=wfa_generateCode(this,projectFile)
            dlg=com.mathworks.toolbox.coder.proj.workflowui.WorkflowDialog.getInstance;
            report=this.wfa_generateCodeWithConfig(projectFile,dlg.getConfiguration());
            if isfield(report,'inference')
                report=emlcprivate('flattenInferenceReportForJava',report);
            else
                report=[];
            end
        end


        function report=wfa_generateCodeWithConfig(this,prjFileName,cfg)
            try
                t=tic;
                genHDLTb=cfg.getParamAsBoolean('param.hdl.GenerateHDLTestBench');
                genCosim=cfg.getParamAsBoolean('param.hdl.GenerateCosimTestBench');
                genFIL=cfg.getParamAsBoolean('param.hdl.GenerateFILTestBench');

                if genHDLTb
                    setConfigParamAsBoolean(cfg,'param.hdl.GenerateHDLTestBench',false);
                    onCleanupObjHDL=onCleanup(@()...
                    setConfigParamAsBoolean(cfg,'param.hdl.GenerateHDLTestBench',genHDLTb));
                end
                if genCosim
                    setConfigParamAsBoolean(cfg,'param.hdl.GenerateCosimTestBench',false);
                    onCleanupObjCosim=onCleanup(@()...
                    setConfigParamAsBoolean(cfg,'param.hdl.GenerateCosimTestBench',genCosim));
                end
                if genFIL
                    setConfigParamAsBoolean(cfg,'param.hdl.GenerateFILTestBench',false);
                    onCleanupObjFIL=onCleanup(@()...
                    setConfigParamAsBoolean(cfg,'param.hdl.GenerateFILTestBench',genFIL));
                end

                if genHDLTb||genCosim||genFIL
                    com.mathworks.project.impl.model.ProjectManager.waitForSave(cfg.getProject());
                end

                if isempty(this.workflowState)
                    this.workflowState.inWorkFlowMode=true;
                    this.workflowState.successful=false;
                end

                pathBak=path;
                [prjPath,~,~]=fileparts(strtrim(prjFileName));
                if~isempty(prjPath)
                    addpath(prjPath);
                end
                cleanup=onCleanup(@()path(pathBak));

                adapter=com.mathworks.toolbox.coder.fixedpoint.FixedPointDataAdapterFactory.create(cfg);
                if adapter.isModeAutomatic

                    f2fConverter=coderprivate.Float2FixedManager.instance.fpc;
                    fixPtCfg=f2fConverter.fxpCfg;

                    if isempty(fixPtCfg)

                        args=coder.internal.tools.prj2config(strtrim(prjFileName));
                        fixPtCfg=args{1};
                    end

                    if isa(fixPtCfg,'coder.FixPtConfig')&&isempty(fixPtCfg.DesignFunctionName)
                        fixPtCfg.DesignFunctionName=this.getDesignFcnName(cfg);
                    end

                    report=codegen(prjFileName,'-fixPtData',fixPtCfg,'--javaConfig',cfg);
                else
                    report=codegen(prjFileName,'--javaConfig',cfg);
                end

                coder.internal.emcError(char(adapter.getEntryPoints().iterator().next().getName()),report);

                dirInfo=this.getDirInfoFromPrjFile(prjPath,prjFileName);
                cd(dirInfo.workDir);
                disp(['### ',message('Coder:hdl:mgr_elapsed_time',sprintf('%18.4f',toc(t))).getString()]);
            catch me
                disp(me.message);

                me.throwAsCaller();
            end
        end


        function wfa_generateCosimTB(this,prjFileName)
            try

                genCosim=this.getPluginParam(prjFileName,'param.hdl.GenerateCosimTestBench');

                if genCosim
                    [~,hdlCfg]=hdlismatlabmode;

                    runSim=this.getPluginParam(prjFileName,'param.hdl.SimulateCosimTestBench');
                    logOutputs=this.getPluginParam(prjFileName,'param.hdl.CosimLogOutputs');

                    switch this.getPluginParam(prjFileName,'param.hdl.CosimRunMode')
                    case 'option.hdl.Batch'
                        runmode='Batch';
                    otherwise
                        runmode='GUI';
                    end


                    hMgr=emlhdlcoder.WorkFlow.CodeGenInfoManager.instance;
                    cgInfo=hMgr.getCgInfo;

                    l_updateCosimTbParam(this,prjFileName);

                    cosimtool=this.getPluginParam(prjFileName,'param.hdl.CosimTool');
                    switch cosimtool
                    case 'option.hdl.ModelSim'
                        hdlCfg.CosimTool='ModelSim';
                        gentb=emlhdlcoder.hdlverifier.GenMatlabModelSimTb(cgInfo,runmode);
                    case 'option.hdl.Incisive'
                        hdlCfg.CosimTool='Incisive';
                        gentb=emlhdlcoder.hdlverifier.GenMatlabIncisiveTb(cgInfo,runmode);
                    case 'option.hdl.VivadoSimulator'
                        hdlCfg.CosimTool='Vivado Simulator';
                        gentb=emlhdlcoder.hdlverifier.GenMatlabVivadoSimTb(cgInfo,runmode);
                    end

                    gentb.isOutputDataLogged=logOutputs;


                    gentb.doIt;


                    if runSim
                        runSimulation(gentb);
                    end
                else
                    hdldisp(message('Coder:hdl:mgr_skipped_tb_cosim').getString());
                end

            catch me
                rethrow(me);
            end

        end


        function wfa_generateFILTB(this,prjFileName)
            try

                genFIL=this.getPluginParam(prjFileName,'param.hdl.GenerateFILTestBench');

                if genFIL

                    simFIL=this.getPluginParam(prjFileName,'param.hdl.SimulateFILTestBench');
                    boardName=this.getPluginParam(prjFileName,'param.hdl.FILBoardName');
                    connection=this.getPluginParam(prjFileName,'param.hdl.FILConnection');
                    ipAddr=this.getPluginParam(prjFileName,'param.hdl.FILBoardIPAddress');
                    macAddr=this.getPluginParam(prjFileName,'param.hdl.FILBoardMACAddress');
                    addFile=this.getPluginParam(prjFileName,'param.hdl.FILAdditionalFiles');
                    logOutputs=this.getPluginParam(prjFileName,'param.hdl.FILLogOutputs');


                    hMgr=emlhdlcoder.WorkFlow.CodeGenInfoManager.instance;
                    cgInfo=hMgr.getCgInfo;

                    gentb=emlhdlcoder.hdlverifier.GenMatlabFILTb(...
                    cgInfo,boardName,connection,ipAddr,macAddr,addFile);

                    gentb.isOutputDataLogged=logOutputs;
                    gentb.isBlockingMode=simFIL;


                    gentb.doIt;


                    if simFIL
                        runSimulation(gentb);
                    end
                else
                    hdldisp(message('Coder:hdl:mgr_skipped_tb_cosim').getString());
                end

            catch me
                rethrow(me);
            end

        end


        function qq=get_SynthToolScript_Tool(this,prjFileName)
            persistent synth_tool_scripts;
            if(isempty(synth_tool_scripts)||nargin==2)
                synth_tool_scripts=regexp(this.getPluginParam(prjFileName,'param.hdl.HDLSynthTool'),'\.','split');
                synth_tool_scripts=synth_tool_scripts{3};
            end
            qq=synth_tool_scripts;
            return
        end


        function wfa_runSimulation(this,prjFileName)
            try

                prjFileName=strtrim(prjFileName);

                [~,hdlCfg]=hdlismatlabmode;
                genSim=this.getPluginParam(prjFileName,'param.hdl.GenerateHDLTestBench');
                runSim=this.getPluginParam(prjFileName,'param.hdl.SimulateGeneratedCode');

                hdlDrv=hdlcurrentdriver;

                if~hdlCfg.GenerateHDLCode

                    disp(message('Coder:hdl:mgr_hdl_skip_tb').getString())
                    return;
                end

                if~genSim

                    disp(message('Coder:hdl:mgr_hdltb_skip_tb').getString());
                    return;
                end

                t=tic;

                [prjPath,~,~]=fileparts(strtrim(prjFileName));
                dirInfo=this.getDirInfoFromPrjFile(prjPath,prjFileName);
                cd(dirInfo.workDir);

                dName=hdlCfg.DesignFunctionName;
                tbName=hdlCfg.TestBenchScriptName;

                tool=this.getPluginParam(prjFileName,'param.hdl.SimulationTool');
                hdlCfg.SimulationTool=tool;
                hdlCfg.SimulateGeneratedCode=runSim;

                useFiAccel=hdlCfg.UseFiAccelForTestBench;

                emlcHdlTB=emlhdlcoder.HDLCoderTB(tbName,dName,hdlDrv,useFiAccel);


                l_updateHDLTBParam(this,prjFileName,emlcHdlTB);

                emlcHdlTB.generateTB(hdlDrv);



                if hdlCfg.GenerateEDAScripts
                    synth_tool_scripts=this.get_SynthToolScript_Tool(prjFileName);
                    emlcHdlTB.generateCustomScripts(true,true,synth_tool_scripts);
                end

                if runSim
                    emlcHdlTB.generateTBScriptsForAutoSim(hdlDrv,tool);
                    simDriver=emlhdlcoder.Driver.SimulationDriver(hdlCfg,hdlDrv);
                    simDriver.doIt;
                end

                cd(dirInfo.workDir);

                disp(['### ',message('Coder:hdl:mgr_elapsed_time',sprintf('%18.4f',toc(t))).getString()]);
            catch me
                cd(dirInfo.workDir);
                rethrow(me);
            end
        end


        function wfa_runSystemCSimulation(this,prjFileName)
            try
                prjFileName=strtrim(prjFileName);

                [~,hdlCfg]=hdlismatlabmode;
                runSim=this.getPluginParam(prjFileName,'param.hdl.SimulateGeneratedCode');

                hdlDrv=hdlcurrentdriver;
                dName=hdlCfg.DesignFunctionName;

                if~hdlCfg.GenerateHDLCode

                    disp(message('Coder:hdl:mgr_hdl_skip_tb').getString())
                    return;
                end

                tool=this.getPluginParam(prjFileName,'param.hdl.SynthesisTool');
                sysCTB=this.getPluginParam(prjFileName,'param.hdl.SystemCTestBenchStimulus');
                genHDLTB=this.getPluginParam(prjFileName,'param.hdl.GenerateHDLTestBench');
                tbName=hdlCfg.TestBenchScriptName;

                hdlCfg.SimulateGeneratedCode=runSim;
                hdlCfg.GenerateHDLTestBench=genHDLTB;
                hdlCfg.SynthesisTool=tool;
                if contains(sysCTB,'RAND_TB')
                    hdlCfg.SystemCTestBenchStimulus="Test bench with random input stimulus";
                end

                if~genHDLTB&&tool~="Cadence Stratus"

                    disp(message('Coder:hdl:mgr_hdltb_skip_tb').getString());
                    return;
                end

                [prjPath,~,~]=fileparts(strtrim(prjFileName));
                dirInfo=this.getDirInfoFromPrjFile(prjPath,prjFileName);

                t=tic;

                cd(dirInfo.workDir);
                useFiAccel=hdlCfg.UseFiAccelForTestBench;

                emlcHdlTB=emlhdlcoder.HDLCoderTB(tbName,dName,hdlDrv,useFiAccel);


                l_updateHDLTBParam(this,prjFileName,emlcHdlTB);

                if(tool~="Cadence Stratus"&&genHDLTB)||(tool=="Cadence Stratus"&&sysCTB=="option.hdl.HDLTB")
                    emlcHdlTB.generateTB(hdlDrv);
                end

                if tool=="Cadence Stratus"
                    emlcHdlTB.generateBDWImportScripts(hdlCfg.SystemCTestBenchStimulus,dName);
                end

                if runSim
                    if tool~="Cadence Stratus"&&tool~="Xilinx Vitis HLS"



                        error(message('hdlcoder:workflow:InvalidHLSTool',tool));
                    end

                    simDriver=emlhdlcoder.Driver.SimulationDriver(hdlCfg,hdlDrv);
                    simDriver.doIt;
                end

                cd(dirInfo.workDir);
                disp(['### ',message('Coder:hdl:mgr_elapsed_time',sprintf('%18.4f',toc(t))).getString()]);

            catch me
                cd(dirInfo.workDir);
                rethrow(me);
            end
        end


        function wfa_createSynthesisProject(this,prjFile)
            try
                [~,hdlCfg]=hdlismatlabmode;
                hdlDrv=hdlcurrentdriver;

                tool=this.getPluginParam(prjFile,'param.hdl.SynthesisTool');
                family=this.getPluginParam(prjFile,'param.hdl.SynthesisToolChipFamily');
                device=this.getPluginParam(prjFile,'param.hdl.SynthesisToolDeviceName');
                pkg=this.getPluginParam(prjFile,'param.hdl.SynthesisToolPackageName');
                speed=this.getPluginParam(prjFile,'param.hdl.SynthesisToolSpeedValue');
                filePaths=this.getPluginParam(prjFile,'param.hdl.AdditionalSynthesisProjectFiles');
                filePathStr=char(com.mathworks.project.impl.util.StringUtils.listToDelimitedString(filePaths,';'));

                hdlCfg.SynthesisTool=tool;
                hdlCfg.SynthesisToolChipFamily=family;
                hdlCfg.SynthesisToolDeviceName=device;
                hdlCfg.SynthesisToolPackageName=pkg;
                hdlCfg.SynthesisToolSpeedValue=speed;
                hdlCfg.AdditionalSynthesisProjectFiles=filePathStr;

                synDriver=emlhdlcoder.Driver.SynthesisDriver(hdlCfg,hdlDrv);
                dumpResults=true;

                t=tic;
                synDriver.createProject(dumpResults);
                disp(['### ',message('Coder:hdl:mgr_elapsed_time',sprintf('%18.4f',toc(t))).getString()]);
            catch me
                disp(me.message);rethrow(me);
            end
        end


        function wfa_runSynthesis(this,prjFileName)
            try
                [~,hdlCfg]=hdlismatlabmode;
                hdlDrv=hdlcurrentdriver;

                genHDLTB=this.getPluginParam(prjFileName,'param.hdl.GenerateHDLTestBench');
                hdlCfg.GenerateHDLTestBench=genHDLTB;

                synDriver=emlhdlcoder.Driver.SynthesisDriver(hdlCfg,hdlDrv);

                if(hdlCfg.Workflow=="High Level Synthesis")
                    dumpResults=false;
                else
                    dumpResults=true;
                end

                [prjPath,~,~]=fileparts(strtrim(prjFileName));
                dirInfo=this.getDirInfoFromPrjFile(prjPath,prjFileName);

                t=tic;
                synDriver.runSynthesis(dumpResults);

                cd(dirInfo.workDir);
                disp(['### ',message('Coder:hdl:mgr_elapsed_time',sprintf('%18.4f',toc(t))).getString()]);
            catch me
                cd(dirInfo.workDir);
                disp(me.message);rethrow(me);
            end
        end


        function wfa_runPAR(~,~)
            try
                [~,hdlCfg]=hdlismatlabmode;
                hdlDrv=hdlcurrentdriver;

                synDriver=emlhdlcoder.Driver.SynthesisDriver(hdlCfg,hdlDrv);
                dumpResults=true;

                t=tic;
                synDriver.runPAR(dumpResults);
                disp(['### ',message('Coder:hdl:mgr_elapsed_time',sprintf('%18.4f',toc(t))).getString()]);

            catch me
                disp(me.message);rethrow(me);
            end
        end



        function wfa_runImplementation(~,~)
            try
                [~,hdlCfg]=hdlismatlabmode;
                hdlDrv=hdlcurrentdriver;

                synDriver=emlhdlcoder.Driver.SynthesisDriver(hdlCfg,hdlDrv);
                dumpResults=true;

                t=tic;
                synDriver.runImplementation(dumpResults);
                disp(['### ',message('Coder:hdl:mgr_elapsed_time',sprintf('%18.4f',toc(t))).getString()]);
            catch me
                disp(me.message);rethrow(me);
            end
        end




        function wfa_runIPCoreCreateProject(this,prjFile)
            try
                [~,hdlCfg]=hdlismatlabmode;
                hdlDrv=hdlcurrentdriver;

                embeddedSystemTool=this.getPluginParam(prjFile,'param.hdl.EmbeddedSystemTool');
                hdlCfg.EmbeddedSystemTool=embeddedSystemTool;

                targetIntegrationDriver=emlhdlcoder.Driver.TargetIntegrationDriver(hdlCfg,hdlDrv);
                dumpResults=true;

                t=tic;
                targetIntegrationDriver.ipcoreCreateProject(dumpResults);
                disp(['### ',message('Coder:hdl:mgr_elapsed_time',sprintf('%18.4f',toc(t))).getString()]);

            catch me
                disp(me.message);rethrow(me);
            end
        end


        function wfa_runIPCoreBuildEmbeddedSystem(this,prjFile)
            try
                [~,hdlCfg]=hdlismatlabmode;
                hdlDrv=hdlcurrentdriver;

                isExternalBuild=this.getPluginParam(prjFile,'param.hdl.BitstreamBuildMode');
                if isExternalBuild
                    hdlCfg.BitstreamBuildMode='External';
                else
                    hdlCfg.BitstreamBuildMode='Internal';
                end

                targetIntegrationDriver=emlhdlcoder.Driver.TargetIntegrationDriver(hdlCfg,hdlDrv);
                dumpResults=true;

                t=tic;
                targetIntegrationDriver.ipcoreBuildEmbeddedSystem(dumpResults);
                disp(['### ',message('Coder:hdl:mgr_elapsed_time',sprintf('%18.4f',toc(t))).getString()]);

            catch me
                disp(me.message);rethrow(me);
            end
        end


        function wfa_runIPCoreProgramTargetDevice(~,~)
            try
                [~,hdlCfg]=hdlismatlabmode;
                hdlDrv=hdlcurrentdriver;

                targetIntegrationDriver=emlhdlcoder.Driver.TargetIntegrationDriver(hdlCfg,hdlDrv);
                dumpResults=true;

                t=tic;
                targetIntegrationDriver.ipcoreProgramTargetDevice(dumpResults);
                disp(['### ',message('Coder:hdl:mgr_elapsed_time',sprintf('%18.4f',toc(t))).getString()]);

            catch me
                disp(me.message);rethrow(me);
            end
        end

        function wfa_runFPGATurnkeyBuildBitstream(~,~)
            try
                [~,hdlCfg]=hdlismatlabmode;
                hdlDrv=hdlcurrentdriver;

                targetIntegrationDriver=emlhdlcoder.Driver.TargetIntegrationDriver(hdlCfg,hdlDrv);
                dumpResults=true;

                t=tic;
                targetIntegrationDriver.fpgaturnkeyBuildBitstream(dumpResults);
                disp(['### ',message('Coder:hdl:mgr_elapsed_time',sprintf('%18.4f',toc(t))).getString()]);

            catch me
                disp(me.message);rethrow(me);
            end
        end

        function wfa_runFPGATurnkeyProgramTargetDevice(~,~)
            try
                [~,hdlCfg]=hdlismatlabmode;
                hdlDrv=hdlcurrentdriver;

                targetIntegrationDriver=emlhdlcoder.Driver.TargetIntegrationDriver(hdlCfg,hdlDrv);
                dumpResults=true;

                t=tic;
                targetIntegrationDriver.fpgaturnkeyProgramTargetDevice(dumpResults);
                disp(['### ',message('Coder:hdl:mgr_elapsed_time',sprintf('%18.4f',toc(t))).getString()]);

            catch me
                disp(me.message);rethrow(me);
            end
        end


        function wfa_runReportCriticalPath(this,prjFile)
            try
                [~,hdlCfg]=hdlismatlabmode;
                hdlDrv=hdlcurrentdriver;

                criticalPathSourceOpt=this.getPluginParam(prjFile,'param.hdl.CriticalPathSource');
                criticalPathSource=criticalPathSourceOpt(12:end);

                hdlCfg.ReportCriticalPath=true;
                hdlCfg.CriticalPathSource=criticalPathSource;

                synDriver=emlhdlcoder.Driver.SynthesisDriver(hdlCfg,hdlDrv);

                t=tic;
                synDriver.runReportCriticalPath;
                disp(['### ',message('Coder:hdl:mgr_elapsed_time',sprintf('%18.4f',toc(t))).getString()]);

            catch me
                disp(me.message);rethrow(me);
            end
        end


        function inTypes=getInputTypes(this)
            inTypes={};
            dt=getDeployToolProjectInstance(this);
            fileSet=dt.getConfiguration().getFileSet('fileset.entrypoints');
            entryPoints=fileSet.getFiles();
            iterator=entryPoints.iterator();


            while iterator.hasNext();
                file=iterator.next();

                [inTypes,inputCount]=this.getEntryPointITCs(dt.getConfiguration(),file);
            end
            if inputCount~=length(inTypes)
                inTypes={};
            end
        end



        function[inDataProps,inputCount]=getEntryPointITCs(~,configuration,file)
            inDataProps={};
            inputCount=0;
            data=coder.internal.gui.GuiUtils.getInputRootReader(configuration,file);
            if~isempty(data)
                xInput=data.getChild('Input');
                nItcs=0;

                while xInput.isPresent()
                    inputName=char(xInput.readAttribute('Name'));
                    inputCount=inputCount+1;
                    try
                        inputs=emlcprivate('xml2type',[],xInput,inputName,inputName);
                        for input=1:numel(inputs)
                            nItcs=nItcs+1;
                            if~isa(inputs,'cell')
                                itcs{nItcs}=inputs(input);%#ok<AGROW>
                            else
                                itcs{nItcs}=inputs{input};%#ok<AGROW>
                            end
                        end
                    catch ex
                        if strcmp(ex.message,['Expecting example input: found unsupported class <Undefined> at ',inputName,'.'])

                        else
                            disp(ex.message);
                        end
                    end
                    xInput=xInput.next();
                end

                if nItcs
                    inDataProps=itcs;
                end
            end
        end


        function[status,messages,errorMessage,portInfo]=wfa_getPortInfo(this,data,entryPoint)
            portInfo='';

            javaConfig=data.getConfiguration();

            dataAdapter=com.mathworks.toolbox.coder.fixedpoint.FixedPointDataAdapterFactory.create(javaConfig);
            [~,dName,~]=fileparts(entryPoint);

            prjFile=char(javaConfig.getProject().getFile().getAbsolutePath());
            [prjDir,prjName,prjExt]=fileparts(prjFile);

            if this.needsFixedPointConversion
                dirInfo=getDirInfoFromPrjFile(this,prjDir,[prjName,prjExt]);
                fxpDesignFcnDir=dirInfo.fxpBldDir;
                f2fConverter=coderprivate.Float2FixedManager.instance.fpc;




                if isempty(f2fConverter)
                    return
                end

                fixPtCfg=f2fConverter.fxpCfg;
                if isempty(fixPtCfg)

                    args=coder.internal.tools.prj2config(strtrim(prjFilePath));
                    fixPtCfg=args{1};
                    assert(isa(fixPtCfg,'coder.FixPtConfig'));
                end

                try
                    uiFiTypes=com.mathworks.toolbox.coder.fixedpoint.ConversionModel.convertTypesToArray(javaConfig,true);
                    fiTypes=emlcprivate('convertFromJava',uiFiTypes);
                    fimathStr=char(data.getFimath);
                catch me
                    return
                end

                if~isempty(fiTypes)
                    origItcs=this.getInputTypes;

                    varList=fieldnames(fiTypes);
                    newTypesList={};
                    for zz=1:length(origItcs)
                        try
                            newTypesList{zz}=fiTypes.(origItcs{zz}.Name);%#ok<AGROW>
                        catch

                        end
                    end

                    inputTypes=emlcprivate('convertTypesToFixPt',origItcs,newTypesList,fimathStr);
                else
                    inputTypes=[];
                end

                designFcnName=[dName,char(dataAdapter.getGeneratedFileSuffix)];



                designFcnPath=fullfile(fxpDesignFcnDir,designFcnName);
                if(exist([designFcnPath,'.mlx'],'file')==2)
                    designFcnFile=[designFcnPath,'.mlx'];
                else

                    designFcnFile=[designFcnPath,'.m'];
                end

            else
                inputTypes=coderprivate.Float2FixedManager.getInputs(javaConfig,entryPoint);
                designFcnName=dName;
                designFcnFile=entryPoint;
            end

            hdlDrv=this.hdlState.currentDriver;
            hDI=downstream.DownstreamIntegrationDriver(designFcnName,false,false,'',downstream.queryflowmodesenum.NONE,hdlDrv,true);
            hdlWorkflow=char(javaConfig.getEnumParamDisplayedText('param.hdl.Workflow',false));
            hDI.set('Workflow',hdlWorkflow);
            hDI.set('Board',char(javaConfig.getParamAsString('param.hdl.TargetPlatform')));
            hDI.set('Tool',char(javaConfig.getParamAsString('param.hdl.SynthesisTool')));

            if strcmpi(hdlWorkflow,'IP Core Generation')
                hDI.hIP.setReferenceDesign(char(javaConfig.getParamAsString('param.hdl.ReferenceDesign')));
                refDesignPath=char(javaConfig.getParamAsString('param.hdl.ReferenceDesignPath'));
                if~isempty(refDesignPath)
                    hDI.hIP.setReferenceDesignPath(refDesignPath);
                end
            end



            [status,messages,errorMessage]=hdlDrv.DownstreamIntegrationDriver.hTurnkey.hTable.populateInterfaceTable('',inputTypes,designFcnFile);
            if status
                portInfo=hdlDrv.DownstreamIntegrationDriver.hTurnkey.hTable.getGUIEmlPortInfo;
                hdlDrv.DownstreamIntegrationDriver=hDI;
                hdlcurrentdriver(hdlDrv);
            end
        end


        function portValidateInfo=wfa_validateTargetInterfaceTable(this,javaConfig)
            portValidateInfo='';


            assert(isfield(this.hdlState,'currentDriver'));
            if isempty(this.hdlState.currentDriver.DownstreamIntegrationDriver)
                return;
            end
            try
                tableData=javaConfig.getParamReader('param.hdl.TargetInterface');
            catch ME %#ok<*NASGU>
                return
            end

            result=com.mathworks.project.api.XmlApi.getInstance().create('TargetInterface');

            hDI=this.hdlState.currentDriver.DownstreamIntegrationDriver;
            port=tableData.getChild('Port');
            while port.isPresent()
                portName=char(port.readText('Name'));
                portType=char(port.readText('PortType'));
                portInterface=char(port.readText('SelectedInterface'));
                portBitRange=char(port.readText('BitRange'));

                try
                    hDI.setTargetInterface(portName,portInterface);
                    hDI.setTargetOffset(portName,portBitRange);
                catch ME
                    outputPort=result.createElement('Port');
                    outputPort.writeText('Name',portName);
                    outputPort.writeText('PortType',portType);
                    outputPort.writeText('BitRange',ME.message);
                end
                port=port.next();
            end

            portValidateInfo=result.getXML();
        end


        function defaultBitRangeTable=wfa_portsDefaultBitRanges(this,javaConfig)

            assert(isfield(this.hdlState,'currentDriver'));
            if isempty(this.hdlState.currentDriver.DownstreamIntegrationDriver)
                return;
            end
            try
                tableData=javaConfig.getParamReader('param.hdl.TargetInterface');
            catch ME %#ok<*NASGU>
                return
            end

            hDI=this.hdlState.currentDriver.DownstreamIntegrationDriver;
            port=tableData.getChild('Port');


            while port.isPresent()
                portName=char(port.readText('Name'));
                portInterface=char(port.readText('SelectedInterface'));
                bitRange=char(port.readText('BitRange'));

                if~strcmpi(portInterface,'No Interface Specified')
                    try
                        hDI.setTargetInterface(portName,portInterface);
                        hDI.hTurnkey.hTableMap.setBitRangeUserSpec(portName,bitRange);
                    catch

                    end
                end
                port=port.next();
            end


            port=tableData.getChild('Port');
            result=com.mathworks.project.api.XmlApi.getInstance().create('TargetInterface');
            while port.isPresent()
                portInterface=char(port.readText('SelectedInterface'));
                portName=char(port.readText('Name'));
                if~strcmpi(portInterface,'No Interface Specified')
                    try
                        defaultBitRange=hDI.hTurnkey.hTable.hTableMap.getBitRangeStr(portName);
                        resultPort=result.createElement('Port');
                        resultPort.writeText('Name',portName);
                        resultPort.writeText('PortType',port.readText('PortType'));
                        resultPort.writeText('BitRange',defaultBitRange);
                    catch

                    end
                end
                port=port.next();
            end

            defaultBitRangeTable=result.getXML();
        end
    end

end


function l_updateHDLTBParam(this,prjFileName,emlcHdlTB)
    hMgr=emlhdlcoder.WorkFlow.CodeGenInfoManager.instance;
    cginfo=hMgr.getCgInfo;

    postFix=l_setParam('TestBenchPostfix','tb_postfix');
    tmp=[cginfo.TopFunctionName,postFix];
    tbName=l_getuniquehdlname(tmp,cginfo.EntityNames);

    hdlsetparameter('tb_name',tbName);

    l_setParam('ForceClock','force_clock');
    l_setParam('ClockHighTime','force_clock_high_time');
    l_setParam('ClockLowTime','force_clock_low_time');
    l_setParam('ClockLowTime','force_clock_low_time');
    l_setParam('HoldTime','force_hold_time');

    l_setParam('ForceClockEnable','force_clockenable');
    l_setParam('TestBenchClockEnableDelay','TestBenchClockEnableDelay');

    l_setParam('ForceReset','force_reset');
    l_setParam('ResetLength','resetlength');

    l_setParam('HoldInputDataBetweenSamples','HoldInputDataBetweenSamples');
    l_setParam('InputDataInterval','InputDataInterval');
    l_setParam('InitializeTestBenchInputs','initializetestbenchinputs');

    l_setParam('MultifileTestBench','multifiletestbench');
    l_setParam('TestBenchDataPostfix','tbdata_postfix');

    l_setParam('IgnoreDataChecking','IgnoreDataChecking');

    param=l_getParam('SimulationIterationLimit');
    emlcHdlTB.getHDLDriver.cgInfo.HDLConfig.SimulationIterationLimit=param;


    function param=l_getParam(paramName)
        fullName=['param.hdl.',paramName];
        param=this.getPluginParam(prjFileName,fullName);
    end

    function param=l_setParam(paramName,tbFieldName)
        fullName=['param.hdl.',paramName];
        param=this.getPluginParam(prjFileName,fullName);
        hdlsetparameter(tbFieldName,param);
    end

    function nodename=l_getuniquehdlname(nodename,reserved)
        nodename=hdllegalname(nodename);
        nodename=genvarname(nodename,reserved);
    end
end

function l_updateCosimTbParam(this,prjFileName)
    hMgr=emlhdlcoder.WorkFlow.CodeGenInfoManager.instance;
    cginfo=hMgr.getCgInfo;
    l_updateParam('CosimClockHighTime');
    l_updateParam('CosimClockLowTime');
    l_updateParam('CosimHoldTime');
    l_updateParam('CosimClockEnableDelay');
    l_updateParam('CosimResetLength');


    hMgr.addField('codegenSettigns',cginfo.codegenSettings);

    function param=l_updateParam(paramName)
        fullName=['param.hdl.',paramName];
        param=this.getPluginParam(prjFileName,fullName);
        cginfo.codegenSettings.(paramName)=param;
    end
end

function setConfigParamAsBoolean(config,paramName,paramValue)
    javaMethodEDT('setParamAsBoolean',config,paramName,paramValue);
end



