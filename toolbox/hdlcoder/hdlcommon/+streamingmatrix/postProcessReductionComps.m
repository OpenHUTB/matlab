function postProcessReductionComps(~,applyReductionOutputNW)




























    if isempty(applyReductionOutputNW)

        return
    end

    removeScalarCompsOfType(applyReductionOutputNW,...
    {'hdlcoder.reshape_comp','hdlcoder.selector_comp'});


    comps=applyReductionOutputNW.Components;
    for ii=1:numel(comps)
        if removableAssignmentComp(comps(ii))
            removeAssignmentComp(comps(ii));
        end
    end


    for ii=1:numel(comps)
        if isa(comps(ii),'hdlcoder.selector_comp')
            addIndexSaturation(comps(ii));
        end
    end

end

function removeScalarCompsOfType(N,compTypes)





    comps=N.Components;
    for ii=1:numel(comps)
        if any(strcmp(class(comps(ii)),compTypes))
            in1=comps(ii).PirInputSignals(1);
            if~isa(in1.Type,'hdlcoder.tp_array')
                removeComp(comps(ii));
            end
        end
    end

end

function removeComp(comp)






    ins=comp.PirInputSignals;
    for ii=1:numel(ins)
        ins(ii).disconnectReceiver(comp.PirInputPorts(ii));
    end

    outputs=comp.PirOutputSignals;
    for ii=1:numel(outputs)
        nextPorts=outputs(ii).getReceivers;
        for jj=1:numel(nextPorts)
            outputs(ii).disconnectReceiver(nextPorts(jj));
        end
        if(ii==1)

            for jj=1:numel(nextPorts)
                ins(1).addReceiver(nextPorts(jj));
            end
        end
    end
end

function addIndexSaturation(comp)


    if~isa(comp,'hdlcoder.selector_comp')


        return
    end
    if~isa(comp.PirInputSignals(1),'hdlcoder.signal')||...
        ~numel(comp.PirInputSignals)==2

        return;
    end
    in1Type=comp.PirInputSignals(1).Type;
    if~isa(in1Type,'hdlcoder.tp_array')
        return
    end
    in1Size=prod(in1Type.Dimensions);

    in2S=comp.PirInputSignals(2);
    in2S.disconnectReceiver(comp.PirInputPorts(2));

    nw=comp.Owner;
    outS=nw.addSignal(in2S.Type,'clamped');
    outS.addReceiver(comp.PirInputPorts(2));
    pirelab.getSaturateComp(nw,in2S,outS,1,in1Size);
end

function out=removableAssignmentComp(comp)
    out=false;
    if isa(comp,'hdlcoder.assignment_comp')

        receivingPorts=comp.PirOutputSignals(1).getReceivers;
        for ii=1:numel(receivingPorts)
            if isa(receivingPorts(ii).Owner,'hdlcoder.network')
                out=true;
                break
            end
        end
    end
end

function removeAssignmentComp(comp)







    nwOutSignal=comp.PirInputSignals(2);



    for ii=1:numel(comp.PirInputSignals)
        comp.PirInputSignals(ii).disconnectReceiver(comp.PirInputPorts(ii));
    end



    outS=comp.PirOutputSignals(1);
    receivingPorts=outS.getReceivers;
    for ii=1:numel(receivingPorts)
        if isa(receivingPorts(ii).Owner,'hdlcoder.network')
            outS.disconnectReceiver(receivingPorts(ii));
            nwOutSignal.addReceiver(receivingPorts(ii));
        end
    end
end







