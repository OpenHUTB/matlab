function[ResultDescription,ResultDetails]=checkFILCompatibility(system)


    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckErrorSeverity(1);
    [hdlcoderObj,params]=hdlcoderargs(system);
    hdlcoderObj.setCmdLineParams(params);

    try

        hdlcoderObj.createConfigManager;
        hdlcoderObj.getCPObj;


        [oldDriver,oldMode,oldAutosaveState]=hdlcoderObj.inithdlmake;
        hs.oldDriver=oldDriver;
        hs.oldMode=oldMode;
        hs.oldAutosaveState=oldAutosaveState;

    catch me

        [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,me.message);
        return;
    end

    try


        hdlcoderObj.connectToModel;



        hDI=hdlcoderObj.DownstreamIntegrationDriver;
        if hDI.isFILWorkflow
            checks=l_checkFIL(system,mdladvObj);
            successMsg='Checking block compatibility with FPGA-in-the-Loop';
        else
            checks=l_checkUsrp(system);
            successMsg='Checking block compatibility with USRP(R) workflow';
        end

        hdlcoderObj.cleanup(hs,false);



        [ResultDescription,ResultDetails]=publishResults(mdladvObj,checks,successMsg);

    catch me

        [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,me.message);

        hdlcoderObj.cleanup(hs,false);
        return;
    end
end

