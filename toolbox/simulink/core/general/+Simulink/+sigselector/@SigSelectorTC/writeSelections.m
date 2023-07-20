function writeSelections(this)













    items=this.Items;
    selectedids=this.getSelectedTreeIDs;

    for ct=1:numel(items)

        if strcmp(class(items{ct}),'Simulink.sigselector.SignalItem')

            if any(items{ct}.TreeID==selectedids)
                items{ct}.Selected=true;
            else
                items{ct}.Selected=false;
            end
        else

            for ctc=1:numel(items{ct}.Hierarchy)
                if any(items{ct}.Hierarchy(ctc).TreeID==selectedids)
                    items{ct}.Hierarchy(ctc).Selected=true;
                else
                    items{ct}.Hierarchy(ctc).Selected=false;
                end

                items{ct}.Hierarchy(ctc).Children=LocalMarkBusElements(items{ct}.Hierarchy(ctc).Children,selectedids);
            end
        end
    end


    this.Items=items;

    function bus=LocalMarkBusElements(bus,selectedids)
        for ct=1:numel(bus)
            if any(bus(ct).TreeID==selectedids)
                bus(ct).Selected=true;
            else
                bus(ct).Selected=false;
            end
            if~isempty(bus(ct).Children)
                bus(ct).Children=LocalMarkBusElements(bus(ct).Children,selectedids);
            end
        end


