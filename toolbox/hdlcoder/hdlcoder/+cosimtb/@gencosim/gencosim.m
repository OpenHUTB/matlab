classdef gencosim<handle























    properties(Access=protected)




        cosimSetup;

        hPir;


        hSLHDLCoder;

        cosimMdlName;


        IsCodeCoverageEnabled;





        testbenchSystem;

        dutSrcCaptureSSName;

        dutSinkCaptureSSName;

        cosimSrcSSName;


        cosimSinkSSName;

        simStartSSName;


        openScope;


NumFlattenedDUTOutputs
    end
    methods






        function this=gencosim(varargin)
            if(nargin<3)
                this.hPir=pir;
            else

                this.hPir=varargin{3};
            end

            if(nargin<2)
                this.hSLHDLCoder=hdlcurrentdriver;
            else



                this.hSLHDLCoder=varargin{2};
            end

            this.IsCodeCoverageEnabled=this.hSLHDLCoder.getParameter('hdlcodecoverage');

            if(nargin<1)
                this.cosimSetup='CosimBlockAndDut';
            else




                this.cosimSetup=lower(varargin{1});
            end

            this.openScope=containers.Map('KeyType','char','ValueType','logical');
        end
    end


    methods

        checkEDALinkLicense(this);
        opt=getCurrentLinkOpt(this);
        libName=getLibraryName(this);
        cmd=getTclPreSimCommand(this);
        cmd=getTclPostSimCommand(this);
        cmdstr=getTclCmds(this,batch);
        str=getLaunchBoxDisplayStr(this);
        cmd=getCosimLaunchCmd(this);

        crPaths=getClockResetPaths(this);
        crModes=getClockResetModes(this);
        crTimes=getClockResetTimes(this);
        xsiData=getXSIData(this,portInfo);
        str=getCustomCosimLaunchCmd(this);
    end


    methods


        cmd=getClockForceCommand(this);
        cmd=getClockEnableForceCommand(this);
        cmd=getPreSimRunCommand(this);
        cmd=getResetForceCommand(this);
        cmds=getAddWaveCommand(this);
        cmd=getCompileCmd(this);
    end

    methods



        function topNtwk=getTopNetwork(this)
            topNtwk=this.hPir.getTopNetwork;
        end

        function topName=getDutName(this)
            topNet=this.getTopNetwork;
            topName=topNet.Name;
        end

        function iPorts=getDutInports(this)
            topNet=this.getTopNetwork;
            iPorts=topNet.SLInputPorts;
        end

        function oPorts=getDutOutports(this)
            topNet=this.getTopNetwork;
            oPorts=topNet.SLOutputPorts;
        end

        function e=getNumExtraPortsOnCosimBlk(this)
            topNet=this.getTopNetwork;
            id=length(topNet.PirInputPorts)-length(topNet.SLInputPorts);
            od=length(topNet.PirOutputPorts)-length(topNet.SLOutputPorts);
            if(id==0&&od==0)
                e=1;
            else
                e=max(id-3,od-1);
            end
        end

        function name=getDutInportNameAtIdx(this,idx)
            hn=this.getTopNetwork;
            p=hn.SLInputPorts(idx);
            name=p.Name;
        end

        function name=getDutOutportNameAtIdx(this,idx)
            hn=this.getTopNetwork;
            p=hn.SLOutputPorts(idx);
            name=p.Name;
        end

        function name=getDutOriginalInportNameAtIdx(this,idx)

            name='';
            if this.getDutHasInputs
                cosimMdlDutPath=this.getCosimDutPath;
                if strcmpi(get_param(cosimMdlDutPath,'BlockType'),'ModelReference')
                    cosimMdlDutPath=get_param(cosimMdlDutPath,'ModelNameDialog');
                end
                blks=find_system(cosimMdlDutPath,'LookUnderMasks','all',...
                'FollowLinks','on','SearchDepth',1,'blocktype','Inport');
                for ii=1:length(blks)
                    portNum=get_param(blks{ii},'Port');
                    if strcmp(portNum,int2str(idx))
                        name=this.getSLName(blks{ii});
                    end
                end
            end
        end

        function name=getDutOriginalOutportNameAtIdx(this,idx)

            name='';
            if this.getDutHasOutputs
                cosimMdlDutPath=this.getCosimDutPath;
                if strcmpi(get_param(cosimMdlDutPath,'BlockType'),'ModelReference')
                    cosimMdlDutPath=get_param(cosimMdlDutPath,'ModelNameDialog');
                end
                blks=find_system(cosimMdlDutPath,'LookUnderMasks','all',...
                'FollowLinks','on','SearchDepth',1,'blocktype','Outport');
                for ii=1:length(blks)
                    portNum=get_param(blks{ii},'Port');
                    if strcmp(portNum,int2str(idx))
                        name=this.getSLName(blks{ii});
                    end
                end
            end
        end

        function iscomplex=isDutInportAtIdxComplex(this,idx)
            hn=this.getTopNetwork;
            t=hn.getDUTOrigInputPortType(idx-1);
            tInfo=pirgetdatatypeinfo(t);
            iscomplex=tInfo.iscomplex;
        end

        function iscomplex=isDutOutportAtIdxComplex(this,idx)
            hn=this.getTopNetwork;
            t=hn.getDUTOrigOutputPortType(idx-1);
            tInfo=pirgetdatatypeinfo(t);
            iscomplex=tInfo.iscomplex;
        end

        function isvector=isDutInportAtIdxVector(this,idx)
            hn=this.getTopNetwork;
            t=hn.getDUTOrigInputPortType(idx-1);
            tInfo=pirgetdatatypeinfo(t);
            isvector=tInfo.isvector;
        end

        function isvector=isDutOutportAtIdxVector(this,idx)
            hn=this.getTopNetwork;
            t=hn.getDUTOrigOutputPortType(idx-1);
            tInfo=pirgetdatatypeinfo(t);
            isvector=tInfo.isvector;
        end

        function isonebitvector=isDutInportAtIdxOneBitVector(this,idx)
            hn=this.getTopNetwork;
            t=hn.getDUTOrigInputPortType(idx-1);
            tInfo=pirgetdatatypeinfo(t);
            isonebitvector=tInfo.isvector&&tInfo.wordsize==1;
        end

        function isonebitvector=isDutOutportAtIdxOneBitVector(this,idx)
            hn=this.getTopNetwork;
            t=hn.getDUTOrigOutputPortType(idx-1);
            tInfo=pirgetdatatypeinfo(t);
            isonebitvector=tInfo.isvector&&tInfo.wordsize==1;
        end

        function vlen=getVectorLenAtInputPort(this,idx)
            hn=this.getTopNetwork;
            t=hn.getDUTOrigInputPortType(idx-1);
            vlen=max(t.getDimensions);
        end

        function vlen=getVectorLenAtOutputPort(this,idx)
            hn=this.getTopNetwork;
            t=hn.getDUTOrigOutputPortType(idx-1);
            vlen=max(t.getDimensions);
        end

        function isDouble=isDutInportAtIdxDouble(this,idx)
            hn=this.getTopNetwork;
            t=hn.getDUTOrigInputPortType(idx-1);
            l=t.getLeafType;
            isDouble=l.isDoubleType;
        end

        function isDouble=isDutOutportAtIdxDouble(this,idx)
            hn=this.getTopNetwork;
            t=hn.getDUTOrigOutputPortType(idx-1);
            l=t.getLeafType;
            isDouble=l.isDoubleType;
        end

        function names=getHDLInportNamesAtIdx(this,idx)
            topNet=this.getTopNetwork;
            names=topNet.getHDLInputPortNames(idx);


            if~iscell(names)
                names={names};
            end
        end

        function names=getHDLOutportNamesAtIdx(this,idx)
            topNet=this.getTopNetwork;
            names=topNet.getHDLOutputPortNames(idx);


            if~iscell(names)
                names={names};
            end
        end

        function hdlIn=getNumHDLInportsAtIdx(this,idx)
            names=this.getHDLInportNamesAtIdx(idx);
            hdlIn=length(names);
        end

        function hdlOut=getNumHDLOutportsAtIdx(this,idx)
            names=this.getHDLOutportNamesAtIdx(idx);
            hdlOut=length(names);
        end

        function idxOut=getActualPirInPortBeginIdx(this,idx)
            idxOut=1;
            if idx==1
                return;
            else
                num=this.getDutNumIn;
                for ii=1:num
                    if(ii<=idx-1)
                        idxOut=idxOut+this.getNumHDLInportsAtIdx(ii-1);
                    end
                end
            end
        end

        function idxOut=getActualPirOutPortBeginIdx(this,idx)
            idxOut=1;
            if idx==1
                return;
            else
                num=this.getDutNumOut;
                for ii=1:num
                    if(ii<=idx-1)
                        idxOut=idxOut+getNumHDLOutportsAtIdx(this,ii-1);
                    end
                end
            end
        end

        function b=dutHasClock(this)
            hn=this.getTopNetwork;
            b=hn.NumberOfPirInputPorts('CLOCK')>0;
        end

        function b=dutHasClockEnable(this)
            hn=this.getTopNetwork;
            b=hn.NumberOfPirInputPorts('CLOCK_ENABLE')>0;
        end

        function b=dutHasReset(this)
            hn=this.getTopNetwork;
            b=hn.NumberOfPirInputPorts('RESET')>0;
        end

        function b=getDutHasInputs(this)
            b=false;
            hn=this.getTopNetwork;
            ports=hn.SLInputPorts;
            for ii=1:length(ports)
                p=ports(ii);
                if strcmpi(p.Kind,'Data')
                    b=true;
                    break;
                end
            end
        end

        function b=getDutHasTunableInputs(this)
            b=false;
            hn=this.getTopNetwork;
            iports=hn.PIRInputPorts;
            for ii=1:length(iports)
                p=iports(ii);
                if~isempty(p.getTunableName)
                    b=true;
                    break;
                end
            end
        end






        function isTestpoint=isDutOutportTestpoint(this,idx)
            hn=this.getTopNetwork;
            oports=hn.PIROutputPorts;
            index=1;
            isTestpoint=0;
            for ii=1:length(oports)
                p=oports(ii);
                if strcmpi(p.Kind,'Data')
                    if index==idx
                        isTestpoint=p.isTestpoint();
                        break;
                    end
                    index=index+1;
                end
            end
        end

        function retval=getDutHasTestpointsPresent(this)
            retval=false;
            hn=this.getTopNetwork;
            oports=hn.PIROutputPorts;
            for ii=1:numel(oports)
                p=oports(ii);
                if p.isTestpoint()
                    retval=true;
                    break;
                end
            end
        end

        function b=getDutHasOutputs(this)
            b=false;
            hn=this.getTopNetwork;
            ports=hn.SLOutputPorts;
            for ii=1:length(ports)
                p=ports(ii);
                if strcmpi(p.Kind,'Data')
                    b=true;
                    break;
                end
            end
        end

        function n=getDutNumIn(this)
            hn=this.getTopNetwork;
            n=length(hn.SLInputPorts);
        end

        function n=getDutNumOut(this)
            hn=this.getTopNetwork;
            n=length(hn.SLOutputPorts);
        end

        function n=getDutNumOutWithNoTestpoints(this)
            hn=this.getTopNetwork;
            ports=hn.SLOutputPorts;
            n=0;
            for ii=1:length(ports)
                p=ports(ii);
                if~p.isTestpoint()
                    n=n+1;
                end
            end
        end

        function name=getClockName(this)
            name='';
            hn=this.getTopNetwork;
            iports=hn.PirInputPorts;
            for ii=1:length(iports)
                p=iports(ii);
                if(strcmpi(p.Kind,'clock'))
                    name=p.Name;
                end
            end
        end

        function name=getClockEnableName(this)
            name='';
            hn=this.getTopNetwork;
            iports=hn.PirInputPorts;
            for ii=1:length(iports)
                p=iports(ii);
                if(strcmpi(p.Kind,'clock_enable'))
                    name=p.Name;
                end
            end
        end

        function name=getResetNames(this)
            name={};
            hn=this.getTopNetwork;
            iports=hn.PirInputPorts;
            for ii=1:length(iports)
                p=iports(ii);
                if(strcmpi(p.Kind,'reset'))
                    name=[name,{p.Name}];
                end
            end
        end

        function dp=dutHasDoublePorts(this)
            dp=false;
            hn=this.getTopNetwork;
            iports=hn.PirInputPorts;
            for ii=1:length(iports)
                ip=iports(ii);
                if ip.Signal.Type.isDoubleType
                    dp=true;
                    return;
                end
            end

            oports=hn.PirOutputPorts;
            for ii=1:length(oports)
                op=oports(ii);
                if op.Signal.Type.isDoubleType
                    dp=true;
                    return;
                end
            end
        end

        function name=getGoldenMdlName(this)
            name=this.hSLHDLCoder.ModelName;
        end

        function name=getGoldenMdlDutName(this)
            name=this.hSLHDLCoder.ModelConnection.SubsystemName;
        end

        function strategy=getFPToleranceStrategy(this)
            strategy=this.hSLHDLCoder.getParameter('FPToleranceStrategy');
        end

        function value=getFPToleranceValue(this)
            value=num2str(this.hSLHDLCoder.getParameter('FPToleranceValue'));
        end

        function value=isFloatingPointMode(this)
            value=~isempty(this.hSLHDLCoder.getParameter('FloatingPointTargetConfiguration'));
        end

        function name=getGoldenMdlDutPath(this)
            name=[this.getGoldenMdlName,'/',this.getGoldenMdlDutName];
        end

        function setTestbenchSystem(this)
            if this.hSLHDLCoder.DUTMdlRefHandle>0
                genMdl=this.hSLHDLCoder.getParameter('generatedmodelname');
                dutName=get_param(this.hSLHDLCoder.DUTMdlRefHandle,'Name');


                dutMdlRef=find_system(genMdl,'MatchFilter',@Simulink.match.allVariants,...
                'Name',dutName,'BlockType','ModelReference');
                variantSubsys=get_param(dutMdlRef,'Parent');
                tbSys=get_param(variantSubsys,'Parent');

                if iscell(tbSys)
                    tbSys=tbSys{1};
                end

                [this.testbenchSystem,prefixFound]=this.stripPrefixStr(tbSys,genMdl);

                if prefixFound
                    this.testbenchSystem=[this.cosimMdlName,this.testbenchSystem];
                end

            elseif this.hSLHDLCoder.nonTopDut
                genMdl=this.hSLHDLCoder.getParameter('generatedmodelname');
                Parent=get_param(this.hSLHDLCoder.OrigStartNodeName,'Parent');
                tbSys=regexprep(Parent,['^',this.getGoldenMdlName],...
                genMdl);
                if iscell(tbSys)
                    tbSys=tbSys{1};
                end
                [this.testbenchSystem,prefixFound]=this.stripPrefixStr(tbSys,genMdl);

                if prefixFound
                    this.testbenchSystem=[this.cosimMdlName,this.testbenchSystem];
                end
            else
                this.testbenchSystem=this.getCosimModelName;
            end
        end


        function[newStr,prefixFound]=stripPrefixStr(~,oldStr,prefix)

            newStr=oldStr;
            prefixFound=false;


            if startsWith(oldStr,prefix)
                newStr=oldStr(length(prefix)+1:end);
                prefixFound=true;
            end
        end

        function tbSystem=getTestbenchSystem(this)
            if isempty(this.testbenchSystem)
                this.setTestbenchSystem;
            end
            tbSystem=this.testbenchSystem;
        end

        function tbMdlName=getTBModelName(this)
            if this.hSLHDLCoder.DUTMdlRefHandle>0
                tbMdlName=this.hSLHDLCoder.BackEnd.TopOutModelFile;
            else
                tbMdlName=this.hSLHDLCoder.BackEnd.OutModelFile;
            end
        end

        function topNodeName=getTBDutName(this)


            topNodeName=this.getGoldenMdlDutName;
        end

        function topNodePath=getTBDutPath(this)
            topNodePath=[this.getTestbenchSystem,'/',this.getTBDutName];
        end

        function ssName=getDutSrcCaptureSSName(this)
            ssName=this.dutSrcCaptureSSName;
        end

        function ssName=getDutSinkCaptureSSName(this)
            ssName=this.dutSinkCaptureSSName;
        end

        function ssName=getCosimSrcSSName(this)
            ssName=this.cosimSrcSSName;
        end

        function ssName=getCosimSinkSSName(this)
            ssName=this.cosimSinkSSName;
        end

        function ssName=getStartSimSSName(this)
            ssName=this.simStartSSName;
        end

        function name=stripTBSubsystemPath(this,nameWithPath)
            name='';
            tbSys=this.getTestbenchSystem;

            [name,prefixFound]=this.stripPrefixStr(nameWithPath,[tbSys,'/']);

            if~prefixFound
                error(message('hdlcoder:cosim:badlinkpath'));
            end
        end

        function linkModelName=getCosimModelName(this)
            if isempty(this.cosimMdlName)
                if~isa(this,'cosimtb.gencoverifymdl')
                    this.cosimMdlName=[this.getTBModelName,'_',this.getCurrentLinkOpt];
                else
                    this.cosimMdlName=[this.getTBModelName,this.getCurrentLinkOpt];
                end
            end
            linkModelName=this.cosimMdlName;
        end

        function linkDutName=getCosimDutName(this)

            linkDutName=this.getTBDutName;
        end

        function linkBlkPath=getCosimDutPath(this)
            tbSysName=this.getTestbenchSystem;
            linkBlkPath=[tbSysName,'/',this.getCosimDutName];
        end

        function linkDutName=getCosimLinkDutName(this)
            if~isa(this,'cosimtb.gencoverifymdl')
                linkDutName=[this.getTBDutName,'_',this.getCurrentLinkOpt];
            else
                linkDutName=[this.getTBDutName,this.getCurrentLinkOpt];
            end
        end

        function linkBlkPath=getCosimLinkDutPath(this)
            tbSysName=this.getTestbenchSystem;
            linkBlkPath=[tbSysName,'/',this.getCosimLinkDutName];
        end

        function outputDir=getCodeGenDir(this)
            outputDir=this.hSLHDLCoder.hdlGetCodegendir;
        end

        function exist=edaScriptsGenerated(this)
            exist=this.hSLHDLCoder.getParameter('gen_eda_scripts');
        end

        function len=getResetLength(this)
            len=this.hSLHDLCoder.getParameter('resetlength');
        end

        function clkEnDelay=getClockEnableDelay(this)
            clkEnDelay=this.hSLHDLCoder.getParameter('testbenchclockenabledelay');
        end

        function clkEnDelay=getHoldTime(this)
            clkEnDelay=this.hSLHDLCoder.getParameter('force_hold_time');
        end

        function c=getToolFileComment(this)
            c=this.hSLHDLCoder.getParameter('tool_file_comment');
        end

        function c=getTargetLibName(this)
            c=this.hSLHDLCoder.getParameter('vhdl_library_name');
        end

        function c=getIgnoreDataCheckingLen(this)
            c=this.hSLHDLCoder.getParameter('ignoredatachecking');
        end

        function minST=getDutMinSampleTime(this)
            minST=this.hPir.DutBaseRate;
        end

        function result=vectorGcd(~,invec)
            result=invec(1);
            for i=2:length(invec)
                result=gcd(result,invec(i));
            end
        end

        function mdlBaseSampleTime=getMdlBaseSampleTime(this)
            mdlBaseSampleTime=this.hPir.ModelBaseRate;
            if isempty(mdlBaseSampleTime)

                mdlBaseSampleTime=1;
                warning(message('hdlcoder:cosim:edacosimsampletimessue',this.getGoldenMdlDutName));
            end
        end

        function isvhdl=isCodingForVhdl(this)
            isvhdl=this.hSLHDLCoder.getParameter('isvhdl');
        end

        function isscalar=isScalarizedVectorPorts(this)
            isscalar=(this.hSLHDLCoder.getParameter('ScalarizePorts')~=0)||~this.isCodingForVhdl;
        end

        function r=isDutOutportScalarizedVector(this,ii)
            r=this.isDutOutportAtIdxVector(ii)&&this.isScalarizedVectorPorts;
        end

        function r=isDutInportUnscalarizedOneBitVector(this,ii)
            r=this.isDutInportAtIdxOneBitVector(ii)&&~this.isScalarizedVectorPorts;
        end

        function r=isDutOutportUnscalarizedOneBitVector(this,ii)
            r=this.isDutOutportAtIdxOneBitVector(ii)&&~this.isScalarizedVectorPorts;
        end

        function len=getClockHighTime(this)
            len=this.hSLHDLCoder.getParameter('force_clock_high_time');
        end

        function len=getClockLowTime(this)
            len=this.hSLHDLCoder.getParameter('force_clock_low_time');
        end

        function isRising=isClockEdgeRising(this)
            isRising=this.hSLHDLCoder.getParameter('clockedge')==0;
        end

        function rt=getResetType(this)
            if this.hSLHDLCoder.getParameter('async_reset')
                rt='async';
            else
                rt='sync';
            end
        end

        function lvl=getResetAssertLevel(this)
            lvl=this.hSLHDLCoder.getParameter('reset_asserted_level');
        end

        function lang=getTargetLanguage(this)
            if this.isCodingForVhdl
                lang='vhdl';
            else
                lang='verilog';
            end
        end


        function bn=getSLName(~,blk)
            n=get_param(blk,'Name');
            bn=strrep(n,'/','//');
        end


        function names=getEntityNameList(this)
            names=this.hSLHDLCoder.PirInstance.getEntityNames;
            if~isempty(names)
                if this.isCodingForVhdl
                    pkgReqd=this.hSLHDLCoder.getParameter('vhdl_package_required');
                    pkgName=this.hSLHDLCoder.getParameter('vhdl_package_name');
                    if pkgReqd&&~isempty(names{1})&&~strcmp(names{1},pkgName)
                        names={pkgName,names{:}};%#ok<CCAT>
                    elseif strcmp(names{1},pkgName)

                        names=names(2:end);
                    end
                end
            else
                names={};
            end
        end


        function filenames=getEntityFileNames(this)

            names=this.getEntityNameList;

            if isempty(names)
                filenames={};
            else
                suffix=this.hSLHDLCoder.PirInstance.getHDLFileExtension;

                if this.hSLHDLCoder.getParameter('isvhdl')&&this.hSLHDLCoder.getParameter('split_entity_arch')
                    if this.hSLHDLCoder.getParameter('vhdl_package_required')
                        package_name=names{1};
                        names=names(2:end);
                    end

                    entity_names=strcat(names,...
                    this.hSLHDLCoder.getParameter('split_entity_file_postfix'),...
                    suffix);
                    arch_names=strcat(names,...
                    this.hSLHDLCoder.getParameter('split_arch_file_postfix'),...
                    suffix);
                    if this.hSLHDLCoder.getParameter('vhdl_package_required')
                        filenames={[package_name,suffix]};
                    else
                        filenames={};
                    end
                    for n=1:length(names)
                        filenames{end+1}=entity_names{n};
                        filenames{end+1}=arch_names{n};
                    end
                else
                    filenames=strcat(names,suffix);
                end
            end

        end





        function timeMode=getTimingUnit(~)

            timeMode='ns';
        end


        function tp=getClockPeriod(this)
            tp=this.getClockHighTime+this.getClockLowTime;
        end





        function ocr=getOverClockRate(this)
            gp=pir;
            mdlSTime=this.getMdlBaseSampleTime;
            dutSTime=this.getDutMinSampleTime;
            dutMdlRatio=dutSTime/mdlSTime;
            clockOversamplingFactor=gp.getClockOversamplingFactor;
            if dutMdlRatio*gp.getClockScalingFactor-1<1e-10




                ocr=clockOversamplingFactor;
            else




                ocr=clockOversamplingFactor*dutMdlRatio;
            end
        end






        function portInfo=getPortInfo(this)
            function[t,d]=l_getCosimTypeAndDims(tInfo,numports)









                if numports>1




                    numelems=prod(tInfo.dims);
                    if tInfo.iscomplex
                        numelems=numelems*2;
                    end
                    elemsPerPort=numelems/numports;
                    actualDims=elemsPerPort;

                    if elemsPerPort==1
                        actualScalar=1;
                    else
                        actualScalar=tInfo.isscalar;
                    end

                else
                    actualDims=tInfo.dims;
                    actualScalar=tInfo.isscalar;
                end
                if tInfo.isfloat






                    fplib=targetcodegen.targetCodeGenerationUtils.isFloatingPointMode;
                    if fplib
                        t='Logic';


                    else
                        if matches(tInfo.sltype,{'single','half'})



                            error(message('hdlcoder:cosim:NonDoubleWithoutNFP'));
                        else

                            switch this.getTargetLanguage
                            case 'verilog'
                                t='Logic';

                            otherwise
                                t='Real';
                            end
                        end
                    end
                else
                    t='Logic';
                end

                switch t



                case 'Logic'
                    if actualScalar
                        d=tInfo.wordsize;
                    else
                        if tInfo.wordsize>1
                            d=[actualDims,tInfo.wordsize];
                        else
                            d=actualDims;
                        end
                    end
                otherwise
                    d=actualDims;
                end
            end
            portInfo.PortPaths='';
            portInfo.PortModes='';
            portInfo.PortTimes='';
            portInfo.PortSigns='';
            portInfo.PortFracLengths='';
            portInfo.PortTypes={};
            portInfo.PortDims={};
            hN=this.getTopNetwork;
            top=this.getDutName;

            portIdx=0;
            slInports=this.getDutInports;
            for ii=1:length(slInports)
                port=slInports(ii);
                if~strcmpi(port.Kind,'Data')
                    continue;
                end

                rT=hN.getDUTOrigInputRecordPortType(ii-1);
                if rT.isRecordType
                    numRecElem=rT.NumberOfMembersFlattened;
                    portNames={};portTypes={};portDims={};
                    for jj=1:numRecElem
                        pn=this.getHDLInportNamesAtIdx(portIdx);
                        tInfo=pirgetdatatypeinfo(rT.MemberTypesFlattened(jj));
                        for kk=1:numel(pn)
                            portNames{end+1}=pn{kk};
                            [portTypes{end+1},portDims{end+1}]=l_getCosimTypeAndDims(tInfo,numel(pn));
                        end
                        portIdx=portIdx+1;
                    end
                elseif rT.isArrayOfRecords
                    numVectorPorts=rT.Dimensions;
                    portNames={};portTypes={};portDims={};
                    for ll=1:numVectorPorts
                        baserT=rT.BaseType;
                        numRecElem=baserT.NumberOfMembersFlattened;
                        for jj=1:numRecElem
                            pn=this.getHDLInportNamesAtIdx(portIdx);
                            tInfo=pirgetdatatypeinfo(baserT.MemberTypesFlattened(jj));
                            for kk=1:numel(pn)
                                portNames{end+1}=pn{kk};
                                [portTypes{end+1},portDims{end+1}]=l_getCosimTypeAndDims(tInfo,numel(pn));
                            end
                            portIdx=portIdx+1;
                        end
                    end
                else
                    portTypes={};portDims={};
                    tInfo=pirgetdatatypeinfo(rT);
                    portNames=this.getHDLInportNamesAtIdx(portIdx);
                    for kk=1:numel(portNames)
                        [portTypes{end+1},portDims{end+1}]=l_getCosimTypeAndDims(tInfo,numel(portNames));
                    end
                    portIdx=portIdx+1;
                end
                for jj=1:length(portNames)
                    pName=portNames(jj);
                    pPath=sprintf('/%s/%s;',top,pName{1});
                    portInfo.PortPaths=[portInfo.PortPaths,pPath];
                    portInfo.PortModes=[portInfo.PortModes,'1 '];
                    portInfo.PortTimes=[portInfo.PortTimes,'-1 '];
                    portInfo.PortSigns=[portInfo.PortSigns,'-1 '];
                    portInfo.PortFracLengths=[portInfo.PortFracLengths,'0,'];
                    portInfo.PortTypes=[portInfo.PortTypes,portTypes(jj)];
                    portInfo.PortDims=[portInfo.PortDims,portDims(jj)];
                end
            end

            portIdx=0;
            portIdxForType=1;
            slOutports=this.getDutOutports;
            for ii=1:length(slOutports)
                port=slOutports(ii);
                if~strcmpi(port.Kind,'Data')
                    continue;
                end

                if port.isTestpoint()
                    continue;
                end

                portSig=port.Signal;
                rate=portSig.SimulinkRate;
                if rate<=0||isinf(rate)
                    warning(message('hdlcoder:cosim:edacosimsampletimessue2',...
                    num2str(rate),this.getGoldenMdlDutName,ii));
                end

                rT=hN.getDUTOrigOutputRecordPortType(ii-1);
                if rT.isRecordType
                    numNames=rT.NumberOfMembersFlattened;
                    portNames={};portTypes={};portDims={};
                    bp=[];
                    sign=[];
                    for jj=1:numNames
                        pn=this.getHDLOutportNamesAtIdx(portIdx);
                        tInfo=pirgetdatatypeinfo(rT.MemberTypesFlattened(jj));
                        for kk=1:numel(pn)
                            portNames{end+1}=pn{kk};
                            [portTypes{end+1},portDims{end+1}]=l_getCosimTypeAndDims(tInfo,numel(pn));
                            if tInfo.ishalf
                                sign(end+1)=4;
                                bp(end+1)=0;
                            elseif tInfo.issingle
                                sign(end+1)=3;
                                bp(end+1)=0;
                            elseif tInfo.isdouble
                                sign(end+1)=2;
                                bp(end+1)=0;
                            else
                                sign(end+1)=tInfo.issigned;
                                bp(end+1)=-tInfo.binarypoint;
                            end
                        end
                        portIdx=portIdx+1;
                    end
                elseif rT.isArrayOfRecords
                    numVectorPorts=rT.Dimensions;
                    portNames={};portTypes={};portDims={};
                    bp=[];
                    sign=[];
                    for ll=1:numVectorPorts
                        baserT=rT.BaseType;
                        numNames=baserT.NumberOfMembersFlattened;
                        for jj=1:numNames
                            pn=this.getHDLOutportNamesAtIdx(portIdx);
                            tInfo=pirgetdatatypeinfo(baserT.MemberTypesFlattened(jj));
                            for kk=1:numel(pn)
                                portNames{end+1}=pn{kk};
                                [portTypes{end+1},portDims{end+1}]=l_getCosimTypeAndDims(tInfo,numel(pn));
                                if tInfo.ishalf
                                    sign(end+1)=4;
                                    bp(end+1)=0;
                                elseif tInfo.issingle
                                    sign(end+1)=3;
                                    bp(end+1)=0;
                                elseif tInfo.isdouble
                                    sign(end+1)=2;
                                    bp(end+1)=0;
                                else
                                    sign(end+1)=tInfo.issigned;
                                    bp(end+1)=-tInfo.binarypoint;
                                end
                            end
                            portIdx=portIdx+1;
                        end
                    end
                else
                    portTypes={};portDims={};
                    portNames=this.getHDLOutportNamesAtIdx(portIdx);
                    numNames=numel(portNames);
                    tInfo=pirgetdatatypeinfo(rT);
                    for kk=1:numNames
                        [portTypes{end+1},portDims{end+1}]=l_getCosimTypeAndDims(tInfo,numNames);
                    end
                    if tInfo.ishalf
                        sign=repmat(4,1,numNames);
                        bp=zeros(1,numNames);
                    elseif tInfo.issingle
                        sign=repmat(3,1,numNames);
                        bp=zeros(1,numNames);
                    elseif tInfo.isdouble
                        sign=repmat(2,1,numNames);
                        bp=zeros(1,numNames);
                    elseif rT.isEnumType



                        sign=zeros(1,numNames);
                        numBits=max(1,ceil(log2(numel(rT.EnumValues))));
                        bp=repmat(numBits,1,numNames);
                    else
                        sign=repmat(tInfo.issigned,1,numNames);
                        bp=repmat(-tInfo.binarypoint,1,numNames);
                    end
                    portIdx=portIdx+1;
                end

                for jj=1:length(portNames)
                    pName=portNames(jj);
                    pPath=sprintf('/%s/%s;',top,pName{1});
                    portInfo.PortPaths=[portInfo.PortPaths,pPath];
                    portInfo.PortModes=[portInfo.PortModes,'2 '];
                    portInfo.PortTimes=[portInfo.PortTimes,sprintf('%.65g ',rate)];
                    if this.isDutOutportUnscalarizedOneBitVector(portIdx)

                        portInfo.PortSigns=[portInfo.PortSigns,'-1 '];
                        portInfo.PortFracLengths=[portInfo.PortFracLengths,'0,'];
                    else
                        portInfo.PortSigns=[portInfo.PortSigns,sprintf('%d ',sign(jj))];
                        portInfo.PortFracLengths=[portInfo.PortFracLengths,sprintf('%d,',bp(jj))];
                    end
                    portInfo.PortTypes=[portInfo.PortTypes,portTypes(jj)];
                    portInfo.PortDims=[portInfo.PortDims,portDims(jj)];
                end
            end


            portInfo.PortPaths=portInfo.PortPaths(1:end-1);
            portInfo.PortModes=['[',portInfo.PortModes,']'];
            portInfo.PortTimes=['[',portInfo.PortTimes,']'];
            portInfo.PortSigns=['[',portInfo.PortSigns,']'];
            portInfo.PortFracLengths=['[',portInfo.PortFracLengths(1:end-1),']'];
        end


        function clkEnHigh=getClockEnableHigh(this)
            clkLowTime=this.getClockLowTime;
            holdTime=this.getHoldTime;
            resetLen=this.getResetLength;
            clkEnDelay=this.getClockEnableDelay;
            t=(resetLen+clkEnDelay)*this.getClockPeriod;
            clkEnHigh=t+clkLowTime+holdTime;
        end






        function rLen=computeResetRunTime(this)
            resetLen=this.getResetLength;
            if~this.dutHasClockEnable
                clkEnDelay=0;
            else
                clkEnDelay=this.getClockEnableDelay;
            end
            rLen=(resetLen+clkEnDelay+1)*this.getClockPeriod;
        end















        function rLen=computeResetLength(this)
            resetLen=this.getResetLength*this.getClockPeriod;
            clkLowTime=this.getClockLowTime;
            holdTime=this.getHoldTime;
            rLen=(clkLowTime+resetLen+holdTime);
        end


        function nn=fixName(~,on)

            nn=strrep(on,newline,' ');
        end


        function headerTxt=getTclHeaderTxt(this,tclPath)

            fnameStr=strrep(tclPath,'\','\\');
            createDate=datestr(now,31);

            genBy=this.getToolFileComment;
            genbytxt=regexp(genBy,'(\w.*)','match');
            genBy=genbytxt{1};

            clkLowTime=sprintf('%d%s',this.getClockLowTime,this.getTimingUnit);
            clkHighTime=sprintf('%d%s',this.getClockHighTime,this.getTimingUnit);
            clkPeriod=sprintf('%d%s',this.getClockPeriod,this.getTimingUnit);
            resetLength=sprintf('%d%s',this.getResetLength*this.getClockPeriod,...
            this.getTimingUnit);
            resetAssertLevel=sprintf('%d',this.getResetAssertLevel);
            resetType=sprintf('%s',this.getResetType);
            clkEnDelay=sprintf('%d%s',this.getClockEnableDelay*this.getClockPeriod,...
            this.getTimingUnit);
            holdTime=sprintf('%d%s',this.getHoldTime,this.getTimingUnit);
            modelBaseSampleTime=sprintf('%g',this.getMdlBaseSampleTime);
            dutMinSampleTime=sprintf('%g',this.getDutMinSampleTime);
            baseClockScale=sprintf('%g',this.computeBaseClockScale);
            overClocking=sprintf('%d',this.getOverClockRate);
            finalClockSale=sprintf('%g',this.getFinalScale);
            finalScaleWithUnits=sprintf('%s%s',finalClockSale,this.getTimingUnit);
            resetRiseEdge=sprintf('%g%s',this.computeResetLength,this.getTimingUnit);
            clkEnRiseEdge=sprintf('%g%s',this.getClockEnableHigh,this.getTimingUnit);

            headerTxt=...
            [
            repmat('%%',1,75),'\n',...
            '%%',blanks(1),'Auto generated cosimulation ''tclstart'' script \n',...
            repmat('%%',1,75),'\n',...
            '%%',blanks(2),'Source Model         : ',this.getGoldenMdlName,'\n',...
            '%%',blanks(2),'Generated Model      : ',this.getTBModelName,'\n',...
            '%%',blanks(2),'Cosimulation Model   : ',this.getCosimModelName,'\n',...
            '%%','\n',...
            '%%',blanks(2),'Source DUT           : ',this.fixName(this.getCosimDutPath),'\n',...
            '%%',blanks(2),'Cosimulation DUT     : ',this.fixName(this.getCosimLinkDutPath),'\n',...
            '%%','\n',...
            '%%',blanks(2),'File Location        : ',fnameStr,'\n',...
            '%%',blanks(2),'Created              : ',createDate,'\n',...
            '%%','\n',...
            '%%',blanks(2),genBy,...
            ];


            if this.dutHasClock
                headerTxt=...
                [headerTxt,...
                repmat('%%',1,75),'\n\n',...
                repmat('%%',1,75),'\n',...
                '%%','  ClockName           : ',this.getClockName,'\n',...
                '%%','  ResetName           : ',sprintf('%s ',this.getResetNames{:}),'\n',...
                '%%','  ClockEnableName     : ',this.getClockEnableName,'\n',...
                '%%','\n',...
                '%%','  ClockLowTime        : ',clkLowTime,'\n',...
                '%%','  ClockHighTime       : ',clkHighTime,'\n',...
                '%%','  ClockPeriod         : ',clkPeriod,'\n',...
                '%%','\n',...
                '%%','  ResetLength         : ',resetLength,'\n',...
                '%%','  ClockEnableDelay    : ',clkEnDelay,'\n',...
                '%%','  HoldTime            : ',holdTime,'\n',...
                repmat('%%',1,75),'\n\n',...
                repmat('%%',1,75),'\n',...
                '%%','  ModelBaseSampleTime   : ',modelBaseSampleTime,'\n',...
                '%%','  DutBaseSampleTime     : ',dutMinSampleTime,'\n',...
                '%%','  OverClockFactor     : ',overClocking,'\n',...
                repmat('%%',1,75),'\n\n',...
                repmat('%%',1,75),'\n',...
                '%%','  Mapping of DutBaseSampleTime to ClockPeriod','\n',...
                '%%','\n',...
                '%%','  N = (ClockPeriod / DutBaseSampleTime) * OverClockFactor','\n',...
                '%%','  1 sec in Simulink corresponds to ',finalScaleWithUnits,...
                ' in the HDL Simulator(N = ',finalClockSale,')','\n',...
                '%%','\n',...
                repmat('%%',1,75),'\n\n',...
                repmat('%%',1,75),'\n',...
                '%%','  ResetHighAt          : ','(ClockLowTime + ResetLength + HoldTime)','\n',...
                '%%','  ResetRiseEdge        : ',resetRiseEdge,'\n',...
                '%%','  ResetType            : ',resetType,'\n',...
                '%%','  ResetAssertedLevel   : ',resetAssertLevel,'\n',...
                '%%','\n',...
                '%%','  ClockEnableHighAt    : ',...
                '(ClockLowTime + ResetLength + ClockEnableDelay + HoldTime)','\n',...
                '%%','  ClockEnableRiseEdge  : ',clkEnRiseEdge,'\n',...
                repmat('%%',1,75),'\n',...
                ];
            end

            headerTxt=sprintf(headerTxt);

        end


        function tclCmdFcn=getTclCmdFcnName(this)
            linkMdlName=this.getCosimModelName;
            tclCmdFcn=[this.hSLHDLCoder.getParameter('module_prefix'),linkMdlName,'_tcl'];
        end
        function tclCmdFcn=getTclCmdFcnName2(this)
            linkMdlName=this.getCosimModelName;
            tclCmdFcn=[this.hSLHDLCoder.getParameter('module_prefix'),linkMdlName];
        end

        function tclPath=getTclFileWithPath(this)
            tclCmdFcn=this.getTclCmdFcnName;
            tclCmdFileName=[tclCmdFcn,'.m'];
            tclPath=fullfile(this.getCodeGenDir,tclCmdFileName);
        end


        function tclCmdFcn=getTclCmdBatchFcnName(this)
            linkMdlName=this.getCosimModelName;
            tclCmdFcn=[this.hSLHDLCoder.getParameter('module_prefix'),linkMdlName,'_batch_tcl'];
        end


        function tclPath=getTclBatchFileWithPath(this)
            tclCmdFcn=this.getTclCmdBatchFcnName;
            tclCmdFileName=[tclCmdFcn,'.m'];
            tclPath=fullfile(this.getCodeGenDir,tclCmdFileName);
        end


        function createTCLFile(this)
            if strcmp(this.getCosimLaunchCmd(),'CUSTOM_LAUNCHER')
                tclCmdFileName=fullfile(this.getCodeGenDir,[this.getTclCmdFcnName2,'.tcl']);
                headerTxt=regexprep(this.getTclHeaderTxt(tclCmdFileName),'%','#');
                cmdStr=this.getTclCmds(true);

                fid=fopen(tclCmdFileName,'w');
                fwrite(fid,sprintf('%s\n%s\n',headerTxt,cmdStr));
                fclose(fid);

            else
                tclCmdFcn=this.getTclCmdFcnName;
                tclPath=this.getTclFileWithPath;

                fid=fopen(tclPath,'w');


                headerTxt=getTclHeaderTxt(this,tclPath);


                cmdStr=this.getTclCmds(false);

                tclCmds=sprintf('%s\nfunction tclCmds = %s\ntclCmds = {\n%s};\nend',...
                headerTxt,...
                tclCmdFcn,...
                cmdStr);

                fwrite(fid,tclCmds);
                fclose(fid);

                hdldisp(message('hdlcoder:hdldisp:GenVModelTcl',hdlgetfilelink(tclPath)));

                tclCmdFcn=this.getTclCmdBatchFcnName;
                tclPath=this.getTclBatchFileWithPath;

                fid=fopen(tclPath,'w');


                cmdStr=this.getTclCmds(true);

                tclCmds=sprintf('%s\nfunction tclCmds = %s\ntclCmds = {\n%s};\nend',...
                headerTxt,...
                tclCmdFcn,...
                cmdStr);

                fwrite(fid,tclCmds);
                fclose(fid);

                hdldisp(message('hdlcoder:hdldisp:GenVModelTcl',hdlgetfilelink(tclPath)));
            end
        end


        function newName=addBlockUnique(~,blkType,tgtBlkPath)
            blkH=add_block(blkType,tgtBlkPath,'MakeNameUnique','on');
            newName=getfullname(blkH);
        end


        function str=getLaunchBoxOpenFcnStr(this)

            tclCmdFileName=this.getTclCmdFcnName;
            codegenDir=this.getCodeGenDir;
            matlabCosimCmd=this.getCosimLaunchCmd;

            if strcmp(matlabCosimCmd,'CUSTOM_LAUNCHER')
                str=this.getCustomCosimLaunchCmd;
            else
                str=sprintf(['try\n',...
                '   cosimDirName = pwd;\n',...
                '   cd ''%s'';\n',...
                '   %s(''tclstart'',%s);\n',...
                '   cd (cosimDirName);\n',...
                '   clear cosimDirName;\n',...
                'catch me\n',...
                '   disp(''Failed to launch cosimulator with "%s"'');\n',...
                '   disp (me.message);\n',...
                '   cd (cosimDirName);\n',...
                '   clear cosimDirName;\n',...
                'end'],codegenDir,matlabCosimCmd,tclCmdFileName,matlabCosimCmd);
            end
        end


        function addLaunchSimulatorBox(this)
            ssName=this.getStartSimSSName;
            newSSName=this.addBlockUnique('built-in/Subsystem',ssName);
            this.simStartSSName=newSSName;
            set_param(newSSName,'Position',[22,15,253,56]);
            o=get_param(newSSName,'object');


            o.MaskDisplay=this.getLaunchBoxDisplayStr;


            o.OpenFcn=this.getLaunchBoxOpenFcnStr;
            o.BackgroundColor='cyan';
        end


        function newPos=getLinkBlockPos(this)
            srcDutPath=this.getTBDutPath;
            oldPos=get_param(srcDutPath,'Position');
            srcMdl=this.getTBModelName;
            srcMdlObj=get_param(srcMdl,'object');


            blks=srcMdlObj.Blocks;
            blks=strrep(blks,'/','//');


            blkBot={};
            for ii=1:length(blks)
                blkPath=[srcMdl,'/',blks{ii}];%#ok<*AGROW>
                p=get_param(blkPath,'Position');
                blkBot{end+1}=p(4);
            end
            maxDepth=max([blkBot{:}]);


            numExtraPorts=this.getNumExtraPortsOnCosimBlk;
            if numExtraPorts>0

                scaleHeight=numExtraPorts*0.05;
            else
                scaleHeight=0;
            end

            oldHeight=oldPos(4)-oldPos(2);
            blkHeight=floor(oldHeight+oldHeight*scaleHeight);
            newTop=maxDepth+50;
            newPos=[oldPos(1),newTop,oldPos(3),newTop+blkHeight];
        end


        function addLaunchBox(this)

            this.createTCLFile;

            this.addLaunchSimulatorBox;
        end


        function addEnableAssertionsBlock(this)
            enableAssertionBoxName=[this.getCosimSinkSSName,'/Enable'];
            add_block('built-in/Subsystem',enableAssertionBoxName);
            set_param(enableAssertionBoxName,'ShowName','off')
            set_param(enableAssertionBoxName,'Position',[297,15,505,52]);

            obj=get_param(enableAssertionBoxName,'object');
            obj.MaskDisplay='fprintf(message(''hdlcoder:cosim:vnl_dblclick_assertions'',''OFF'').getString());';
            fcnStr=sprintf(...
            ['blkName = gcb;\n',...
            'idx = regexp(blkName, ''/Enable$'', ''once'');\n',...
            'blkParent = blkName(1:idx-1);\n',...
            'blks=find_system(blkParent, ''LookUnderMasks'', ''all'',''blocktype'', ''Assertion'');\n',...
            'e = get_param(blks{1}, ''Enabled'');\n',...
            'if strcmp(e, ''on''), f= ''off'';, else, f = ''on'';, end\n',...
            'for ii=1:length(blks), set_param(blks{ii}, ''Enabled'', f);, end\n',...
'set_param(gcb, ''MaskDisplay'','...
            ,'[''fprintf(message(''''hdlcoder:cosim:vnl_dblclick_assertions'''','','''''''',upper(e),'''''''','').getString())'']);\n']);
            obj.OpenFcn=fcnStr;
        end


        function addCleanupScopesBlock(this)
            compareSSPath=this.getCosimSinkSSName;
            boxName=[compareSSPath,'/','CleanupScopes'];
            add_block('built-in/Subsystem',boxName);
            set_param(boxName,'ShowName','off')
            set_param(boxName,'Position',[297,55,505,97]);
            scopeStr='Scope';

            obj=get_param(boxName,'object');
            obj.MaskDisplay='fprintf(message(''hdlcoder:cosim:vnl_dblclick'').getString());';
            fcnStr=sprintf(...
            ['blkName = gcb; %%self block\n',...
            'idx = regexp(blkName, ''/CleanupScopes$'', ''once'');\n',...
            'blkParent = blkName(1:idx-1);\n',...
            'blks=find_system(blkParent, ''LookUnderMasks'', ''all'',''blocktype'', ''%s'');\n',...
            'for itr = 1:length(blks)\n',...
            '\t hScopeCfg = get_param(blks{itr},''ScopeConfiguration'');\n',...
            '\t hScopeCfg.Visible = ~ hScopeCfg.Visible;\n',...
            'end\n',...
            'drawnow;\n'],scopeStr);

            obj.OpenFcn=fcnStr;
        end




        function[newPos,newO]=getToCosimSrcPosition(this)
            cosimMdlDutPath=this.getCosimDutPath;

            pos=get_param(cosimMdlDutPath,'Position');
            o=get_param(cosimMdlDutPath,'Orientation');

            if strcmpi(o,'right')
                newPos=[pos(1)-30,pos(2),pos(1)-20,pos(4)];
            elseif strcmpi(o,'left')
                newPos=[pos(3)+20,pos(2),pos(3)+30,pos(4)];
                newOri='left';
            elseif strcmpi(o,'down')
                newPos=[pos(1),pos(2)-30,pos(3),pos(2)-20];
            else
                newPos=[pos(1),pos(4)+20,pos(3),pos(4)+30];
            end

            newO=o;
        end


        function[newPos,newO]=getToCosimSinkPosition(this)
            cosimMdlDutPath=this.getCosimDutPath;

            pos=get_param(cosimMdlDutPath,'Position');
            o=get_param(cosimMdlDutPath,'Orientation');

            if strcmpi(o,'right')
                newPos=[pos(3)+20,pos(2),pos(3)+30,pos(4)];
            elseif strcmpi(o,'left')
                newPos=[pos(1)-30,pos(2),pos(1)-20,pos(4)];
            elseif strcmpi(o,'down')
                newPos=[pos(1),pos(4)+20,pos(3),pos(4)+30];
            else
                newPos=[pos(1),pos(2)-30,pos(3),pos(2)-20];
            end

            newO=o;
        end


        function configureLinkBlockInParallel(this)
            tbSys=this.getTestbenchSystem;
            cosimMdlDutPath=this.getCosimDutPath;
            cosimMdlDutH=get_param(cosimMdlDutPath,'handle');
            if this.hSLHDLCoder.DUTMdlRefHandle>0



                variants=get_param(this.hSLHDLCoder.DUTMdlRefHandle,'Variants');







                if strcmp(variants(1).Name,'HDLC_internal_variant_OriginalDUT')
                    bName2=variants(2).BlockName;
                else
                    bName2=variants(1).BlockName;
                end
                gmModel=get_param(bName2,'ModelName');

                save_system(gmModel,[],'OverWriteIfChangedOnDisk',true);
                cosimMdlNewDutH=add_block(bName2,cosimMdlDutPath,'MakeNameUnique','on');

                set_param(cosimMdlNewDutH,'LoadFcn','');

            end




            [di,do]=this.getDutSrcAndSinkPorts(cosimMdlDutH);





            [ips,ops]=this.getDutDrvSrcAndRcvSinkPorts(cosimMdlDutPath);


            testpointPortSinkBlocks=this.collectTestpointSinks(cosimMdlDutPath);
            dutHasTestpointOutputs=getDutHasTestpointsPresent(this);


            this.disconnectDut(cosimMdlDutPath);


            if this.hSLHDLCoder.DUTMdlRefHandle>0


                pos=get_param(cosimMdlDutH,'Position');
                dutname=get_param(cosimMdlDutH,'Name');
                delete_block(cosimMdlDutH);
                cosimMdlDutH=cosimMdlNewDutH;
                set_param(cosimMdlDutH,'Position',pos);
                set_param(cosimMdlDutH,'Name',dutname);
            end


            ops=this.removeTestpointSinks(testpointPortSinkBlocks,ops);



            dutHasInputs=this.getDutHasInputs;
            dutHasOutputs=this.getDutHasOutputs;

            dutHasTunableInputs=this.getDutHasTunableInputs;
            if dutHasTunableInputs
                error(message('hdlcoder:cosim:edacosimtunable'));
            end



            if dutHasInputs
                [newissPos,newissO]=this.getToCosimSrcPosition;
                numInPorts=this.getDutNumIn;
                this.addFromDutToCosimSS(true,newissPos,newissO,numInPorts);

                cosimISSName=this.stripTBSubsystemPath(this.getDutSrcCaptureSSName);

                for ii=1:length(di)
                    add_line(tbSys,[cosimISSName,'/',int2str(ii)],di{ii},'Autorouting','on');
                end
            end

            if dutHasOutputs

                [newossPos,newossO]=this.getToCosimSinkPosition;
                numOutPorts=this.getDutNumOutWithNoTestpoints;
                this.addFromDutToCosimSS(false,newossPos,newossO,numOutPorts);

                cosimOSSName=this.stripTBSubsystemPath(this.getDutSinkCaptureSSName);

                for ii=1:numOutPorts
                    add_line(tbSys,do{ii},[cosimOSSName,'/',int2str(ii)],'Autorouting','on');
                end
            end

            dutPrefix=[this.getCosimDutName,'/'];
            dutPrefixLen=numel(dutPrefix);
            if dutHasInputs



                for ii=1:length(ips)
                    dutSrc=ips{ii};
                    if strncmp(dutSrc,dutPrefix,dutPrefixLen)
                        dutSrc=strrep(dutSrc,dutPrefix,[cosimOSSName,'/']);
                    end
                    cosimInPort=[cosimISSName,'/',int2str(ii)];
                    add_line(tbSys,dutSrc,cosimInPort,'Autorouting','on');
                end
            end

            if dutHasOutputs

                for ii=1:length(ops)
                    dutSink=ops{ii};
                    for jj=1:length(dutSink)
                        cosimOutPort=[cosimOSSName,'/',int2str(ii)];



                        if~strncmp(dutSink{jj},dutPrefix,dutPrefixLen)
                            add_line(tbSys,cosimOutPort,dutSink{jj},'Autorouting','on');
                        end
                    end
                end
            end

            if dutHasTestpointOutputs
                dutTPHandles=getTestptSrcHandles(this,cosimMdlDutH);
                for ii=1:length(dutTPHandles)
                    tpPort=dutTPHandles(ii);
                    this.addAndConnectToTestpointTerminator(tpPort)
                end
            end




            this.createLinkBlock;
            cosimblkPath=this.getCosimLinkDutPath;
            newPos=this.getLinkBlockPos;
            set_param(cosimblkPath,'Position',newPos);

            linkPos=get_param(cosimblkPath,'Position');
            linkblkH=get_param(cosimblkPath,'handle');
            [linkBlkDi,linkBlkDo]=this.getlinkDutSrcAndSinkPorts(linkblkH);


            if dutHasInputs
                newissPos=[linkPos(1)-40,linkPos(2),linkPos(1)-30,linkPos(4)];
                this.addCosimSrcSS(tbSys,cosimblkPath,newissPos,linkBlkDi);
            end



            if dutHasOutputs
                newossPos=[linkPos(3)+30,linkPos(2),linkPos(3)+40,linkPos(4)];
                this.addCosimSinkSS(tbSys,cosimblkPath,newossPos,linkBlkDo);
            end






            [~,mdlBlks]=find_mdlrefs(this.getCosimModelName,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
            if~isempty(mdlBlks)
                note=Simulink.Annotation([this.getCosimModelName,'/',message('hdlcoder:cosim:modelrefload').getString]);
                note.position=[newPos(1)-200,newPos(4)+40];
                note.BackgroundColor='yellow';
            end
        end



        function addAndConnectToTestpointTerminator(this,tpPort)
            tpParent=get_param(tpPort,'Parent');
            tpPortPos=get_param(tpPort,'Position');
            tpTermPos=[tpPortPos(1)+350,tpPortPos(2)-10,tpPortPos(1)+380,tpPortPos(2)+20];
            tbenchSys=this.getTestbenchSystem;
            tpTermName=[tbenchSys,'/','tpTerminator'];
            newTPTerm=this.addBlockUnique('simulink/Sinks/Terminator',tpTermName);
            set_param(newTPTerm,'Position',tpTermPos);
            srcPortIndex=get_param(tpPort,'PortNumber');
            srcPortParent=get_param(tpPort,'Parent');
            add_line(tbenchSys,[this.getTBDutName,'/',int2str(srcPortIndex)],[get_param(newTPTerm,'Name'),'/1'],'Autorouting','on');
        end



        function addFromDutToCosimSS(this,capturingInputs,newSSPos,...
            newSSO,numPorts)
            if capturingInputs
                ssPath=this.getDutSrcCaptureSSName;
                newssPath=this.addBlockUnique('built-in/Subsystem',ssPath);
                this.dutSrcCaptureSSName=newssPath;
                gotoName='in';
            else
                ssPath=this.getDutSinkCaptureSSName;
                newssPath=this.addBlockUnique('built-in/Subsystem',ssPath);
                this.dutSinkCaptureSSName=newssPath;
                gotoName='out';
            end

            set_param(newssPath,'Orientation',newSSO);
            set_param(newssPath,'Position',newSSPos);
            set_param(newssPath,'MaskDisplay','disp('''')');
            set_param(newssPath,'BackgroundColor','cyan');

            ipos=[100,48,130,62];
            for ii=1:numPorts
                ssinportblk=[newssPath,'/','in',int2str(ii)];%#ok<*AGROW>
                newPos=ipos+[0,ii*60,0,ii*60];
                add_block('built-in/Inport',ssinportblk,'Position',newPos);
            end

            hN=this.getTopNetwork;
            curInPort=1;
            ops=[335,48,365,62];
            for ii=1:numPorts
                iiStr=int2str(ii);
                ssoutportblk=[newssPath,'/','out',iiStr];
                newPos=ops+[0,ii*60,0,ii*60];
                add_block('built-in/Outport',ssoutportblk,'Position',newPos);
                add_line(newssPath,['in',iiStr,'/1'],['out',iiStr,'/1'],...
                'Autorouting','on');


                isOutportTP=0;
                if~capturingInputs
                    isOutportTP=isDutOutportTestpoint(this,curInPort);
                end
                if~isOutportTP
                    gotoblock=[newssPath,'/','goto',iiStr];
                    gPos=newPos+[0,30,0,30];
                    add_block('built-in/Goto',gotoblock,'Position',gPos,...
                    'GotoTag',[gotoName,iiStr],'TagVisibility','global');
                end

                if capturingInputs&&this.isDutInportUnscalarizedOneBitVector(curInPort)


                    newBlk=['fixbitv',iiStr];
                    onebitfixblk=[newssPath,'/',newBlk];
                    fPos=newPos+[-50,30,-50,30];
                    vlen=this.getVectorLenAtInputPort(curInPort);
                    add_block('built-in/Selector',onebitfixblk,'Position',fPos,...
                    'Indices',sprintf('[%d:-1:1]',vlen));
                    add_line(newssPath,['in',iiStr,'/1'],[newBlk,'/1'],...
                    'Autorouting','on');
                    add_line(newssPath,[newBlk,'/1'],['goto',iiStr,'/1'],...
                    'Autorouting','on');
                elseif~capturingInputs&&~isOutportTP&&...
                    this.isDutOutportUnscalarizedOneBitVector(curInPort)

                    newBlk=['fixbitv',iiStr];
                    onebitfixblk=[newssPath,'/',newBlk];
                    fPos=newPos+[-50,30,-50,30];
                    vlen=this.getVectorLenAtOutputPort(curInPort);
                    add_block('built-in/Selector',onebitfixblk,'Position',fPos,...
                    'Indices',sprintf('[%d:-1:1]',vlen));
                    add_line(newssPath,['in',iiStr,'/1'],[newBlk,'/1'],...
                    'Autorouting','on');
                    add_line(newssPath,[newBlk,'/1'],['goto',iiStr,'/1'],...
                    'Autorouting','on');
                elseif~isOutportTP
                    add_line(newssPath,['in',iiStr,'/1'],['goto',iiStr,'/1'],...
                    'Autorouting','on');
                end

                if capturingInputs
                    rT=hN.getDUTOrigInputRecordPortType(ii-1);
                elseif isOutportTP
                    curInPort=curInPort+1;
                    continue;
                else
                    rT=hN.getDUTOrigOutputRecordPortType(ii-1);
                end
                if rT.isRecordType
                    curInPort=curInPort+rT.NumberOfMembersFlattened;
                elseif rT.isArrayOfRecords
                    numVectorPorts=rT.Dimensions;
                    baserT=rT.BaseType;
                    curInPort=curInPort+(baserT.NumberOfMembersFlattened*numVectorPorts);
                else
                    curInPort=curInPort+1;
                end
            end
        end


        function[busSel,numElems]=createBusSelector(this,ssPath,recType,pos)
            numElems=recType.NumberOfMembersFlattened;
            busOutNames='';
            for jj=1:numElems
                if(jj~=numElems)
                    comma=',';
                else
                    comma='';
                end
                busOutNames=sprintf('%s%s%s',busOutNames,...
                recType.MemberNamesFlattened{jj},comma);
            end

            busSel=this.addBlockUnique('built-in/BusSelector',...
            [ssPath,'/BusSel']);
            set_param(busSel,'Position',pos);
            set_param(busSel,'OutputSignals',busOutNames);
        end


        function addCosimSrcSS(this,cosimMdlName,cosimBlkFP,newSSPos,linkBlkDi)
            ssPath=this.getCosimSrcSSName;
            newssPath=this.addBlockUnique('built-in/Subsystem',ssPath);
            set_param(newssPath,'Position',newSSPos);
            ori=get_param(cosimBlkFP,'Orientation');
            set_param(newssPath,'Orientation',ori);
            set_param(newssPath,'MaskDisplay','disp('''')');
            set_param(newssPath,'BackgroundColor','cyan');

            this.cosimSrcSSName=newssPath;
            dutNumIn=this.getDutNumIn;
            basePos=[100,48,130,62];
            ipos=basePos;

            hN=this.getTopNetwork;


            srcPortSet={};
            srcPortType={};
            for ii=1:dutNumIn
                iiStr=int2str(ii);
                blkName=['from',iiStr];
                blkPath=[newssPath,'/',blkName];
                add_block('built-in/From',blkPath,'Position',ipos);

                vlen=this.getVectorLenAtInputPort(ii);
                if vlen>1
                    blkDist=60+5*double(vlen);
                else
                    blkDist=60;
                end

                set_param(blkPath,'GotoTag',['in',iiStr]);
                rT=hN.getDUTOrigInputRecordPortType(ii-1);
                if rT.isRecordType
                    numElems=rT.NumberOfMembersFlattened;
                    fpos=[ipos(1)+60,ipos(2)-10*numElems,ipos(1)+65,ipos(2)+10*numElems];
                    busSel=this.createBusSelector(newssPath,rT,fpos);
                    busSelName=get_param(busSel,'Name');
                    add_line(newssPath,[blkName,'/1'],...
                    [busSelName,'/1'],'Autorouting','on');
                    for jj=1:numElems
                        srcPortSet{end+1}=[busSelName,'/',int2str(jj)];
                        srcPortType{end+1}=rT.MemberTypesFlattened(jj);
                        ipos=ipos+[0,blkDist,0,blkDist];
                    end
                elseif rT.isArrayOfRecords
                    numVectorPorts=rT.Dimensions;
                    for jj=1:numVectorPorts



                        selBlock=this.addBlockUnique('built-in/Selector',...
                        [newssPath,'/VectorSel']);

                        set_param(selBlock,'Indices',int2str(jj));
                        selBlockName=get_param(selBlock,'Name');
                        add_line(newssPath,[blkName,'/1'],...
                        [selBlockName,'/1'],'Autorouting','on');

                        baserT=rT.BaseType;
                        numElems=baserT.NumberOfMembersFlattened;

                        fpos=[ipos(1)+160,ipos(2)-10*numElems,ipos(1)+165,ipos(2)+10*numElems];
                        busSel=this.createBusSelector(newssPath,baserT,fpos);


                        selpos=fpos-[100,0,50,0];
                        selpos=selpos+[0,2,0,2];
                        set_param(selBlock,'Position',selpos);

                        busSelName=get_param(busSel,'Name');
                        add_line(newssPath,[selBlockName,'/1'],...
                        [busSelName,'/1'],'Autorouting','on');

                        for kk=1:numElems
                            srcPortSet{end+1}=[busSelName,'/',int2str(kk)];
                            srcPortType{end+1}=baserT.MemberTypesFlattened(kk);
                            ipos=ipos+[0,blkDist,0,blkDist];
                        end
                    end
                else
                    srcPortSet{end+1}=[blkName,'/1'];
                    srcPortType{end+1}=rT;
                    ipos=ipos+[0,blkDist,0,blkDist];
                end
            end





            dtcCtr=1;
            for ii=1:numel(srcPortSet)
                hT=srcPortType{ii}.getLeafType;
                if hT.isFloatType()
                    fpos=basePos+[120,(ii-1)*60,120,(ii-1)*60];

                    blkName=['dtc',int2str(dtcCtr)];
                    blk=add_block('built-in/DataTypeConversion',...
                    [newssPath,'/',blkName],'Position',fpos);

                    if hT.isDoubleType
                        typeStr='double';
                    elseif hT.isSingleType
                        typeStr='single';
                    elseif hT.isHalfType
                        typeStr='half';
                    end

                    set_param(blk,'OutDataTypeStr',typeStr);

                    blkPort=[blkName,'/1'];
                    add_line(newssPath,srcPortSet{ii},blkPort,'Autorouting','on');
                    srcPortSet{ii}=blkPort;
                    dtcCtr=dtcCtr+1;
                end
            end




            c2reCtr=1;
            for ii=numel(srcPortSet):-1:1
                hT=srcPortType{ii};
                tInfo=pirgetdatatypeinfo(hT);
                if tInfo.iscomplex

                    fpos=basePos+[180,(ii-1)*60,180,(ii-1)*60];

                    blkName=['c2re',int2str(c2reCtr)];
                    add_block('built-in/ComplexToRealImag',...
                    [newssPath,'/',blkName],'Position',fpos);
                    blkPort=[blkName,'/1'];
                    add_line(newssPath,srcPortSet{ii},blkPort,'Autorouting','on');


                    srcPortSet{ii}=blkPort;
                    blkPort=[blkName,'/2'];
                    srcPortSet=[srcPortSet(1:ii),blkPort,srcPortSet(ii+1:end)];
                    srcPortType=[srcPortType(1:ii),srcPortType(ii),srcPortType(ii+1:end)];
                    c2reCtr=c2reCtr+1;
                end
            end



            demuxblocks={};
            demuxCtr=1;
            scalarizedPorts=this.isScalarizedVectorPorts;
            for ii=numel(srcPortSet):-1:1
                hT=srcPortType{ii};
                tInfo=pirgetdatatypeinfo(hT);
                if scalarizedPorts&&tInfo.isvector
                    fpos=basePos+[240,(ii-1)*60,240,(ii-1)*60];

                    blkName=['demux',int2str(demuxCtr)];
                    demuxBlk=[newssPath,'/',blkName];
                    add_block('built-in/Demux',demuxBlk,'Position',fpos);
                    numVectorPorts=max(hT.getDimensions);
                    set_param(demuxBlk,'Outputs',int2str(numVectorPorts));
                    blkPort=[blkName,'/1'];
                    add_line(newssPath,srcPortSet{ii},blkPort,'Autorouting','on');
                    demuxblocks{end+1}=demuxBlk;


                    srcPortSet{ii}=blkPort;
                    for jj=2:numVectorPorts
                        blkPort=[blkName,'/',int2str(jj)];
                        idx=ii+jj-2;
                        srcPortSet=[srcPortSet(1:idx),blkPort,srcPortSet(idx+1:end)];
                        srcPortType=[srcPortType(1:idx),srcPortType(ii),srcPortType(idx+1:end)];
                    end

                    demuxCtr=demuxCtr+1;
                end
            end

            ops=basePos+[360,0,360,0];
            totalInPorts=numel(srcPortSet);
            baseDst=60;
            availSpace=32767-ops(2);
            if(totalInPorts*baseDst)>availSpace
                baseDst=floor(availSpace/totalInPorts);
            end

            for ii=1:totalInPorts
                blkName=['out',int2str(ii)];
                opblk=[newssPath,'/',blkName];
                add_block('built-in/Outport',opblk,'Position',ops);
                ops=ops+[0,baseDst,0,baseDst];
                add_line(newssPath,srcPortSet{ii},[blkName,'/1'],'Autorouting','on');
            end

            set_param(newssPath,'Position',newSSPos);
            cosimIOSSName=this.stripTBSubsystemPath(newssPath);
            for ii=1:length(linkBlkDi)
                add_line(cosimMdlName,[cosimIOSSName,'/',int2str(ii)],linkBlkDi{ii});
            end
        end





        function fixBlkP1=insertSigSpecBlock(this,ii,newssPath,opos,inCtr)
            fixBlk=sprintf('fixbitv%d_%d',ii,inCtr);
            onebitfixblk=[newssPath,'/',fixBlk];
            fPos=opos+[50,-6,70,2];
            add_block('built-in/SignalSpecification',onebitfixblk,'Position',fPos);

            set_param(onebitfixblk,'OutDataTypeStr','fixdt(0,1,0)');
            vlen=this.getVectorLenAtOutputPort(ii);
            set_param(onebitfixblk,'Dimensions',int2str(vlen));

            inPort=['in',int2str(inCtr),'/1'];
            fixBlkP1=[fixBlk,'/1'];
            add_line(newssPath,inPort,fixBlkP1);
        end





        function shouldOpen=shouldScopeBeOpened(~,hT)
            shouldOpen=logical(~(hT.isArrayType&&hT.Dimensions>300));
        end


        function addCosimSinkSS(this,cosimMdlName,cosimBlkFP,newSSPos,linkBlkDo)
            ssPath=this.getCosimSinkSSName;
            newssPath=this.addBlockUnique('built-in/Subsystem',ssPath);
            set_param(newssPath,'Position',newSSPos);
            ori=get_param(cosimBlkFP,'Orientation');
            set_param(newssPath,'Orientation',ori);
            set_param(newssPath,'MaskDisplay','disp('''')');
            set_param(newssPath,'BackgroundColor','cyan');
            this.cosimSinkSSName=newssPath;



            hN=this.getTopNetwork;
            dutNumOut=this.getDutNumOutWithNoTestpoints;
            dno=dutNumOut;
            for ii=1:dno
                hT=hN.getDUTOrigOutputRecordPortType(ii-1);
                if hT.isRecordType
                    dutNumOut=dutNumOut+hT.NumberOfMembersFlattened-1;
                elseif hT.isArrayOfRecords
                    numVectorPorts=hT.Dimensions;
                    basehT=hT.BaseType;
                    dutNumOut=dutNumOut+(basehT.NumberOfMembersFlattened*numVectorPorts)-1;
                end
            end

            this.NumFlattenedDUTOutputs=dutNumOut;

            basePos=[100,128,130,142];
            ipos=basePos;

            vecSz=length(linkBlkDo);
            if vecSz>500
                blkDist=floor((32767-(2*basePos(1)))/vecSz);
            else
                blkDist=60;
            end


            ssinportblks=cell(1,vecSz);
            srcPortSet=cell(1,vecSz);
            srcPortType={};

            cosimIOSSName=this.stripTBSubsystemPath(this.getCosimSinkSSName);
            for ii=1:vecSz
                blkName=sprintf('in%d',ii);
                ssinportblks{ii}=sprintf('%s/%s',newssPath,blkName);
                srcPortSet{ii}=[blkName,'/1'];
                add_block('built-in/Inport',ssinportblks{ii},'Position',ipos);
                ipos=ipos+[0,blkDist,0,blkDist];
                add_line(cosimMdlName,linkBlkDo{ii},sprintf('%s/%d',cosimIOSSName,ii));
            end
            set_param(newssPath,'Position',newSSPos);


            muxblocks={};
            muxCtr=1;
            curInPort=numel(srcPortSet);
            baseDst=60;
            availSpace=32767-basePos(2);
            if(curInPort*baseDst)>availSpace
                baseDst=floor(availSpace/curInPort);
            end

            for ii=dutNumOut:-1:1
                if this.isDutOutportScalarizedVector(ii)

                    if this.isDutOutportAtIdxComplex(ii)
                        numMux=2;
                    else
                        numMux=1;
                    end

                    for jj=numMux:-1:1
                        blkName=['mux',int2str(muxCtr)];
                        newBlk=[newssPath,'/',blkName];
                        fpos=basePos+[120,(curInPort-1)*baseDst,120,(curInPort-1)*baseDst];
                        add_block('built-in/Mux',newBlk,'Position',fpos);

                        numVectorPorts=this.getVectorLenAtOutputPort(ii);
                        set_param(newBlk,'Inputs',int2str(numVectorPorts));
                        for kk=numVectorPorts:-1:1
                            add_line(newssPath,srcPortSet{curInPort},...
                            [blkName,'/',int2str(kk)]);
                            curInPort=curInPort-1;
                        end
                        srcPortSet=[srcPortSet(1:curInPort),[blkName,'/1']...
                        ,srcPortSet((curInPort+numVectorPorts+1):end)];

                        muxblocks{end+1}=newBlk;
                        muxCtr=muxCtr+1;
                    end

                else
                    if this.isDutOutportAtIdxComplex(ii)
                        curInPort=curInPort-2;
                    else
                        curInPort=curInPort-1;
                    end
                end
            end



            curInPort=1;
            for ii=1:dutNumOut
                hasRe2cBlock=this.isDutOutportAtIdxComplex(ii);
                hasMuxBlock=this.isDutOutportScalarizedVector(ii);
                needSigSpecBlock=this.isDutOutportUnscalarizedOneBitVector(ii);
                if~hasMuxBlock&&needSigSpecBlock
                    matchingidx=this.getActualPirOutPortBeginIdx(ii);
                    matchingblk=ssinportblks{matchingidx};
                    sspos=get_param(matchingblk,'Position');
                    inPort=this.insertSigSpecBlock(ii,newssPath,...
                    sspos,curInPort);
                    srcPortSet{curInPort}=inPort;
                    curInPort=curInPort+1;
                    if hasRe2cBlock
                        matchingidx=this.getActualPirOutPortBeginIdx(ii);
                        matchingblk=ssinportblks{matchingidx};
                        sspos=get_param(matchingblk,'Position')+[0,60,0,60];
                        inPort=this.insertSigSpecBlock(ii,newssPath,...
                        sspos,curInPort);
                        srcPortSet{curInPort}=inPort;
                        curInPort=curInPort+1;
                    end
                else
                    if hasRe2cBlock
                        curInPort=curInPort+2;
                    else
                        curInPort=curInPort+1;
                    end
                end
            end




            re2cCtr=1;
            curInPort=numel(srcPortSet);
            for ii=dutNumOut:-1:1
                if this.isDutOutportAtIdxComplex(ii)

                    blkName=['re2c',int2str(re2cCtr)];
                    newBlk=[newssPath,'/',blkName];
                    matchingidx=this.getActualPirOutPortBeginIdx(ii);
                    matchingblk=ssinportblks{matchingidx};
                    fpos=get_param(matchingblk,'Position')+[180,0,180,4];
                    add_block('built-in/RealImagToComplex',newBlk,...
                    'Position',fpos);
                    for kk=2:-1:1
                        add_line(newssPath,srcPortSet{curInPort},...
                        [blkName,'/',int2str(kk)]);
                        curInPort=curInPort-1;
                    end
                    srcPortSet=[srcPortSet(1:curInPort),[blkName,'/1']...
                    ,srcPortSet((curInPort+3):end)];

                    re2cCtr=re2cCtr+1;
                else
                    curInPort=curInPort-1;
                end
            end




            fromPorts=cell(1,dutNumOut);
            curInPort=1;
            for ii=1:this.getDutNumOutWithNoTestpoints
                isTP=isDutOutportTestpoint(this,ii);
                if isTP
                    continue;
                end
                iiStr=int2str(ii);
                blkName=['from',iiStr];
                newBlk=[newssPath,'/',blkName];
                matchingidx=this.getActualPirOutPortBeginIdx(ii);
                matchingblk=ssinportblks{matchingidx};
                opos=get_param(matchingblk,'Position');
                fpos=opos+[240,15,240,15];

                add_block('built-in/From',newBlk,'Position',fpos,...
                'GotoTag',['out',iiStr],'TagVisibility','global');
                fromPorts{curInPort}=[blkName,'/1'];


                rT=hN.getDUTOrigOutputRecordPortType(ii-1);
                if rT.isRecordType
                    numEl=rT.NumberOfMembersFlattened;
                    fpos=opos+[300,0,275,numEl*15];
                    busSel=this.createBusSelector(newssPath,rT,fpos);
                    busPort=[get_param(busSel,'Name'),'/1'];
                    add_line(newssPath,fromPorts{curInPort},busPort);


                    for jj=1:numEl
                        fromPorts{curInPort}=[get_param(busSel,'Name'),'/',int2str(jj)];
                        curInPort=curInPort+1;
                    end
                elseif rT.isArrayOfRecords
                    numVectorPorts=rT.Dimensions;
                    basecurInPort=fromPorts{curInPort};
                    for kk=1:numVectorPorts
                        selBlock=this.addBlockUnique('built-in/Selector',...
                        [newssPath,'/VectorSel']);
                        set_param(selBlock,'Indices',int2str(kk));
                        selBlockName=get_param(selBlock,'Name');
                        add_line(newssPath,basecurInPort,...
                        [selBlockName,'/1'],'Autorouting','on');

                        baserT=rT.BaseType;
                        numEl=baserT.NumberOfMembersFlattened;
                        fpos=opos+[400,0,375,numEl*15];
                        fpos=fpos+[0,double(kk-1)*200,0,double(kk-1)*200];

                        selpos=fpos-[100,0,50,0];
                        selpos=selpos+[0,2,0,2];
                        set_param(selBlock,'Position',selpos);

                        busSel=this.createBusSelector(newssPath,baserT,fpos);
                        busPort=[get_param(busSel,'Name'),'/1'];
                        add_line(newssPath,[selBlockName,'/1'],busPort,'Autorouting','on');
                        for jj=1:numEl
                            fromPorts{curInPort}=[get_param(busSel,'Name'),'/',int2str(jj)];
                            curInPort=curInPort+1;
                        end
                    end
                else
                    curInPort=curInPort+1;
                end
            end





            idcLen=this.getIgnoreDataCheckingLen;
            assertblocks={};
            curInPort=1;




            function[blk,isActiveFloat,isComplex,hasIDC]=l_getComparatorInfo(this,baseT)
                tInfo=pirgetdatatypeinfo(baseT);

                isActiveFloat=baseT.isFloatType&&this.isFloatingPointMode;
                isHalf=tInfo.ishalf;
                isComplex=tInfo.iscomplex;
                hasIDC=(this.getIgnoreDataCheckingLen>0);
                usesULP=(this.getFPToleranceStrategy>1);

                blk='hdlmdlgenlib/Assert';
                if isActiveFloat
                    if isHalf,blk=[blk,'Half'];end

                    if usesULP,blk=[blk,'ULP'];
                    else,blk=[blk,'Rel'];
                    end
                end
                blk=[blk,'Eq'];

                if isComplex,blk=[blk,'Complex'];end
                if hasIDC,blk=[blk,'IDC'];end
            end

            for ii=1:this.getDutNumOutWithNoTestpoints
                opName=this.getDutOriginalOutportNameAtIdx(ii);

                rT=hN.getDUTOrigOutputRecordPortType(ii-1);
                if rT.isRecordType
                    baseName=['Assert_',opName];
                    numEl=rT.NumberOfMembersFlattened;
                    for jj=1:numEl
                        assertblocks{end+1}=[baseName,'_',rT.MemberNamesFlattened{jj}];
                        newBlk=[newssPath,'/',assertblocks{end}];
                        hT=rT.MemberTypesFlattened(jj);
                        [blkName,isActiveFloat,outPortComplex,needIdcLogic]=l_getComparatorInfo(this,hT);

                        opos=get_param([newssPath,'/',strtok(fromPorts{curInPort},'/')],'Position');
                        fpos=opos+[60,-8+(jj-1)*60,85,-17+(jj-1)*60];
                        add_block(blkName,newBlk,'Position',fpos);
                        set_param(newBlk,'linkStatus','none');
                        if isActiveFloat
                            set_param(newBlk,'ToleranceValue',this.getFPToleranceValue);
                        end
                        add_line(newssPath,srcPortSet{curInPort},[assertblocks{end},'/1']);
                        add_line(newssPath,fromPorts{curInPort},[assertblocks{end},'/2']);
                        curInPort=curInPort+1;

                        if outPortComplex
                            scopePath=[newBlk,'/Scope_re'];
                            scopeName=['compare_re: ',opName];
                            set_param(scopePath,'Name',scopeName);
                            this.openScope(scopeName)=this.shouldScopeBeOpened(rT);
                            scopePath=[newBlk,'/Scope_im'];
                            scopeName=['compare_im: ',opName];
                            set_param(scopePath,'Name',scopeName);
                            this.openScope(scopeName)=this.shouldScopeBeOpened(rT);
                        else
                            scopePath=[newBlk,'/Scope'];
                            scopeName=['compare: ',opName];
                            set_param(scopePath,'Name',scopeName);
                            this.openScope(scopeName)=this.shouldScopeBeOpened(rT);
                        end

                        if needIdcLogic
                            idcBlk=[newBlk,'/IgnoreCycles'];
                            set_param(idcBlk,'Value',int2str(idcLen));
                        end
                    end
                elseif rT.isArrayOfRecords
                    numVectorPorts=rT.Dimensions;
                    for ll=1:numVectorPorts
                        baserT=rT.BaseType;

                        baseName=['Assert_',opName];
                        numEl=baserT.NumberOfMembersFlattened;
                        for jj=1:numEl
                            assertblocks{end+1}=[baseName,'_',int2str(ll),'_',baserT.MemberNamesFlattened{jj}];
                            newBlk=[newssPath,'/',assertblocks{end}];
                            hT=baserT.MemberTypesFlattened(jj);
                            [blkName,isActiveFloat,outPortComplex,needIdcLogic]=l_getComparatorInfo(this,hT);
                            opos=get_param([newssPath,'/',strtok(fromPorts{curInPort},'/')],'Position');
                            fpos=opos+[60,-8+(jj-1)*60,85,-17+(jj-1)*60];
                            add_block(blkName,newBlk,'Position',fpos);
                            set_param(newBlk,'linkStatus','none');
                            if isActiveFloat
                                set_param(newBlk,'ToleranceValue',this.getFPToleranceValue);
                            end
                            add_line(newssPath,srcPortSet{curInPort},[assertblocks{end},'/1']);
                            add_line(newssPath,fromPorts{curInPort},[assertblocks{end},'/2']);
                            curInPort=curInPort+1;

                            if outPortComplex
                                scopePath=[newBlk,'/Scope_re'];
                                scopeName=['compare_re: ',opName];
                                set_param(scopePath,'Name',scopeName);
                                this.openScope(scopeName)=this.shouldScopeBeOpened(baserT);
                                scopePath=[newBlk,'/Scope_im'];
                                scopeName=['compare_im: ',opName];
                                set_param(scopePath,'Name',scopeName);
                                this.openScope(scopeName)=this.shouldScopeBeOpened(baserT);
                            else
                                scopePath=[newBlk,'/Scope'];
                                scopeName=['compare: ',opName];
                                set_param(scopePath,'Name',scopeName);
                                this.openScope(scopeName)=this.shouldScopeBeOpened(baserT);
                            end

                            if needIdcLogic
                                idcBlk=[newBlk,'/IgnoreCycles'];
                                set_param(idcBlk,'Value',int2str(idcLen));
                            end
                        end
                    end
                else
                    assertblocks{end+1}=['Assert_',opName];
                    newBlk=[newssPath,'/',assertblocks{end}];
                    baserT=rT.BaseType;
                    [blkName,isActiveFloat,outPortComplex,needIdcLogic]=l_getComparatorInfo(this,baserT);
                    opos=get_param([newssPath,'/',strtok(fromPorts{curInPort},'/')],'Position');
                    fpos=opos+[60,-18,60,3];
                    add_block(blkName,newBlk,'Position',fpos);
                    set_param(newBlk,'linkStatus','none');
                    if isActiveFloat
                        set_param(newBlk,'ToleranceValue',this.getFPToleranceValue);
                    end
                    add_line(newssPath,srcPortSet{curInPort},[assertblocks{end},'/1']);
                    add_line(newssPath,fromPorts{curInPort},[assertblocks{end},'/2']);
                    curInPort=curInPort+1;
                    if outPortComplex
                        scopePath=[newBlk,'/Scope_re'];
                        scopeName=['compare_re: ',opName];
                        set_param(scopePath,'Name',scopeName);
                        this.openScope(scopeName)=this.shouldScopeBeOpened(rT);
                        scopePath=[newBlk,'/Scope_im'];
                        scopeName=['compare_im: ',opName];
                        set_param(scopePath,'Name',scopeName);
                        this.openScope(scopeName)=this.shouldScopeBeOpened(rT);
                    else
                        scopePath=[newBlk,'/Scope'];
                        scopeName=['compare: ',opName];
                        set_param(scopePath,'Name',scopeName);
                        this.openScope(scopeName)=this.shouldScopeBeOpened(rT);
                    end

                    if needIdcLogic
                        idcBlk=[newBlk,'/IgnoreCycles'];
                        set_param(idcBlk,'Value',int2str(idcLen));
                    end



                    this.changeCosimLabelInBlock(newBlk);
                end
            end


            this.addEnableAssertionsBlock;

            if~this.haveTooManyScopes()
                this.addCleanupScopesBlock;
            end

        end


        function changeCosimLabelInBlock(~,~)

        end


        function blocks=collectTestpointSinks(~,cosimDutFP)
            cosimMdlDutH=get_param(cosimDutFP,'handle');
            phan=get_param(cosimDutFP,'PortHandles');
            pcon=get_param(cosimDutFP,'PortConnectivity');
            blocks=[];




            totalInports=length(phan.Inport);
            outportStartIndex=totalInports+1;
            for ii=outportStartIndex:length(pcon)
                phanIndex=ii-totalInports;
                oport=phan.Outport(phanIndex);
                isTP=get_param(oport,'Testpoint');
                if strcmp(isTP,'on')
                    dstBlk=pcon(ii).DstBlock;
                    blocks=[blocks,dstBlk];
                end
            end
            blocks=unique(blocks);
        end






        function ops=removeTestpointSinks(~,testpointPortSinkBlocks,ops)
            deletedBlockNames=cell(0,0);
            for ii=1:numel(testpointPortSinkBlocks)
                tpSinkName=get_param(testpointPortSinkBlocks(ii),'Name');
                delete_block(testpointPortSinkBlocks(ii));
                deletedBlockNames{end+1}=tpSinkName;
            end
            ind=[];
            for ii=1:numel(deletedBlockNames)
                blkName=deletedBlockNames(ii);
                for jj=1:numel(ops)
                    port=ops{jj};
                    portParent=strtok(port,'/');
                    if strcmp(blkName,portParent)
                        ind=[ind,jj];
                    end
                end
            end


            ops(ind)=[];
        end


        function disconnectDut(~,cosimDutFP)
            cosimMdlDutH=get_param(cosimDutFP,'handle');
            phan=get_param(cosimDutFP,'PortHandles');


            for ii=1:length(phan.Inport)
                p=get_param(phan.Inport(ii),'object');
                if(p.Line>0)
                    delete_line(p.Line);
                end
            end


            for ii=1:length(phan.Outport)
                p=get_param(phan.Outport(ii),'object');
                if(p.Line>0)
                    delete_line(p.Line);
                end
            end
        end


        function[di,do]=getDutSrcAndSinkPorts(this,cosimMdlDutH)
            ph=get_param(cosimMdlDutH,'PortHandles');
            dn=this.getSLName(cosimMdlDutH);
            di={};
            do={};
            for ii=1:length(ph.Inport)
                di{end+1}=[dn,'/',int2str(ii)];
            end
            for ii=1:length(ph.Outport)
                do{end+1}=[dn,'/',int2str(ii)];
            end
        end


        function[linkBlkDi,linkBlkDo]=getlinkDutSrcAndSinkPorts(this,cosimMdlDutH)
            ph=get_param(cosimMdlDutH,'PortHandles');
            dn=this.getSLName(cosimMdlDutH);
            linkBlkDi={};
            linkBlkDo={};
            for ii=1:length(ph.Inport)
                linkBlkDi{end+1}=[dn,'/',int2str(ii)];
            end
            for ii=1:length(ph.Outport)
                linkBlkDo{end+1}=[dn,'/',int2str(ii)];
            end
        end


        function[ips,ops]=getDutDrvSrcAndRcvSinkPorts(this,blk)
            cosimMdlDutH=get_param(blk,'handle');


            iph=this.getInportSrcHandles(cosimMdlDutH);


            oph=this.getOutportDstHandles(cosimMdlDutH);

            ips=this.getPortParentNames(iph);
            ops=this.getPortParentNames(oph);
        end


        function inportHandles=getInportSrcHandles(this,cosimMdlDutH)
            inportHandleArray={};%#ok<*NASGU>
            phan=get_param(cosimMdlDutH,'PortHandles');

            for m=1:length(phan.Inport)
                inportHandleArray{end+1}=this.getSrcBlkOutportHandleAtIdx(cosimMdlDutH,m);
            end

            inportHandles=inportHandleArray;
        end


        function portHandles=getTestptSrcHandles(~,cosimMdlDutH)
            portHandleArray=[];
            phan=get_param(cosimMdlDutH,'PortHandles');

            for m=1:length(phan.Outport)
                isTP=get_param(phan.Outport(m),'Testpoint');
                if strcmp(isTP,'on')
                    portHandleArray=[portHandleArray,phan.Outport(m)];
                end
            end

            portHandles=portHandleArray;
        end


        function badPortConnectivity(~,cosimMdlDutH,portIdx,dir)
            error(message('hdlcoder:cosim:badSrcBlock',dir,portIdx,...
            get_param(cosimMdlDutH,'Name')));
        end


        function hSrcBlkPort=getSrcBlkOutportHandleAtIdx(this,cosimMdlDutH,...
            srcPortIdx)
            dutPortConnectivity=get_param(cosimMdlDutH,'portConnectivity');
            srcBlock=dutPortConnectivity(srcPortIdx).SrcBlock;
            srcPort=dutPortConnectivity(srcPortIdx).SrcPort;

            if isempty(srcBlock)||srcBlock==-1
                this.badPortConnectivity(cosimMdlDutH,srcPortIdx,'in');
            end

            srcBlkPortHandles=get_param(srcBlock,'portHandles');
            hSrcBlkPort=srcBlkPortHandles.Outport(srcPort+1);

            if isempty(hSrcBlkPort)
                this.badPortConnectivity(cosimMdlDutH,srcPortIdx,'in');
            end
        end






        function outportHandles=getOutportDstHandles(this,cosimMdlDutH)
            outportHandleArray={};
            phan=get_param(cosimMdlDutH,'PortHandles');

            numIn=length(phan.Inport);
            for m=1:length(phan.Outport)

                outportHandleArray{end+1}=this.getSinkBlkInportHandleAtIdx(cosimMdlDutH,m,numIn);
            end

            outportHandles=outportHandleArray;
        end


        function hSinkBlkPort=getSinkBlkInportHandleAtIdx(this,cosimMdlDutH,...
            actOutPortIdx,dutNumIn)
            hSinkBlkPort={};
            dutPortConnectivity=get_param(cosimMdlDutH,'portConnectivity');


            dutOutPortIdx=actOutPortIdx+dutNumIn;
            dstBlocks=dutPortConnectivity(dutOutPortIdx).DstBlock;


            dstBlkInPortIndices=dutPortConnectivity(dutOutPortIdx).DstPort;

            if isempty(dstBlocks)||any(dstBlocks==-1)
                this.badPortConnectivity(cosimMdlDutH,actOutPortIdx,'out');
            end

            for ii=1:length(dstBlocks)
                dstBlk=dstBlocks(ii);
                dstBlkPHan=get_param(dstBlk,'portHandles');

                dstBlkInportHan=dstBlkPHan.Inport;
                dstBlkNumIn=length(dstBlkInportHan);

                sinkInPortIdx=dstBlkInPortIndices(ii)+1;
                if sinkInPortIdx<=dstBlkNumIn

                    hSinkBlkPort{end+1}=dstBlkInportHan(sinkInPortIdx);
                else
                    dstBlkEnablePortHan=dstBlkPHan.Enable;
                    dstBlkTriggerPortHan=dstBlkPHan.Trigger;

                    hasEnable=~isempty(dstBlkEnablePortHan);
                    hasTrigger=~isempty(dstBlkTriggerPortHan);

                    if hasEnable&&hasTrigger
                        if sinkInPortIdx==(dstBlkNumIn+1)

                            hSinkBlkPort{end+1}=dstBlkEnablePortHan;
                        elseif sinkInPortIdx==(dstBlkNumIn+2)

                            hSinkBlkPort{end+1}=dstBlkTriggerPortHan;
                        end
                    elseif hasEnable
                        hSinkBlkPort{end+1}=dstBlkEnablePortHan;
                    elseif hasTrigger
                        hSinkBlkPort{end+1}=dstBlkTriggerPortHan;
                    end
                end


                if isempty(hSinkBlkPort)
                    this.badPortConnectivity(cosimMdlDutH,actOutPortIdx,'out');
                end
            end
        end


        function pn=getPortNameWithPath(this,p)
            pn='';
            if~isempty(p)
                pKind=get_param(p,'PortType');
                pNum=get_param(p,'PortNumber');

                parent=get_param(p,'Parent');
                parentHan=get_param(parent,'handle');
                parentName=this.getSLName(parentHan);

                if(strcmpi(pKind,'Enable')||strcmpi(pKind,'Trigger'))

                    pn=sprintf('%s/%s',parentName,pKind);
                else

                    pn=sprintf('%s/%d',parentName,pNum);
                end
            end
        end








        function pnames=getPortParentNames(this,ph)
            pnames={};
            for ii=1:length(ph)
                t=ph{ii};
                tnames={};
                if iscell(t)
                    for jj=1:length(t)
                        p=t{jj};
                        tnames{end+1}=this.getPortNameWithPath(p);
                    end
                else
                    tnames=this.getPortNameWithPath(t);
                end

                pnames{end+1}=tnames;
            end
        end


        function configureLinkBlockOnly(this)
            this.createLinkBlock;
            srcBlkPath=this.getTBDutPath;
            oldPos=get_param(srcBlkPath,'Position');
            orient=get_param(srcBlkPath,'Orientation');
            cosimblkPath=this.getCosimLinkDutPath;
            set_param(cosimblkPath,'Position',oldPos);
            set_param(cosimblkPath,'Orientation',orient);
        end


        function configureLinkBlockAndReplaceDut(this)
            this.createLinkBlock;

            dutInCosimMdl=this.getCosimDutPath;
            delete_block(dutInCosimMdl);

            srcBlkPath=this.getTBDutPath;
            oldPos=get_param(srcBlkPath,'Position');
            orient=get_param(srcBlkPath,'Orientation');

            cosimblkPath=this.getCosimLinkDutPath;
            set_param(cosimblkPath,'Position',oldPos);
            set_param(cosimblkPath,'Orientation',orient);
        end



        function clockScale=computeBaseClockScale(this)
            clockScale=this.getClockPeriod;




            dutMinSampleTime=this.getDutMinSampleTime;

            if~isempty(dutMinSampleTime)&&dutMinSampleTime>0
                clockScale=clockScale/dutMinSampleTime;
            end
        end

        function finalScale=getFinalScale(this)
            clockScale=this.computeBaseClockScale;
            overClockRate=this.getOverClockRate;
            finalScale=clockScale*overClockRate;
        end


        function createLinkBlock(this)
            srcBlkPath=this.getTBDutPath;
            cosimblkPath=this.getCosimLinkDutPath;
            portInfo=this.getPortInfo;

            add_block([this.getLibraryName,'/HDL Cosimulation'],cosimblkPath);



            set_param(cosimblkPath,...
            'PortPaths',portInfo.PortPaths,...
            'PortModes',portInfo.PortModes,...
            'PortTimes',portInfo.PortTimes,...
            'PortSigns',portInfo.PortSigns,...
            'PortFracLengths',portInfo.PortFracLengths,...
            'ClockPaths',this.getClockResetPaths,...
            'ClockModes',this.getClockResetModes,...
            'ClockTimes',this.getClockResetTimes);

            o=get_param(cosimblkPath,'object');

            o.TimingMode=this.getTimingUnit;


            clockScale=this.getFinalScale;
            o.TimingScaleFactor=sprintf('%16.15g',clockScale);

            o.TclPreSimCommand=this.getTclPreSimCommand;
            o.TclPostSimCommand=sprintf([o.TclPostSimCommand,'\n',this.getTclPostSimCommand]);

            o.UserData=this.getXSIData(portInfo);

            if this.dutHasClock
                PreRunTime=uint64(this.computeResetRunTime);
                o.PreRunTime=int2str(PreRunTime);
                o.PreRunTimeUnit=this.getTimingUnit;
            end
        end






        function createLinkMdl(this,drawTB)
            if nargin<2
                drawTB=true;
            end

            linkMdlName=this.getCosimModelName;
            tbFileName=this.getTBModelName;


            hb=slhdlcoder.SimulinkBackEnd(this.hPir,...
            'InModelFile',tbFileName,...
            'OutModelFile',linkMdlName,...
            'ShowModel','no');
            hb.createAndInitTargetModel;


            this.cosimMdlName=hb.OutModelFile;

            tbSysName=this.getTestbenchSystem;
            this.dutSrcCaptureSSName=[tbSysName,'/ToCosimSrc'];
            this.dutSinkCaptureSSName=[tbSysName,'/ToCosimSink'];
            this.cosimSrcSSName=[tbSysName,'/FromCosimSrc'];
            this.cosimSinkSSName=[tbSysName,'/Compare'];
            this.simStartSSName=[tbSysName,'/Start Simulator'];
            link=sprintf('<a href="matlab:open_system(''%s'')">%s</a>',...
            this.cosimMdlName,this.cosimMdlName);
            hdldisp(message('hdlcoder:hdldisp:GeneratingNewCModel',link));

            if(drawTB)


                drawSrcModelDut=true;
                hb.drawTestBench(drawSrcModelDut);
            end


            load_system('hdlmdlgenlib');
        end


        function openScopes(this)
            if this.getDutHasOutputs&&strcmpi(this.cosimSetup,'CosimBlockAndDut')
                dutCompareSS=this.getCosimSinkSSName;


                blks=find_system(dutCompareSS,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','blocktype','Scope');






                for ii=1:numel(blks)
                    blk=blks{ii};



                    set_param(blk,'Location',...
                    mat2str(slprivate('rectconv',[120,258,618,456],'sl')));
                    key=get_param(blk,'Name');
                    if this.haveTooManyScopes()
                        set_param(blk,'Open','off');
                    elseif this.openScope.isKey(key)&&this.openScope(key)==true
                        set_param(blk,'Open','on');
                        open_system(blk);
                    end
                end
            end


            idcLen=this.getIgnoreDataCheckingLen;
            if idcLen>0
                set_param(this.cosimMdlName,'InheritedTsInSrcMsg','none');
            end
        end


        function generateLinkModel(this)
            if(strcmpi(this.cosimSetup,'CosimBlockAndDut'))
                this.createLinkMdl;
                this.configureLinkBlockInParallel;
            elseif(strcmpi(this.cosimSetup,'CosimBlockAsDut'))
                this.createLinkMdl;
                this.configureLinkBlockAndReplaceDut;
            elseif strcmpi(this.cosimSetup,'cegen')
                this.createLinkMdl;
                this.configureCEModel;
            else

                blankModel=false;
                this.createLinkMdl(blankModel);
                this.configureLinkBlockOnly;
            end
        end


        function validateModel(this)
            dutMinSampleTime=this.getDutMinSampleTime;

            if dutMinSampleTime<=0||isinf(dutMinSampleTime)
                warning(message('hdlcoder:cosim:edacosimsampletimessue3',...
                int2str(dutMinSampleTime),this.getGoldenMdlDutName));
            end

            mdlBaseSampleTime=this.getMdlBaseSampleTime;
            if isempty(mdlBaseSampleTime)
                warning(message('hdlcoder:cosim:edacosimsampletimessue',...
                this.getGoldenMdlDutName));
            elseif mdlBaseSampleTime<=0||isinf(mdlBaseSampleTime)
                warning(message('hdlcoder:cosim:edacosimsampletimessue4',...
                int2str(mdlBaseSampleTime),this.getGoldenMdlDutName));
            end
        end


        function doIt(this)
            hasLicense=this.checkEDALinkLicense;
            if hasLicense
                current_system=get_param(0,'CurrentSystem');

                this.validateModel;

                this.generateLinkModel;

                this.addLaunchBox;

                this.openScopes;
                open_system(this.cosimMdlName);

                cosimBlkPath=this.getCosimLinkDutPath;
                set_param(cosimBlkPath,'AllowDirectFeedthrough','on');
                hdldisp(message('hdlcoder:hdldisp:DirectFeedOn',cosimBlkPath));
                hdlresetgcb(current_system);
            else
                warning(message('hdlcoder:cosim:edacosimlicenseissue','generatecosimmodel'));
            end
        end
        function tf=haveTooManyScopes(this)
            tf=(this.NumFlattenedDUTOutputs>20);
        end
    end
end




