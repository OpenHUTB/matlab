function sysHdl=slPrepMdlForExportFcn(modelH,expSysHdl,expFcnFileName)



    modelName=[get_param(expSysHdl,'Name'),'_expfcn'];
    tmpMdl=find_system('type','block_diagram','Name',modelName);
    if~isempty(tmpMdl)
        close_system(tmpMdl,0);
    end
    set_param(modelH,'Name',modelName);
    DisableDiagnosticOptionWarning(modelH);


    expSysName=[modelName,'/',get_param(expSysHdl,'Name')];
    new_expSysHdl=find_system(modelName,'SearchDepth',1,'BlockType','SubSystem',...
    'Name',get_param(expSysHdl,'Name'));
    if(iscell(new_expSysHdl))
        new_expSysHdl=new_expSysHdl{1};
    end
    subsystems=find_system(new_expSysHdl,'SearchDepth',1,'BlockType','SubSystem');
    for i=1:length(subsystems)
        sys=subsystems{i};

        if strcmp(sys,new_expSysHdl)
            continue;
        end
        ssPortH=get_param(sys,'PortHandles');
        if~isempty(ssPortH.Trigger)
            trigBlk=LocalGetBlockPathForSysPort(ssPortH.Trigger);
            if~strcmp(get_param(trigBlk,'TriggerType'),'function-call')
                for j=1:length(ssPortH.Inport)
                    inpBlk=LocalGetBlockPathForSysPort(ssPortH.Inport(j));
                    if~strcmp(get_param(inpBlk,'LatchByDelayingOutsideSignal'),'off')
                        DAStudio.error('RTW:buildProcess:expTrigSystemNotAllowLatch',...
                        strrep(getfullname(inpBlk),sprintf('\n'),'\n'))
                    end
                end







                trigPortH=ssPortH.Trigger;
                lineH=get_param(trigPortH,'Line');
                trigSrcBlkH=get_param(lineH,'SrcBlockHandle');
                trigSrcPortH=get_param(lineH,'SrcPortHandle');

                tmpLine=get_param(trigSrcPortH,'Line');
                dstBlks=get_param(tmpLine,'DstBlockHandle');
                if length(dstBlks)>1
                    DAStudio.error('RTW:buildProcess:trigSignalBranch',...
                    strrep(getfullname(trigSrcBlkH),sprintf('\n'),'\n'))
                end

                if~strcmp(get_param(trigSrcBlkH,'BlockType'),'Inport')
                    DAStudio.error('RTW:buildProcess:trigPortMustBeDrivenByInport',...
                    strrep(getfullname(trigBlk),sprintf('\n'),'\n'))
                end

                srcBlkPos=get_param(trigSrcBlkH,'Position');
                srcBlkX=srcBlkPos(3);
                srcBlkY=(srcBlkPos(2)+srcBlkPos(4))/2;
                trig2FcnCallBlkPos=[srcBlkX+15,srcBlkY-10,srcBlkX+65,srcBlkY+10];
                trig2FcnCallBlkH=add_block('expfcnlib/ConvTrig2FcnCall',...
                [expSysName,'/__ConvTrig2FcnCallFcnCall__',sprintf('%d',i)],...
                'Position',trig2FcnCallBlkPos,...
                'ForegroundColor','black',...
                'LinkStatus','inactive',...
                'ShowName','on','FontSize',10);



                underInitDetect=...
                get_param(modelName,'UnderspecifiedInitializationDetection');
                trig2FcnCallOutportBlk=[getfullname(trig2FcnCallBlkH),'/sys/Out1'];
                if strcmpi(underInitDetect,'Simplified')
                    set_param(trig2FcnCallOutportBlk,...
                    'SourceOfInitialOutputValue','Input signal');
                else
                    assert(strcmpi(underInitDetect,'Classic'));
                    set_param(trig2FcnCallOutportBlk,...
                    'SourceOfInitialOutputValue','Dialog',...
                    'InitialOutput','[]');
                end


                tempSID=Simulink.ID.getSID(trig2FcnCallBlkH);



                origSID=[get_param(bdroot(expSysHdl),'Name'),':0'];






                rtwprivate('rtwattic','addToSIDMap',tempSID,origSID);


                delete_line(expSysName,trigSrcPortH,trigPortH);
                conBlkPortH=get_param(trig2FcnCallBlkH,'PortHandles');
                newTrigH=conBlkPortH.Inport;
                newOutportH=conBlkPortH.Outport;
                add_line(expSysName,trigSrcPortH,newTrigH);
                add_line(expSysName,newOutportH,trigPortH);


                origTrigType=get_param(trigBlk,'triggerType');
                set_param(trig2FcnCallBlkH,'LinkStatus','inactive');
                set_param(trig2FcnCallBlkH,'triggerType',origTrigType);


                set_param(LocalGetBlockPathForSysPort(trigPortH),'triggerType','function-call');
                set_param(LocalGetBlockPathForSysPort(trigPortH),'SampleTimeType','triggered');
                trigBlkPortHdl=get_param(trigBlk,'PortHandles');
                if~isempty(trigBlkPortHdl.Outport)
                    DAStudio.error('RTW:buildProcess:trigPortCannotShowOutport',...
                    strrep(getfullname(trigBlk),sprintf('\n'),'\n'))
                end


                set_param(trig2FcnCallBlkH,'Priority',get_param(sys,'Priority'));
                set_param(sys,'Priority','');
            end
        end
    end


    blksInSys=find_system(new_expSysHdl,'SearchDepth',1);
    for i=1:length(blksInSys)
        blkH=blksInSys{i};
        blockType=get_param(blkH,'BlockType');
        maskType=get_param(blkH,'MaskType');
        if strcmp(blockType,'DataStoreRead')||...
            strcmp(blockType,'DataStoreWrite')||...
            strcmp(blockType,'DataStoreMemory')||...
            strcmp(blockType,'Inport')||...
            strcmp(blockType,'Outport')||...
            strcmp(maskType,'ConvertTrig2FcnCall')
            continue;
        else
            set_param(blkH,'Selected','on');
        end
    end


    set_param(new_expSysHdl,'Location',[1,1,2,2])
    open_system(new_expSysHdl);
    Simulink.BlockDiagram.createSubSystem;
    if~isempty(expFcnFileName)
        set_param(gcb,'Name',expFcnFileName);
    else
        set_param(gcb,'Name',get_param(new_expSysHdl,'Name'));
    end

    set_param(gcb,'MaskType',[get_param(expSysHdl,'Name'),'_ExpCodeSys']);
    sysHdl=gcb;

    hsidspace=get_param(modelH,'SIDSpace');
    hsidspace.swapSID(get_param(new_expSysHdl,'handle'),get_param(sysHdl,'handle'));
    portHdls=get_param(sysHdl,'PortHandles');


    portHdls2=get_param(new_expSysHdl,'PortHandles');

    for i=1:length(portHdls.Inport)
        portBlk=LocalGetBlockPathForSysPort(portHdls.Inport(i));
        set_param(portBlk,'Name',[get_param(portBlk,'Name'),'_ext']);
    end
    for i=1:length(portHdls.Inport)
        inportHdl=portHdls.Inport(i);
        portBlk=LocalGetBlockPathForSysPort(inportHdl);
        portBlkH=get_param(portBlk,'Handle');
        lineH=get_param(inportHdl,'Line');
        if lineH==-1

            delete_block(portBlk);
            continue;
        end


        srcBlkH=get_param(lineH,'SrcBlockHandle');
        if srcBlkH==-1

            delete_block(portBlk);
            continue;
        end
        if strcmp(get_param(srcBlkH,'MaskType'),'ConvertTrig2FcnCall')
            locPortHdls=get_param(srcBlkH,'PortHandles');
            lineH=get_param(locPortHdls.Inport(1),'Line');
            srcBlkH=get_param(lineH,'SrcBlockHandle');
            inportName=get_param(srcBlkH,'Name');
            set_param(portBlk,'Description',get_param(srcBlkH,'Description'));
            rmidata.duplicate(portBlkH,modelH,srcBlkH);
            if iscvar(inportName)
                set_param(portBlk,'Name',get_param(srcBlkH,'Name'));
            else
                DAStudio.error('RTW:buildProcess:invalidFcnNameAtInport',inportName);
            end
        elseif strcmp(get_param(srcBlkH,'BlockType'),'Inport')
            set_param(portBlk,'Name',get_param(srcBlkH,'Name'));

            if rtwprivate('rtwattic','hasSIDMap')





                portNumber2=str2double(get(srcBlkH,'port'));


                inportHdl2=portHdls2.Inport(portNumber2);

                lineH2=get_param(inportHdl2,'Line');
                if lineH2~=-1
                    srcBlkH2=get_param(lineH2,'SrcBlockHandle');
                    if srcBlkH2~=-1



                        tempInportSid=Simulink.ID.getSID(portBlkH);


                        origInportSid=Simulink.ID.getSID(srcBlkH2);




                        rtwprivate('rtwattic','addToSIDMap',tempInportSid,origInportSid);
                    end
                end
            end

        end
    end
    for i=1:length(portHdls.Outport)
        portBlk=LocalGetBlockPathForSysPort(portHdls.Outport(i));
        set_param(portBlk,'Name',[get_param(portBlk,'Name'),'_ext']);
    end
    for i=1:length(portHdls.Outport)
        outportHdl=portHdls.Outport(i);
        portBlk=LocalGetBlockPathForSysPort(outportHdl);
        portBlkH=get_param(portBlk,'Handle');
        lineH=get_param(outportHdl,'Line');
        if lineH==-1

            delete_block(portBlk);
            continue;
        end
        dstBlkH=get_param(lineH,'DstBlockHandle');


        if dstBlkH==-1

            delete_block(portBlk);
            continue;
        end
        if strcmp(get_param(dstBlkH,'BlockType'),'Outport')
            set_param(portBlk,'Name',get_param(dstBlkH,'Name'));

            if rtwprivate('rtwattic','hasSIDMap')





                portNumber2=str2double(get(dstBlkH,'port'));

                outportHdl2=portHdls2.Outport(portNumber2);
                lineH2=get_param(outportHdl2,'Line');
                if lineH2~=-1
                    dstBlkH2=get_param(lineH2,'DstBlockHandle');
                    if dstBlkH2~=-1



                        tempOutportSid=Simulink.ID.getSID(portBlkH);


                        origOutportSid=Simulink.ID.getSID(dstBlkH2);




                        rtwprivate('rtwattic','addToSIDMap',tempOutportSid,origOutportSid);
                    end
                end
            end

        end
    end
    close_system(new_expSysHdl,0);
