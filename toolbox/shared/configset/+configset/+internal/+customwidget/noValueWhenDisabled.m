function out=noValueWhenDisabled(cs,name,direction,widgetVals)




    if direction==0
        adp=configset.internal.data.ConfigSetAdapter(cs);
        st=adp.getParamStatus(name);
        if st==0
            val=cs.getProp(name);
        else
            val='';
        end


        if strcmp(name,'DVParametersConfigFileName')
            out={val,'',''};
        else
            out={val};
        end

    elseif direction==1
        out=widgetVals{1};
    end
