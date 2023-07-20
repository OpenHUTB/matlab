function[outputData,blkPortHdls]=logComponentIO(obj)































    import stm.internal.TestForSubsystem.publishSpinnerText;
    import stm.internal.TestForSubsystem.publishWarning;





    subs=obj.subs;
    blkPortHdls=componentIOHandles(obj,subs);






    for i=1:obj.numOfComps
        if obj.proceedToNextStep(i)&&get_param(obj.subsys(i),"Type")~="block_diagram"


            ssType=Simulink.SubsystemType(subs{i}.handle);
            if blkPortHdls(i).UnsupportedLineTypes||ssType.isFunctionCallSubsystem()
                blkPortHdls(i)=struct(...
                'InputSrcPortHandles',[],...
                'OutputDriverPortHandles',[],...
                'EnableSrcPortHandle',[],...
                'TriggerSrcPortHandle',[],...
                'ResetSrcPortHandle',[],...
                'UnsupportedLineTypes',blkPortHdls(i).UnsupportedLineTypes);
                obj.populateErrorContainer(MException('stm:general:InvalidSubsystemPortsForBaselineGeneration',message('stm:general:InvalidSubsystemPortsForBaselineGeneration').getString()),i);
            end
        end
    end
    obj.abortIfNoRemainingCUT();



    testfileFolder=fileparts(obj.testfileLocation);
    obj.resolveFilePaths(testfileFolder,true);
    currFolder=cd(testfileFolder);
    ocf=onCleanup(@()cd(currFolder));

    publishSpinnerText(message('stm:general:SettingUpLogging').getString());


    preserve_dirty=Simulink.PreserveDirtyFlag(get_param(obj.topModel,'Handle'),'blockDiagram');%#ok<NASGU>


    simIn=Simulink.SimulationInput(obj.topModel);











    [dsmInfo,obj,blkPortHdls]=localGetDSMInfo(obj.topModel,subs,blkPortHdls,obj);

    for i=1:obj.numOfComps
        if obj.proceedToNextStep(i)
            errSig=obj.setDSMTempLogging(dsmInfo(i),i);
            if~isempty(errSig)
                eID='stm:TestForSubsystem:ErrorDSBusLoggingTestForSubsystem';
                blkPortHdls(i)=struct('InputSrcPortHandles',[],'OutputDriverPortHandles',[],'EnableSrcPortHandle',[],'TriggerSrcPortHandle',[],'ResetSrcPortHandle',[],'UnsupportedLineTypes',blkPortHdls(i).UnsupportedLineTypes);
                obj.populateErrorContainer(MException(eID,message(eID,errSig).getString()),i);
            end
        end
    end
    obj.abortIfNoRemainingCUT();


    gotoFromInfo=cellfun(@(x)Simulink.harness.internal.getGotoFromInfo(x.handle),subs,'UniformOutput',false);
    obj.setInputTempLoggingNames(gotoFromInfo,'From');



    for i=1:obj.numOfComps
        if obj.proceedToNextStep(i)&&messagePortsAtBoundary(blkPortHdls(i))
            blkPortHdls(i)=struct('InputSrcPortHandles',[],'OutputDriverPortHandles',[],'EnableSrcPortHandle',[],'TriggerSrcPortHandle',[],'ResetSrcPortHandle',[],'UnsupportedLineTypes',blkPortHdls(i).UnsupportedLineTypes);
            obj.populateErrorContainer(MException('stm:general:InvalidSubsystemPortsForBaselineGeneration',message('stm:general:InvalidSubsystemPortsForBaselineGeneration').getString()),i);
        end
    end



    inputSrcPortHandles=arrayfun(@(x)x.InputSrcPortHandles,blkPortHdls,'UniformOutput',false);

    if obj.setInputTempLoggingNames(inputSrcPortHandles,'Inport')
        publishWarning('stm:general:WarningConstantTimeForTestFromSubsystem',obj.shouldThrow);
    end


    enableSrcPortHandle=arrayfun(@(x)x.EnableSrcPortHandle,blkPortHdls,'UniformOutput',false);
    obj.setInputTempLoggingNames(enableSrcPortHandle,'EnablePort');



    triggerSrcPortHandle=arrayfun(@(x)x.TriggerSrcPortHandle,blkPortHdls,'UniformOutput',false);
    obj.setInputTempLoggingNames(triggerSrcPortHandle,'TriggerPort');


    resetSrcPortHandle=arrayfun(@(x)x.ResetSrcPortHandle,blkPortHdls,'UniformOutput',false);
    obj.setInputTempLoggingNames(resetSrcPortHandle,'ResetPort');


    simIn=saveAndSetupLoggingSettings(simIn);


    if obj.testType==sltest.testmanager.TestCaseTypes.Baseline

        outputDriverPortHandles=arrayfun(@(x)x.OutputDriverPortHandles,blkPortHdls,'UniformOutput',false);
        obj.setOutputTempLoggingNames(outputDriverPortHandles,'sltest_outputs');


        gotoBlksph=cellfun(@(y)arrayfun(@(x)get_param(x,'porthandles'),y.gotoBlks),gotoFromInfo,'UniformOutput',false);
        gotoSrcPortHandles=cellfun(@(y)arrayfun(@(s)stm.internal.TestForSubsystem.returnSourceBlockOutportHandle(s.Inport),y),gotoBlksph,'UniformOutput',false);
        obj.setOutputTempLoggingNames(gotoSrcPortHandles,'sltest_goto');
    end







    obj.abortIfNoRemainingCUT();



    publishSpinnerText(message('stm:general:SimulatingModelAndCapturingSignals').getString());


    outputData=obj.simulateModel(simIn);


    obj.revertSigNamesAndLogging(unique(obj.subModel));


    clear preserve_dirty;

