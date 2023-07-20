function downCallback(hObj,hDlg)




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
    notBottom=(~foundCombinedOne&&rowNum<length(data)-1)||...
    (foundCombinedOne&&((rowNum>combinedRow&&rowNum<length(data)-1)||...
    (combinedRow>rowNum&&combinedRow<length(data)-1)));

    if notBottom&&~strcmp(data(rowNum+1).Category,'None')&&...
        ~strcmp(data(rowNum+2).Category,'None')&&...
        ~(strcmp(data(rowNum+1).SLObjectType,'Outport')&&...
        strcmp(data(rowNum+1).Category,'Value'))


        [belowRowMerged,~,~,~]=...
        obj.foundCombinedIO(rowNum+1,data,data(rowNum+2).ArgName);
        belowRowMerged=(belowRowMerged&&...
        ~strcmp(data(rowNum+2).ArgName,data(rowNum+1).ArgName));
        currentRowDelta=1;
        if belowRowMerged
            currentRowDelta=2;
        end

        if~foundCombinedOne
            data(rowNum+2).Position=data(rowNum+2).Position-1;
            if belowRowMerged
                data(rowNum+3).Position=data(rowNum+3).Position-1;
            end
            data(rowNum+1).Position=data(rowNum+1).Position+currentRowDelta;
        else

            if combinedRow>rowNum
                data(rowNum+2).Position=data(rowNum+2).Position+currentRowDelta;
                data(rowNum+1).Position=data(rowNum+1).Position+currentRowDelta;

                data(rowNum+3).Position=data(rowNum+3).Position-2;
                if belowRowMerged
                    data(rowNum+4).Position=data(rowNum+4).Position-2;
                end
            else
                data(rowNum+1).Position=data(rowNum+1).Position+currentRowDelta;
                data(rowNum).Position=data(rowNum).Position+currentRowDelta;

                data(rowNum+2).Position=data(rowNum+2).Position-2;
                if belowRowMerged
                    data(rowNum+3).Position=data(rowNum+3).Position-2;
                end
            end
        end
        obj.selRow=rowNum+currentRowDelta;
    end

    hDlg.enableApplyButton(1);

