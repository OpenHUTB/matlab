function isStrPort=hasStringPort(~,hPir)



    isStrPort=false;

    topNtwk=hPir.getTopNetwork;

    for ii=1:topNtwk.NumberOfPirInputPorts
        hT=topNtwk.PirInputSignals(ii).Type;
        if isCharType(hT.BaseType)
            isStrPort=true;
            break;
        end
    end

    if~isStrPort

        for ii=1:topNtwk.NumberOfPirOutputPorts
            hT=topNtwk.PirOutputSignals(ii).Type;
            if isCharType(hT.BaseType)
                isStrPort=true;
                break;
            end
        end

    end

end
