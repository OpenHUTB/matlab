classdef(ConstructOnLoad,UseClassDefaultsOnLoad,Hidden)ControlsGroup<...
    matlab.graphics.primitive.world.Group...
    &matlab.graphics.mixin.SceneNodeGroup...
    &matlab.graphics.mixin.AxesParentable





    properties(AbortSet)
        Anchor(1,3)double=[0,0,0];
    end

    properties(Access=private,Transient,NonCopyable)
BillboardGroup
PixelTransform
    end


    methods
        function obj=ControlsGroup(varargin)
            obj@matlab.graphics.primitive.world.Group(varargin{:});

            obj.BillboardGroup=matlab.graphics.primitive.Marker(...
            'Internal',true,...
            'XLimInclude','off',...
            'YLimInclude','off',...
            'ZLimInclude','off',...
            'Anchor',obj.Anchor);
            obj.addNode(obj.BillboardGroup);

            obj.PixelTransform=matlab.graphics.primitive.Transform(...
            'Internal',true);
            obj.BillboardGroup.addNode(obj.PixelTransform);

            obj.addDependencyConsumed('resolution');
        end

        function set.Anchor(obj,val)
            if~isempty(obj.BillboardGroup)&&isvalid(obj.BillboardGroup)
                obj.BillboardGroup.Anchor=val;
            end
            obj.Anchor=val;
        end
    end

    methods(Hidden)
        function trueParent=addChild(hObj,newChild)


            if newChild==hObj.BillboardGroup

                trueParent=hObj;
            else

                trueParent=hObj.PixelTransform;
            end
        end

        function ch=doGetChildren(obj)


            ch=obj.PixelTransform.Children;
            if~isempty(ch)
                ch=ch(1);
            end
        end

        function doUpdate(obj,updateState)
            obj.PixelTransform.Matrix=makehgtform('scale',1./updateState.PixelsPerPoint);
        end
    end
end
