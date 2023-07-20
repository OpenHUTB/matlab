function choiceArray=addChoice(this,nameArray,labelArray)












    choiceArray=systemcomposer.arch.Component.empty(1,0);
    nameArray=string(nameArray);
    if nargin<3
        labelArray=string.empty(1,0);
    else
        labelArray=string(labelArray);
        if~isequal(numel(nameArray),numel(labelArray))
            error('systemcomposer:API:AddChoiceInputArgs',message('SystemArchitecture:API:AddChoiceInputArgs').getString);
        end
    end
    for i=1:numel(nameArray)
        choiceArray(end+1)=this.OwnedArchitecture.addComponent(nameArray{i});
        if~isempty(labelArray)
            set_param(choiceArray(end).SimulinkHandle,'VariantControl',labelArray{i});
        else

            varCtrlLabels=[];
            choices=this.getChoices;
            for idx=1:numel(choices)
                varCtrlLabels=[varCtrlLabels;string(this.getCondition(choices(idx)))];
            end

            currIdx=1;
            labelPrefix="Choice_";
            uniqueVarCtrlLabel=strcat(labelPrefix,num2str(currIdx));
            while any(strcmp(uniqueVarCtrlLabel,varCtrlLabels))
                currIdx=currIdx+1;
                uniqueVarCtrlLabel=strcat(labelPrefix,num2str(currIdx));
            end

            set_param(choiceArray(end).SimulinkHandle,'VariantControl',uniqueVarCtrlLabel);
        end
    end
end