end


function out=componentIOHandles(obj,subs)
















    out=arrayfun(@(i)struct('InputSrcPortHandles',[],'OutputDriverPortHandles',[],'EnableSrcPortHandle',[],'TriggerSrcPortHandle',[],'ResetSrcPortHandle',[],'UnsupportedLineTypes',false),1:obj.numOfComps,'UniformOutput',true);

    for i=1:obj.numOfComps

        if Simulink.SubsystemType.isBlockDiagram(obj.subsys(i))


            ins=find_system(obj.subsys(i),'SearchDepth',1,'BlockType','Inport','OutputFunctionCall','off');
            ph=cellfun(@(s)get_param(s,'porthandles'),ins);
            out(i).InputSrcPortHandles=arrayfun(@(s)s.Outport,ph,'UniformOutput',true);

            outs=find_system(obj.subsys(i),'SearchDepth',1,'BlockType','Outport');
            ph=cellfun(@(s)get_param(s,'porthandles'),outs);
            rootOutportInputs=arrayfun(@(s)s.Inport,ph,'UniformOutput',true);

            out(i).OutputDriverPortHandles=arrayfun(@(s)stm.internal.TestForSubsystem.returnSourceBlockOutportHandle(s),rootOutportInputs);
        else
            tmp=get_param(subs{i}.handle,'porthandles');
            blockType=get_param(subs{i}.handle,'BlockType');
            if strcmp(blockType,'ModelReference')


                mdlEventPortInfo=get_param(subs{i}.handle,'ModelEventPortInfo');
                if~isempty(mdlEventPortInfo)
                    seperatorLoc=find(mdlEventPortInfo==',');

                    numMdlEventPorts=length(seperatorLoc)+1;


                    tmp.Inport(length(tmp.Inport)-numMdlEventPorts+1:end)=[];
                end
            end

            out(i).InputSrcPortHandles=arrayfun(@(s)stm.internal.TestForSubsystem.returnSourceBlockOutportHandle(s),tmp.Inport);
            out(i).OutputDriverPortHandles=tmp.Outport;
            out(i).EnableSrcPortHandle=stm.internal.TestForSubsystem.returnSourceBlockOutportHandle(tmp.Enable);
            out(i).TriggerSrcPortHandle=stm.internal.TestForSubsystem.returnSourceBlockOutportHandle(tmp.Trigger);
            out(i).ResetSrcPortHandle=stm.internal.TestForSubsystem.returnSourceBlockOutportHandle(tmp.Reset);
            out(i).UnsupportedLineTypes=~isempty(tmp.State)||~isempty(tmp.LConn)...
            ||~isempty(tmp.RConn)||~isempty(tmp.Ifaction);
        end



        isSSWithNoInputOutput=(~out(i).UnsupportedLineTypes)&&isempty(out(i).InputSrcPortHandles)&&isempty(out(i).OutputDriverPortHandles)&&...
        (isempty(out(i).EnableSrcPortHandle)||out(i).EnableSrcPortHandle==-1)&&(isempty(out(i).TriggerSrcPortHandle)||out(i).TriggerSrcPortHandle==-1)&&(isempty(out(i).ResetSrcPortHandle)||out(i).ResetSrcPortHandle==-1);

        if isSSWithNoInputOutput
            eID='stm:general:TestForSubsystemNoInputsOutputs';
            obj.populateErrorContainer(MException(eID,message(eID).getString),i);
        end






        if any(ismember(out(i).OutputDriverPortHandles,out(i).InputSrcPortHandles))
            eID='stm:general:TestForSubsystemLoopNotSupported';
            obj.populateErrorContainer(MException(eID,message(eID).getString),i);
        end


    end
