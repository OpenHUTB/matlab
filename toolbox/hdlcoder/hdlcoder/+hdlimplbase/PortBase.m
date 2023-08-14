classdef PortBase<hdlimplbase.EmlImplBase




    methods
        function this=PortBase(~)
        end

    end

    methods

        function ishwfr=isInHwFriendly(~,hC)

            ishwfr=hC.Owner.hasSLHWFriendlySemantics||hC.Owner.getWithinHWFriendlyHierarchy;

        end
    end


    methods(Hidden)

        function v=baseValidateCtlPort(this,hC)




            blockInfo=this.getBlockInfo(hC.SimulinkHandle);
            blockInfo.isInHwFriendly=this.isInHwFriendly(hC);

            result=checkCtlPortOutput(blockInfo);
            if isempty(result)
                v=hdlvalidatestruct;
            else
                v=result;
            end

            ctlport=getCtlPort(hC);
            result=checkCtlPortType(ctlport);
            if~isempty(result)
                v(end+1)=result;
            end

            result=checkForOutputsHeld(blockInfo);
            if~isempty(result)
                for ii=1:length(result)
                    v(end+1)=result(ii);%#ok<AGROW>
                end
            end

            hN=hC.Owner;
            sigs=[hN.SLInputSignals;hN.SLOutputSignals];
            result=this.checkRates(sigs);
            if~isempty(result)
                v(end+1)=result;
            end

            result=checkIfDut(hC);
            if~isempty(result)
                v(end+1)=result;
            end

            if~isa(this,'hdldefaults.ResetPort')
                result=checkPortInitialValues(hC,blockInfo);
                if~isempty(result)
                    for i=1:length(result)
                        v(end+1)=result(i);%#ok<AGROW>
                    end
                end
                result=checkNestedInResetRegion(hC);
                if~isempty(result)
                    for i=1:length(result)
                        v(end+1)=result(i);%#ok<AGROW>
                    end
                end
            end
        end





        function result=checkRates(~,sigs)


            result=[];
            ratesMatch=checkSignalRates(sigs);

            if~ratesMatch
                result=hdlvalidatestruct(1,message('hdlcoder:validate:mismatchedRates'));
            end
        end







        function hNewC=elaborate(~,hN,hC)

            desc=hC.getComment();


            if~isempty(desc)
                pirelab.getAnnotationComp(hN,hC.Name,desc,hC.SimulinkHandle);
            end



            hC.Owner.removeComponent(hC);

            hNewC=hC;

        end


        function fixblkinhdllib(this,blkh)%#ok<INUSL>






            pos=get_param(blkh,'Position');
            set_param(blkh,'Position',[pos(1)+10,pos(2)+10,pos(1)+30,pos(2)+30]);


        end


        function info=getBlockInfo(this,slbh)

            info=struct;

            info.BlockHandle=slbh;
            if isa(this,'hdldefaults.ResetPort')
                info.StatesWhenEnabling='';
                info.SLOutputPorts='';
            elseif isa(this,'hdldefaults.ActionPort')
                info.StatesWhenEnabling=get_param(slbh,'InitializeStates');
                info.SLOutputPorts='';
            else

                info.StatesWhenEnabling=get_param(slbh,'StatesWhenEnabling');
                info.SLOutputPorts=get_param(slbh,'ShowOutputPort');
            end




            parent=get_param(slbh,'Parent');
            inPorts=find_system(parent,'FollowLinks','on','LookUnderMasks','all',...
            'SearchDepth',1,'BlockType','Inport');
            outPorts=find_system(parent,'FollowLinks','on','LookUnderMasks','all',...
            'SearchDepth',1,'BlockType','Outport');


            info.InputBlocks=repmat(struct,length(inPorts),1);
            info.OutputBlocks=repmat(struct,length(outPorts),1);

            for i=1:length(inPorts)
                info.InputBlocks(i).LatchByDelayingOutsideSignal=uncellify(get_param(inPorts(i),...
                'LatchByDelayingOutsideSignal'));
                info.InputBlocks(i).Name=uncellify(get_param(inPorts(i),'Name'));
            end
            for i=1:length(outPorts)
                info.OutputBlocks(i).SourceOfInitialOutputValue=uncellify(get_param(outPorts(i),...
                'SourceOfInitialOutputValue'));
                info.OutputBlocks(i).OutputWhenDisabled=uncellify(get_param(outPorts(i),...
                'OutputWhenDisabled'));
                info.OutputBlocks(i).InitialOutput=uncellify(get_param(outPorts(i),...
                'InitialOutput'));
                info.OutputBlocks(i).Name=uncellify(get_param(outPorts(i),'Name'));
            end
        end



        function postElab(~,~,~,~)
        end


        function hNewC=preElab(~,~,hC)
            hNewC=hC;
        end

    end

