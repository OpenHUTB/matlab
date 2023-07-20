



classdef GenSVDPITb<handle
    properties(Access=private)
        IsCodeCoverageEnabled;
        ReferenceModelConfigSetMap;
    end

    properties
simulator


codeGenDir
isDutVHDL

hD


dpiModuleName
dpiDutPath
dpiMdlName
dpiRefModel
dpiSimTime
dpiDLLFile
dpiSVFile


OutputPortsSampleTime
    end

    methods

        function this=GenSVDPITb(varargin)
            this.IsCodeCoverageEnabled=l_processOneOptionalArg(varargin);
            this.ReferenceModelConfigSetMap=containers.Map;
        end
        function delete(this)

            if~isempty(this.dpiMdlName)&&bdIsLoaded(this.dpiMdlName)
                close_system(this.dpiMdlName,0);
            end
            if~isempty(this.dpiRefModel)&&bdIsLoaded(this.dpiRefModel)
                close_system(this.dpiRefModel,0);
            end
        end
        function name=getEntityTop(~)
            gp=pir;
            name=gp.getTopNetwork.Name;
        end

        function testBenchName=getTestBenchName(this)
            gp=pir;
            testBenchName=[this.getEntityTop,'_dpi',gp.getParamValue('tb_postfix')];
        end


        function tbMdlName=getGeneratedModelName(this)

            if this.hD.DUTMdlRefHandle>0
                tbMdlName=this.hD.BackEnd.TopOutModelFile;
            else
                tbMdlName=this.hD.BackEnd.OutModelFile;
            end
        end

        function dpiInfo=buildDPIModel(this)
            genMdlName=getGeneratedModelName(this);
            this.dpiMdlName=[genMdlName,'_ref'];

            hdldisp(message('HDLLink:GenerateSVDPITestbench:PreparingModel'));





            hb=slhdlcoder.SimulinkBackEnd(this.hD.PirInstance,...
            'InModelFile',genMdlName,...
            'OutModelFile',this.dpiMdlName,...
            'ShowModel','no');
            hb.createAndInitTargetModel;
            hb.drawTestBench(true);


            this.dpiMdlName=hb.OutModelFile;

            restoreConfigSets=onCleanup(@()l_restoreModelRefConfigSets_And_Close(this.ReferenceModelConfigSetMap,this.dpiMdlName));
            this.dpiDutPath=getDutPathFromHDLC(this);

            hdldisp(message('HDLLink:GenerateSVDPITestbench:GeneratingSVDPI'));
            l_setDPICodeGenParam(this.dpiMdlName);

            hwconfig.TargetLargestAtomicFloat=get_param(this.dpiMdlName,'TargetLargestAtomicFloat');
            hwconfig.TargetLargestAtomicInteger=get_param(this.dpiMdlName,'TargetLargestAtomicInteger');

            if isDutModelRef(this)
                refModel=get_param(this.dpiDutPath,'ModelName');
                load_system(refModel);

                this.dpiRefModel=[refModel,'_ref'];

                hb=slhdlcoder.SimulinkBackEnd(this.hD.PirInstance,...
                'InModelFile',refModel,...
                'OutModelFile',this.dpiRefModel,...
                'ShowModel','no');
                hb.createAndInitTargetModel;
                hb.drawTestBench(true);

                this.dpiRefModel=hb.OutModelFile;
                load_system(this.dpiRefModel);


                set_param(this.dpiMdlName,'ModelReferenceSymbolNameMessage','none');
                set_param(this.dpiRefModel,'ModelReferenceSymbolNameMessage','none');

                l_setDPICodeGenParam(this.dpiRefModel,hwconfig);


                set_param(this.dpiDutPath,'Variant','off');
                set_param(this.dpiDutPath,'ModelName',this.dpiRefModel);


                l_saveModel(this.dpiRefModel,this.codeGenDir);


                mdlObj=get_param(bdroot(this.dpiDutPath),'object');
                mdlObj.refreshModelBlocks;
            end




            allModelRef=find_system(this.dpiMdlName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','ModelReference');
            for ii=1:numel(allModelRef)
                refModel=get_param(allModelRef{ii},'ModelName');
                this.ReferenceModelConfigSetMap(refModel)=copy(getActiveConfigSet(refModel));
                l_setDPICodeGenParam(refModel,hwconfig);
                save_system(refModel);
            end

            l_saveModel(this.dpiMdlName,this.codeGenDir);

            addIOports(this);


            l_saveModel(this.dpiMdlName,this.codeGenDir);

            savedWarnState=warning('QUERY','Simulink:Blocks:BusObjectNeededForRootOutport');
            warning('OFF','Simulink:Blocks:BusObjectNeededForRootOutport');
            restoreWarnState=onCleanup(@()warning(savedWarnState));
            rtwbuild(this.dpiMdlName);


            dpiFolder=RTW.getBuildDir(this.dpiMdlName).BuildDirectory;
            this.dpiModuleName=[this.dpiMdlName,'_dpi'];
            this.dpiSVFile=[this.dpiModuleName,'.sv'];
            switch computer
            case 'PCWIN64'
                dllExt='_win64.dll';
            otherwise
                dllExt='.so';
            end

            cCodeInfo=load(fullfile(dpiFolder,'codeInfo.mat'));
            dpiInfo=dpigenerator_getcodeinfo('get');
            this.dpiDLLFile=fullfile(dpiFolder,[this.dpiMdlName,dllExt]);
            copyfile(fullfile(dpiFolder,this.dpiSVFile),this.codeGenDir,'f');
            copyfile(this.dpiDLLFile,this.codeGenDir,'f');


            stopTime=get_param(this.dpiMdlName,'StopTime');
            try
                dpiInfo.SimTime=evalin('base',stopTime);
            catch E
                dpiInfo.SimTime=[];
            end

            if isempty(dpiInfo.SimTime)
                hws=get_param(this.dpiMdlName,'modelworkspace');
                dpiInfo.SimTime=hws.evalin(stopTime);
            end

            dpiInfo.BaseRate=cCodeInfo.codeInfo.OutputFunctions.Timing.SamplePeriod;
            [dpiInfo.PortDims,dpiInfo.PortNames]=l_getDPIPortData(dpiInfo);
            dpiInfo.ModuleName=this.dpiModuleName;

        end

        function name=getDutPathFromHDLC(this)
            name=this.hD.ModelConnection.System;

            name=regexprep(name,['^',this.hD.ModelConnection.ModelName],this.dpiMdlName);
        end

        function r=isDutModelRef(this)
            dutBlockType=get_param(this.dpiDutPath,'BlockType');
            r=strcmpi(dutBlockType,'ModelReference');
        end


        function addIOports(this)

            load_system(this.dpiMdlName);


            portHandles=get_param(this.dpiDutPath,'PortHandles');

            dutPortConnectivity=get_param(this.dpiDutPath,'portConnectivity');


            allGoto=find_system(gcs,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','Goto');
            exclusion={};
            for ii=1:numel(allGoto)
                vis=get_param(allGoto{ii},'TagVisibility');
                if strcmpi(vis,'global')
                    tag=get_param(allGoto{ii},'GotoTag');
                    exclusion=[exclusion,{tag}];%#ok<AGROW>
                end
            end

            for m=1:length(portHandles.Inport)

                srcBlkH=dutPortConnectivity(m).SrcBlock;
                srcBlkPortHandles=get_param(srcBlkH,'portHandles');
                srcBlkPortIndx=dutPortConnectivity(m).SrcPort+1;
                srcBlkPortH=srcBlkPortHandles.Outport(srcBlkPortIndx);
                gotoTag=l_addGotoBlock(this.dpiDutPath,srcBlkPortH,m,exclusion);
                exclusion=[exclusion,{gotoTag}];%#ok<AGROW>
                addOutputPort(this,m,gotoTag,'');
            end
            k=numel(portHandles.Inport);
            this.OutputPortsSampleTime=l_getPortHandleSampleTime(this.dpiMdlName,portHandles.Outport);
            for m=1:length(portHandles.Outport)
                srcBlkPortH=portHandles.Outport(m);
                gotoTag=l_addGotoBlock(this.dpiDutPath,srcBlkPortH,m+k,exclusion);
                exclusion=[exclusion,{gotoTag}];%#ok<AGROW>
                outportName=find_system(this.dpiDutPath,'SearchDepth',1,'BlockType','Outport','Port',num2str(m));
                if~isempty(outportName)
                    outDataType=get_param(outportName{1},'OutDataTypeStr');
                else
                    outDataType='';
                end
                addOutputPort(this,m+k,gotoTag,outDataType);
            end
        end


        function addOutputPort(this,m,gotoTag,outDataType)

            fromName=[this.dpiMdlName,'/From',num2str(m)];
            position=[850,390+100*m,900,440+100*m];
            fromName=l_addUniqueBlock('built-in/From',fromName,'Position',position);
            set_param(fromName,'GotoTag',gotoTag);
            fromPortH=get_param(fromName,'portHandles');

            outportName=[this.dpiMdlName,'/','dpi_',num2str(m)];
            position=[1050,390+100*m,1100,440+100*m];
            outportName=l_addUniqueBlock('built-in/Outport',outportName,'Position',position);
            outportH=get_param(outportName,'portHandles');

            add_line(this.dpiMdlName,fromPortH.Outport,outportH.Inport,...
            'Autorouting','on');
            set_param(outportName,'Port',num2str(m));
            if~isempty(outDataType)
                set_param(outportName,'OutDataTypeStr',outDataType);
            end
        end

        function r=getDPIWrapperName(this)
            r=[this.dpiModuleName,'_dpi_wrapper'];
        end

        function generateQuestaSimScript(this,tbName,dutFileList)
            scriptName=[tbName,'.do'];
            SimCmd='vsim -voptargs=+acc';
            fullScript=fullfile(this.codeGenDir,scriptName);
            dpigenerator_disp(['Generating SystemVerilog DPI testbench simulation script for ModelSim/QuestaSim ',dpigenerator_getfilelink(fullScript)]);

            fileID=fopen(fullScript,'w');
            fprintf(fileID,'vlib work\n');
            if this.isDutVHDL
                compileCmd='vcom';
            else
                compileCmd='vlog';
            end

            if this.IsCodeCoverageEnabled
                compileCmd=[compileCmd,' +cover'];
                SimCmd=[SimCmd,' -coverage'];
            end

            existLibs=containers.Map;
            existLibs('work')=1;
            for ii=1:numel(dutFileList)/2
                fileName=dutFileList{ii*2-1};
                fileName=strrep(fileName,'\','/');
                libName=dutFileList{ii*2};
                if isempty(libName)
                    libName='work';
                else
                    if~existLibs.isKey(libName)
                        fprintf(fileID,'vlib %s\n',libName);
                        fprintf(fileID,'vmap %s %s\n',libName,libName);
                        existLibs(libName)=1;
                    end
                end
                fprintf(fileID,'%s %s -work %s\n',compileCmd,fileName,libName);
            end
            [~,dllName,~]=fileparts(this.dpiDLLFile);
            fprintf(fileID,'vlog -dpicopyopt 0 -sv %s\n',this.dpiSVFile);
            fprintf(fileID,'vlog -sv %s\n',[tbName,'.sv']);


            addLibCmd='';
            allLibNames=existLibs.keys;
            for ii=1:numel(allLibNames)
                addLibCmd=[addLibCmd,'-L ',allLibNames{ii},' '];%#ok<AGROW>
            end

            fprintf(fileID,'%s %s -sv_lib %s work.%s\n',SimCmd,addLibCmd,dllName,tbName);
            fprintf(fileID,'add wave /*\n');
            fprintf(fileID,'run -all\n');
            if this.IsCodeCoverageEnabled
                fprintf(fileID,['coverage report -html CodeCoverage.html\n',...
                'coverage save CodeCoverage.ucdb\n']);
            end
            fclose(fileID);
        end

        function generateXceliumScript(this,tbName,dutFileList)
            scriptName=[tbName,'.sh'];
            ElabCmd='xmelab -64bit';
            SimCmd='xmsim -64bit';
            fullScript=fullfile(this.codeGenDir,scriptName);
            dpigenerator_disp(['Generating SystemVerilog DPI testbench simulation script for Xcelium ',dpigenerator_getfilelink(fullScript)]);
            fileID=fopen(fullScript,'w');
            fprintf(fileID,'INSTALL_DIR=$(xmroot)\n');
            fprintf(fileID,'export INSTALL_DIR\n');

            if this.isDutVHDL
                compileCmd='xmvhdl -64bit -v93';
            else
                compileCmd='xmvlog -64bit';
            end

            existLibs=containers.Map;
            existLibs('work')=1;
            fprintf(fileID,'mkdir work\n');

            for ii=1:numel(dutFileList)/2
                fileName=dutFileList{ii*2-1};
                fileName=strrep(fileName,'\','/');
                libName=dutFileList{ii*2};
                if isempty(libName)
                    libName='work';
                end
                if~existLibs.isKey(libName)
                    existLibs(libName)=1;
                    fprintf(fileID,'mkdir %s\n',libName);
                end
                fprintf(fileID,'%s -work %s %s\n',compileCmd,libName,fileName);
            end

            if this.IsCodeCoverageEnabled
                ElabCmd=[ElabCmd,' -coverage A'];
                SimCmd=[SimCmd,' -covtest CodeCoverage'];
            end

            [~,dllName,~]=fileparts(this.dpiDLLFile);
            fprintf(fileID,'xmvlog -64bit -sv -work work %s\n',this.dpiSVFile);
            fprintf(fileID,'xmvlog -64bit -sv -work work %s\n',[tbName,'.sv']);
            fprintf(fileID,'%s %s\n',ElabCmd,tbName);
            fprintf(fileID,[SimCmd,' -EXIT -sv_lib %s %s\n'],dllName,tbName);
            if this.IsCodeCoverageEnabled
                fprintf(fileID,'imc -load cov_work/scope/CodeCoverage/ -execcmd "report -detail -html -all -out CodeCoverageReport"');
            end
            fclose(fileID);


            fullScript=fullfile(this.codeGenDir,'hdl.var');
            fileID=fopen(fullScript,'w');
            fprintf(fileID,'softinclude $INSTALL_DIR/tools/inca/files/hdl.var\n');
            fclose(fileID);

            libraries=existLibs.keys;
            fullScript=fullfile(this.codeGenDir,'cds.lib');
            fileID=fopen(fullScript,'w');
            fprintf(fileID,'softinclude $INSTALL_DIR/tools/inca/files/cds.lib\n');
            for ii=1:numel(libraries)
                lib=libraries{ii};
                fprintf(fileID,'DEFINE %s %s\n',lib,lib);
            end
            fclose(fileID);
        end

        function generateVCSScript(this,tbName,dutFileList)
            if this.IsCodeCoverageEnabled

                warning(message('HDLLink:GenerateSVDPITestbench:SimulatorNotSupportedForCodeCoverage'));
            end
            scriptName=[tbName,'.sh'];
            fullScript=fullfile(this.codeGenDir,scriptName);
            dpigenerator_disp(['Generating SystemVerilog DPI testbench simulation script for VCS ',dpigenerator_getfilelink(fullScript)]);
            fileID=fopen(fullfile(this.codeGenDir,scriptName),'w');

            if this.isDutVHDL
                compileCmd='vhdlan -full64';
            else
                compileCmd='vlogan -full64';
            end

            existLibs=containers.Map;
            existLibs('work')=1;
            fprintf(fileID,'mkdir work\n');
            for ii=1:numel(dutFileList)/2
                fileName=dutFileList{ii*2-1};
                fileName=strrep(fileName,'\','/');
                libName=dutFileList{ii*2};
                if isempty(libName)
                    libName='work';
                end
                if~existLibs.isKey(libName)
                    existLibs(libName)=1;
                    fprintf(fileID,'mkdir %s\n',libName);
                end
                fprintf(fileID,'%s -work %s %s\n',compileCmd,libName,fileName);
            end
            [~,dllName,~]=fileparts(this.dpiDLLFile);
            fprintf(fileID,'vlogan -full64 -sverilog %s\n',this.dpiSVFile);
            fprintf(fileID,'vlogan -full64 -sverilog %s\n',[tbName,'.sv']);
            fprintf(fileID,'vcs -full64  %s\n',tbName);
            fprintf(fileID,'./simv -sv_lib ./%s -ucli -do run.do\n',dllName);
            fclose(fileID);


            doFile=fullfile(this.codeGenDir,'run.do');
            fileID=fopen(doFile,'w');
            fprintf(fileID,'run\n');
            fprintf(fileID,'exit\n');
            fclose(fileID);

            libraries=existLibs.keys;
            fullScript=fullfile(this.codeGenDir,'synopsys_sim.setup');
            fileID=fopen(fullScript,'w');
            fprintf(fileID,'WORK > DEFAULT\n');
            for ii=1:numel(libraries)
                lib=libraries{ii};
                fprintf(fileID,'%s : %s\n',lib,lib);
            end
            fclose(fileID);
        end

        function generateVivadoSimulatorScript(this,tbName,dutFileList)
            if this.IsCodeCoverageEnabled

                warning(message('HDLLink:GenerateSVDPITestbench:SimulatorNotSupportedForCodeCoverage'));
            end
            if isunix
                scriptName=[tbName,'.sh'];
                batch_call='';
                lib_extension='';
            else
                scriptName=[tbName,'.bat'];
                batch_call='call ';
                lib_extension='.dll';
            end
            fullScript=fullfile(this.codeGenDir,scriptName);
            dpigenerator_disp(['Generating SystemVerilog DPI testbench simulation script for Vivado Simulator ',dpigenerator_getfilelink(fullScript)]);
            fileID=fopen(fullfile(this.codeGenDir,scriptName),'w');
            c=onCleanup(@()fclose(fileID));

            if this.isDutVHDL
                compileCmd=[batch_call,'xvhdl'];
            else
                compileCmd=[batch_call,'xvlog'];
            end

            existLibs=containers.Map;
            existLibs('work')=1;
            for ii=1:numel(dutFileList)/2
                fileName=dutFileList{ii*2-1};
                fileName=strrep(fileName,'\','/');
                libName=dutFileList{ii*2};

                if~existLibs.isKey(libName)
                    existLibs(libName)=1;
                end


                if isempty(libName)
                    fprintf(fileID,'%s %s\n',compileCmd,fileName);
                else
                    fprintf(fileID,'%s -work %s %s\n',compileCmd,libName,fileName);
                end
            end

            fprintf(fileID,'%sxvlog -sv %s %s\n',batch_call,this.dpiSVFile,[tbName,'.sv']);
            libraryList='';
            for idx=keys(existLibs)
                keysidx=idx{1};
                if isempty(keysidx)
                    continue;
                else

                    libtemp=libraryList;
                    libraryList=[libtemp,' -L ',keysidx];
                end
            end

            [~,dllName,~]=fileparts(this.dpiDLLFile);
            fprintf(fileID,'%sxelab %s %s -sv_root ./ -sv_lib %s%s -R',batch_call,tbName,libraryList,dllName,lib_extension);
        end


        function checkLicense(~)

            if~license('test','Real-Time_Workshop')
                error(message('HDLLink:GenerateSVDPITestbench:NoSimulinkCoderLicense'));
            end
        end
        function reportError(this,msg)
            this.hD.addTestbenchCheck(this.hD.ModelConnection.ModelName,'error',msg)
        end
        function hasError=checkCompatibility(this)
            hdldisp(message('HDLLink:GenerateSVDPITestbench:StartCheckingCompatibility'));
            hasError=false;



            switch this.simulator
            case{'VCS','Incisive'}
                if~isunix
                    reportError(this,message('HDLLink:GenerateSVDPITestbench:NotUnix',this.simulator));
                    hasError=true;
                end
            case{'ModelSim','Vivado Simulator'}

            otherwise
                reportError(this,message('HDLLink:GenerateSVDPITestbench:UnsupportedSimulator',this.simulator));
                hasError=true;
            end








            hP=pir;
            topCtx=hP.getTopPirCtx;
            dutN=topCtx.getTopNetwork;







            CLIObj=this.hD.getCLI;
            if strcmpi(CLIObj.TargetLanguage,'VHDL')&&~strcmpi(CLIObj.VHDLLibraryName,'work')


                reportError(this,message('HDLLink:GenerateSVDPITestbench:VHDLLibraryNameNotSupported'));
                hasError=true;
            end

            if hdlgetparameter('TriggerAsClock')
                reportError(this,message('HDLLink:GenerateSVDPITestbench:TriggerAsClock'));
                hasError=true;
            end

            inPorts=dutN.PirInputPorts;
            tmp=arrayfun(@(x)strcmpi(x.Kind,'clock'),inPorts);
            numClk=sum(tmp);
            if numClk>1
                reportError(this,message('HDLLink:GenerateSVDPITestbench:MultipleClocks'));
                hasError=true;
            end

            for m=1:2
                if m==1
                    inPorts=dutN.PirInputPorts;
                else
                    inPorts=dutN.PirOutputPorts;
                end
                for ii=1:numel(inPorts)
                    name=inPorts(ii).Name;
                    switch inPorts(ii).Kind
                    case 'data'
                        hS=dutN.findSignal('name',name);
                        if hS.Type.isDoubleType||hS.Type.BaseType.isDoubleType
                            reportError(this,message('HDLLink:GenerateSVDPITestbench:DoubleDataType',name));
                            hasError=true;
                        elseif hS.Type.isSingleType&&~(isNativeFloatingPointMode()||hdlgetparameter('nativefloatingpoint'))


                            reportError(this,message('HDLLink:GenerateSVDPITestbench:SingleDataTypeNeedsNativeFloatingPoint',name));
                            hasError=true;
                        elseif hS.Type.isHalfType
                            reportError(this,message('HDLLink:GenerateSVDPITestbench:HalfDataTypeNotSupported',name));
                            hasError=true;
                        elseif hS.Type.isArrayType&&strcmpi(hdlgetparameter('GenerateSVDPITestbench'),'Vivado Simulator')&&hdlgetparameter('isvhdl')



                            error(message('HDLLink:GenerateSVDPITestbench:VivadoSimulatorMixedLangIssue'));
                        elseif hS.Type.isEnumType||hS.Type.BaseType.isEnumType
                            reportError(this,message('HDLLink:GenerateSVDPITestbench:EnumDataType',name));
                            hasError=true;
                        elseif hS.Type.BaseType.WordLength>64
                            reportError(this,message('HDLLink:GenerateSVDPITestbench:WordLengthGreaterThan64',name));
                            hasError=true;
                        end
                    end
                end
            end
            hdldisp(message('HDLLink:GenerateSVDPITestbench:FinishCheckingCompatibility'));
        end


        function generateSimulatorScript(this,simulator,tbName,dutFileList)
            switch simulator
            case 'ModelSim'
                generateQuestaSimScript(this,tbName,dutFileList);
            case 'Incisive'
                generateXceliumScript(this,tbName,dutFileList);
            case 'VCS'
                generateVCSScript(this,tbName,dutFileList);
            case 'Vivado Simulator'
                generateVivadoSimulatorScript(this,tbName,dutFileList);
            end
        end


        function tbFilesList=doIt(this,simulator,codeGenDir)
            tbFilesList={};

            checkLicense(this);

            this.codeGenDir=codeGenDir;
            this.simulator=simulator;
            this.hD=hdlcurrentdriver;

            this.isDutVHDL=hdlgetparameter('isvhdl');


            dutFileList=l_getDutFileList(this.hD);

            hasError=checkCompatibility(this);
            if hasError
                hdldisp(message('HDLLink:GenerateSVDPITestbench:Failed',this.hD.ModelConnection.ModelName));
                return;
            end

            tbName=this.getTestBenchName;


            dpiInfo=buildDPIModel(this);


            h=svdpitb.GenPirTb;
            h.generateSVPirTb(tbName,this.codeGenDir,dpiInfo,this.OutputPortsSampleTime);


            generateSimulatorScript(this,simulator,tbName,dutFileList);

        end
    end
end

function[type,wlen]=l_getDPIBlackboxDataType(dutType,dims)
    if(dims>1||dutType.isArrayType)
        arrtypef=pir_arr_factory_tc;
        if(dims>1)
            arrtypef.addDimension(dims);
        else
            arrtypef.addDimension(dutType.Dimensions);
        end
        baseType=l_getDPIBlackboxDataType(dutType.BaseType,0);
        arrtypef.addBaseType(baseType);
        type=pir_array_t(arrtypef);
        wlen=dutType.BaseType.WordLength;
    else
        type=pir_fixpt_t(dutType.Signed,l_getDPIWordLen(dutType.WordLength),dutType.FractionLength);
        wlen=dutType.BaseType.WordLength;
    end
end

function wlenout=l_getDPIWordLen(wlenin)
    assert(wlenin<=64);
    if wlenin>=1&&wlenin<=8
        wlenout=8;
    else
        tmp=ceil(log2(wlenin));
        wlenout=2^tmp;
    end
end



function l_setDPICodeGenParam(modelName,hwconfig)
    set_param(modelName,'SystemTargetFile','systemverilog_dpi_grt.tlc');
    set_param(modelName,'DPIFixedPointDataType','CompatibleCType');
    set_param(modelName,'RTWCAPISignals','on');
    set_param(modelName,'ObjectivePriorities',{'Execution efficiency'});
    if(hdlverifierfeature('SVDPI_DEBUG'))
        set_param(modelName,'BuildConfiguration','Debug');
    else
        set_param(modelName,'BuildConfiguration','Faster Runs');
    end
    set_param(modelName,'DPIGenerateTestBench','off');

    set_param(modelName,'DPICustomizeSystemVerilogCode','on');
    set_param(modelName,'DPISystemVerilogTemplate','hdlverifier_dpitb_template.vgt');
    set_param(modelName,'RTWVerbose','Off');
    set_param(modelName,'Toolchain','Automatically locate an installed toolchain');
    set_param(modelName,'GenCodeOnly','off');

    if(nargin==2)
        props=fields(hwconfig);
        for m=1:numel(props)
            set_param(modelName,props{m},hwconfig.(props{m}));
        end
    end
end

function newName=l_addUniqueBlock(blkType,tgtBlkPath,varargin)
    blkH=add_block(blkType,tgtBlkPath,'MakeNameUnique','on',varargin{:});
    newName=getfullname(blkH);
end

function gotoTag=l_addGotoBlock(dutBlkPath,srcBlkPortH,m,exclusion)
    position=get_param(dutBlkPath,'Position');
    parentSys=get_param(dutBlkPath,'Parent');
    gotoTag=['dpi_goto_',num2str(m)];
    gotoTag=matlab.lang.makeUniqueStrings(gotoTag,exclusion);

    gotoName=[parentSys,'/',gotoTag];
    position=[position(1)-m*50,position(2)+m*50];
    position=[position,position+50];
    gotoName=l_addUniqueBlock('built-in/Goto',gotoName,...
    'Position',position);
    set_param(gotoName,'GotoTag',gotoTag);
    set_param(gotoName,'TagVisibility','global');
    gotoPortH=get_param(gotoName,'portHandles');
    add_line(parentSys,srcBlkPortH,gotoPortH.Inport(1),...
    'Autorouting','on');
end



function l_saveModel(mdlName,folder)
    fullMdlName=fullfile(folder,[mdlName,'.slx']);
    save_system(mdlName,fullMdlName,...
    'OverwriteIfChangedOnDisk',true,...
    'SaveModelWorkspace',false);
end

function dutFileList=l_getDutFileList(hD)
    dutFileList={};

    codeGenInfo=hD.getFILCodeGenInfo;
    subModelData=codeGenInfo.SubModelData;
    numSubModels=numel(subModelData);
    allSrcFileList=codeGenInfo.EntityFileNames;

    startIdx=1;
    for ii=1:numSubModels
        stopIdx=startIdx+numel(subModelData(ii).FileNames)-1;

        for jj=startIdx:stopIdx
            dutFileList=[dutFileList,allSrcFileList(jj),subModelData(ii).LibName];%#ok<AGROW>
        end
        startIdx=stopIdx+1;
    end

    for jj=startIdx:numel(allSrcFileList)
        dutFileList=[dutFileList,allSrcFileList(jj),{''}];%#ok<AGROW>
    end



end

function[dims,portNames]=l_getDPIPortData(dpiCodeInfo)

    fcnObj=dpig.internal.GetSVFcn(dpiCodeInfo);
    [portNames,~]=fcnObj.getOutputFcnCallArgs(false);
    dims=fcnObj.mCodeInfo.OutStruct.FlattenedDimensions;
end

function IsCodeCovEnabled=l_processOneOptionalArg(optionalArgs)

    numvarargs=length(optionalArgs);
    if numvarargs>1
        error('Too many optional arguments');
    end

    optarg={false};

    optarg(1:numvarargs)=optionalArgs;

    IsCodeCovEnabled=optarg{1};
end

function l_restoreModelRefConfigSets_And_Close(ReferenceModelConfigSetMap,dpiMdlName)

    for ModelRef=keys(ReferenceModelConfigSetMap)
        ModelRefkey=ModelRef{1};
        ConfigRef=ReferenceModelConfigSetMap(ModelRefkey);
        try
            attachConfigSet(ModelRefkey,ConfigRef,true);
        catch exc
            if strcmp(exc.identifier,'Simulink:Commands:InvSimulinkObjectName')

                continue;
            end
        end
        setActiveConfigSet(ModelRefkey,ConfigRef.Name);
        save_system(ModelRefkey);
    end

    bdclose(dpiMdlName);
end

function PortsSampleTime=l_getPortHandleSampleTime(modelName,PortHandles)
    PortsSampleTime=cell(1,numel(PortHandles));
    feval(modelName,[],[],[],'compileForSizes');
    onCleanupObj=onCleanup(@()feval(modelName,[],[],[],'term'));
    for idx=1:numel(PortHandles)
        ST=get_param(PortHandles(idx),'CompiledSampleTime');
        PortsSampleTime{idx}=ST(1);
    end
end






