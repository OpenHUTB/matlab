function rfblksstoreopcondition(source,dialog,original_conditionnames,allvalues)





    if strcmpi(get_param(bdroot,'BlockDiagramType'),'library')
        return
    end

    numConditions=numel(original_conditionnames);

    new_conditionnames=cell(size(original_conditionnames));
    new_conditionvalues=cell(size(original_conditionnames));

    for ii=1:numConditions
        cwidgetname=['Condition',num2str(ii)];
        cwidgetvalue=getWidgetValue(dialog,cwidgetname);

        new_conditionnames{ii}=cwidgetvalue;

        vwidgetname=['Value',num2str(ii)];
        vwidgetvalue=getWidgetValue(dialog,vwidgetname);
        new_conditionvalues{ii}=allvalues{ii}{vwidgetvalue+1};
    end

    source.block.UserData.ConditionNames=new_conditionnames;
    source.block.UserData.ConditionValues=new_conditionvalues;

