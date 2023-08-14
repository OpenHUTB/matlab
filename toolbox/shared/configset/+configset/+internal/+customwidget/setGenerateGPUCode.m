function out=setGenerateGPUCode(cs,name,direction,widgetVals)





    if direction==0
        paramVal=cs.getProp(name);
        if strcmp(paramVal,'None')
            out={'off'};
        else
            out={'on'};
        end
    elseif direction==1
        if widgetVals{1}
            out='CUDA';
        else
            out='None';
        end
    end
