classdef(ConstructOnLoad,UseClassDefaultsOnLoad,Hidden,Sealed)ProgressBar<...
    matlab.graphics.primitive.world.Group&...
    matlab.graphics.controls.internal.Control





    properties(AffectsObject,AbortSet)











        Progress(1,1)double=NaN






        Color matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0.6,1.0];


        Position matlab.internal.datatype.matlab.graphics.datatype.Position=[0,0,1,1]
    end

    properties(Access=private,Transient,NonCopyable)

ProgressFace
ProgressEdge
    end

    methods
        function obj=ProgressBar(varargin)
            obj@matlab.graphics.primitive.world.Group(varargin{:});

            obj.ProgressFace=matlab.graphics.primitive.world.Quadrilateral(...
            'Layer','front',...
            'ColorType','truecoloralpha',...
            'Clipping','off',...
            'Description','Progress face',...
            'PickableParts','none',...
            'Internal',true);
            obj.addNode(obj.ProgressFace);

            obj.ProgressEdge=matlab.graphics.primitive.world.LineStrip(...
            'Clipping','off',...
            'Layer','front',...
            'AlignVertexCenters','on',...
            'Description','Progress outline',...
            'PickableParts','none',...
            'Internal',true);
            obj.addNode(obj.ProgressEdge);

            obj.addDependencyConsumed('dataspace');
            obj.addDependencyConsumed('hgtransform_under_dataspace');
            obj.addDependencyConsumed('colorspace');
        end
    end

    methods(Hidden)
        doUpdate(obj,updateState);
    end
end