end

function result=messagePortsAtBoundary(blkPortHdls)
    function ret=isMessageMode(hdl)
        ret=false;
        if hdl==-1
            return;
        end
        str=get_param(hdl,'CompiledMessageMode');
        if~isempty(str)
            ret=strcmp('on',str);
        end
    end

    result=false;

    if any(unique(arrayfun(@(s)isMessageMode(s),blkPortHdls.InputSrcPortHandles,'UniformOutput',true)))
        result=true;
        return;
    end

    if any(unique(arrayfun(@(s)isMessageMode(s),blkPortHdls.OutputDriverPortHandles,'UniformOutput',true)))
        result=true;
        return;
    end
end

function simIn=saveAndSetupLoggingSettings(simIn)
    set_params=["SaveTime","on",...
    "ReturnWorkspaceOutputs","on",...
    "SignalLogging","on",...
    "SignalLoggingName","sltlogsout",...
    "SignalLoggingSaveFormat","DataSet",...
    "DSMLogging","on",...
    "DSMLoggingName","sltdsmout",...
    "SDIOptimizeVisual","off",...
    "StrictBusMsg","ErrorLevel1",...
    "LoggingToFile","off"...
    ];
    simIn=simIn.setModelParameter(set_params{:});
end

function[dsmInfo,obj,blkPortHndls]=localGetDSMInfo(mdl,subs,blkPortHndls,obj)

    if strcmpi(get_param(mdl,'SimulationMode'),'normal')
        compileCmd='compile';
    else
        compileCmd='compileForAccel';
    end



    try
        feval(mdl,[],[],[],compileCmd);
    catch me


        eID="stm:TestForSubsystem:ModelCompilationOrSimulationFailed";
        exToShow=MException(eID,message(eID).getString);
        exToShow=exToShow.addCause(me);
        throwAsCaller(exToShow);
    end
    ocpp=onCleanup(@()feval(mdl,[],[],[],'term'));
    dsmInfo=cellfun(@(x)stm.internal.TestForSubsystem.getDSMInfo(x.handle),subs,'UniformOutput',true);








    [obj,blkPortHndls]=filterCUTsWithUnloggableIOSigs(obj,blkPortHndls);
end