function checks=l_checkFIL(system,mdladvObj)



    checks=struct('path',{},...
    'type',{},...
    'message',{},...
    'level',{},...
    'MessageID',{});


    if~hdlcoderui.isedasimlinksinstalled
        checks(end+1).path=system;
        checks(end).type='model';
        checks(end).message=...
        ['HDL Verifier is not available. Make sure HDL Verifier'...
        ,'is licensed and installed for use with FPGA-in-the-Loop.'];
        checks(end).level='Error';
        checks(end).MessageID='hdlcoder:workflow:FILRequiresEDASL';
    end

    hD=hdlcurrentdriver;
    TCResettable=hD.getParameter('ResettableTimingController');
    if TCResettable==1
        msg=message('hdlcoder:workflow:FILResettableTCUnsupported',...
        hD.ModelName);
        checks(end+1).path=system;
        checks(end).type='model';
        checks(end).message=msg.getString;
        checks(end).level='Error';
        checks(end).MessageID=msg.Identifier;
    end

    mdlName=bdroot(system);
    minReset=hdlget_param(mdlName,'MinimizeGlobalReset');
    if strcmpi(minReset,'on')
        taskID='com.mathworks.HDL.CheckFIL';
        msgStr=message('hdlcoder:workflow:TurnOffMinReset').getString;
        actionLink=sprintf('<a href="matlab:hdlset_param(%s,''MinimizeGlobalReset'',''off''); hdlturnkey.resetHDLWATask(''%s'');">%s</a>',...
        cleanBlockNameForQuotedDisp(mdlName),taskID,msgStr);
        msg=message('hdlcoder:workflow:FILMinimizeReset',actionLink);
        checks(end+1).path=mdlName;
        checks(end).message=msg.getString;
        checks(end).type='model';
        checks(end).level='Warning';
        checks(end).MessageID=msg.Identifier;
    end

    regInitSetting=hdlget_param(mdlName,'NoResetInitializationMode');
    if strcmpi(regInitSetting,'Script')
        taskID='com.mathworks.HDL.CheckFIL';
        msgStr=message('hdlcoder:workflow:ChangeRegInitSetting').getString;
        actionLink=sprintf('<a href="matlab:hdlset_param(%s,''NoResetInitializationMode'',''InsideModule''); hdlturnkey.resetHDLWATask(''%s'');">%s</a>',...
        cleanBlockNameForQuotedDisp(mdlName),taskID,msgStr);
        msg=message('hdlcoder:workflow:FILRegInitSetting',actionLink);
        checks(end+1).path=mdlName;
        checks(end).message=msg.getString;
        checks(end).type='model';
        checks(end).level='Warning';
        checks(end).MessageID=msg.Identifier;
    end


    minClkEn=hdlget_param(mdlName,'MinimizeClockEnables');
    if strcmpi(minClkEn,'on')
        taskID='com.mathworks.HDL.CheckFIL';
        msgStr=message('hdlcoder:workflow:TurnOffMinClockEnable').getString;
        actionLink=sprintf('<a href="matlab:hdlset_param(%s,''MinimizeClockEnables'',''off''); hdlturnkey.resetHDLWATask(''%s'');">%s</a>',...
        cleanBlockNameForQuotedDisp(mdlName),taskID,msgStr);
        msg=message('hdlcoder:workflow:FILMinClkEn',actionLink);
        checks(end+1).path=mdlName;
        checks(end).message=msg.getString;
        checks(end).type='model';
        checks(end).level='Warning';
        checks(end).MessageID=msg.Identifier;
    end





    solverType=get_param(mdlName,'SolverType');
    multitaskingMode=get_param(mdlName,'EnableMultiTasking');
    if strcmp(solverType,'Fixed-step')&&strcmp(multitaskingMode,'on')
        taskID='com.mathworks.HDL.CheckFIL';
        msgStr=message('hdlcoder:workflow:ChangeToSingleTasking').getString;
        actionLink=sprintf('<a href="matlab:set_param(%s,''EnableMultiTasking'',''off''); hdlturnkey.resetHDLWATask(''%s'');">%s</a>',...
        cleanBlockNameForQuotedDisp(mdlName),taskID,msgStr);
        msg=message('hdlcoder:workflow:FILSolverMode',actionLink);
        checks(end+1).path=mdlName;
        checks(end).message=msg.getString;
        checks(end).type='model';
        checks(end).level='Warning';
        checks(end).MessageID=msg.Identifier;
    end

    if strcmpi(get_param(system,'Type'),'block_diagram')
        checks(end+1).path=system;
        checks(end).type='model';
        checks(end).message=...
        'Top-level system is not supported by FPGA-in-the-loop testbench generation. ';
        checks(end).level='Error';
        checks(end).MessageID='hdlcoder:workflow:FILTopLevelSystemNotSupported';
        return;
    end
    h=get_param(system,'PortHandles');


    nInPorts=length(h.Inport);
    nOutPorts=length(h.Outport);

    if nOutPorts==0
        checks(end+1).path=system;
        checks(end).type='model';
        checks(end).message=...
        ['Sink subsystem is not supported by FPGA-in-the-loop. '...
        ,'Make sure the subsystem has at least one input port.'];
        checks(end).level='Error';
        checks(end).MessageID='hdlcoder:workflow:FILSinkNotSupported';
    end


    for ii=1:nInPorts

        if~isFloatpointAllowed(mdladvObj)
            datatype=get_param(h.Inport(ii),'CompiledPortDataType');
            if strcmpi(datatype,'double')||strcmpi(datatype,'single')
                checks(end+1).path=system;%#ok<AGROW>
                checks(end).type='model';
                checks(end).message=...
                getString(message('EDALink:FILSfuncErrWarn:DtypeSpecNoDouble',...
                getString(message('EDALink:FILSfuncErrWarn:InputPortErrorHeader',ii,getPortName(system,ii,'Inport')))));
                checks(end).level='Error';
                checks(end).MessageID='hdlcoder:workflow:FILInputDoubleNotSupported';
            end
        end
        datatype=get_param(h.Inport(ii),'CompiledPortDataType');
        members=enumeration(datatype);
        if~isempty(members)
            msg=message('hdlcoder:workflow:FILEnumTypeUnsupported',getPortName(system,ii,'Inport'));
            checks(end+1).path=system;%#ok<AGROW>
            checks(end).type='model';
            checks(end).message=msg.getString;
            checks(end).level='Error';
            checks(end).MessageID=msg.Identifier;
        end

        sampletime=get_param(h.Inport(ii),'CompiledSampleTime');
        if iscell(sampletime)&&numel(sampletime)>1
            checks(end+1).path=system;%#ok<AGROW>
            checks(end).type='model';
            checks(end).message=...
            sprintf('FPGA-in-the-Loop does not support bus types on port "%s".',getPortName(system,ii,'Inport'));
            checks(end).level='Error';
            checks(end).MessageID='hdlcoder:workflow:FILBusNotSupported';
        else
            if sampletime(1)==0
                checks(end+1).path=system;%#ok<AGROW>
                checks(end).type='model';
                checks(end).message=...
                sprintf('FPGA-in-the-Loop does not allow zero sample time at port "%s". The generated FIL block might not work correctly.',getPortName(system,ii,'Inport'));
                checks(end).level='Error';
                checks(end).MessageID='hdlcoder:workflow:FILInputZeroSampleTimeNotSupported';
            end
        end
    end

    for ii=1:nOutPorts
        if~isFloatpointAllowed(mdladvObj)
            datatype=get_param(h.Outport(ii),'CompiledPortDataType');
            if strcmpi(datatype,'double')||strcmpi(datatype,'single')
                checks(end+1).path=system;%#ok<AGROW>
                checks(end).type='model';
                checks(end).message=...
                getString(message('EDALink:FILSfuncErrWarn:DtypeSpecNoDouble',...
                getString(message('EDALink:FILSfuncErrWarn:OutputPortErrorHeader',ii,getPortName(system,ii,'Outport')))));
                checks(end).level='Error';
                checks(end).MessageID='hdlcoder:workflow:FILOutputDoubleNotSupported';
            end
        end

        datatype=get_param(h.Outport(ii),'CompiledPortDataType');
        members=enumeration(datatype);
        if~isempty(members)
            msg=message('hdlcoder:workflow:FILEnumTypeUnsupported',getPortName(system,ii,'Outport'));
            checks(end+1).path=system;%#ok<AGROW>
            checks(end).type='model';
            checks(end).message=msg.getString;
            checks(end).level='Error';
            checks(end).MessageID=msg.Identifier;
        end

        sampletime=get_param(h.Outport(ii),'CompiledSampleTime');
        if iscell(sampletime)
            sampletime=~isequal(cell2mat(sampletime),0.*cell2mat(sampletime));
        end
        if sampletime==0
            checks(end+1).path=system;%#ok<AGROW>
            checks(end).type='model';

            checks(end).message=...
            sprintf('FPGA-in-the-Loop does not allow zero sample time at port "%s". Use a non-zero sample time instead.',getPortName(system,ii,'Outport'));
            checks(end).level='Error';
            checks(end).MessageID='hdlcoder:workflow:hdlcoder:workflow:FILOutputZeroSampleTimeNotSupported';
        end
    end
