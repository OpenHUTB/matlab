function inputParamList=getEMLStandardInputParams(startRow)








    if nargin==0
        startRow=1;
    end

    inputParamList{1}=ModelAdvisor.InputParameter;
    inputParamList{end}.RowSpan=[startRow,startRow];
    inputParamList{end}.ColSpan=[1,4];
    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:hism:common_eml_check_ref_files');
    inputParamList{end}.Type='Bool';
    inputParamList{end}.Value=true;
    inputParamList{end}.Visible=false;

    startRow=startRow+1;
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[startRow,startRow];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';

    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[startRow,startRow];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='all';
end
