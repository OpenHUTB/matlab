function connectCopyToTree(hSrc,hCopy,hCopyParent,hContext)













    connectCopyToTree@matlab.graphics.primitive.world.Group(hSrc,hCopy,hCopyParent,hContext);

    hOldCursor=hSrc.Cursor;
    if~isempty(hOldCursor)
        hNewCursor=hOldCursor.copy();

        hOldSource=hOldCursor.DataSource;
        if~isempty(hOldSource)
            hTarget=hOldSource.getAnnotationTarget();


            if hContext.willBeCopied(hTarget)
                hTarget=hContext.getCopy(hTarget);
            end



            hNewSource=matlab.graphics.chart.interaction.dataannotatable.internal.createDataAnnotatable(hTarget);

            if~isempty(hNewSource)



                hDataTipTemplate=hOldSource.DataTipTemplate;



                if strcmpi(hDataTipTemplate.Serializable,'on')
                    matlab.graphics.datatip.internal.DataTipTemplateHelper.applyDataTipTemplate(hNewSource,hDataTipTemplate);
                end
                hNewCursor.DataSource=hNewSource;
            else




                hNewCursor.DataSource=[];
            end
        end

        hCopy.Cursor=hNewCursor;
    end
