classdef gencoverifymdl<cosimtb.gencosim




    methods






        function this=gencoverifymdl(varargin)
            this=this@cosimtb.gencosim(varargin{:});



            if(nargin<1)
                this.cosimSetup='CoverifyBlockAndDut';
            else


                this.cosimSetup=lower(varargin{1});
            end
        end




        function linkSuffix=getCurrentLinkOpt(~)
            hD=hdlcurrentdriver;
            if~isempty(hD)
                linkSuffix=hD.getParameter('ValidationModelNameSuffix');
            else
                linkSuffix='_vnl';
            end
        end


        function hl=checkCoverifyLicense(~)
            hl=true;
            try
                slhdlcoder.checkLicense;
            catch me %#ok<NASGU>
                hl=false;
            end
        end

        function iPorts=getDutInports(this)
            topNet=this.getTopNetwork;
            iPorts=topNet.PIRInputPorts;
        end

        function oPorts=getDutOutports(this)
            topNet=this.getTopNetwork;
            oPorts=topNet.PIROutputPorts;
        end

        function e=getNumExtraPortsOnCosimBlk(this)
            topNet=this.getTopNetwork;
            id=length(topNet.PirInputPorts)-length(topNet.PIRInputPorts);
            od=length(topNet.PirOutputPorts)-length(topNet.PIROutputPorts);
            if(id==0&&od==0)
                e=1;
            else
                e=max(id-3,od-1);
            end
        end

        function name=getDutInportNameAtIdx(this,idx)
            hn=this.getTopNetwork;
            p=hn.PIRInputPorts(idx);
            name=p.Name;
        end

        function name=getDutOutportNameAtIdx(this,idx)
            hn=this.getTopNetwork;
            p=hn.PIROutputPorts(idx);
            name=p.Name;
        end

        function name=getDutOriginalInportNameAtIdx(this,idx)

            name='';
            if this.getDutHasInputs
                cosimMdlDutPath=this.getCosimDutPath;
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

        function inType=getDutInportType(~,hn,idx)
            inType=[];
            hs=hn.getInputPortSignal(idx-1);
            if~isempty(hs)
                inType=hs.Type;
            end
        end

        function outType=getDutOutportType(~,hn,idx)
            outType=[];
            hs=hn.getOutputPortSignal(idx-1);
            if~isempty(hs)
                outType=hs.Type;
            end
        end

        function maxLatency=getMaxLatency(this)
            maxLatency=this.hSLHDLCoder.getParameter('maxcomputationlatency');
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

        function val=getNeedsEnabledValidation(this)
            maxLatency=this.hSLHDLCoder.getParameter('maxcomputationlatency');
            maxOversampling=this.hSLHDLCoder.getParameter('maxoversampling');

            topN=this.hPir.getTopNetwork;
            numOuts=topN.NumberOfPirOutputPorts;
            if numOuts==0
                val=false;
                return;
            end
            delayLen=this.hPir.getDutExtraLatency(numOuts-1);
            gp=pir;
            shareOrstream=gp.sharingSuccess||gp.streamingSuccess;
            val=maxOversampling==1&&maxLatency>1&&...
            delayLen>=1&&shareOrstream;
        end

        function delayLen=getDutOutportPathDelay(this,idx)
            delayLen=this.hPir.getDutExtraLatency(idx-1);

            if this.getNeedsEnabledValidation

                inputRate=this.getMaxLatency;
                delayLen=ceil(delayLen/inputRate);
            else

                hN=this.hPir.getTopNetwork;
                hOutSignal=hN.PirOutputSignals(idx);

                samplerate=hOutSignal.SimulinkRate;
                clockrate=this.hPir.DutBaseRate;
                ratio=samplerate/clockrate;

                phaseCycles=this.hPir.getOutputPortPhase(idx-1);
                if(phaseCycles>0)
                    delayLen=delayLen+ceil(phaseCycles/ratio);
                end
            end
        end

        function iscomplex=isDutInportAtIdxComplex(this,idx)
            hn=this.getTopNetwork;
            t=this.getDutInportType(hn,idx);
            tInfo=pirgetdatatypeinfo(t);
            iscomplex=tInfo.iscomplex;
        end

        function iscomplex=isDutOutportAtIdxComplex(this,idx)
            hn=this.getTopNetwork;
            t=this.getDutOutportType(hn,idx);
            tInfo=pirgetdatatypeinfo(t);
            iscomplex=tInfo.iscomplex;
        end

        function isfloat=isDutOutportAtIdxFloat(this,idx)
            hn=this.getTopNetwork;
            t=this.getDutOutportType(hn,idx);
            tInfo=pirgetdatatypeinfo(t);
            isfloat=tInfo.isfloat;
        end

        function isHalf=isDutOutportAtIdxHalf(this,idx)
            hn=this.getTopNetwork;
            t=this.getDutOutportType(hn,idx);
            tInfo=pirgetdatatypeinfo(t);
            isHalf=tInfo.ishalf;
        end

        function isvector=isDutInportAtIdxVector(this,idx)
            hn=this.getTopNetwork;
            t=this.getDutInportType(hn,idx);
            tInfo=pirgetdatatypeinfo(t);
            isvector=tInfo.isvector;
        end

        function isvector=isDutOutportAtIdxVector(this,idx)
            hn=this.getTopNetwork;
            t=this.getDutOutportType(hn,idx);
            tInfo=pirgetdatatypeinfo(t);
            isvector=tInfo.isvector;
        end

        function isonebitvector=isDutInportAtIdxOneBitVector(this,idx)
            hn=this.getTopNetwork;
            t=this.getDutInportType(hn,idx);
            tInfo=pirgetdatatypeinfo(t);
            isonebitvector=tInfo.isvector&&tInfo.wordsize==1;
        end

        function isonebitvector=isDutOutportAtIdxOneBitVector(this,idx)
            hn=this.getTopNetwork;
            t=this.getDutOutportType(hn,idx);
            tInfo=pirgetdatatypeinfo(t);
            isonebitvector=tInfo.isvector&&tInfo.wordsize==1;
        end

        function vlen=getVectorLenAtInputPort(this,idx)
            hn=this.getTopNetwork;
            t=this.getDutInportType(hn,idx);
            vlen=max(t.getDimensions);
        end

        function vlen=getVectorLenAtOutputPort(this,idx)
            hn=this.getTopNetwork;
            t=this.getDutOutportType(hn,idx);
            vlen=max(t.getDimensions);
        end

        function isDouble=isDutInportAtIdxDouble(this,idx)
            hn=this.getTopNetwork;
            t=this.getDutInportType(hn,idx);
            isDouble=t.LeafType.isDoubleType;
        end

        function isDouble=isDutOutportAtIdxDouble(this,idx)
            hn=this.getTopNetwork;
            t=this.getDutOutportType(hn,idx);
            isDouble=t.LeafType.isDoubleType;
        end

        function isTunable=isDutInportTunable(this,idx)
            hn=this.getTopNetwork;
            port=hn.PIRInputPorts(idx);
            isTunable=~isempty(port.getTunableName);
        end

        function isTestpoint=isDutOutportTestpoint(this,idx)
            hb=this.getTopNetwork;
            port=hb.PIROutputPorts(idx);
            isTestpoint=port.isTestpoint();
        end

        function hdlIn=getNumHDLInportsAtIdx(~,~)


            hdlIn=1;
        end

        function hdlOut=getNumHDLOutportsAtIdx(~,~)


            hdlOut=1;
        end

        function lat=getDutExtraLatency(this,portNum)
            lat=this.hPir.getDutExtraLatency(portNum-1);
        end

        function b=getDutHasInputs(this)
            b=false;
            hn=this.getTopNetwork;
            ports=hn.PIRInputPorts;
            for ii=1:length(ports)
                p=ports(ii);
                if strcmpi(p.Kind,'Data')&&isempty(p.getTunableName)
                    b=true;
                    break;
                end
            end
        end

        function b=getDutHasOutputs(this)
            b=false;
            hn=this.getTopNetwork;
            ports=hn.PIROutputPorts;
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
            n=length(hn.PIRInputPorts);
        end

        function n=getDutNumOut(this)
            hn=this.getTopNetwork;
            n=length(hn.PIROutputPorts);
        end

        function name=getGoldenMdlName(this)
            name=this.hSLHDLCoder.ModelName;
        end

        function name=getGoldenMdlDutName(this)
            if this.hSLHDLCoder.nonTopDut||this.hSLHDLCoder.DUTMdlRefHandle>0
                name=get_param(this.hSLHDLCoder.OrigStartNodeName,'Name');
            else
                name=this.hSLHDLCoder.getStartNodeName;
                [~,remain]=strtok(name,'/');
                name=remain(2:end);
            end
        end

        function setTestbenchSystem(this)
            if this.hSLHDLCoder.DUTMdlRefHandle>0
                genMdl=this.hSLHDLCoder.getParameter('generatedmodelname');
                dutName=get_param(this.hSLHDLCoder.DUTMdlRefHandle,'Name');
                dutMdlRef=find_system(genMdl,'LookUnderMasks','all',...
                'MatchFilter',@Simulink.match.allVariants,...
                'Name',dutName,'BlockType','ModelReference');
                variantSubsys=get_param(dutMdlRef,'Parent');
                tbSys=get_param(variantSubsys,'Parent');
                if iscell(tbSys)
                    tbSys=tbSys{1};
                end
                this.testbenchSystem=regexprep(tbSys,['^',genMdl],...
                this.cosimMdlName);
            elseif this.hSLHDLCoder.nonTopDut
                genMdl=this.hSLHDLCoder.getParameter('generatedmodelname');
                Parent=get_param(this.hSLHDLCoder.OrigStartNodeName,'Parent');
                tbSys=regexprep(Parent,['^',this.getGoldenMdlName],...
                genMdl);
                if iscell(tbSys)
                    tbSys=tbSys{1};
                end
                this.testbenchSystem=regexprep(tbSys,['^',genMdl],...
                this.cosimMdlName);
            else
                this.testbenchSystem=this.getCosimModelName;
            end
        end

        function tbSystem=getTestbenchSystem(this)
            if isempty(this.testbenchSystem)
                this.setTestbenchSystem;
            end
            tbSystem=this.testbenchSystem;
        end


        function configureLinkBlockInParallel(this)
            tbSys=this.getTestbenchSystem;
            cosimMdlDutPath=this.getCosimDutPath;
            cosimMdlDutH=get_param(cosimMdlDutPath,'handle');


            if this.hSLHDLCoder.DUTMdlRefHandle>0
                set_param(cosimMdlDutH,'LoadFcn','');
            end




            [di,do]=this.getDutSrcAndSinkPorts(cosimMdlDutH);





            [ips,ops]=this.getDutDrvSrcAndRcvSinkPorts(cosimMdlDutPath);


            this.disconnectDut(cosimMdlDutPath);


            if this.hSLHDLCoder.DUTMdlRefHandle>0


                pos=get_param(cosimMdlDutH,'Position');
                dutVariantName=get_param(cosimMdlDutH,'Name');
                cosimMdlDutH=add_block(get_param(cosimMdlDutPath,'ActiveVariantBlock'),cosimMdlDutPath,'MakeNameUnique','on');
                delete_block(cosimMdlDutPath);
                set_param(cosimMdlDutH,'Name',dutVariantName);
                set_param(cosimMdlDutH,'Position',pos);
            end



            dutHasInputs=this.getDutHasInputs;
            dutHasOutputs=this.getDutHasOutputs;



            if dutHasInputs
                numInPorts=this.getDutNumIn;
                this.addFromDutToCosimSS(true,numInPorts,'in');

                cosimISSName=this.stripTBSubsystemPath(this.getDutSrcCaptureSSName);

                for ii=1:length(di)
                    add_line(tbSys,[cosimISSName,'/',int2str(ii)],di{ii},...
                    'Autorouting','on');
                end
            end

            if dutHasOutputs

                numOutPorts=this.getDutNumOut;
                this.addFromDutToCosimSS(false,numOutPorts,'out');

                cosimOSSName=this.stripTBSubsystemPath(this.getDutSinkCaptureSSName);

                for ii=1:length(do)
                    add_line(tbSys,do{ii},[cosimOSSName,'/',int2str(ii)],...
                    'Autorouting','on');
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
                            add_line(tbSys,cosimOutPort,dutSink{jj},...
                            'Autorouting','on');
                        end
                    end
                end
            end




            this.createCoverifyBlock;
            cosimblkPath=this.getCosimLinkDutPath;
            newPos=this.getLinkBlockPos;
            set_param(cosimblkPath,'Position',newPos);
            set_param(cosimblkPath,'Orientation','right');

            linkPos=get_param(cosimblkPath,'Position');
            linkblkH=get_param(cosimblkPath,'handle');
            [linkBlkDi,linkBlkDo]=this.getlinkDutSrcAndSinkPorts(linkblkH);


            if dutHasInputs
                newissPos=[linkPos(1)-40,linkPos(2),linkPos(1)-30,linkPos(4)];
                this.addCosimSrcSS(tbSys,cosimblkPath,newissPos,...
                linkBlkDi,cosimblkPath);
            end



            if dutHasOutputs
                newossPos=[linkPos(3)+30,linkPos(2),linkPos(3)+40,linkPos(4)];
                this.addCosimSinkSS(tbSys,cosimblkPath,newossPos,linkBlkDo);
            end



            set_param(this.getCosimModelName,'InheritedTsInSrcMsg','none');



            [~,mdlBlks]=find_mdlrefs(this.getCosimModelName,...
            'MatchFilter',@Simulink.match.internal.activePlusStartupVariantSubsystem);
            if~isempty(mdlBlks)
                note=Simulink.Annotation([this.getCosimModelName,'/',message('hdlcoder:cosim:modelrefload').getString]);
                note.position=[newPos(1)-200,newPos(4)+40];
                note.BackgroundColor='yellow';
            end
        end

        function configureLinkBlockInParallelForStreamedDUT(this)
            cosimMdlDutPath=this.getCosimDutPath;
            vnlHelper=streamingmatrix.GeneratedModelHelper.getVNLHelper(...
            this.hPir.getTopNetwork,cosimMdlDutPath);

            srcCaptureName=this.stripTBSubsystemPath(this.getDutSrcCaptureSSName);
            sinkCaptureName=this.stripTBSubsystemPath(this.getDutSinkCaptureSSName);




            vnlHelper.replaceGMInputOutputSubsystems(srcCaptureName,sinkCaptureName);


            this.createCoverifyBlock;
            cosimBlkPath=this.getCosimLinkDutPath;
            newPos=this.getLinkBlockPos;
            set_param(cosimBlkPath,'Position',newPos);
            set_param(cosimBlkPath,'Orientation','right');




            cosimSrcName=this.stripTBSubsystemPath(this.getCosimSrcSSName);
            cosimSinkName=this.stripTBSubsystemPath(this.getCosimSinkSSName);
            vnlHelper.addOriginalDUTInputOutputSubsystems(cosimBlkPath,cosimSrcName,cosimSinkName);



            set_param(this.getCosimModelName,'InheritedTsInSrcMsg','none');





            [~,mdlBlks]=find_mdlrefs(this.getCosimModelName,...
            'MatchFilter',@Simulink.match.internal.activePlusStartupVariantSubsystem);
            if~isempty(mdlBlks)
                note=Simulink.Annotation([this.getCosimModelName,'/',message('hdlcoder:cosim:modelrefload').getString]);
                note.position=[newPos(1)-200,newPos(4)+40];
                note.BackgroundColor='yellow';
            end
        end



        addStreamedCosimSinkSS(this)


        function addFromDutToCosimSS(this,capturingInputs,numPorts,gotoName)
            if capturingInputs
                ssPath=this.getDutSrcCaptureSSName;
                newssPath=this.addBlockUnique('built-in/Subsystem',ssPath);
                this.dutSrcCaptureSSName=newssPath;
                [newSSPos,newSSO]=this.getToCosimSrcPosition;
            else
                ssPath=this.getDutSinkCaptureSSName;
                newssPath=this.addBlockUnique('built-in/Subsystem',ssPath);
                this.dutSinkCaptureSSName=newssPath;
                [newSSPos,newSSO]=this.getToCosimSinkPosition;
            end

            set_param(newssPath,'Position',newSSPos);
            set_param(newssPath,'Orientation',newSSO);
            set_param(newssPath,'MaskDisplay','disp('''')');
            set_param(newssPath,'BackgroundColor','cyan');

            ipos=[100,48,130,62];
            newPos=ipos;
            for ii=1:numPorts
                ssinportblk=[newssPath,'/','in',int2str(ii)];
                add_block('built-in/Inport',ssinportblk);
                newPos=newPos+[0,60,0,60];
                set_param(ssinportblk,'Position',newPos);
            end

            ops=[335,48,365,62];
            if capturingInputs&&this.getNeedsEnabledValidation
                counterName='Counter';
                ctrPos=[ipos(1)-5,ipos(2)-10,ipos(3)+5,ipos(4)+10];
                counterBlock=add_block('simulink/Sources/Counter Limited',...
                [newssPath,'/',counterName]);
                set_param(counterBlock,'uplimit',int2str(this.getMaxLatency-1));
                set_param(counterBlock,'Position',ctrPos);

                is0Name='is_zero';
                is0=add_block('simulink/Logic and Bit Operations/Compare To Constant',...
                [newssPath,'/',is0Name]);
                iszPos=[ctrPos(1)+120,ctrPos(2),ctrPos(3)+120,ctrPos(4)];
                set_param(is0,'Position',iszPos);
                set_param(is0,'relop','==');
                set_param(is0,'const',int2str(0));

                enbOutput=add_block('built-in/Goto',[newssPath,'/enb_out']);
                set_param(enbOutput,'Position',ops);
                set_param(enbOutput,'GotoTag',[gotoName,'_enb']);
                set_param(enbOutput,'TagVisibility','global');

                add_line(newssPath,[counterName,'/1'],[is0Name,'/1'],...
                'Autorouting','on');
                add_line(newssPath,[is0Name,'/1'],'enb_out/1','Autorouting','on');
            end

            newPos=ops+[0,30,0,30];
            for ii=1:numPorts
                idxstr=int2str(ii);
                instr=['in',idxstr,'/1'];
                ssoutportblk=[newssPath,'/','out',idxstr];
                add_block('built-in/Outport',ssoutportblk);
                newPos=newPos+[0,30,0,30];
                set_param(ssoutportblk,'Position',newPos);
                add_line(newssPath,instr,['out',idxstr,'/1'],'Autorouting','on');


                if~capturingInputs&&isDutOutportTestpoint(this,ii)
                    continue
                end


                if~(strcmp(gotoName,'in')&&isDutInportTunable(this,ii))


                    gotoblock=[newssPath,'/','goto',idxstr];
                    add_block('built-in/Goto',gotoblock);
                    newPos=newPos+[0,30,0,30];
                    set_param(gotoblock,'Position',newPos);
                    set_param(gotoblock,'GotoTag',[gotoName,idxstr]);
                    set_param(gotoblock,'TagVisibility','global');


                    srcPort=instr;
                    add_line(newssPath,srcPort,['goto',idxstr,'/1'],...
                    'Autorouting','on');
                end
            end
        end


        function addCosimSrcSS(this,cosimMdlName,cosimBlkFP,newSSPos,...
            linkBlkDi,linkblkH)
            ssPath=this.getCosimSrcSSName;
            newssPath=this.addBlockUnique('built-in/Subsystem',ssPath);
            this.cosimSrcSSName=newssPath;
            cosimIOSSName=this.stripTBSubsystemPath(newssPath);

            dutNumIn=this.getDutNumIn;

            basePos=[100,48,130,62];

            ipos=basePos;
            frominportblks={};
            for ii=1:dutNumIn

                if isDutInportTunable(this,ii)
                    continue;
                end

                frominportblks{end+1}=[newssPath,'/','from',int2str(ii)];%#ok<AGROW>
                add_block('built-in/From',frominportblks{ii});
                set_param(frominportblks{ii},'Position',ipos);

                vlen=this.getVectorLenAtInputPort(ii);
                if vlen>1
                    blkDist=60+5*double(vlen);
                else
                    blkDist=60;
                end

                ipos=[ipos(1),ipos(2)+blkDist,ipos(3),ipos(4)+blkDist];
                set_param(frominportblks{ii},'GotoTag',['in',int2str(ii)]);
            end

            matchingblk=frominportblks{1};
            fpos=get_param(matchingblk,'Position');
            l=fpos(1)+180;t=fpos(2);r=fpos(3)+180;b=fpos(4);
            ops=[l,t,r,b];

            ssoutportblks={};
            for ii=1:length(linkBlkDi)
                opblk=[newssPath,'/','out',int2str(ii)];
                add_block('built-in/Outport',opblk);

                set_param(opblk,'Position',ops);
                ops=[ops(1),ops(2)+60,ops(3),ops(4)+60];

                ssoutportblks{end+1}=opblk;%#ok<AGROW>
            end


            outCtr=1;
            for ii=1:dutNumIn

                if isDutInportTunable(this,ii)
                    continue;
                end

                fromBlk=['from',int2str(ii),'/1'];
                outPort=['out',int2str(outCtr),'/1'];
                add_line(newssPath,fromBlk,outPort);
                outCtr=outCtr+1;
            end

            set_param(newssPath,'Position',newSSPos);
            ori=get_param(cosimBlkFP,'Orientation');
            set_param(newssPath,'Orientation',ori);
            set_param(newssPath,'MaskDisplay','disp('''')');
            set_param(newssPath,'BackgroundColor','cyan');

            for ii=1:length(linkBlkDi)
                add_line(cosimMdlName,[cosimIOSSName,'/',int2str(ii)],...
                linkBlkDi{ii});
            end

            if this.getNeedsEnabledValidation
                enbFrom='from_enb';
                enbBlk=add_block('built-in/From',[newssPath,'/',enbFrom]);
                enbPos=[basePos(1),basePos(2)-60,basePos(3),basePos(4)-60];
                set_param(enbBlk,'Position',enbPos);
                set_param(enbBlk,'GotoTag','in_enb');

                outEnb='out_enb';
                outBlk=add_block('built-in/Outport',[newssPath,'/',outEnb]);
                outPos=[enbPos(1)+180,enbPos(2),enbPos(3)+180,enbPos(4)];
                set_param(outBlk,'Position',outPos);

                add_line(newssPath,[enbFrom,'/1'],[outEnb,'/1']);

                add_block('built-in/EnablePort',[linkblkH,'/val_enb'],...
                'MakeNameUnique','on');

                vnlSS=this.getCosimLinkDutName;
                outIdx=get_param(outBlk,'Port');
                add_line(cosimMdlName,[cosimIOSSName,'/',outIdx],...
                [vnlSS,'/Enable'],'AUTOROUTING','on');
            end

        end


        function addCompareComp(this,ii,balanceDelays,outPortComplex,...
            outPortFloat,outPortHalf,compblock,matchingblk,opName,posOffset)

            if nargin<10
                posOffset=[0,0,0,0];
            end

            portLat=this.getDutOutportPathDelay(ii);
            portType=this.getDutOutportType(this.getTopNetwork,ii);
            needIdcLogic=balanceDelays&&(portLat>0);

            if needIdcLogic
                if outPortComplex
                    if outPortFloat&&this.isFloatingPointMode()
                        if this.getFPToleranceStrategy>1
                            add_block('hdlmdlgenlib/AssertULPEqComplexIDC',compblock);
                        else
                            add_block('hdlmdlgenlib/AssertRelEqComplexIDC',compblock);
                        end
                    else
                        add_block('hdlmdlgenlib/AssertEqComplexIDC',compblock);
                    end
                else
                    if outPortFloat&&this.isFloatingPointMode()
                        if outPortHalf
                            if this.getFPToleranceStrategy>1
                                add_block('hdlmdlgenlib/AssertHalfULPEqIDC',compblock);
                            else
                                add_block('hdlmdlgenlib/AssertHalfRelEqIDC',compblock);
                            end
                        else
                            if this.getFPToleranceStrategy>1
                                add_block('hdlmdlgenlib/AssertULPEqIDC',compblock);
                            else
                                add_block('hdlmdlgenlib/AssertRelEqIDC',compblock);
                            end
                        end
                    else
                        add_block('hdlmdlgenlib/AssertEqIDC',compblock);
                    end
                end
            else
                if outPortComplex
                    if outPortFloat&&this.isFloatingPointMode()
                        if this.getFPToleranceStrategy>1
                            add_block('hdlmdlgenlib/AssertULPEqComplex',compblock);
                        else
                            add_block('hdlmdlgenlib/AssertRelEqComplex',compblock);
                        end
                    else
                        add_block('hdlmdlgenlib/AssertEqComplex',compblock);
                    end
                elseif isCharType(portType.BaseType)
                    add_block('hdlmdlgenlib/AssertStrEq',compblock);
                else
                    if outPortFloat&&this.isFloatingPointMode()

                        if outPortHalf
                            if this.getFPToleranceStrategy>1
                                add_block('hdlmdlgenlib/AssertHalfULPEq',compblock);
                            else
                                add_block('hdlmdlgenlib/AssertHalfRelEq',compblock);
                            end
                        else
                            if this.getFPToleranceStrategy>1
                                add_block('hdlmdlgenlib/AssertULPEq',compblock);
                            else
                                add_block('hdlmdlgenlib/AssertRelEq',compblock);
                            end
                        end
                    else
                        add_block('hdlmdlgenlib/AssertEq',compblock);
                    end
                end
            end

            fpos=get_param(matchingblk,'Position');
            fpos=[fpos(1)+240,fpos(2),fpos(1)+270,fpos(2)+30];
            fpos=fpos+posOffset;
            set_param(compblock,'Position',fpos);
            set_param(compblock,'linkStatus','none');
            if outPortFloat&&this.isFloatingPointMode()
                set_param(compblock,'ToleranceValue',this.getFPToleranceValue);
            end

            if outPortComplex
                scopePath=[compblock,'/Scope_re'];
                set_param(scopePath,'Name',['compare_re: ',opName]);
                scopePath=[compblock,'/Scope_im'];
                set_param(scopePath,'Name',['compare_im: ',opName]);

            elseif isCharType(portType.BaseType)

            else
                scopePath=[compblock,'/Scope'];
                set_param(scopePath,'Name',['compare: ',opName]);
            end

            if needIdcLogic
                idcLen=this.getIgnoreDataCheckingLen;
                idcBlk=[compblock,'/IgnoreCycles'];
                ignoreDataCycles=portLat;

                if portLat>0&&this.hPir.dutHasMultipleSampleTimes
                    outRate=this.getTopNetwork.PirOutputSignals(ii).SimulinkRate;


                    if outRate~=this.hPir.DutBaseRate
                        ignoreDataCycles=ignoreDataCycles+1;
                    end
                end
                latVal=max(idcLen,ignoreDataCycles);
                set_param(idcBlk,'Value',int2str(latVal));
                hT=this.getDutOutportType(this.getTopNetwork,ii);

                isTypeEnum=hT.isArrayOfEnums||hT.isEnumType;
                if isTypeEnum

                    if hT.isArrayOfEnums
                        typeName=hT.BaseType.Name;
                    else
                        typeName=hT.Name;
                    end
                    constBlock=[compblock,'/Constant1'];


                    set_param(constBlock,'Value',this.getDefaultValueForEnum(typeName));
                end
            end
        end


        function value=getDefaultValueForEnum(~,typeName)


            m=methods(typeName);


            if any(strcmp(m,'getDefaultValue'))
                value=[typeName,'.getDefaultValue'];



            else
                [~,s]=enumeration(typeName);
                value=[typeName,'.',s{1}];
            end
        end


        function addCosimSinkSS(this,cosimMdlName,cosimBlkFP,newSSPos,linkBlkDo)


            ssPath=this.getCosimSinkSSName;


            newssPath=this.addBlockUnique('built-in/Subsystem',ssPath);
            this.cosimSinkSSName=newssPath;
            set_param(newssPath,'Position',newSSPos);
            ori=get_param(cosimBlkFP,'Orientation');
            set_param(newssPath,'Orientation',ori);
            set_param(newssPath,'MaskDisplay','disp('''')');
            set_param(newssPath,'BackgroundColor','cyan');


            dutNumOut=this.getDutNumOut;
            basePos=[100,128,130,142];


            ipos=basePos;


            inputRate=this.getMaxLatency;
            doVal=this.getNeedsEnabledValidation;
            balanceDelays=this.hSLHDLCoder.getParameter('balancedelays');
            cosimIOSSName=this.stripTBSubsystemPath(this.getCosimSinkSSName);


            load_system('simulink');


            for ii=1:dutNumOut


                if isDutOutportTestpoint(this,ii)
                    continue;
                end


                idxstr=int2str(ii);


                ssinportblk=[newssPath,'/in',idxstr];
                add_block('built-in/Inport',ssinportblk,'Position',ipos);



                posMatchBlockInport=ssinportblk;


                add_line(cosimMdlName,linkBlkDo{ii},...
                [cosimIOSSName,'/',idxstr],'Autorouting','on');


                fromblock=[newssPath,'/','from',idxstr];
                add_block('built-in/From',fromblock);

                posMatchBlockFrom=fromblock;

                fpos=ipos+[0,30,0,30];
                set_param(fromblock,'Position',fpos);
                set_param(fromblock,'GotoTag',['out',idxstr]);
                set_param(fromblock,'TagVisibility','global');


                el=this.getDutOutportPathDelay(ii);
                delayBlock=[newssPath,'/pathdelay',idxstr];

                if doVal
                    dutLat=this.getDutExtraLatency(ii);
                    if dutLat>0
                        add_block('hdlmdlgenlib/RTDelay',delayBlock);
                        set_param(delayBlock,'LinkStatus','none');
                        set_param([delayBlock,'/RT'],...
                        'OutPortSampleTimeMultiple',int2str(inputRate));
                        set_param([delayBlock,'/Delay'],'NumDelays',int2str(el));
                    else
                        add_block('built-in/RateTransition',delayBlock);
                        set_param(delayBlock,'OutPortSampleTimeOpt',...
                        'Multiple of input port sample time');
                        set_param(delayBlock,'OutPortSampleTimeMultiple',...
                        int2str(inputRate));
                    end
                else
                    if el>0
                        add_block('simulink/Discrete/Delay',delayBlock);
                        set_param(delayBlock,'NumDelays',int2str(el));
                    else
                        delayBlock='';
                    end
                end


                if~isempty(delayBlock)
                    posMatchBlockInport=delayBlock;
                    ip_pos=ipos+[85,-8,105,22];
                    set_param(delayBlock,'Position',ip_pos);
                    hT=this.getDutOutportType(this.getTopNetwork,ii);

                    isTypeEnum=hT.isArrayOfEnums||hT.isEnumType;
                    if isTypeEnum

                        if hT.isArrayOfEnums
                            typeName=hT.BaseType.Name;
                        else
                            typeName=hT.Name;
                        end


                        set_param(delayBlock,...
                        'InitialCondition',this.getDefaultValueForEnum(typeName));
                    end
                end


                if doVal
                    dutLat=this.getDutExtraLatency(ii);
                    remLat=mod(dutLat,inputRate);
                    offsetLat=inputRate-remLat;
                    dutRTCBlock=[newssPath,'/dutRT',idxstr];
                    if remLat>0
                        add_block('hdlmdlgenlib/DelayRT',dutRTCBlock);
                        set_param(dutRTCBlock,'LinkStatus','none');
                        set_param([dutRTCBlock,'/RT'],'OutPortSampleTimeMultiple',...
                        int2str(inputRate));
                        set_param([dutRTCBlock,'/Delay'],'NumDelays',...
                        int2str(offsetLat));
                    else
                        add_block('built-in/RateTransition',dutRTCBlock);
                        set_param(dutRTCBlock,'OutPortSampleTimeOpt',...
                        'Multiple of input port sample time');
                        set_param(dutRTCBlock,'OutPortSampleTimeMultiple',...
                        int2str(inputRate));
                    end
                    dp_pos=fpos+[85,-8,105,22];
                    set_param(dutRTCBlock,'Position',dp_pos);
                    posMatchBlockFrom=dutRTCBlock;
                else
                    dutRTCBlock='';
                end



                originalModelInputPort=['in',idxstr,'/1'];


                if~isempty(delayBlock)

                    dPort=['pathdelay',idxstr,'/1'];
                    add_line(newssPath,originalModelInputPort,dPort);



                    originalModelInputPort=dPort;
                end



                gmModelInputPort=['from',idxstr,'/1'];


                if~isempty(dutRTCBlock)
                    rtPort=['dutRT',idxstr,'/1'];
                    add_line(newssPath,gmModelInputPort,rtPort);



                    gmModelInputPort=rtPort;
                end


                portType=this.getDutOutportType(this.getTopNetwork,ii);


                if portType.isRecordType

                    bpos=this.handleBusInputs(ii,1,portType,1,balanceDelays,ipos,posMatchBlockInport,posMatchBlockFrom,newssPath,originalModelInputPort,gmModelInputPort);
                    ipos=[ipos(1),bpos(2),ipos(3),bpos(4)];

                elseif portType.BaseType.isRecordType

                    bpos=this.handleBusInputs(ii,1,portType.BaseType,portType.Dimensions,balanceDelays,ipos,posMatchBlockInport,posMatchBlockFrom,newssPath,originalModelInputPort,gmModelInputPort);
                    ipos=[ipos(1),bpos(2),ipos(3),bpos(4)];
                else

                    outPortComplex=this.isDutOutportAtIdxComplex(ii);
                    outPortFloat=this.isDutOutportAtIdxFloat(ii);
                    outPortHalf=this.isDutOutportAtIdxHalf(ii);
                    opName=this.getDutOriginalOutportNameAtIdx(ii);

                    this.handleNonBusInputs(ii,opName,balanceDelays,outPortComplex,outPortFloat,outPortHalf,posMatchBlockInport,newssPath,originalModelInputPort,gmModelInputPort);

                    ipos=fpos+[0,50,0,50];
                end
            end


            this.addEnableAssertionsBlock;
            this.addCleanupScopesBlock;
        end


        function bpos=handleBusInputs(this,index,elemIdx,portType,dimensions,balanceDelays,ipos,posMatchBlockInport,posMatchBlockFrom,newssPath,originalModelInputPort,gmModelInputPort)


            if dimensions>1

                selectorNameInport=[newssPath,'/Selector_Inport'];
                selectorNameFrom=[newssPath,'/Selector_From'];

                selectorInportPos=get_param(posMatchBlockInport,'Position')+[60,0,60,0];
                selectorFromPos=get_param(posMatchBlockFrom,'Position')+[60,0,60,0];

                positionOffset=[0,50*portType.NumberOfMembersFlattened+10,0,50*portType.NumberOfMembersFlattened+10];

                for ii=1:dimensions


                    selectorInportBlkHandle=add_block('simulink/Signal Routing/Selector',selectorNameInport,'MakeNameUnique','on');
                    selectorInportBlkUniqueName=get_param(selectorInportBlkHandle,'Name');


                    set_param(selectorInportBlkHandle,'IndexOptions','Index vector (dialog)');





                    if dimensions<3
                        set_param(selectorInportBlkHandle,'Indices',int2str(ii));
                        set_param(selectorInportBlkHandle,'InputPortWidth',int2str(dimensions));
                    else



                        set_param(selectorInportBlkHandle,'InputPortWidth',int2str(dimensions));
                        set_param(selectorInportBlkHandle,'Indices',int2str(ii));
                    end

                    set_param(selectorInportBlkHandle,'Position',selectorInportPos);
                    selectorInportPos=selectorInportPos+positionOffset;

                    selectorInportPort=[selectorInportBlkUniqueName,'/1'];
                    add_line(newssPath,originalModelInputPort,selectorInportPort);


                    selectorFromBlkHandle=add_block('simulink/Signal Routing/Selector',selectorNameFrom,'MakeNameUnique','on');
                    selectorFromBlkUniqueName=get_param(selectorFromBlkHandle,'Name');


                    set_param(selectorFromBlkHandle,'IndexOptions','Index vector (dialog)');





                    if dimensions<3
                        set_param(selectorFromBlkHandle,'Indices',int2str(ii));
                        set_param(selectorFromBlkHandle,'InputPortWidth',int2str(dimensions));
                    else



                        set_param(selectorFromBlkHandle,'InputPortWidth',int2str(dimensions));
                        set_param(selectorFromBlkHandle,'Indices',int2str(ii));
                    end

                    set_param(selectorFromBlkHandle,'Position',selectorFromPos);
                    selectorFromPos=selectorFromPos+positionOffset;

                    selectorFromPort=[selectorFromBlkUniqueName,'/1'];
                    add_line(newssPath,gmModelInputPort,selectorFromPort);

                    bpos=this.handleBusInputs(index,ii,portType,1,balanceDelays,ipos,[newssPath,'/',selectorInportBlkUniqueName],[newssPath,'/',selectorFromBlkUniqueName],newssPath,selectorInportPort,selectorFromPort);
                end
            else
                busselInportPos=get_param(posMatchBlockInport,'Position')+[60,0,60,0];

                [busselInport,numElems]=this.createBusSelector(newssPath,portType,busselInportPos);

                busselInportPos=get_param(busselInport,'Position');
                busselInportPos=busselInportPos+[0,0,-25,numElems*10];
                set_param(busselInport,'Position',busselInportPos);

                busselInport=split(busselInport,'/');
                busselInport=busselInport{end};
                busselInportPort=[busselInport,'/1'];
                add_line(newssPath,originalModelInputPort,busselInportPort);

                busselHeight=busselInportPos(4)-busselInportPos(2);
                busselFromPos=[busselInportPos(1)+20,busselInportPos(4)+10,busselInportPos(3)+20,busselInportPos(4)+10+busselHeight];
                [busselFrom,~]=this.createBusSelector(newssPath,portType,busselFromPos);

                busselFrom=split(busselFrom,'/');
                busselFrom=busselFrom{end};
                busselFromPort=[busselFrom,'/1'];
                add_line(newssPath,gmModelInputPort,busselFromPort);

                nameBase=this.getDutOriginalOutportNameAtIdx(index);
                posOffset=[0,0,0,0];

                for jj=1:numElems
                    hT=portType.MemberTypesFlattened(jj);
                    tInfo=pirgetdatatypeinfo(portType.MemberTypesFlattened(jj));

                    outPortComplex=tInfo.iscomplex;
                    outPortFloat=hT.getLeafType.isFloatType;
                    outPortHalf=hT.getLeafType.isHalfType;
                    opName=[nameBase,'_',matlab.lang.makeValidName(portType.MemberNamesFlattened{jj})];

                    this.handleNonBusInputs(index,[opName,'_',int2str(elemIdx)],balanceDelays,outPortComplex,outPortFloat,outPortHalf,[newssPath,'/',busselInport],newssPath,[busselInport,'/',int2str(jj)],[busselFrom,'/',int2str(jj)],posOffset);
                    posOffset=posOffset+[0,50,0,50];
                end

                iposHeight=ipos(4)-ipos(2);
                busselFromPos=busselFromPos+posOffset;
                bpos=[ipos(1),busselFromPos(2),ipos(3),busselFromPos(2)+iposHeight];
            end
        end


        function handleNonBusInputs(this,index,opName,balanceDelays,outPortComplex,outPortFloat,outPortHalf,posMatchBlock,newssPath,originalModelInputPort,gmModelInputPort,posOffset)

            if nargin<12
                posOffset=[0,0,0,0];
            end


            assertblock=slpir.PIR2SL.getUniqueName(['Assert_',opName]);

            compblock=[newssPath,'/',assertblock];
            this.addCompareComp(index,balanceDelays,outPortComplex,...
            outPortFloat,outPortHalf,compblock,posMatchBlock,opName,posOffset);



            assertBlkP1=[assertblock,'/1'];

            add_line(newssPath,originalModelInputPort,assertBlkP1,'Autorouting','on');



            assertBlkP2=[assertblock,'/2'];

            add_line(newssPath,gmModelInputPort,assertBlkP2,'Autorouting','on');
        end


        function configureLinkBlockOnly(this)
            this.createCoverifyBlock;
            srcBlkPath=this.getTBDutPath;
            oldPos=get_param(srcBlkPath,'Position');
            orient=get_param(srcBlkPath,'Orientation');
            cosimblkPath=this.getCosimLinkDutPath;
            set_param(cosimblkPath,'Position',oldPos);
            set_param(cosimblkPath,'Orientation',orient);
        end


        function configureLinkBlockAndReplaceDut(this)
            this.createCoverifyBlock;

            dutInCosimMdl=this.getCosimDutPath;
            delete_block(dutInCosimMdl);

            srcBlkPath=this.getTBDutPath;
            oldPos=get_param(srcBlkPath,'Position');
            orient=get_param(srcBlkPath,'Orientation');

            cosimblkPath=this.getCosimLinkDutPath;
            set_param(cosimblkPath,'Position',oldPos);
            set_param(cosimblkPath,'Orientation',orient);
        end


        function createCoverifyBlock(this)
            cosimblkPath=this.getCosimLinkDutPath;

            if this.hSLHDLCoder.DUTMdlRefHandle>0



                tbDutPath=this.getTBDutPath;


                variants=get_param(this.hSLHDLCoder.DUTMdlRefHandle,'Variants');
                if strcmp(variants(1).Name,'HDLC_internal_variant_OriginalDUT')
                    bName1=variants(1).BlockName;
                    bName2=variants(2).BlockName;
                else
                    bName1=variants(2).BlockName;
                    bName2=variants(1).BlockName;
                end
                dutModel=get_param(bName1,'ModelName');
                gmModel=get_param(bName2,'ModelName');
                blkh=add_block(tbDutPath,cosimblkPath);

                set_param(blkh,'ModelName',dutModel);




                set_param(tbDutPath,'ModelName',gmModel);

            elseif this.hSLHDLCoder.nonTopDut
                tbDutPath=this.hSLHDLCoder.OrigStartNodeName;
                add_block(tbDutPath,cosimblkPath);

            else
                add_block(this.getGoldenMdlDutPath,cosimblkPath);
            end
        end






        function createCoverifyMdl(this,drawTB)
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

            set_param(linkMdlName,'ShowPortDataTypes','off');


            this.cosimMdlName=hb.OutModelFile;
            cosimMdlPath=fullfile(this.getCodeGenDir,this.cosimMdlName);

            tbSysName=this.getTestbenchSystem;
            this.dutSrcCaptureSSName=[tbSysName,'/ToCoverifySrc'];
            this.dutSinkCaptureSSName=[tbSysName,'/ToCoverifySink'];
            this.cosimSrcSSName=[tbSysName,'/FromCoverifySrc'];
            this.cosimSinkSSName=[tbSysName,'/Compare'];
            this.simStartSSName=[tbSysName,'/Start Simulator'];
            link=sprintf('<a href="matlab:open_system(''%s'')">%s</a>',...
            cosimMdlPath,this.cosimMdlName);
            hdldisp(message('hdlcoder:hdldisp:GeneratingNewVModel',link));
            if drawTB


                drawSrcModelDut=true;
                hb.drawTestBench(drawSrcModelDut);
            end


            load_system('hdlmdlgenlib');
        end


        function openScopes(this)
            if this.getDutHasOutputs
                if(strcmpi(this.cosimSetup,'CoverifyBlockAndDut'))
                    dutCompareSS=this.getCosimSinkSSName;
                    blks=find_system(dutCompareSS,'LookUnderMasks','all',...
                    'MatchFilter',@Simulink.match.internal.activePlusStartupVariantSubsystem,...
                    'blocktype','Scope');

                    for ii=1:length(blks)
                        blk=blks{ii};
                        scopeblkHndl=get_param(blk,'Handle');
                        set_param(blk,'Open','on');
                        figHndle=get_param(scopeblkHndl,'Figure');
                        set(figHndle,'Position',[120,258,618,456]);
                    end

                    open_system(blks);
                end
            end
        end

        function saveCoverifyMdl(this)
            genMdlName=this.getCosimModelName;
            fullGenMdlName=fullfile(this.getCodeGenDir,[genMdlName,'.slx']);
            save_system(genMdlName,fullGenMdlName,'OverwriteIfChangedOnDisk',...
            true,'SaveModelWorkspace',false);
        end


        function generateCoverifyModel(this)
            if(strcmpi(this.cosimSetup,'CoverifyBlockAndDut'))
                this.createCoverifyMdl;

                isStreamedDUT=streamingmatrix.hasStreamedIOPorts(this.hPir.getTopNetwork);

                if~isStreamedDUT
                    this.configureLinkBlockInParallel;
                else
                    this.configureLinkBlockInParallelForStreamedDUT;
                end

                this.saveCoverifyMdl;
                slpir.PIR2SL.clearNameMap;
            end
        end


        function validateModel(~)

        end


        function doIt(this)
            hasLicense=this.checkCoverifyLicense;
            if hasLicense
                current_system=this.hSLHDLCoder.getStartNodeName;
                this.validateModel;

                this.generateCoverifyModel;
                hdldisp(message('hdlcoder:hdldisp:FinishGenVModel'));
                hdlresetgcb(current_system);
            else
                warning(message('hdlcoder:cosim:edacosimlicenseissue',...
                'generatecoverifymodel'));
            end
        end
    end
end



