function elaborateFromGotoRtwcg(hN)

    vComps=hN.Components;
    numComps=length(vComps);

    for i=1:numComps
        hC=vComps(i);

        if hC.isNetworkInstance
            hRefNtwk=hC.ReferenceNetwork;
            slEnginePir.elaborateFromGotoRtwcg(hRefNtwk);
        end

        if~hC.getRtwcgDraw
            continue;
        end

        blktype=hC.getPropertyValueString('Type');

        if strcmp(blktype,'Goto')||strcmp(blktype,'From')
            elaborate(hN,hC,blktype);
            hN.removeComponent(hC);

        end
    end
end

function newComp=elaborate(hN,hC,blktype)

    [tagName,tagScope]=getTag(hC);

    if strcmp(blktype,'From')
        fromOut=hC.PirOutputSignals(1);
        newComp=pirelab.getFromComp(hN,fromOut,tagName,tagScope,hC.Name);

    elseif strcmp(blktype,'Goto')
        gotoIn=hC.PirInputSignals(1);
        newComp=pirelab.getGotoComp(hN,gotoIn,tagName,tagScope,hC.Name);

    end
end


function[tag,scope]=getTag(hC)

    tag=hC.getPropertyValueString('GotoTag');
    scope=['ntwk_',hC.getPropertyValueString('TagVisibility')];

end
