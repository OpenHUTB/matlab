function loadLinks(simObj,s)




    coder.allowpcode('plain');


    lnkStruct=matlabshared.satellitescenario.internal.Simulator.linkStruct;


    lnk=s.Links;


    simObj.Links=repmat(lnkStruct,1,numel(lnk));


    for idx=1:simObj.NumLinks
        simObj.Links(idx).ID=lnk(idx).ID;
        simObj.Links(idx).Sequence=lnk(idx).Sequence;
        simObj.Links(idx).NodeType=lnk(idx).NodeType;
        simObj.Links(idx).Status=lnk(idx).Status;
        if isfield(lnk,'StatusHistory')

            simObj.Links(idx).StatusHistory=lnk(idx).StatusHistory;
        end
        simObj.Links(idx).NumIntervals=lnk(idx).NumIntervals;
        simObj.Links(idx).Intervals=lnk(idx).Intervals;
        simObj.Links(idx).EbNo=lnk(idx).EbNo;
        simObj.Links(idx).EbNoHistory=lnk(idx).EbNoHistory;
        if isfield(lnk,'ReceivedIsotropicPower')

            simObj.Links(idx).ReceivedIsotropicPower=lnk(idx).ReceivedIsotropicPower;
        end
        if isfield(lnk,'ReceivedIsotropicPowerHistory')

            simObj.Links(idx).ReceivedIsotropicPowerHistory=lnk(idx).ReceivedIsotropicPowerHistory;
        else
            simObj.Links(idx).ReceivedIsotropicPowerHistory=zeros(1,0);
        end
        if isfield(lnk,'PowerAtReceiverInput')

            simObj.Links(idx).PowerAtReceiverInput=lnk(idx).PowerAtReceiverInput;
        else
            simObj.Links(idx).PowerAtReceiverInput=zeros(1,0);
        end
        if isfield(lnk,'PowerAtReceiverInputHistory')

            simObj.Links(idx).PowerAtReceiverInputHistory=lnk(idx).PowerAtReceiverInputHistory;
        end
    end
end

