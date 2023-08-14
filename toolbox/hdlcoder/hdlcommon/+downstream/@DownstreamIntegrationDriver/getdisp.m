function getdisp(obj)





    if~obj.cmdDisplay
        return;
    end

    optionWidth=25;


    fprintf(['%',num2str(optionWidth),'s : %s\n'],'OptionID','Value');


    workflowID='';
    optionList=obj.getOptionList;
    for ii=1:length(optionList)
        hOption=optionList{ii};
        workflowID=obj.dispWorkflowID(workflowID,hOption,optionWidth);

        fprintf(['%',num2str(optionWidth),'s : %s\n'],hOption.OptionID,hOption.Value);
    end


    obj.dispButton;
end
