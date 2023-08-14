function varargout=slBus(method,varargin)







    [varargout{1:nargout}]=feval(method,varargin{1:end});

    function prm=LocalGetBlockForPortPrm(portH,parameterName)%#ok
        persistent subsys;
        parentName=get_param(portH,'Parent');

        if strcmp(get_param(parentName,'BlockType'),'Goto')
            fromBlocks=get_param(parentName,'FromBlocks');

            prm=get_param(fromBlocks(1).handle,parameterName);
            return;
        end

        if isempty(subsys)||~strcmp(parentName,subsys.name)
            subsys.name=parentName;
            blks=get_param(subsys.name,'Blocks');

            if~iscell(blks)
                subsys.blocks{1}=strrep(blks,'/','//');
            else
                subsys.blocks=strrep(blks,'/','//');
            end
            subsys.ports=get_param(subsys.name,'Ports');
        end

        subsys.blocks=processBlocksForCompositePorts(parentName,subsys.blocks);

        portNumber=get_param(portH,'PortNumber');
        portType=get_param(portH,'PortType');

        switch portType
        case 'inport'
            prm=get_param([subsys.name,'/',subsys.blocks{portNumber}],...
            parameterName);
        case 'outport'
            prm=get_param([subsys.name,'/',...
            subsys.blocks{end-subsys.ports(2)+portNumber}],...
            parameterName);
        case 'enable'
            prm=get_param([subsys.name,'/',subsys.blocks{portNumber}],...
            parameterName);
        case 'trigger'
            prm=get_param([subsys.name,'/',subsys.blocks{portNumber}],...
            parameterName);
        case 'StateEnable'
            prm=get_param([subsys.name,'/',subsys.blocks{portNumber}],...
            parameterName);
        case 'Reset'
            prm=get_param([subsys.name,'/',subsys.blocks{portNumber}],...
            parameterName);
        otherwise
            MSLDiagnostic('RTW:buildProcess:UnknownPortType',portType).reportAsWarning;
        end

        function blocks=processBlocksForCompositePorts(parentPath,blksIn)
            blocks=blksIn;


            parent=get_param(parentPath,'Handle');
            if~Simulink.BlockDiagram.Internal.hasCompositePorts(parent)
                return;
            end


            if~strcmpi(get_param(bdroot(parentPath),'SimulationStatus'),'Paused')
                return;
            end



            lastPort=[];
            toRemove=[];
            for i=1:numel(blocks)

                b=get_param([parentPath,'/',blocks{i}],'Handle');

                bType=get_param(b,'BlockType');
                if~any(strcmpi(bType,{'Inport','Outport'}))||~strcmpi(get_param(b,'IsComposite'),'on')
                    continue;
                end

                thisPort=Simulink.BlockDiagram.Internal.getInterfaceModelBlock(b).port;
                if~isequal(thisPort,lastPort)

                    lastPort=thisPort;

                    pbs=thisPort.blocks.toArray();
                    syntBlock=Simulink.BlockDiagram.Internal.getSlBlock(pbs(end));

                    blocks{i}=strrep(get_param(syntBlock,'Name'),'/','//');
                else

                    toRemove(end+1)=i;
                end
            end

            blocks(toRemove)=[];

            function outportH=outPortH2bus(strucBus,systemName,outPortHandles)
                persistent handleNum;

                if isempty(handleNum)
                    handleNum=1;
                end

                if strucBus.type==2&&strucBus.node.isVirtualBus
                    numInports=length(strucBus.node.leafe);
                    outportH=zeros(1,numInports);
                    for i=1:numInports
                        outportH(i)=outPortH2bus(strucBus.node.leafe{i},...
                        systemName,outPortHandles);
                    end
                    outportH=coder.internal.GraphicalUtils.addMuxBlock(strucBus,systemName,outportH);
                elseif strucBus.type==2&&strucBus.node.hasBusObject
                    outportH=outPortHandles(handleNum);
                    if~strcmp(get_param(get_param(outportH,'Parent'),...
                        'BlockType'),'BusSelector')
                        set_param(outportH,'Name',strucBus.name);
                    end
                    handleNum=handleNum+1;
                elseif strucBus.type==1
                    outportH=outPortHandles(handleNum);
                    outportH=coder.internal.IOUtils.LocalSetInPortNonAutoSCOrUdi(systemName,outportH,strucBus,handleNum);
                    if~strcmp(get_param(get_param(outportH,'Parent'),...
                        'BlockType'),'BusSelector')
                        set_param(outportH,'Name',strucBus.name);
                    end
                    handleNum=handleNum+1;
                else
                    disp(DAStudio.message('RTW:buildProcess:UnknownTypeOfNode'));
                end



                function[outportH,thisHdl,inlineSubsystemName]=addInportBlock(strucBus,modelName,thisHdl)%#ok
                    persistent inportPos;
                    persistent portNumber;
                    persistent fcnPortIdx;
                    persistent addedFcnCallGen;

                    inlineSubsystemName='';
                    exportFcns=thisHdl.exportFcns;
                    numFcnCalls=0;
                    fcnCallRecords=[];


                    if exportFcns
                        fcnCallInps=thisHdl.mdlFcnCallInps;
                        if isempty(fcnCallInps.Inports)
                            numFcnCalls=1;
                        else
                            numFcnCalls=length(fcnCallInps.Inports);
                        end
                    end

                    if isfield(thisHdl,'fcnCallRecords')
                        fcnCallRecords=thisHdl.fcnCallRecords;
                    end

                    isStrucFcnCallInport=false;
                    exportDirect=false;
                    exportFromWrapper=false;


                    if exportFcns
                        fcnCallSSPortH=get_param(thisHdl.mdlExpFcnCallSS,'PortHandles');
                        origPortH=strucBus.prm.OrigPortH;
                        if isempty(fcnCallSSPortH.Trigger)

                            for fIdx=1:length(fcnCallInps.Inports)
                                if get_param(origPortH,'PortNumber')==(fcnCallInps.Inports(fIdx).PortIdx+1)&&...
                                    get_param(get_param(origPortH,'Parent'),'Handle')==thisHdl.mdlExpFcnCallSS
                                    isStrucFcnCallInport=true;
                                    exportFromWrapper=true;
                                    break;
                                end
                            end
                        else

                            if get_param(origPortH,'PortNumber')==(length(fcnCallSSPortH.Inport)+1)&&...
                                get_param(get_param(origPortH,'Parent'),'Handle')==thisHdl.mdlExpFcnCallSS
                                isStrucFcnCallInport=true;
                                exportDirect=true;
                            end
                        end
                    end

                    if isempty(inportPos)
                        inportPos=[70,20,90,30];
                        portNumber=0;
                        fcnPortIdx=1;
                        addedFcnCallGen=0;
                    end

                    if numFcnCalls>0&&exportFcns&&isStrucFcnCallInport&&~addedFcnCallGen
                        addedFcnCallGen=1;
                        if strcmp(get_param(modelName,'AutosarCompliant'),'on')==1||...
                            numFcnCalls>1
                            pFcnCall=ones(1,numFcnCalls);
                            fcnCallTs=ones(1,numFcnCalls);
                            timerSource=ones(1,numFcnCalls);
                            extTimerApi='getTick()';
                            tickRes=ones(1,numFcnCalls);
                            tickLen=32*ones(1,numFcnCalls);
                            set_param(modelName,'TasksWithSamePriorityMsg','none')
                            inputH=add_block('expfcnlib/FcnCallGen',...
                            [modelName,'/__FcnCallGen__',sprintf('%d',portNumber)],...
                            'Position',rtwprivate('sanitizePosition',inportPos),...
                            'ForegroundColor','black',...
                            'ShowName','on','FontSize',10);
                            set_param(inputH,'periodicFcnCall',strcat('[',num2str(pFcnCall),']'),...
                            'fcnCallTs',strcat('[',num2str(fcnCallTs),']'),...
                            'timerSource',strcat('[',num2str(timerSource),']'),...
                            'extTimerAPI',strcat('[',extTimerApi,']'),...
                            'tickRes',strcat('[',num2str(tickRes),']'),...
                            'tickLen',strcat('[',num2str(tickLen),']'));
                        else
                            inputH=add_block(['simulink/Ports &',sprintf('\n'),'Subsystems/Function-Call',sprintf('\n'),'Generator'],...
                            [modelName,'/__FcnCallGen__',sprintf('%d',portNumber)],...
                            'Position',rtwprivate('sanitizePosition',inportPos),...
                            'ForegroundColor','black',...
                            'ShowName','on','FontSize',10);
                            set_param(inputH,'sample_time','-1');
                        end


                        tempSID=Simulink.ID.getSID(inputH);



                        origSID=[modelName,':0'];




                        rtwprivate('rtwattic','addToSIDMap',tempSID,origSID);

                        set_param(inputH,'Diagnostics','AllowInheritedTsInSrc');
                        muxH=add_block('built-in/demux',[modelName,'/_FcnCallSplitter'],...
                        'Position',rtwprivate('sanitizePosition',inportPos+[20,0,20,0]),...
                        'ForegroundColor','black',...
                        'ShowName','on','FontSize',10);


                        tempSID=Simulink.ID.getSID(muxH);


                        rtwprivate('rtwattic','addToSIDMap',tempSID,origSID);

                        set_param(muxH,'Outputs',num2str(numFcnCalls));
                        portH=get_param(inputH,'PortHandles');
                        outportH=portH.Outport;
                        portH=get_param(muxH,'PortHandles');
                        inportH=portH.Inport;
                        add_line(modelName,outportH,inportH);
                    end

                    inportPos=inportPos+[0,30,0,30];
                    portNumber=portNumber+1;

                    if exportFcns&&strucBus.type==1&&...
