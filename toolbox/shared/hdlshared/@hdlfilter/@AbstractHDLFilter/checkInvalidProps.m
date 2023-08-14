function v=checkInvalidProps(this,varargin)






    user_props=varargin(1:2:end);
    user_vals=varargin(2:2:end);
    invalid_props=this.getunsupportedprops;
    for n=1:length(lower(user_props))
        pos=strmatch(lower(user_props(n)),lower(invalid_props));
        if~isempty(pos)
            cas_props=lower(this.getCascadedProperties);
            cellprop_pos=strmatch(lower(user_props(n)),cas_props);
            if isempty(cellprop_pos)
                v=hdlvalidatestruct(1,message('HDLShared:filters:validate:invalidProperty',invalid_props{pos}));
                return
            else
                if~iscell(user_vals{n})
                    v=hdlvalidatestruct(1,message('HDLShared:filters:validate:invalidProperty',invalid_props{pos}));
                    return
                end
            end
        end
    end
    v=hdlvalidatestruct;
