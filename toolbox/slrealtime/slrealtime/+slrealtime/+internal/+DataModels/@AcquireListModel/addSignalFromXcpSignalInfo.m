function[as_output]=addSignalFromXcpSignalInfo(this,signalStruct,xcpSignal,decimation)








    agi=-1;
    si=-1;

    agilist=-1;
    silist=-1;

    sigInfo=xcpSignal;


    output=this.getXcpSignalInfoIndex(sigInfo);
    agi=output.acquiregroupindex;
    si=output.signalindex;





    agi=this.getAcquireGroupIndex(sigInfo.tid,decimation);
    if agi==-1

        agi=this.addAcquireGroup(sigInfo.tid,sigInfo.discreteInterval,sigInfo.sampleTimeString,decimation);
    end
    agilist=agi;
    acquireGroup=this.AcquireGroups(agi);


    silist=acquireGroup.addSignalFromXcpSignalInfo(sigInfo,signalStruct);

    this.updateMaxGroupLength();

    agi=agilist;
    si=silist;

    as_output=struct('acquiregroupindex',agi,'signalindex',si);

end
