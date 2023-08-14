function addonStruct=performanceAdvisorTaskDialogSchema(this)

    addonStruct=this.createDialogForMACheck(true);

    addonStruct.Items=hajackRunTaskAdvisor(addonStruct.Items);

end




function items=hajackRunTaskAdvisor(items)

    for i=1:length(items)

        if isfield(items{i},'MatlabMethod')&&strcmp(items{i}.MatlabMethod,'runTaskAdvisor')
            items{i}.MatlabMethod='runTaskAdvisorWrapper';
            return;
        else

            if isfield(items{i},'Items')
                items{i}.Items=hajackRunTaskAdvisor(items{i}.Items);
            end
        end
    end

end