function out=sldvParameterTableValues(cs,~,direction,widgetVals)







    cs=cs.getConfigSet;

    if direction==0

        [tableInfo,~]=configset.internal.customwidget.sldvParameterTable(cs);
        out={tableInfo.Data,'','','','','','',''};

    elseif direction==1






        if iscell(widgetVals{1})
            out=widgetVals{1};
        else
            out=widgetVals;
        end

    end
end



