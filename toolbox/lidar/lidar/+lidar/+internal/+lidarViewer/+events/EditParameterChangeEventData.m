classdef(ConstructOnLoad)EditParameterChangeEventData<event.EventData







    properties

algoParam

EditName

        ToApplyOnAllFrames=false;

        IsOKButton=false;

IsTemporal

PointCloudIn
    end

    methods

        function data=EditParameterChangeEventData(params,editName,isOKButton,...
            isTemporal,pointCloudIn,toApplyOnAllFrames)

            data.algoParam=params;
            data.EditName=editName;
            data.IsOKButton=isOKButton;
            data.IsTemporal=isTemporal;
            data.PointCloudIn=pointCloudIn;
            if~isTemporal
                data.ToApplyOnAllFrames=toApplyOnAllFrames;
            end
        end

    end

end
