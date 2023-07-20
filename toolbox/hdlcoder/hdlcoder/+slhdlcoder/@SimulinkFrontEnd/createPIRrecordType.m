function pirrecord=createPIRrecordType(this,slbh,portH,sigHier)




    try
        busobj=slhdlcoder.SimulinkFrontEnd.getSlResolvedBusObject(sigHier.BusObject,slbh);
    catch
        busobj=[];
    end

    try
        pirrecord=getpirrecordtype(this,slbh,sigHier.Children,busobj,portH,sigHier.BusObject);
        portDims=get_param(portH,'CompiledPortDimensions');
        if notVirtual(portH,portDims)&&~slhdlcoder.SimulinkFrontEnd.isascalartype(portDims)&&~outputAsBus(slbh,portDims)

            parsedoutdims=hdlparseportdims(portDims,1);
            isvector=[parsedoutdims(2,1),parsedoutdims(3,1)];
            if length(isvector)>1&&~any(isvector==0)&&max(isvector)~=prod(isvector)




                msg=message('hdlcoder:engine:MatrixInvalidType');
                blockPath=get_param(portH,'parent');
                this.updateChecks(blockPath,'block',msg,'Error');
            end

            pirrecord=pirelab.createPirArrayType(pirrecord,isvector);
        end
    catch me


        this.updateChecks(get_param(portH,'parent'),'block',me,'Error');
        pirrecord=hdlcoder.tp_unsigned(32);
    end
end


function pirrecord=getpirrecordtype(this,slbh,busChildren,busobj,portH,busName)












    rtf=hdlcoder.tpc_rec_factory;

    if isempty(busobj)
        busStruct=get_param(portH,'CompiledBusStruct');
    end
    for ii=1:length(busChildren)
        name=busChildren(ii).SignalName;
        recordLen=1;
        busFieldName='';
        if~isempty(busobj)
            elemt=busobj.Elements(ii);
            isComplex=strcmpi(elemt.Complexity,'complex');
            type=elemt.DataType;
            dims=elemt.Dimensions;
            busFieldName=elemt.Name;
        else
            busSig=busStruct.signals(ii);
            if~isempty(busSig.busObjectName)
                subbusobj=slhdlcoder.SimulinkFrontEnd.getSlResolvedBusObject(busSig.busObjectName,slbh);
            else
                subbusobj=[];
            end
            if~isempty(busSig.signals)

                srcPorts=get_param(busSig.src,'PortHandles');
                oportH=srcPorts.Outport;
                subBusChildren=busChildren(ii).Children;
                if(isempty(subbusobj))
                    signalType=getpirrecordtype(this,slbh,subBusChildren,subbusobj,oportH,busName);
                else
                    signalType=getpirrecordtype(this,slbh,subBusChildren,subbusobj,oportH,busSig.busObjectName);
                end
                rtf.addMember(name,signalType);
                continue;
            end
            portIdx=busSig.srcPort+1;
            srcH=busSig.src;
            phan=get_param(srcH,'PortHandles');
            sigH=phan.Outport(portIdx);
            if(busSig.dfsDataTypeElemIdx==-1)
                isComplex=get_param(sigH,'CompiledPortComplexSignal');
                type=get_param(sigH,'CompiledPortDataType');
                dims=get_param(sigH,'CompiledPortDimensions');
            else
                srcObj=get_param(sigH,'Object');
                srcAttr=srcObj.getCompiledAttributes(busSig.dfsDataTypeElemIdx);

                isComplex=srcAttr.isComplex;
                type=srcAttr.dataType;
                dims=srcAttr.dimensions;
            end
        end

        if strncmpi(type,'Bus:',4)
            signalType=hdlResolveBus(this,type(5:end),slbh,busChildren(ii).Children);

            if~slhdlcoder.SimulinkFrontEnd.isascalartype(dims)
                if(~isempty(busobj)&&hdlgetparameter('GenerateRecordType'))
                    msg=message('hdlcoder:engine:RecordNestedArrayUnsupported',this.hPir.ModelName);
                    blockPath=get_param(portH,'parent');
                    this.updateChecks(blockPath,'block',msg,'Error');
                end
                recordLen=dims;
            end
        else
            try
                [~,msgobj,level]=slhdlcoder.SimulinkFrontEnd.isaValidType(type,dims);
                if~isempty(msgobj)
                    this.updateChecks(getfullname(slbh),'block',msgobj,level);
                end
                if length(dims)>1&&(prod(dims)>1||dims(1)==-2)
                    parsedoutdims=hdlparseportdims(dims,1);
                    dims=[parsedoutdims(2:end,1)];
                end
                signalType=getpirsignaltype(type,isComplex,dims);
            catch outerme %#ok<NASGU>
                try
                    dtObj=fixdt(type);
                catch me %#ok<NASGU>
                    dtObj=slResolve(type,slbh);
                end
                if isa(dtObj,'Simulink.Bus')
                    signalType=hdlResolveBus(this,type,slbh,busChildren(ii).Children);
                    if~slhdlcoder.SimulinkFrontEnd.isascalartype(dims)
                        msg=message('hdlcoder:validate:ArrayOfBusInBus');
                        blockPath=get_param(portH,'parent');
                        this.updateChecks(blockPath,'block',msg,'Error');
                    end
                elseif strcmpi(dtObj.DataTypeMode,'Double')
                    signalType=getpirsignaltype('double',isComplex,dims);
                elseif strcmpi(dtObj.DataTypeMode,'Single')

                    signalType=getpirsignaltype('single',isComplex,dims);
                else
                    [~,msgobj,level]=slhdlcoder.SimulinkFrontEnd.isaValidType(dtObj,dims);
                    if~isempty(msgobj)
                        this.updateChecks(getfullname(slbh),'block',msgobj,level);
                    end
                    [~,sltype]=hdlgettypesfromsizes(dtObj.WordLength,...
                    dtObj.FractionLength,strcmpi(dtObj.Signedness,'Signed'));
                    signalType=getpirsignaltype(sltype,isComplex,dims);
                end
            end
        end

        for jj=1:recordLen
            if strcmp(busFieldName,name)||isempty(busFieldName)
                rtf.addMember(name,signalType);
            else

                rtf.addMember(name,busFieldName,signalType);
            end
        end
    end
    if(~isempty(busobj))

        busName=strtrim(busName);
        rtf.setRecordName(busName);
    end
    pirrecord=hdlcoder.tp_record(rtf);
end

function signalType=hdlResolveBus(this,type,slbh,children)



    subbusobj=slhdlcoder.SimulinkFrontEnd.getSlResolvedBusObject(type,slbh);

    signalType=getpirrecordtype(this,slbh,children,subbusobj,[],type);
end

function flag=outputAsBus(slbh,portDims)

    flag=false;
    if strcmp(get_param(slbh,'BlockType'),'BusSelector')
        flag=strcmpi(get_param(slbh,'OutputAsBus'),'on')&&portDims(1)<=1;
    end
end

function flag=notVirtual(portH,portDims)
    portType=get_param(portH,'CompiledBusType');
    flag=((portDims(1)~=-2)&&~strcmpi(portType,'VIRTUAL_BUS'));
end
