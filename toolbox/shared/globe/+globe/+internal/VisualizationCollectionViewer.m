classdef(Hidden)VisualizationCollectionViewer<matlab.mixin.SetGet


    properties
        EnableWindowLaunch(1,1)logical=true
        Animation(1,1)string="fly"
        Color=[1,1,1]
        WaitForResponse(1,1)logical=true
        ID=[]
        Indices=[]
    end

    properties(Constant)
        Defaults=struct(...
        'EnableWindowLaunch',true,...
        'Animation',"fly",...
        'Color',[1,1,1],...
        'WaitForResponse',true,...
        'ID',[],...
        'Indices',[])
    end

    methods
        function defaultProperties=getDefaultProperties(viewer)


            defaults=viewer.Defaults;
            defaultProperties={...
            'Color',defaults.Color,...
            'EnableWindowLaunch',defaults.EnableWindowLaunch,...
            'Animation',defaults.Animation,...
            'ID',defaults.ID,...
            'Indices',defaults.Indices,...
            'WaitForResponse',defaults.WaitForResponse};
        end

        function reset(viewer)
            defaultProperties=viewer.getDefaultProperties();
            globe.internal.setObjectNameValuePairs(viewer,defaultProperties)
        end
    end
end
