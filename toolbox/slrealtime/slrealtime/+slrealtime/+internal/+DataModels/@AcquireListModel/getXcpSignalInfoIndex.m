function[output]=getXcpSignalInfoIndex(this,signalInfo)






    agi=-1;
    si=-1;


    for ag=1:double(this.nAcquireGroups)
        AcuireGroup=this.AcquireGroups(ag);
        si=AcuireGroup.getXcpSignalInfoIndex(signalInfo);
        if si~=-1
            agi=ag;
            output=struct('acquiregroupindex',agi,'signalindex',si);
            return
        end
    end
    output=struct('acquiregroupindex',agi,'signalindex',si);

end
