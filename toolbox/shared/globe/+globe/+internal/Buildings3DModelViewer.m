classdef(Sealed,Hidden)Buildings3DModelViewer<globe.internal.Geographic3DModelViewer




    methods
        function[ID,plotDescriptors]=buildings3DModel(viewer,model)
            [ID,plotDescriptors]=viewer.geoModel3D(model,model.BuildingsCenter,...
            'Animation','zoom',...
            'Persistent',true,...
            'AllowPicking',true);
        end
    end
end