end

function checks=l_checkUsrp(system)
    checks=struct('path',{},...
    'type',{},...
    'message',{},...
    'level',{},...
    'MessageID',{});

    portHandle=get_param(system,'PortHandles');
    nInput=length(portHandle.Inport);
    nOutput=length(portHandle.Outport);

    isInterfaceValid=l_checkInterface(portHandle.Inport);

    if~isInterfaceValid
        errmsg=message('hdlcoder:usrp:InvalidInputInterface');
        checks(end+1)=l_getErrCheck(system,errmsg);
    end

    isInterfaceValid=l_checkInterface(portHandle.Outport);
    if~isInterfaceValid
        errmsg=message('hdlcoder:usrp:InvalidOutputInterface');
        checks(end+1)=l_getErrCheck(system,errmsg);
    end


    for ii=1:nInput
        type=get_param(portHandle.Inport(ii),'CompiledPortDataType');
        members=enumeration(type);
        [bitwidth,~,sign]=hdlgetsizesfromtype(type);
        if bitwidth~=16
            errmsg=message('hdlcoder:usrp:InvalidInputDataType',bitwidth,type,ii);
            checks(end+1)=l_getErrCheck(system,errmsg);%#ok<AGROW>
        end
        if~sign
            errmsg=message('hdlcoder:usrp:InvalidInputSign',ii);
            checks(end+1)=l_getErrCheck(system,errmsg);%#ok<AGROW>
        end
        if~isempty(members)
            errmsg=message('hdlcoder:usrp:InvalidInputEnumPortType',ii);
            checks(end+1)=l_getErrCheck(system,errmsg);%#ok<AGROW>
        end
    end

    for ii=1:nOutput
        type=get_param(portHandle.Outport(ii),'CompiledPortDataType');
        members=enumeration(type);
        [bitwidth,~,sign]=hdlgetsizesfromtype(type);
        if bitwidth~=16
            errmsg=message('hdlcoder:usrp:InvalidOutputDataType',bitwidth,type,ii);
            checks(end+1)=l_getErrCheck(system,errmsg);%#ok<AGROW>
        end
        if~sign
            errmsg=message('hdlcoder:usrp:InvalidOutputSign',ii);
            checks(end+1)=l_getErrCheck(system,errmsg);%#ok<AGROW>
        end
        if~isempty(members)
            errmsg=message('hdlcoder:usrp:InvalidOutputEnumPortType',ii);
            checks(end+1)=l_getErrCheck(system,errmsg);%#ok<AGROW>
        end
    end

    if nInput==2
        rate1=get_param(portHandle.Inport(1),'CompiledSampleTime');
        rate2=get_param(portHandle.Inport(2),'CompiledSampleTime');
        if rate1(1)~=rate2(1)
            errmsg=message('hdlcoder:usrp:InvalidInputSampleTime');
            checks(end+1)=l_getErrCheck(system,errmsg);
        end
    end

    if nOutput==2
        rate1=get_param(portHandle.Outport(1),'CompiledSampleTime');
        rate2=get_param(portHandle.Outport(2),'CompiledSampleTime');
        if rate1(1)~=rate2(1)
            errmsg=message('hdlcoder:usrp:InvalidOutputSampleTime');
            checks(end+1)=l_getErrCheck(system,errmsg);
        end
    end
