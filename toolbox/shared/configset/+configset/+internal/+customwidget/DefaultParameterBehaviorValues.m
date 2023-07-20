function out=DefaultParameterBehaviorValues(hSrc,name,direction,widgetVals)



    cs=hSrc.getConfigSet;
    if isempty(cs)

        return;
    end

    value=cs.get_param(name);

    if direction==0
        out={value,'',value,''};
    elseif direction==1
        if~isempty(cs.getComponent('PLC Coder'))&&~strcmp(value,widgetVals{3})
            index=3;
        else
            index=1;
        end

        out=widgetVals{index};
    end