isStrucFcnCallInport
                        expFcnName=[];
                        expFcnDscr='';
                        expFcnRequirementInfo='';
                        candidateName='';
                        if~isempty(strucBus.name)
                            if iscvar(strucBus.name)
                                expFcnName=strucBus.name;
                            else
                                candidateName=sprintf('''%s''',strucBus.name);
                            end
                        end
                        if isempty(expFcnName)&&isfield(strucBus,'portName')
                            if iscvar(strucBus.portName)
                                expFcnName=strucBus.portName;
                            else
                                if isempty(candidateName)
                                    candidateName=sprintf('''%s''',strucBus.portName);
                                else
                                    candidateName=sprintf('%s, ''%s''',candidateName,strucBus.portName);
                                end
                            end
                        end
                        if isempty(expFcnName)


                            if(strcmp(get_param(modelName,'AutosarCompliant'),'on')==1)
                                expFcnName=get(fcssH,'Name');
                            else
                                DAStudio.error('RTW:buildProcess:noValidFcnCallIDErr',...
                                portNumber,candidateName);
                            end
                        end
                        if~isempty(strucBus.portDesription)
                            expFcnDscr=strucBus.portDesription;
                        end
                        if~isempty(strucBus.requirementInfo)
                            expFcnRequirementInfo=strucBus.requirementInfo;
                        end
                        expFcnH=add_block('expfcnlib/Exported Function',...
                        [modelName,'/__ExpFcn__',sprintf('%d',portNumber)],...
                        'Position',rtwprivate('sanitizePosition',inportPos+[40,0,40,0]),...
                        'LinkStatus','inactive',...
                        'ExportedFcnName',expFcnName,...
                        'Description',expFcnDscr,...
                        'RequirementInfo',expFcnRequirementInfo);
                        if~isempty(fcnCallInps)
                            inlineSubsystemName=coder.internal.RightClickBuildExportFunction.setExpFcnSubsystemParameters(fcnCallInps,fcnPortIdx,expFcnH,expFcnName);
                        end



                        assert(length(find_system(expFcnH,'LookUnderMasks','On',...
                        'BlockType','Outport'))==1);
                        underInitDetect=...
                        get_param(modelName,'UnderspecifiedInitializationDetection');
                        expFcnOutportBlk=[getfullname(expFcnH),'/Out1'];
                        if strcmpi(underInitDetect,'Simplified')
                            set_param(expFcnOutportBlk,...
                            'SourceOfInitialOutputValue','Input signal');
                        else
                            assert(strcmpi(underInitDetect,'Classic'));
                            set_param(expFcnOutportBlk,...
                            'SourceOfInitialOutputValue','Dialog',...
                            'InitialOutput','[]');
                        end


                        tempSID=Simulink.ID.getSID(expFcnH);


                        origSID=[modelName,':0'];




                        rtwprivate('rtwattic','addToSIDMap',tempSID,origSID);

                        set_param(expFcnH,'UserData',portNumber);
                        expFcnPortH=get_param(expFcnH,'PortHandles');
                        portH=get_param([modelName,'/_FcnCallSplitter'],'PortHandles');
                        outportH=portH.Outport(fcnPortIdx);
                        add_line(modelName,outportH,expFcnPortH.Trigger);
                        outportH=expFcnPortH.Outport;
                    else
                        inputH=add_block('built-in/Inport',...
                        [modelName,'/xxInPortxx',sprintf('%d',portNumber)],...
                        'Position',rtwprivate('sanitizePosition',inportPos),...
                        'ForegroundColor','black',...
                        'ShowName','on','FontSize',10,'Interpolate','off');

                        if rtwprivate('rtwattic','hasSIDMap')

                            tempInportSid=Simulink.ID.getSID(inputH);
                            if strucBus.type==1||(strucBus.type==2&&strucBus.node.hasBusObject)
                                origInportSid=strucBus.blkSid;
                            else


                                origInportSid=coder.internal.Utilities.extractBlkSid(strucBus);
                            end






                            rtwprivate('rtwattic','addToSIDMap',tempInportSid,origInportSid);
                        end


                        if exportFcns
                            set_param(inputH,'UserData',portNumber);
                        end
                    end

                    if exportFcns==1&&strucBus.type==1&&...
