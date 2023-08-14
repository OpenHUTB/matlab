function res=isConnectionLineSelected(cbinfo)




    res=false;
    selected=SLStudio.Utils.getSelectedSegmentHandles(cbinfo);
    if~isempty(selected)
        for i=1:length(selected)
            if strcmpi(get_param(selected(i),'LineType'),'connection')
                res=true;
                break
            end
        end
    end
end
