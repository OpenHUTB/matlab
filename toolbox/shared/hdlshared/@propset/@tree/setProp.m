function[success,err]=setProp(h,prop,value)



















    for i=1:numel(h.prop_sets)
        if h.prop_set_enables(i)
            [success,err]=h.prop_sets{i}.setProp(prop,value);
            if success
                return
            end
        end
    end


    success=false;


