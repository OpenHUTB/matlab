function[as_output]=addSignal(this,signalStruct,signalType,codeDescriptor,slrt_task_info)







    if nargin<3,signalType=slrealtime.internal.instrument.SignalTypes.Badged;end
    if nargin<4,codeDescriptor=[];end
    if nargin<5,slrt_task_info=[];end


    agi=-1;
    si=-1;
    as_output=struct('acquiregroupindex',agi,'signalindex',si);

    if~startsWith(this.mldatxfile,"MODEL:")


        if isempty(codeDescriptor)||isempty(slrt_task_info)






            [codeDescriptor,slrt_task_info,app]=slrealtime.internal.streamingSignalInfoUtil.getCodeDescriptorFromMLDATX(this.mldatxfile);%#ok
        end




        try
            signalInfos=slrealtime.internal.streamingSignalInfoUtil.getXcpSignalInfoFromCodeDescriptor(signalStruct,codeDescriptor,slrt_task_info);
        catch ME
            codeDescriptor=[];%#ok
            rethrow(ME);
        end
        codeDescriptor=[];%#ok
    else




        model=extractAfter(this.mldatxfile,"MODEL:");

        if signalStruct.portindex==-1
            blks=getBlockAndPortsFromSignalName(model,signalStruct.signame);
        else
            blockpath=signalStruct.blockpath.convertToCell;
            if length(blockpath)>1
                str=slrealtime.Instrument.getSignalStringToDisplay(signalStruct);
                slrealtime.internal.throw.Warning('slrealtime:instrument:NormalModeModelReference',str);
                return;
            end
            blks.blockpath=blockpath;
            blks.portindex=signalStruct.portindex;
        end

        signalInfos=[];
        for i=1:length(blks)
            tid=getTID(model,blks(i).blockpath{1},blks(i).portindex);
            signalInfos(i).blockPath=blks(i).blockpath;%#ok
            signalInfos(i).blockSID=blks(i).blockpath;%#ok
            signalInfos(i).portNumber=blks(i).portindex-1;%#ok
            signalInfos(i).signalName=signalStruct.signame;%#ok
            signalInfos(i).loggedName='';%#ok
            signalInfos(i).propagatedName='';%#ok
            signalInfos(i).signalSourceUUID='';%#ok
            signalInfos(i).signalSourceUUIDasInteger=uint64(0);%#ok
            signalInfos(i).discreteInterval=1;%#ok
            signalInfos(i).sampleTimeString='1';%#ok
            signalInfos(i).tid=tid;%#ok
            signalInfos(i).leafElements=[];%#ok
            signalInfos(i).isVarDims=false;%#ok
            signalInfos(i).isMessageLine=false;%#ok
            signalInfos(i).isDiscrete=false;%#ok
            signalInfos(i).domainType='';%#ok
            signalInfos(i).maxPoints=0;%#ok
            signalInfos(i).targetAddress=-1;%#ok
            signalInfos(i).type=coder.internal.xcp.TypeInfo;%#ok
            signalInfos(i).dimensions=getDimensions(blks(i).blockpath{1},blks(i).portindex);%#ok
            signalInfos(i).dataTypeID=0;%#ok
            signalInfos(i).dataTypeSize=8;%#ok
            signalInfos(i).isHalf=false;%#ok
            signalInfos(i).isEnum=false;%#ok
            signalInfos(i).isFixedPoint=false;%#ok
            signalInfos(i).isString=false;%#ok
            signalInfos(i).isNVBus=false;%#ok
            signalInfos(i).isComplex=false;%#ok
            signalInfos(i).isFrame=false;%#ok
            signalInfos(i).enumClassification='';%#ok
            signalInfos(i).enumClassName='';%#ok
            signalInfos(i).enumLabels=[];%#ok
            signalInfos(i).enumValues=[];%#ok
            signalInfos(i).fxpSlopeAdjFactor=0;%#ok
            signalInfos(i).fxpNumericType=0;%#ok
            signalInfos(i).fxpFractionLength=0;%#ok
            signalInfos(i).fxpBias=0;%#ok
            signalInfos(i).fxpWordLength=0;%#ok
            signalInfos(i).fxpFixedExponent=0;%#ok
            signalInfos(i).fxpSignedness=0;%#ok
            signalInfos(i).structElements=[];%#ok
            signalInfos(i).structElementOffset=-1;%#ok
            signalInfos(i).structElementName='';%#ok
            signalInfos(i).matlabObsFcn=[];%#ok
            signalInfos(i).matlabObsParam=[];%#ok
            signalInfos(i).matlabObsCallbackGroup=[];%#ok
            signalInfos(i).matlabObsFuncHandle=[];%#ok
            signalInfos(i).matlabObsDropIfBusy=[];%#ok




            signalInfos(i).SimulationDataBlockPath=Simulink.SimulationData.BlockPath(signalInfos(i).blockPath);%#ok
            signalInfos(i).decimation=signalStruct.decimation;%#ok
        end
    end

    if isempty(signalInfos)
        return;
    end


    if(signalType.isInstrumentSignal)
        for isf=1:length(signalInfos)
            sigInfo=signalInfos(isf);

            if length(sigInfo.dimensions)>2
                str=slrealtime.Instrument.getSignalStringToDisplay(signalStruct);
                slrealtime.internal.throw.Warning('slrealtime:instrument:CannotInstrumentND',str);
                return;
            end

            if sigInfo.isFixedPoint||sigInfo.isHalf
                str=slrealtime.Instrument.getSignalStringToDisplay(signalStruct);
                slrealtime.internal.throw.Warning('slrealtime:instrument:CannotInstrumentFixedPoint',str);
                return;
            end
        end
    end



    if length(signalInfos)>1
        str=slrealtime.Instrument.getSignalStringToDisplay(signalStruct);
        slrealtime.internal.throw.Warning('slrealtime:instrument:DoubleResolves',str);
    end


    agilist=-1*ones(length(signalInfos),1);
    silist=-1*ones(length(signalInfos),1);
    for isf=1:length(signalInfos)
        sigInfo=signalInfos(isf);
        decimation=sigInfo.decimation;





        agi=this.getAcquireGroupIndex(sigInfo.tid,decimation);
        if agi==-1

            agi=this.addAcquireGroup(sigInfo.tid,sigInfo.discreteInterval,sigInfo.sampleTimeString,decimation);
        end
        agilist(isf)=agi;
        acquireGroup=this.AcquireGroups(agi);


        silist(isf)=acquireGroup.addSignalFromXcpSignalInfo(sigInfo,signalStruct);
    end

    this.updateMaxGroupLength();

    agi=agilist;
    si=silist;

    as_output=struct('acquiregroupindex',agi,'signalindex',si);
