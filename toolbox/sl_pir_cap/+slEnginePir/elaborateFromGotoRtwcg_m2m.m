function elaborateFromGotoRtwcg_m2m(hN)

    vComps=hN.Components;
    numComps=length(vComps);

    goto_from_map=struct('goto',{},'from',{});

    for i=1:numComps
        hC=vComps(i);

        if hC.isNetworkInstance
            hRefNtwk=hC.ReferenceNetwork;
            slEnginePir.elaborateFromGotoRtwcg(hRefNtwk);
        end

        if hC.getRtwcgDraw
            blktype=hC.getPropertyValueString('Type');
        else
            blktype=get_param(hC.SimulinkHandle,'BlockType');
        end

        if strcmp(blktype,'Goto')||strcmp(blktype,'From')
            if hC.getRtwcgDraw
                elaborate(hN,hC,blktype);
                hN.removeComponent(hC);

            else
                if strcmp(blktype,'Goto')




                else

                end
            end
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

    if hC.getRtwcgDraw
        tag=hC.getPropertyValueString('GotoTag');
        scope=['ntwk_',hC.getPropertyValueString('TagVisibility')];
    else
        tag=get_param(hC.SimulinkHandle,'GotoTag');
        scope='ntwk_global';
    end
end
