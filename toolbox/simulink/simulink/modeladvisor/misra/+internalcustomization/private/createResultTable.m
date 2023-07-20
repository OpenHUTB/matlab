






function resultTable=createResultTable(checkID,isJustifyActive)

    if nargin==1
        isJustifyActive=false;
    end

    resultTable=ModelAdvisor.FormatTemplate('TableTemplate');
    resultTable.setCheckText(...
    DAStudio.message(['RTW:misra:',checkID,'_CheckText']));
    resultTable.setSubBar(false);
    resultTable.setRefLink({...
    {DAStudio.message(['RTW:misra:',checkID,'_RefLink'])}...
    });
    if isJustifyActive
        resultTable.setColTitles({...
        DAStudio.message('RTW:misra:Common_ResultTableLocation'),...
        DAStudio.message('RTW:misra:Common_ResultTableAction')});
    else
        resultTable.setColTitles({...
        DAStudio.message('RTW:misra:Common_ResultTableLocation')});
    end

end