function[obj,blkPortHndls]=filterCUTsWithUnloggableIOSigs(obj,blkPortHndls)


    assert(contains(get_param(obj.topModel,'SimulationStatus'),["compiled","paused"]));
    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
    sourcesDrivingMergeBlkInports=findOutportHandlesFeedingToMergeBlks(obj.topModel);
    for i=1:obj.numOfComps
        if obj.proceedToNextStep(i)
            compHndl=get_param(obj.subsys(i),"Handle");



            if doesCUTOutputDriveMergeBlkInputs(compHndl,blkPortHndls(i).OutputDriverPortHandles,sourcesDrivingMergeBlkInports)||...
                doesCUTUseLoggingUnsupportedSignal(compHndl)
                eID='stm:general:BaselineForMergeAndFcnCallBlockNotSupported';
                blkPortHndls(i)=struct('InputSrcPortHandles',[],'OutputDriverPortHandles',[],'EnableSrcPortHandle',[],'TriggerSrcPortHandle',[],'ResetSrcPortHandle',[],'UnsupportedLineTypes',blkPortHndls(i).UnsupportedLineTypes);
                obj.populateErrorContainer(MException(eID,message(eID).getString),i);
            end
        end
    end
end

function unsupportedPorts=findOutportHandlesFeedingToMergeBlks(mdl)


    allMdls=find_mdlrefs(mdl,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
    mergeBlks=(Simulink.findBlocksOfType(allMdls,'Merge',Simulink.FindOptions('FollowLinks',true)))';
    unsupportedPorts=[];

    for mergeBlk=mergeBlks
        inports=reshape(get_param(mergeBlk,'PortHandles').Inport,1,[]);
        unsupportedPorts=[unsupportedPorts,getAllSrcs(inports)];%#ok<AGROW>
    end
end

function result=doesCUTOutputDriveMergeBlkInputs(compHndl,outportsToLog,sourcesDrivingMergeBlkInports)


    result=(~isempty(sourcesDrivingMergeBlkInports))&&(~isempty(intersect(sourcesDrivingMergeBlkInports,...
    makeListOfSrcAndActualPorts(compHndl,outportsToLog))));
end

function portList=makeListOfSrcAndActualPorts(compHndl,actualOutportsToLog)

    outports=find_system(compHndl,"SearchDepth",1,"BlockType","Outport")';
    allSrcs=getAllSrcs(outports);



    portList=[allSrcs,reshape(actualOutportsToLog,1,[])];
end

function isUnsupported=doesCUTUseLoggingUnsupportedSignal(compHndl)





    ssType=Simulink.SubsystemType(compHndl);
    if ssType.isBlockDiagram(compHndl)



        outs=find_system(compHndl,"SearchDepth",1,"BlockType","Outport")';



        isUnsupported=isAnyPortFedByUnloggableSig(outs);
    else


        portHndls=get_param(compHndl,"PortHandles");
        ins=reshape(portHndls.Inport,1,[]);
        isUnsupported=isAnyPortFedByUnloggableSig(ins);
        if~isUnsupported


            if ssType.isSubsystem&&get_param(compHndl,"ReferencedSubsystem")==""





                outs=find_system(compHndl,"SearchDepth",1,"BlockType","Outport")';
                isUnsupported=isAnyPortFedByUnloggableSig(outs);






            else






                outs=reshape(portHndls.Outport,1,[]);
                isUnsupported=isAnyPortEmittingFcnCallSig(outs);
            end
        end
    end
end

function result=isAnyPortFedByUnloggableSig(hndls)

    result=false;

    srcPorts=getAllSrcs(hndls);
    for srcPort=srcPorts

        if isFcnCallPort(srcPort)||isStatePort(srcPort)
            result=true;
            return;
        end
    end
end

function srcPorts=getAllSrcs(hndls)
    srcPorts=[];
    for hndl=hndls


        thissSrcs=get_param(hndl,"Object").getActualSrc;
        if~isempty(thissSrcs)
            srcPorts=[srcPorts,thissSrcs(:,1)'];%#ok<AGROW> 
        end
    end
end

function result=isFcnCallPort(port)

    result=get_param(port,"CompiledPortDataType")=="fcn_call";
end

function result=isStatePort(port)

    blockOwningPort=get_param(port,"ParentHandle");
    portHndlsOfOwnerBlk=get_param(blockOwningPort,"PortHandles");
    result=any(port==portHndlsOfOwnerBlk.State);
end

function result=isAnyPortEmittingFcnCallSig(outports)
    result=false;
    for outport=outports
        if isFcnCallPort(outport)
            result=true;
            return;
        end
    end
end


