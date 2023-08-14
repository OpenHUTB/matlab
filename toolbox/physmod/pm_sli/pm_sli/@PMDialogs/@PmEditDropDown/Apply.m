function retStatus=Apply(hThis)







    try

        if~isempty(hThis.Choices)





            tag=[hThis.ObjId,'.',hThis.ValueBlkParam,'.Combo'];
            dialogs=DAStudio.ToolRoot.getOpenDialogs(...
            hThis.BlockHandle.getDialogSource());




            for i=1:length(dialogs)
                dialog=dialogs(i);
                value=dialog.getWidgetValue(tag);
                if(~isempty(value))
                    widgetVal=value;
                    break;
                end
            end

            pm_assert(~isnumeric(widgetVal));
            conditionedVal=widgetVal;
        else




            conditionedVal=hThis.Value;

        end




        hBlk=pmsl_getdoublehandle(hThis.BlockHandle);
        hThis.setParamCache(hBlk,hThis.ValueBlkParam,conditionedVal);
        retStatus=hThis.applyChildren();

    catch %#ok<CTCH>
        retStatus=false;
    end

end