end

function result=checkCtlPortOutput(blockInfo)
    result=[];
    if strcmp(blockInfo.SLOutputPorts,'on')
        result=hdlvalidatestruct(1,message('hdlcoder:validate:outputPort'));
    end
end




function ctlport=getCtlPort(hC)
    ctlport=[];
    hN=hC.Owner;
    inputs=hN.PirInputPorts;
    numInputs=length(inputs);

    for i=numInputs:-1:1
        current=inputs(i);
        if current.isSubsystemEnable()
            ctlport=current;
            break;
        elseif current.isSubsystemTrigger()
            ctlport=current;
            break;
        elseif current.isSubsystemSyncReset()
            ctlport=current;
            break;
        end
    end
end


function result=checkCtlPortType(ctlport)
    result=[];
    if~isempty(ctlport)
        hS=ctlport.Signal;
        if~isempty(hS)
            ctlportType=hS.Type;

            if~ctlportType.isBooleanType&&~ctlportType.isUnsignedType(1)


                if ctlport.isSubsystemEnable
                    msgid='hdlcoder:validate:enablePortType';
                elseif ctlport.isSubsystemTrigger
                    msgid='hdlcoder:validate:triggerPortType';
                elseif ctlport.isSubsystemSyncReset
                    msgid='hdlcoder:validate:resetPortType';
                end
                result=hdlvalidatestruct(1,message(msgid));
            end
        end
    end
end


function result=checkForOutputsHeld(blockInfo)
    result=[];

    outputs=blockInfo.OutputBlocks;
    numOutputs=length(outputs);

    for i=1:numOutputs
        current=outputs(i);
        if~strcmp(current.OutputWhenDisabled,'held')
            msg=hdlvalidatestruct(1,message('hdlcoder:validate:heldOutputWhenDisabled',current.Name));
            if isempty(result)
                result=msg;
            else
                result(end+1)=msg;%#ok<AGROW>
            end
        end
    end
end



function result=checkIfDut(hC)
    result=[];
    subsystem=hC.Owner;
    p=pir;
    dut=p.getTopNetwork;

    if strcmp(subsystem.RefNum,dut.RefNum)
        result=hdlvalidatestruct(1,message('hdlcoder:validate:topDUT'));
    end
end



function result=checkPortInitialValues(hC,blockInfo)
    result=hdlvalidatestruct;
    hN=hC.Owner;
    outPorts=hN.PirOutputPorts;
    if blockInfo.isInHwFriendly
        return
    end
    outputs=blockInfo.OutputBlocks;
    numOutputs=length(outputs);

    for i=1:numOutputs
        current=outputs(i);
        if strcmpi(current.SourceOfInitialOutputValue,'Input Signal')
            initVal=[];
        else
            initVal=slResolve(current.InitialOutput,blockInfo.BlockHandle);
        end
        isDefault=isempty(initVal);
        if isDefault
            initVal=checkPortDefaultValues(hN,i,blockInfo);
            if isempty(initVal)
                if~strcmpi(current.SourceOfInitialOutputValue,'Input Signal')
                    msg=hdlvalidatestruct(1,message('hdlcoder:validate:defaultInitVal',current.Name));
                    result(end+1)=msg;%#ok<AGROW>
                else
                    continue;
                end
            else
                if ischar(initVal)
                    initVal=slResolve(initVal,blockInfo.BlockHandle);
                end
            end
        end
        if isstruct(initVal)
            if~iszerostruct(initVal)



                msg=hdlvalidatestruct(1,message('hdlcoder:validate:busInputsInitVal',current.Name));
                result(end+1)=msg;%#ok<AGROW>
            end
        elseif(hN.SLOutputSignals(i).Type.isRecordType&&~all(initVal(:)==0))



            msg=hdlvalidatestruct(1,message('hdlcoder:validate:busInputsInitVal',current.Name));
            result(end+1)=msg;%#ok<AGROW>
        else
            initVal=resolveInitValDataType(hN,i,initVal,blockInfo);

            if(~all(initVal(:)==0))
                outPorts(i).setIsNonZeroInitVal(true);
            end
            outPorts(i).setInitialOutput(initVal);
        end
    end