isStrucFcnCallInport
                        fcnPortIdx=fcnPortIdx+1;
                    else
                        if isfield(strucBus,'portName')
                            LocalSetName(inputH,strucBus.portName,'Inport');
                        else
                            LocalSetName(inputH,strucBus.name,'Inport');
                        end
                        portH=get_param(inputH,'PortHandles');
                        outportH=portH.Outport;
                    end
                    set_param(outportH,'Name',strucBus.name);

                    if exportFcns&&strucBus.type==1&&...
isStrucFcnCallInport

                    else
                        bNeedDtOverride=...
                        (strucBus.prm.isFixPt&&strucBus.prm.isScaledDouble);



                        if~bNeedDtOverride&&strucBus.type==1
                            coder.internal.ParameterUtils.LocalSetBlockParameters(inputH,strucBus.prm,thisHdl)
                        end

                        outportH=coder.internal.IOUtils.LocalSetInPortNonAutoSCOrUdi(modelName,outportH,strucBus,portNumber);

                        if bNeedDtOverride&&strucBus.type==1
                            [outportH,inPortBlkH]=LocalAddSignalSpec(modelName,outportH);
                            coder.internal.ParameterUtils.LocalSetBlockParameters(inPortBlkH,strucBus.prm,thisHdl);
                        end




                        if strucBus.type==2&&strucBus.node.hasBusObject
                            coder.internal.BusUtils.localSetBusObjectParams(inputH,strucBus.node.busObject);
                            coder.internal.SampleTimeChecks.LocalSetSampleTime(inputH,strucBus.prm,thisHdl);
                            if isequal(strucBus.node.busObject.asStruct,'on')


                                set_param(inputH,'PortDimensions',strucBus.prm.SymbolicDimensions);
                            end
                        end
                    end

                    if isfield(thisHdl,'fcnCallRecords')
                        thisHdl.fcnCallRecords=fcnCallRecords;
                    end


                    function[outportH_output,inH]=LocalAddSignalSpec(modelName,outportH)

                        persistent uniqueNumber;

                        if isempty(uniqueNumber)
                            uniqueNumber=1;
                        else
                            uniqueNumber=uniqueNumber+1;
                        end

                        pos=get_param(outportH,'Position');

                        outPortPos=[pos(1)+100,pos(2)-5,pos(1)+140,pos(2)+5];

                        scaledDoubleSigSpecBlkName=...
                        sprintf('%s/xxSigSpecxx_%d',modelName,uniqueNumber);

                        scaleDblH=add_block('built-in/SubSystem',...
                        scaledDoubleSigSpecBlkName,...
                        'Position',rtwprivate('sanitizePosition',outPortPos));


                        tempSID=Simulink.ID.getSID(scaleDblH);


                        origSID=[modelName,':0'];




                        rtwprivate('rtwattic','addToSIDMap',tempSID,origSID);

                        inH=add_block('built-in/Inport',...
                        [scaledDoubleSigSpecBlkName,'/In1'],...
                        'Position',[15,15,35,35]);

                        tempSID=Simulink.ID.getSID(inH);



                        rtwprivate('rtwattic','addToSIDMap',tempSID,origSID);

                        outH=add_block('built-in/Outport',...
                        [scaledDoubleSigSpecBlkName,'/Out1'],...
                        'Position',[115,15,135,35]);


                        tempSID=Simulink.ID.getSID(outH);



                        rtwprivate('rtwattic','addToSIDMap',tempSID,origSID);

                        in_PortH=get_param(inH,'PortHandles');
                        out_PortH=get_param(outH,'PortHandles');
                        add_line(scaleDblH,in_PortH.Outport,out_PortH.Inport);

                        portH=get_param(scaleDblH,'PortHandles');
                        add_line(modelName,outportH,portH.Inport);
                        outportH_output=portH.Outport;

                        set_param(scaleDblH,'DataTypeOverride','ScaledDoubles');




                        function LocalAddOutPortBlock(modelName,outPortH,strucBus,thisHdl,varargin)%#ok
                            persistent portNumber;

                            if isempty(portNumber)
                                portNumber=1;
                            else
                                portNumber=portNumber+1;
                            end

                            bNeedSignalSpec=true;

                            if nargin>4&&~Simulink.BlockDiagram.Internal.isCompositePortBlock(get_param(varargin{1},'Handle'))
                                srcBlk=varargin{1};
                                bNeedSignalSpec=false;
                            else
                                srcBlk='built-in/Outport';
                            end

                            bBlockParamSet=false;

                            if strucBus.type==1||(strucBus.type==2&&strucBus.node.hasBusObject)

                                if strucBus.type==1&&bNeedSignalSpec&&...
                                    strucBus.prm.isFixPt&&strucBus.prm.isScaledDouble
                                    [outPortH,inPortBlkH]=LocalAddSignalSpec(modelName,outPortH);
                                    coder.internal.ParameterUtils.LocalSetBlockParameters(inPortBlkH,strucBus.prm,thisHdl);
                                    bBlockParamSet=true;
                                end

                                if~strcmp(strucBus.prm.RTWStorageClass,'Auto')||...
                                    ~isempty(strucBus.prm.SignalObject)
                                    outPortH=coder.internal.IOUtils.LocalSetOutPortNonAutoSCOrUdi(modelName,outPortH,strucBus,portNumber);
                                else
                                    if~strcmp(get_param(get_param(outPortH,'Parent'),...
                                        'BlockType'),'BusSelector')
                                        set_param(outPortH,'Name',strucBus.name);
                                    end
                                end
                            else
                                if~strcmp(get_param(get_param(outPortH,'Parent'),...
                                    'BlockType'),'BusSelector')
                                    set_param(outPortH,'Name',strucBus.name);
                                end
                            end

                            pos=get_param(outPortH,'Position');
                            outPortPos=[pos(1)+100,pos(2)-5,pos(1)+120,pos(2)+5];
                            outPortBlkH=...
                            add_block(srcBlk,sprintf('%s/xxOutPortxx_%d',modelName,portNumber),...
                            'Position',rtwprivate('sanitizePosition',outPortPos));
                            if rtwprivate('rtwattic','hasSIDMap')

                                tempOutportSid=Simulink.ID.getSID(outPortBlkH);
                                if strucBus.type==1||(strucBus.type==2&&strucBus.node.hasBusObject)
                                    origOutportSid=strucBus.blkSid;
                                else


                                    origOutportSid=coder.internal.Utilities.extractBlkSid(strucBus);
                                end






                                rtwprivate('rtwattic','addToSIDMap',tempOutportSid,origOutportSid);
                            end
                            portH=get_param(outPortBlkH,'PortHandles');

                            add_line(modelName,outPortH,portH.Inport);

                            if isfield(strucBus,'portName')
                                LocalSetName(outPortBlkH,strucBus.portName,'Outport');
                            else
                                LocalSetName(outPortBlkH,strucBus.name,'Outport');
                            end

                            if strucBus.type==1&&bNeedSignalSpec&&~bBlockParamSet
                                coder.internal.ParameterUtils.LocalSetBlockParameters(outPortBlkH,strucBus.prm,thisHdl);
                            elseif strucBus.type==2&&strucBus.node.hasBusObject
                                coder.internal.BusUtils.localSetBusObjectParams(outPortBlkH,strucBus.node.busObject);
                                coder.internal.SampleTimeChecks.LocalSetSampleTime(outPortBlkH,strucBus.prm,thisHdl);
                            end


                            function outportH=LocalAddBusSelectBlock(modelName,outPortH,busCellArray)
                                persistent busSelectNumber;
                                persistent last_y_max;

                                if isempty(busSelectNumber)
                                    busSelectNumber=1;
                                    last_y_max=0;
                                else
                                    busSelectNumber=busSelectNumber+1;
                                end

                                busString='';
                                numberOfOutports=length(busCellArray);

                                for i=1:numberOfOutports-1
                                    busString=[busString,busCellArray{i},','];%#ok<AGROW>
                                end
                                busString=[busString,busCellArray{end}];

                                pos=get_param(outPortH,'Position');
                                len=numberOfOutports*20;
                                if(pos(2)-len/2)<0
                                    demuxPos=[pos(1)+100,last_y_max+20,pos(1)+105,last_y_max+len+20];
                                    last_y_max=last_y_max+len+20;
                                else
                                    demuxPos=[pos(1)+100,last_y_max+10,pos(1)+105,last_y_max+len+10];
                                    last_y_max=last_y_max+len+10;
                                end

                                demuxBlkH=add_block('built-in/BusSelector',...
                                [modelName,'/temporaryBusSelectName_',...
                                sprintf('%d',busSelectNumber)],...
                                'Position',rtwprivate('sanitizePosition',demuxPos),'ForegroundColor','black',...
                                'OutputSignals',busString);


                                tempSID=Simulink.ID.getSID(demuxBlkH);


                                origSID=[modelName,':0'];




                                rtwprivate('rtwattic','addToSIDMap',tempSID,origSID);

                                portH=get_param(demuxBlkH,'PortHandles');
                                add_line(modelName,outPortH,portH.Inport);
                                outportH=portH.Outport;

                                function num=getInstanceNumber(name)
                                    persistent nameCellArray;
                                    persistent nameNumArray;
                                    num=0;

                                    if isempty(nameCellArray)
                                        nameCellArray{1}=name;
                                        nameNumArray(1)=0;
                                    else
                                        res=strcmp(nameCellArray,name);
                                        if any(res)
                                            num=nameNumArray(res)+1;
                                            nameNumArray(res)=num;
                                        else
                                            nameCellArray{end+1}=name;
                                            nameNumArray(end+1)=0;
                                        end
                                    end


                                    function LocalSetName(blkHdl,name,type)
                                        persistent num;
                                        if isempty(name)||strcmp(name,'<')
                                            if isempty(num)
                                                num=1;
                                            else
                                                num=num+1;
                                            end
                                            name=[type,sprintf('%d',num)];
                                            set_param(blkHdl,'ShowName','off');
                                        end

                                        new_name=name;
                                        new_name_no_cr=strrep(name,sprintf('\n'),' ');

                                        for i=1:20
                                            try
                                                set_param(blkHdl,'Name',new_name);
                                                break;
                                            catch exc %#ok<NASGU>
                                                n=getInstanceNumber(new_name_no_cr);
                                                new_name=sprintf('%s%c',new_name_no_cr,coder.internal.ModelNameUtils.getNameSuffix(abs(n-1)));
                                            end
                                        end


                                        function ResetNameStruct()%#ok<DEFNU> 
                                            clear getInstanceNumber;
                                            clear LocalSetName;
