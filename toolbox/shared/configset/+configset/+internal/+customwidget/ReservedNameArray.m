function out=ReservedNameArray(cs,name,direction,widgetVals)


    if direction==0
        paramVal=cs.getProp(name);
        widgetVal=slprivate('cs_reserved_array_to_names',paramVal);
        out={widgetVal};

    elseif direction==1
        widgetVal=widgetVals{1};
        paramVal=slprivate('cs_reserved_names_to_array',widgetVal);
        out=paramVal;
    end

