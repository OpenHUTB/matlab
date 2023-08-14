function[value,success]=getProp(h,prop)






















    if nargin>1
        for i=1:numel(h.prop_sets)
            if h.prop_set_enables(i)
                try



                    value=h.prop_sets{i}.(prop);
                    success=true;
                    break;
                catch me


                    value=[];
                    success=false;

                    if nargout<2
                        PropErrorStr(h,prop);
                    end
                end
            end
        end
    else

        value={};
        for i=1:numel(h.prop_sets)
            if h.prop_set_enables(i)
                value=[value;fieldnames(h.prop_sets{i})];%#ok<AGROW>
            end
        end
        success=true;
    end
end
