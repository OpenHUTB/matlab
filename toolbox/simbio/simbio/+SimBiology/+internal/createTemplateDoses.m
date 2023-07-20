function templateDoses=createTemplateDoses(doses)










    numDoses=numel(doses);
    templateDoses=cell(1,numDoses);
    excludeProperties=properties('SimBiology.ModelComponent');
    scheduleDoseProperties=setdiff(properties('SimBiology.ScheduleDose'),excludeProperties);
    repeatDoseProperties=setdiff(properties('SimBiology.RepeatDose'),excludeProperties);
    for i=1:numDoses
        if isa(doses(i),'SimBiology.ScheduleDose')
            templateDoses{i}=sbiodose(doses(i).Name,'schedule');
            doseProperties=scheduleDoseProperties;
        else
            templateDoses{i}=sbiodose(doses(i).Name,'repeat');
            doseProperties=repeatDoseProperties;
        end
        for j=1:numel(doseProperties)
            if~isnumeric(doses(i).(doseProperties{j}))
                templateDoses{i}.(doseProperties{j})=doses(i).(doseProperties{j});
            end
        end
    end
    templateDoses=[templateDoses{:}];

end
