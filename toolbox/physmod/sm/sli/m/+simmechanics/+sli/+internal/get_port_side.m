function side=get_port_side(blkType,portId)







    side='Unknown';
    blkInfoMap=simmechanics.sli.internal.getTypeIdBlockInfoMap;
    if(blkInfoMap.isKey(blkType))
        blkInfo=blkInfoMap(blkType);
        ports=blkInfo.Ports;
        for idx=1:length(ports)
            if strcmp(portId,ports(idx).Id)
                side=ports(idx).Side;
                break;
            end
        end
    end
end
