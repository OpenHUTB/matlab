function initSelectedIDs(this)








    treeids=[];


    sigs=this.Items;
    for ct=1:numel(sigs)
        if strcmp(class(sigs{ct}),'Simulink.sigselector.SignalItem')

            if sigs{ct}.Selected
                treeids(end+1)=sigs{ct}.TreeID;
            end
        else

            for ctc=1:numel(sigs{ct}.Hierarchy)

                if sigs{ct}.Hierarchy(ctc).Selected
                    treeids(end+1)=sigs{ct}.Hierarchy(ctc).TreeID;
                end

                treeids=LocalCheckBusElements(sigs{ct}.Hierarchy(ctc).Children,treeids);
            end
        end
    end
    this.SelectedIDs=treeids;
end


function selectedids=LocalCheckBusElements(bus,selectedids)
    for ct=1:numel(bus)
        if bus(ct).Selected
            selectedids(end+1)=bus(ct).TreeID;
        end
        if~isempty(bus(ct).Children)
            selectedids=LocalCheckBusElements(bus(ct).Children,selectedids);
        end
    end
end


