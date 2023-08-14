function cachedSignals=cacheConstSignalIndices(simOut,outLoggingName,sigLoggingName)


    assert(isa(simOut,'Simulink.SimulationOutput'));



    cachedSignals=struct('sigLoggingName',sigLoggingName,'outLoggingName'...
    ,outLoggingName,sigLoggingName,[],outLoggingName,[]);










    if any(strcmp(simOut.who,sigLoggingName))
        logsout=simOut.get(sigLoggingName);
        cachedSignals.(sigLoggingName)=findConstSignalsInDS(logsout);
    end

    if any(strcmp(simOut.who,outLoggingName))
        yout=simOut.get(outLoggingName);
        cachedSignals.(outLoggingName)=findConstSignalsInDS(yout);
    end

end

function ind=findConstSignalsInDS(dataSet)






    ind=[];




    assert(isa(dataSet,'Simulink.SimulationData.Dataset'));

    len=dataSet.numElements;

    for i=1:len

        bpObj=dataSet{i}.BlockPath;
        portIdx=dataSet{i}.PortIndex;
        portType=dataSet{i}.PortType;
        block=bpObj.getBlock(bpObj.getLength());
        sampleTime=get_param(block,'CompiledSampleTime');





        if iscell(sampleTime)
            sampleTime=sampleTime{portIdx};
        end
        if isequal(sampleTime(1),Inf)
            ind(end+1)=i;%#ok<AGROW>
        end
    end
end
