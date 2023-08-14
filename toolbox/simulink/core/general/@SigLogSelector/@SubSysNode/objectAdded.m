function objectAdded(h,~,event)




    me=SigLogSelector.getExplorer;
    if isempty(me)||~strcmp('done',me.status)
        return;
    end

    if isprop(event,'Child')
        blk=event.Child;
    else







        blk=find(event.Source.getHierarchicalChildren,...
        '-isa','Stateflow.Chart',...
        '-or','-isa','Stateflow.TruthTableChart',...
        '-or','-isa','Stateflow.StateTransitionTableChart',...
        '-or','-isa','Stateflow.LinkChart',...
        '-depth',1);%#ok<GTARG>
    end




    if~blk.isHierarchical&&blk.isa('Simulink.Block')
        h.clearSignalChildren;
        h.fireListChanged;
        return;
    end

    blk=SigLogSelector.filter(blk);

    if(isempty(blk))
        return;
    end









    if blk.isa('Simulink.Block')&&slprivate('is_stateflow_based_block',blk.Handle)
        locSFAddTempListeners(blk,h);
        return;
    end

    newnode=h.addChild(blk);
    newnode.populate;





    childSF=blk.find('-isa','Simulink.SubSystem');
    for idx=1:length(childSF)
        if slprivate('is_stateflow_based_block',childSF(idx).Handle)


            locSFAddTempListeners(childSF(idx),newnode);
        end
    end


    h.clearSignalChildren;
    h.fireListChanged;


    ed=DAStudio.EventDispatcher;
    ed.broadcastEvent('ChildAddedEvent',h,newnode);



    if newnode.containsModelReference
        me=SigLogSelector.getExplorer;
        me.getRoot.modelBlockAddedOrRemoved;
    end

end


function locSFAddTempListeners(blk,node)
    l=Simulink.listener(blk,'ObjectChildAdded',...
    @(s,e)locSFObjectAdded(s,e,node));
    if(isempty(node.SFObjectBeingAddedListeners))
        node.SFObjectBeingAddedListeners=l;
    else
        node.SFObjectBeingAddedListeners(end+1)=l;
    end
    l=Simulink.listener(blk,'NameChangeEvent',...
    @(s,e)locSFObjectAdded(s,e,node));
    node.SFObjectBeingAddedListeners(end+1)=l;
end


function locSFObjectAdded(s,e,h)





    for idx=1:2:length(h.SFObjectBeingAddedListeners)
        if~iscell(h.SFObjectBeingAddedListeners(idx).Source)&&isequal(h.SFObjectBeingAddedListeners(idx).Source.Name,e.Source.Name)...
            ||iscell(h.SFObjectBeingAddedListeners(idx).Source)&&isequal(h.SFObjectBeingAddedListeners(idx).Source{1}.Name,e.Source.Name)
            delete(h.SFObjectBeingAddedListeners([idx,idx+1]));
            h.SFObjectBeingAddedListeners([idx,idx+1])=[];
            break;
        end
    end
    h.objectAdded(s,e);

end
