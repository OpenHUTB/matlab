function createFromTLC(obj,tlcOpt,owner)



    name=tlcOpt.tlcvariable;
    if isempty(name)


        name=tlcOpt.makevariable;
    end
    obj.Name=name;
    obj.FullName=name;
    obj.Custom=true;
    obj.Component=class(owner);
    obj.v_Tag=['Tag_ConfigSet_RTW_STFTarget_',name];



    type=tlcOpt.type;
    obj.Hidden=isempty(type)||strcmp(type,'NonUI');

    if isempty(tlcOpt.prompt)
        obj.Prompt=name;
        obj.Description=name;
    else
        obj.Prompt=tlcOpt.prompt;
        obj.Description=tlcOpt.prompt;
    end

    obj.ToolTip=tlcOpt.tooltip;
    if isfield(tlcOpt,'popupstrings')&&~isempty(tlcOpt.popupstrings)
        popup=tlcOpt.popupstrings;
        dispVals=strsplit(popup,'|');
        if owner.isValidProperty(name)
            allowedVals=owner.getPropAllowedValues(name);
            if isempty(allowedVals)
                allowedVals=dispVals;
            end
        else
            allowedVals=dispVals;
        end














        n=length(allowedVals);
        for j=1:n
            val=allowedVals{j};
            s.disp=val;
            s.str=val;
            opts(j)=s;%#ok
        end
        obj.v_AvailableValues=opts;
        obj.Type='enum';
    else
        try
            value=owner.getProp(name);
            obj.Type=configset.util.deduceType(value);
        catch
            obj.Type=tlcOpt.type;
        end
        obj.v_AvailableValues=[];
    end

    if~isempty(tlcOpt.callback)
        obj.CallbackFunction=tlcOpt.callback;
    end


