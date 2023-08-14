function[value,success]=getProp(h,prop)






















    if nargin>1
        for i=1:numel(h.prop_sets)
            if h.prop_set_enables(i)


                [value,success]=h.prop_sets{i}.getProp(prop);
                if success
                    return
                end
            end
        end


        value=[];
        success=false;

        if nargout<2
            PropErrorStr(h,prop);
        end
    else

        value={};
        for i=1:numel(h.prop_sets)
            if h.prop_set_enables(i)
                value=[value;getProp(h.prop_sets{i})];%#ok
            end
        end
        success=true;
    end
