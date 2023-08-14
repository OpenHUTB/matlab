classdef(Hidden)Geographic3DModel<matlab.mixin.SetGet




    properties
        Model{validateModel}
        VertexColors(:,3){mustBeNumeric}=[-1,-1,-1]
        Color matlab.internal.datatype.matlab.graphics.datatype.RGBColor
        EnableLighting(1,1)logical=true
        YUpCoordinate(1,1)logical=true
        MetallicFactor(1,1)double=0.1
        RoughnessFactor(1,1)double=0.5
        BoundingSphereRadius(1,1)double=-1
    end

    properties(Hidden)
UID
File
    end

    methods
        function geomodel=Geographic3DModel(model,varargin)
            geomodel.Model=model;

            globe.internal.setObjectNameValuePairs(geomodel,varargin)
            if(geomodel.BoundingSphereRadius==-1)

                geomodel.BoundingSphereRadius=computeBoundingSphereRadius(model);
            end


            [~,uid]=fileparts(tempname);
            geomodel.UID=replace(uid,'_','');
        end
    end
end

function validateModel(model)
    if~isempty(model)
        validateattributes(model.Points,{'numeric'},{'ncols',3},'','Model');
    end
end

function radius=computeBoundingSphereRadius(model)
    xyzData=model.Points;
    [minPosition,maxPosition]=bounds(xyzData);
    radius=abs(max(maxPosition-minPosition)/2);
end