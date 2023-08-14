function out=isCustom(obj)





    if isempty(obj.UI)

        out=false;
    elseif~isempty(obj.UI.f_tooltip)||~isempty(obj.UI.f_prompt)||...
        ~isempty(obj.f_Tag)||~isempty(obj.f_AvailableValues)
        out=true;
    else
        out=false;
    end
