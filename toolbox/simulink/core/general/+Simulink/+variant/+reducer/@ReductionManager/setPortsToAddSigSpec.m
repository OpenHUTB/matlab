function setPortsToAddSigSpec(obj,portParent,ssPortInfo)








    if slvariants.internal.utils.isBlockInsideSubsystemReference(portParent)




        return;
    end




    if isKey(obj.PortsToAddSigSpec,portParent)


        Simulink.variant.reducer.utils.assert(~iscell(obj.PortsToAddSigSpec(portParent)));
        valOld=obj.PortsToAddSigSpec(portParent);








        toModifyIdx=[];
        for valId=1:numel(valOld)

            if isequal(valOld(valId).SrcPortHandle,ssPortInfo.SrcPortHandle)


                toModifyIdx=valId;
                break;
            end






            dstPortsOld=valOld(valId).DstPortHandle(:)';

            if isequal(dstPortsOld,(ssPortInfo.DstPortHandle(:))')



                toModifyIdx=valId;
                break;
            end
        end

        valNew=valOld;
        if~isempty(toModifyIdx)





            valNew(toModifyIdx)=ssPortInfo;
        else



            valNew=[valOld,ssPortInfo];
        end
    else


        valNew=ssPortInfo;
    end
    obj.PortsToAddSigSpec(portParent)=valNew;

end


