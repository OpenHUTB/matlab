function dlgSchema=internalGetPmSchema(hThis,hBlk,~)






    hBlk=pmsl_getdoublehandle(hBlk);

    try
        isComponentBlock=simscape.engine.sli.internal.iscomponentblock(hBlk);




        if isComponentBlock&&hThis.RequestChooser
            getSchema=nesl_private('nesl_create_pmchooserschema');
            dlgSchema=getSchema(hThis.ComponentName,hBlk);



            if isempty(hThis.ComponentName)
                hThis.ComponentName=simscape.getBlockComponent(hBlk);
            end
        else
            hThis.ComponentName=simscape.getBlockComponent(hBlk);
            dlgSchema=simscape.internal.dialog.loadSchema(hThis.ComponentName,hBlk);
        end

    catch ME

        if(strcmp(ME.identifier,'physmod:pm_sli:sl:InvalidMethodReturnType'))
            rethrow(ME);
        else
            pm_error('physmod:ne_sli:internal:UnableToCreateDialog');
        end

    end

end
