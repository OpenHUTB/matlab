function ret_component=getPreviousComponent(hindex_component)

    if(~isempty(hindex_component.inputs))
        ret_component=hindex_component.inputs.net.driver.component;
    else


        ret_component=[];
    end
end