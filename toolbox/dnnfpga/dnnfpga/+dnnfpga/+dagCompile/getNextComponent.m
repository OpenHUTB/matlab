function ret_component=getNextComponent(hindex_component)




    if(~isempty(hindex_component.outputs))
        if(numel(hindex_component.outputs.net.receivers)>1)
            for i=1:numel(hindex_component.outputs.net.receivers)
                ret_component(i)=hindex_component.outputs.net.receivers(i).component;
            end
        else
            ret_component=hindex_component.outputs.net.receivers.component;
        end
    else


        ret_component=[];
    end
end