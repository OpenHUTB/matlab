function out=OptimizationGRTERTValue(hSrc,name,direction,widgetVals)




    cs=hSrc.getConfigSet;

    if direction==0
        value=cs.get_param(name);
        out={value,value};
    elseif direction==1
        if~isempty(cs)&&strcmp(cs.get_param('IsERTTarget'),'on')
            target=1;
        else
            target=2;
        end

        out=widgetVals{target};
    end

