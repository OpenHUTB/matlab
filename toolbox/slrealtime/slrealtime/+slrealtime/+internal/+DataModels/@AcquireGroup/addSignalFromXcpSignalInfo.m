function[si]=addSignalFromXcpSignalInfo(this,sigInfo,sigStruct)







    if~(isfield(sigInfo,'blockPath')&&isfield(sigInfo,'portNumber')&&isfield(sigInfo,'signalName'))
        if~isa(sigInfo,'slrealtime.internal.DataModels.XcpSignal')
            slrealtime.internal.throw.Error('slrealtime:instrument:InvalidArg');
        end
    end

    if~(isfield(sigStruct,'blockpath')&&isfield(sigStruct,'portindex')&&isfield(sigStruct,'signame')&&isfield(sigStruct,'statename'))
        if~isa(sigStruct,'slrealtime.internal.DataModels.SignalStruct')
            slrealtime.internal.throw.Error('slrealtime:instrument:InvalidArg');
        end
    end



    m=mf.zero.getModel(this);

    xs=slrealtime.internal.DataModels.XcpSignal(m);


    if~isempty(sigInfo.structElements)
        xs=addStructElementArray(m,xs,sigInfo);
    end

    xs.fillFromSignalInfoMXArray(sigInfo);




    xs.SimulationDataBlockPath=Simulink.SimulationData.BlockPath(sigInfo.blockPath);
    this.xcpSignals.add(xs);



    ss=slrealtime.internal.DataModels.SignalStruct(m);
    if isa(sigStruct,'slrealtime.internal.DataModels.SignalStruct')
        ss.fillFromSignalStruct(sigStruct);
    else
        ss.fillFromSignalStructMXArray(sigStruct);
        ss.SimulationDataBlockPath=Simulink.SimulationData.BlockPath(sigStruct.blockpath);
    end
    this.signalStructs.add(ss);


    this.nSignals=length(toArray(this.signalStructs));
    si=this.nSignals;

end


function parentSS=addStructElementArray(m,parentSS,signalInfo)
    sElems=[];
    for i=1:length(signalInfo.structElements)
        se=signalInfo.structElements(i);
        s=slrealtime.internal.DataModels.XcpSignal(m);
        if~isempty(se.structElements)
            s=addStructElementArray(m,s,se);
        end
        s.fillFromStructElementMXArray(se);

        sElems=[sElems;s];%#ok
    end

    parentSS.structElements=sElems;
end
