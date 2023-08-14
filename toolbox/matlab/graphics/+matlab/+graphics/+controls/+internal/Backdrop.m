
classdef(ConstructOnLoad,UseClassDefaultsOnLoad,Hidden,Sealed)Backdrop<...
    matlab.graphics.primitive.world.Group&...
    matlab.graphics.controls.internal.Control





    properties(AffectsObject,AbortSet)




        Color(1,:){mustBeNumeric}=[0,0,0];


        Position matlab.internal.datatype.matlab.graphics.datatype.Position=[0,0,1,1];
    end

    properties(Dependent)
        Layer;
    end

    properties(Access=private,Transient,NonCopyable)

Face
    end

    methods
        function obj=Backdrop(varargin)
            obj@matlab.graphics.primitive.world.Group(varargin{:});

            obj.Face=matlab.graphics.primitive.world.Quadrilateral(...
            'Layer','front',...
            'ColorType','truecoloralpha',...
            'Clipping','off',...
            'Description','ControlsArea face',...
            'PickableParts','none',...
            'Internal',true);
            obj.addNode(obj.Face);

            obj.addDependencyConsumed('dataspace');
            obj.addDependencyConsumed('hgtransform_under_dataspace');
            obj.addDependencyConsumed('colorspace');
        end

        function set.Color(obj,newValue)
            if numel(newValue)==3||numel(newValue)==4

                obj.Color=newValue;
            else
                error(message("MATLAB:graphics:controls:Backdrop:InvalidColorValue"));
            end
        end

        function set.Layer(obj,val)
            obj.Face.Layer=val;
        end

        function val=get.Layer(obj)
            val=obj.Face.Layer;
        end
    end

    methods(Hidden)
        function setPickableParts(obj,val)
            obj.Face.PickableParts=val;
        end

        function doUpdate(obj,updateState)
            pos=obj.Position;
            verts=[...
            pos(1),pos(2);
            pos(1),pos(2)+pos(4);
            pos(1)+pos(3),pos(2)+pos(4);
            pos(1)+pos(3),pos(2)];
            iter=matlab.graphics.axis.dataspace.IndexPointsIterator('Vertices',verts);
            vertdata=updateState.DataSpace.TransformPoints(updateState.TransformUnderDataSpace,iter);
            obj.Face.VertexData=vertdata;

            iter=matlab.graphics.axis.colorspace.IndexColorsIterator('Colors',obj.Color);
            if numel(obj.Color)>3
                iter.AlphaData=obj.Color(4);
            end
            colordata=updateState.ColorSpace.TransformTrueColorToTrueColor(iter);
            obj.Face.ColorData=colordata.Data;
            obj.Face.ColorType=colordata.Type;
            obj.Face.ColorBinding='object';
        end
    end
end
