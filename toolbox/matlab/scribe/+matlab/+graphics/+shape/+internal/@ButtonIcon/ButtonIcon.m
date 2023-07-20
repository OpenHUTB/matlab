classdef(ConstructOnLoad,UseClassDefaultsOnLoad,Hidden,Sealed)ButtonIcon<...
    matlab.graphics.primitive.world.Group






    properties(AffectsObject)




        Vertices(:,2)double=[]






        Faces double=[]




        FaceColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0];
    end

    properties(Access=private,Transient,NonCopyable)
Face
    end

    methods
        function obj=ButtonIcon(varargin)





            obj.Face=matlab.graphics.primitive.world.TriangleStrip(...
            'Clipping','off',...
            'PickableParts','visible',...
            'Layer','front',...
            'Internal',true);
            obj.addNode(obj.Face);

            obj.addDependencyConsumed('view');
            obj.addDependencyConsumed('dataspace');
            obj.addDependencyConsumed('colorspace');

            if nargin
                set(obj,varargin{:});
            end
        end
    end

    methods(Hidden)
        doUpdate(obj,updateState)
    end
end
