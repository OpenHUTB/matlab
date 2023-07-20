function tab=disableWidgets(tab)




    if(isfield(tab,'Items'))
        for i=1:size(tab.Items,2)
            thisItem=tab.Items{i};
            if(isfield(thisItem,'Items'))

                thisItem=Simulink.CSCUI.disableWidgets(thisItem);
            else

                thisItem.Enabled=0;
            end
            tab.Items{i}=thisItem;
        end
    end

