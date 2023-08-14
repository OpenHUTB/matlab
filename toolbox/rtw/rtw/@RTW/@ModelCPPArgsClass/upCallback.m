function upCallback(hObj,hDlg)





    dataType=class(hObj);
    if strcmp(dataType,'RTW.FcnClassUI')
        rowNum=hObj.fcnclass.cache.selRow;
        obj=hObj.fcnclass.cache;
        data=hObj.fcnclass.cache.Data;
    else
        rowNum=hObj.cache.selRow;
        obj=hObj.cache;
        data=hObj.cache.Data;
    end

    [foundCombinedOne,combinedRow,~,~]=...
    obj.foundCombinedIO(rowNum,data,data(rowNum+1).ArgName);
    notTop=(~foundCombinedOne&&rowNum>0)||...
    (foundCombinedOne&&((rowNum<combinedRow&&rowNum>0)||...
    (combinedRow<rowNum&&combinedRow>0)));

    if notTop&&~strcmp(data(rowNum+1).Category,'None')&&...
        ~(strcmp(data(rowNum).SLObjectType,'Outport')&&...
        strcmp(data(rowNum).Category,'Value'))


        [aboveRowMerged,~,~,~]=...
        obj.foundCombinedIO(rowNum-1,data,data(rowNum).ArgName);
        aboveRowMerged=(aboveRowMerged&&...
        ~strcmp(data(rowNum).ArgName,data(rowNum+1).ArgName));
        currentRowDelta=-1;
        if aboveRowMerged
            currentRowDelta=-2;
        end
        if~foundCombinedOne
            data(rowNum).Position=data(rowNum).Position+1;
            if aboveRowMerged
                data(rowNum-1).Position=data(rowNum-1).Position+1;
            end
            data(rowNum+1).Position=data(rowNum+1).Position+currentRowDelta;
        else

            if combinedRow>rowNum
                data(rowNum+2).Position=data(rowNum+2).Position+currentRowDelta;
                data(rowNum+1).Position=data(rowNum+1).Position+currentRowDelta;

                data(rowNum).Position=data(rowNum).Position+2;
                if aboveRowMerged
                    data(rowNum-1).Position=data(rowNum-1).Position+2;
                end
            else
                data(rowNum+1).Position=data(rowNum+1).Position+currentRowDelta;
                data(rowNum).Position=data(rowNum).Position+currentRowDelta;

                data(rowNum-1).Position=data(rowNum-1).Position+2;
                if aboveRowMerged
                    data(rowNum-2).Position=data(rowNum-2).Position+2;
                end
            end
        end
        obj.selRow=rowNum+currentRowDelta;
    end

    hDlg.enableApplyButton(1);

