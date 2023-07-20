function loadAccesses(simObj,s)




    coder.allowpcode('plain');


    acStruct=matlabshared.satellitescenario.internal.Simulator.accessStruct;


    ac=s.Accesses;



    simObj.Accesses=repmat(acStruct,1,numel(ac));


    for idx=1:simObj.NumAccesses
        simObj.Accesses(idx).ID=ac(idx).ID;
        simObj.Accesses(idx).Sequence=ac(idx).Sequence;
        simObj.Accesses(idx).NodeType=ac(idx).NodeType;
        simObj.Accesses(idx).Status=ac(idx).Status;
        if isfield(ac,'StatusHistory')

            simObj.Accesses(idx).StatusHistory=ac(idx).StatusHistory;
        end
        simObj.Accesses(idx).NumIntervals=ac(idx).NumIntervals;
        simObj.Accesses(idx).Intervals=ac(idx).Intervals;
    end
end

