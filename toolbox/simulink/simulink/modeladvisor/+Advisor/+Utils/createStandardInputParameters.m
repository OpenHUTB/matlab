function parameterObj=createStandardInputParameters(parameterID)




    switch parameterID
    case 'find_system.FollowLinks'
        parameterObj=ModelAdvisor.InputParameter;
        parameterObj.RowSpan=[1,1];
        parameterObj.ColSpan=[1,2];
        parameterObj.Name='Follow links';
        parameterObj.Type='Enum';
        parameterObj.Value='on';
        parameterObj.Entries={'on','off'};
        parameterObj.Visible=false;
    case 'find_system.LookUnderMasks'
        parameterObj=ModelAdvisor.InputParameter;
        parameterObj.RowSpan=[1,1];
        parameterObj.ColSpan=[4,5];
        parameterObj.Name='Look under masks';
        parameterObj.Type='Enum';
        parameterObj.Value='graphical';
        parameterObj.Entries={'none','graphical','functional','all'};
        parameterObj.Visible=false;
    case 'find_system.LookUnderMasks.HighIntegrity'
        parameterObj=ModelAdvisor.InputParameter;
        parameterObj.RowSpan=[1,1];
        parameterObj.ColSpan=[4,5];
        parameterObj.Name='Look under masks';
        parameterObj.Type='Enum';
        parameterObj.Value='all';
        parameterObj.Entries={'none','graphical','functional','all'};
        parameterObj.Visible=false;
    case 'maab.StandardSelection'
        parameterObj=ModelAdvisor.InputParameter;
        parameterObj.RowSpan=[1,1];
        parameterObj.ColSpan=[1,2];
        parameterObj.Name=DAStudio.message('ModelAdvisor:engine:Standard');
        parameterObj.Type='Enum';
        parameterObj.Value='MAB';
        parameterObj.Entries={'MAB','Custom'};
        parameterObj.Visible=false;
    case 'jmaab.StandardSelection'
        parameterObj=ModelAdvisor.InputParameter;
        parameterObj.RowSpan=[1,1];
        parameterObj.ColSpan=[1,2];
        parameterObj.Name=DAStudio.message('ModelAdvisor:engine:Standard');
        parameterObj.Type='Enum';
        parameterObj.Value='JMAAB';
        parameterObj.Entries={'JMAAB','Custom'};
        parameterObj.Visible=false;
    otherwise
        DAStudio.error('ModelAdvisor:engine:InvalidInputParameterName',parameterID);
    end
end
