
function[obj,activity,chartHandle]=getSFInstrumentationMetadata(bindableTypeEnum,bindableMetaData)
    if(bindableTypeEnum==BindMode.BindableTypeEnum.SFCHART)


        chartHandle=Simulink.ID.getHandle(bindableMetaData.sid);
        obj=sfprivate('block2handle',chartHandle);
        activity=bindableMetaData.activityType;
    elseif(bindableTypeEnum==BindMode.BindableTypeEnum.SFSTATE)
        obj=Simulink.ID.getHandle(bindableMetaData.sid);
        chartHandle=sfprivate('chart2block',obj.Chart.Id);
        activity=bindableMetaData.activityType;
    elseif(bindableTypeEnum==BindMode.BindableTypeEnum.SFDATA)
        obj=Simulink.ID.getHandle(bindableMetaData.sid);
        chartId=sf('DataChartParent',obj.Id);
        chartHandle=sfprivate('chart2block',chartId);
        activity='Data';
    end

    if strcmp(activity,'self activity')
        activity='Self';
    elseif strcmp(activity,'child activity')
        activity='Child';
    elseif strcmp(activity,'leaf activity')
        activity='Leaf';
    end
end