end


function initVal=checkPortDefaultValues(hN,index,blockInfo)
    hOutSignal=hN.SLOutputSignals;
    hDriver=hOutSignal(index).getDrivers;
    initVal=[];


    if isprop(hDriver.Owner,'BlockTag')&&strcmpi(hDriver.Owner.BlockTag,'built-in/Constant')
        slHandle=hDriver.Owner.SimulinkHandle;
        initVal=hdlslResolve('Value',slHandle);



    elseif strcmpi(hDriver.Owner.ClassName,'ntwk_instance_comp')
        hRefN=hDriver.Owner.ReferenceNetwork;
        if hRefN.isInConditionalHierarchy
            slbh=hDriver.Component.SimulinkHandle;
            outPortSub=find_system(slbh,'FollowLinks','on','LookUnderMasks','all',...
            'SearchDepth',1,'BlockType','Outport','port',sprintf('%d',hDriver.PortIndex+1));
            initVal=get_param(outPortSub,...
            'InitialOutput');
            if strcmpi(initVal,'[]')
                initVal=checkPortDefaultValues(hRefN,hDriver.PortIndex+1,blockInfo);
            end
        end
    end
end


function newInitVal=resolveInitValDataType(hN,index,initVal,blockInfo)
    hOutSignal=hN.SLOutputSignals;
    newInitVal=initVal;
    if ischar(initVal)
        newInitVal=slResolve(newInitVal,blockInfo.BlockHandle);
    end

    if strcmpi(hdlsignalsltype(hOutSignal(index)),'boolean')
        newInitVal=boolean(newInitVal);
    else
        hType=pirelab.getTypeInfoAsFi(hOutSignal(index).Type.BaseType,'Nearest','Saturate');
        inputType=fixed.internal.type.extractNumericType(hType);
        if strcmpi(inputType.DataType,'Fixed')
            sign=inputType.SignednessBool;
            wordLength=inputType.WordLength;
            fractionLength=inputType.FractionLength;
            newInitVal=fi(newInitVal,sign,wordLength,fractionLength);
        end
    end
end


function result=checkNestedInResetRegion(hC)
    result=[];
    hN=hC.Owner;
    if hN.isInResettableHierarchy
        fullPath=getfullname(hC.SimulinkHandle);
        result=hdlvalidatestruct(1,...
        message('hdlcoder:validate:CtlPortNestedInResetSS',fullPath));
    end
end
function allMatch=checkSignalRates(signals)
    allMatch=true;
    singleRate=[];
    if~isempty(signals)
        for i=1:length(signals)
            currentRate=signals(i).SimulinkRate;
            if~isinf(currentRate)&&currentRate~=-1
                if isempty(singleRate)
                    singleRate=currentRate;
                else
                    if currentRate~=singleRate
                        allMatch=false;
                        break;
                    end
                end
            end
        end
    end
end

function result=uncellify(whatever)
    if iscell(whatever)&&length(whatever)==1
        result=whatever{1};
    else
        result=whatever;
    end
end


function flag=iszerostruct(initVal)
    assert(isstruct(initVal));
    flds=fieldnames(initVal);
    flag=true;
    for ii=1:length(flds)
        field=flds{ii};
        val=initVal.(field);
        if isstruct(val)
            flag=flag&iszerostruct(val);
        elseif any(val)
            flag=false;
            return;
        end
    end
end