end

function check=l_getErrCheck(system,errmsg)
    check.path=system;
    check.type='model';
    check.message=errmsg.getString;
    check.level='Error';
    check.MessageID=errmsg.Identifier;
end

function isInterfaceValid=l_checkInterface(iohandle)

    isInterfaceValid=true;

    numports=length(iohandle);
    if numports==1

        isComplexSignal=get_param(iohandle(1),'CompiledPortComplexSignal');
        dim=get_param(iohandle(1),'CompiledPortDimensions');
        numElements=prod(dim(2:dim(1)+1));
        if isComplexSignal&&numElements~=1
            isInterfaceValid=false;
        elseif~isComplexSignal&&numElements~=2
            isInterfaceValid=false;
        end
    elseif numports==2
        for ii=1:2
            isComplexSignal=get_param(iohandle(ii),'CompiledPortComplexSignal');
            dim=get_param(iohandle(ii),'CompiledPortDimensions');
            numElements=prod(dim(2:dim(1)+1));
            if isComplexSignal
                isInterfaceValid=false;
            elseif numElements~=1
                isInterfaceValid=false;
            end
        end
    else
        isInterfaceValid=false;
    end
end

function portName=getPortName(system,portNum,portType)




    try
        if strcmpi(get_param(system,'BlockType'),'ModelReference')


            system=get_param(system,'ModelName');
        end


        compiledBlockList=getCompiledBlockList(get_param(system,'Object'));



        allPortsIdx=strcmp(get_param(compiledBlockList,'BlockType'),portType);
        allPorts=compiledBlockList(allPortsIdx);


        portIdx=strcmp(get_param(allPorts,'Port'),num2str(portNum));
        port=allPorts(portIdx);


        portName=get_param(port,'PortName');
    catch


        portName=num2str(portNum);
    end
end

function r=isFloatpointAllowed(~)
    r=targetcodegen.targetCodeGenerationUtils.isFloatingPointMode();
end




