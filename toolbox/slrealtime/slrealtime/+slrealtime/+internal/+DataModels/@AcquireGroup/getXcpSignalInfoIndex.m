function[si]=getXcpSignalInfoIndex(this,signalInfo)






    si=-1;


    matches=arrayfun(@(x)isequal(signalInfo.SimulationDataBlockPath,x.SimulationDataBlockPath)&&isequal(signalInfo.portNumber,x.portNumber)&&isequal(signalInfo.signalName,x.signalName),this.xcpSignals.toArray);
    if any(matches)
        idxs=find(matches);
        si=idxs(1);
    end
end