end


function blkPath=LocalGetBlockPathForSysPort(portH)
    parentName=get_param(portH,'Parent');



    blks=get_param(parentName,'Blocks');
    if~iscell(blks)
        subsys.blocks{1}=strrep(blks,'/','//');
    else
        subsys.blocks=strrep(blks,'/','//');
    end
    sysPorts=get_param(parentName,'Ports');

    portNumber=get_param(portH,'PortNumber');
    portType=get_param(portH,'PortType');

    switch portType
    case 'inport'
        blkPath=[parentName,'/',subsys.blocks{portNumber}];
    case 'outport'
        blkPath=[parentName,'/',subsys.blocks{end-sysPorts(2)+portNumber}];
    case 'enable'
        blkPath=[parentName,'/',subsys.blocks{portNumber}];
    case 'trigger'
        blkPath=[parentName,'/',subsys.blocks{portNumber}];
    otherwise
        DAStudio.error('RTW:buildProcess:unknownPortType',portType);
    end
end


function DisableDiagnosticOptionWarning(modelH)
    diagOptions={'AlgebraicLoopMsg'
'ArtificialAlgebraicLoopMsg'
'CheckMatrixSingularityMsg'
'DiscreteInheritContinuousMsg'
'FixptConstOverflowMsg'
'FixptConstPrecisionLossMsg'
'FixptConstUnderflowMsg'
'InheritedTsInSrcMsg'
'Int32ToFloatConvMsg'
'IntegerOverflowMsg'
'IntegerSaturationMsg'
'LinearizationMsg'
'ModelReferenceIOMsg'
'MultiTaskCondExecSysMsg'
'MultiTaskDSMMsg'
'ParameterDowncastMsg'
'ParameterOverflowMsg'
'ParameterPrecisionLossMsg'
'ParameterTunabilityLossMsg'
'ParameterUnderflowMsg'
'SaveWithDisabledLinksMsg'
'SaveWithParameterizedLinksMsg'
'SFcnCompatibilityMsg'
'SfunCompatibilityCheckMsg'
'SignalLabelMismatchMsg'
'SigSpecEnsureSampleTimeMsg'
'SimStateInterfaceChecksumMismatchMsg'
'SingleTaskRateTransMsg'
'SolverPrmCheckMsg'
'StrictBusMsg'
'TasksWithSamePriorityMsg'
'TimeAdjustmentMsg'
'UnconnectedInputMsg'
'UnconnectedLineMsg'
'UnconnectedOutputMsg'
'UnderSpecifiedDataTypeMsg'
'UniqueDataStoreMsg'
'UnknownTsInhSupMsg'
'UnnecessaryDatatypeConvMsg'
'VectorMatrixConversionMsg'
'CheckModelReferenceTargetMessage'
'ModelReferenceCSMismatchMessage'
'ModelReferenceDataLoggingMessage'
'ModelReferenceIOMismatchMessage'
'ModelReferenceSymbolNameMessage'
    'ModelReferenceVersionMismatchMessage'};

    for i=1:length(diagOptions)
        if strcmp(get_param(modelH,diagOptions{i}),'warning')
            try
                set_param(modelH,diagOptions{i},'none');
            catch
                diagOptions{i}
            end
        end
    end
end
