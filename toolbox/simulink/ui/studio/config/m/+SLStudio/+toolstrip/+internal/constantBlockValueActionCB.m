function constantBlockValueActionCB(cbinfo)





    constant_value=cbinfo.EventData;

    selection=cbinfo.getSelection;
    for i=1:numel(selection)
        if strcmp(selection(i).BlockType,'Constant')
            try
                set_param(selection(i).Handle,'Value',constant_value);
            catch
            end
        end
    end
end