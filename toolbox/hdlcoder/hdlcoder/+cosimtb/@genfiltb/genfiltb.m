classdef genfiltb<cosimtb.gencosim







    properties(Access=private)
        hFilBuildInfo;
        hFilMgr;
    end

    methods






        function this=genfiltb(varargin)
            this=this@cosimtb.gencosim(varargin{:});
            if nargin<4
                this.hFilBuildInfo=eda.internal.workflow.FILBuildInfo;
            else
                this.hFilBuildInfo=varargin{4};
            end
            this.hFilBuildInfo.SynthesisFrequency='25MHz';
        end


        function linkSuffix=getCurrentLinkOpt(this)
            linkSuffix='fil';
        end


        function hl=hasLicense(this)
            tooldir=fullfile(matlabroot,'toolbox','shared','eda');
            if~(license('test','EDA_Simulator_Link')&&exist(tooldir,'dir'))
                error(message('hdlcoder:fil:filnotinstalled'));
            end
            hl=true;
        end


        function hl=checkEDALinkLicense(this)
            hl=hasLicense(this);
        end





        function getPortInfo(this,params)
            slInports=getDutInports(this);
            slOutports=getDutOutports(this);
            for ii=1:length(slInports)
                port=slInports(ii);
                type=pirgetdatatypeinfo(port.Signal.Type);
                params.inputPorts(ii).dtypeSpec=type.sltype;
            end

            for ii=1:length(slOutports)
                port=slOutports(ii);
                type=pirgetdatatypeinfo(port.Signal.Type);
                params.outputPorts(ii).dtypeSpec=type.sltype;
            end
        end


        function changeCosimLabelInBlock(~,block)
            try



                hPort=find_system(block,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','Inport');
                for kk=1:numel(hPort)
                    portName=get_param(hPort{kk},'Name');
                    if strcmp(portName,'cosim')


                        portH=get_param(hPort{kk},'PortHandles');
                        lineH=get_param(portH.Outport,'Line');
                        set_param(lineH,'Name','FIL');

                        set_param(hPort{kk},'Name','FIL');
                    end
                end



                hComplex2reim=find_system(block,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','ComplexToRealImag');
                for kk=1:numel(hComplex2reim)
                    portH=get_param(hComplex2reim{kk},'PortHandles');
                    for pp=1:numel(portH.Outport)
                        lineH=get_param(portH.Outport(pp),'Line');
                        if strcmpi('cosim_re',get_param(lineH,'Name'))
                            set_param(lineH,'Name','FIL_re');
                        elseif strcmpi('cosim_im',get_param(lineH,'Name'))
                            set_param(lineH,'Name','FIL_im');
                        end
                    end
                end

            catch ME %#ok<NASGU>


            end
        end

        function createLinkBlock(this)
            params=this.hFilMgr.mBuildInfo.ParamsTObj;

            p1=eda.internal.filhost.ParamsT(this.hFilMgr.mBuildInfo);
            params.commIPDevices=p1.commIPDevices;
            params.buildInfo=p1.buildInfo;
            params.dialogState.bitstreamFile=this.hFilMgr.BitFile.FullPath;



            hn=this.hSLHDLCoder.getCurrentNetwork;
            sInports=hn.getInputPorts('data');
            for ii=1:length(sInports)
                params.inputPorts(ii).dtypeSpec='Inherit: auto';
                params.inputPorts(ii).sampleTime='Inherit: Inherit via propagation';
            end

            load_system('fillib');
            cosimblkPath=getCosimLinkDutPath(this);
            add_block('fillib/FPGA-in-the-Loop (FIL)',cosimblkPath);
            eda.internal.filhost.SimulinkBlockParamManagerT.SetUserData(cosimblkPath,params);
        end






        function createLinkMdl(this,drawTB)
            if nargin<2
                drawTB=true;
            end

            linkMdlName=getCosimModelName(this);
            tbFileName=getTBModelName(this);



            if~bdIsLoaded(tbFileName)
                load_system(fullfile(this.getCodeGenDir,tbFileName));
            end

            hb=slhdlcoder.SimulinkBackEnd(this.hPir,...
            'InModelFile',tbFileName,...
            'OutModelFile',linkMdlName,...
            'ShowModel','no');
            hb.createAndInitTargetModel;


            this.cosimMdlName=hb.OutModelFile;

            tbSysName=this.getTestbenchSystem;


            set_param(this.cosimMdlName,'EnableMultiTasking','off')

            this.dutSrcCaptureSSName=[tbSysName,'/ToFILSrc'];
            this.dutSinkCaptureSSName=[tbSysName,'/ToFILSink'];
            this.cosimSrcSSName=[tbSysName,'/FromFILSrc'];
            this.cosimSinkSSName=[tbSysName,'/Compare'];
            this.simStartSSName=[tbSysName,'/Start Simulator'];
            link=sprintf('<a href="matlab:open_system(''%s'')">%s</a>',...
            this.cosimMdlName,this.cosimMdlName);
            hdldisp(message('hdlcoder:hdldisp:GeneratingNewFILModel',link));

            if(drawTB)


                drawSrcModelDut=true;
                hb.drawTestBench(drawSrcModelDut);
            end


            load_system('hdlmdlgenlib');
        end

        function generateProgrammingFile(this,varargin)
            codeGenInfo=this.hSLHDLCoder.getFILCodeGenInfo;




            this.hFilBuildInfo=getFILBuildInfoFromSHDLC(codeGenInfo,this.hFilBuildInfo);


            this.hFilMgr=eda.internal.workflow.LegacyCodeFILManager(this.hFilBuildInfo);

            oldMode=hdlcodegenmode;
            hdlcodegenmode('filtercoder');
            try

                if isempty(varargin)
                    success=this.hFilMgr.build('QuestionDialog','on',...
                    'BuildOutput','FPGAFilesOnly');
                else
                    success=this.hFilMgr.build(varargin{:});
                end

                if~success
                    error(message('hdlcoder:fil:FILBuildNotComplete'));
                end
                hdlcodegenmode(oldMode);
            catch ME
                hdlcodegenmode(oldMode);
                rethrow(ME);
            end
        end



        function validateModel(this)
            dutMinSampleTime=getDutMinSampleTime(this);

            if this.hasHalfDataType
                error(message('hdlcoder:fil:FILNotSupportHalfDataType'));
            end

            if dutMinSampleTime<=0||isinf(dutMinSampleTime)
                warning(message('hdlcoder:fil:edacosimsampletimessue',...
                int2str(dutMinSampleTime),getGoldenMdlDutName(this)));
            end

            mdlBaseSampleTime=getMdlBaseSampleTime(this);
            if isempty(mdlBaseSampleTime)
                warning(message('hdlcoder:fil:edacosimsampletimessue2',...
                getGoldenMdlDutName(this)));
            elseif mdlBaseSampleTime<=0||isinf(mdlBaseSampleTime)
                warning(message('hdlcoder:fil:edacosimsampletimessue3',...
                int2str(mdlBaseSampleTime),getGoldenMdlDutName(this)));
            end
        end


        function doIt(this,varargin)
            hasLicense=this.checkEDALinkLicense;
            if hasLicense
                current_system=get_param(0,'CurrentSystem');
                hdldisp(message('hdlcoder:hdldisp:GeneratingNewFILTB',current_system));
                validateModel(this);
                generateProgrammingFile(this,varargin{:});

                generateLinkModel(this);

                openScopes(this);
                open_system(this.cosimMdlName);
                hdldisp(message('hdlcoder:hdldisp:FILComplete'));
                hdlresetgcb(current_system);
            else
                error(message('hdlcoder:fil:edalinklicenseissue'));
            end

        end

        function libName=getLibraryName(this)%#ok<*MANU>
            libName='fillib';
        end






        function cmd=getCompileCmd(this)
            cmd='';
        end


        function cmd=getClockForceCommand(this)
            cmd='';
        end


        function cmd=getClockEnableForceCommand(this)
            cmd='';
        end


        function cmd=getPreSimRunCommand(this)
            cmd='';
        end


        function cmd=getResetForceCommand(this)
            cmd='';
        end


        function cmds=getAddWaveCommand(this)
            cmds='';
        end


        function cmd=getTclPreSimCommand(this)
            cmd='';
        end


        function cmd=getCosimLaunchCmd(this)
            cmd='';
        end


        function str=getLaunchBoxDisplayStr(this)
            str='';
        end


        function cmdstr=getTclCmds(this,batch)
            cmdstr='';
        end

        function res=hasHalfDataType(this)
            hN=this.getTopNetwork;
            res=false;
            hDUTSignals=[hN.SLInputSignals;hN.SLOutputSignals];
            for idx=1:numel(hDUTSignals)
                hS=hDUTSignals(idx);
                if isa(hS.Type,'hdlcoder.tp_half')
                    res=true;
                    break;
                end
            end
        end
    end
end