end

function out=getTID(model,blk,portIdx)







    out=[];

    sampleTimesTable=Simulink.BlockDiagram.getSampleTimes(model);
    sampleTimes={sampleTimesTable.Value};
    sampleTimes=sampleTimes(cellfun(@(x)all(size(x)==[1,2]),sampleTimes));

    ports=get_param(blk,'PortHandles');
    st=get_param(ports.Outport(portIdx),'CompiledSampleTime');

    function val=ismatch(a,b)
        if isinf(a)&&isinf(b)
            val=true;
        else
            if abs(a-b)==0
                val=true;
            else
                val=abs(a-b)<=eps(min(abs(a),abs(b)));
            end
        end
    end
    j=cellfun(@(x)(ismatch(st(1),x(1))...
    &&ismatch(st(2),x(2))),...
    sampleTimes);
    if(sum(j)==1)
        out=find(j==1)-1;
    end
end

function dims=getDimensions(blkpath,portindex)






    portHs=get_param(blkpath,'PortHandles');
    portH=portHs.Outport(portindex);
    port=get(portH,'Object');
    dims=port.CompiledPortDimensions;




    if length(dims)==2
        if dims(1)==1
            dims=dims(2);
        elseif dims(2)==1
            dims=dims(1);
        end
    end
end

function blks=getBlockAndPortsFromSignalName(model,signame)






    blks=[];

    allLines=find_system(model,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FindAll','on','Type','line');
    allNames=get(allLines,'Name');
    lines=allLines(strcmp(allNames,signame));

    if~isempty(lines)
        blks=struct('blockpath',[],'portindex',[]);
        srcPortHs=get(lines,'SrcPortHandle');
        if iscell(srcPortHs)
            srcPortHs=cell2mat(srcPortHs);
        end
        ports=unique(srcPortHs);
        for i=1:length(ports)
            blks(i).blockpath={get(ports(i),'Parent')};
            blks(i).portindex=get(ports(i),'PortNumber');
        end
    end
end
