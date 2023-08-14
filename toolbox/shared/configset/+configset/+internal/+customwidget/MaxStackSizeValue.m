function out=MaxStackSizeValue(cs,name,direction,widgetVals)





    if~isempty(cs.getConfigSet)
        cs=cs.getConfigSet;
    end

    if direction==0
        val=cs.get_param(name);
        out={val,val};
    elseif direction==1
        if~isempty(cs)&&strcmp(cs.get_param('IsERTTarget'),'on')
            target=1;
        else
            target=2;
        end

        out=widgetVals{target};
        if strcmp(out,configset.internal.getMessage('optMaxStackSizeInherit'))
            out='Inherit from target';
        end
    end

