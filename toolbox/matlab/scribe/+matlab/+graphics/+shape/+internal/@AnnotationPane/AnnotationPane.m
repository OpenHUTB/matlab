classdef(ConstructOnLoad=true,UseClassDefaultsOnLoad=true,Sealed)AnnotationPane<matlab.graphics.primitive.world.Group&...
    matlab.graphics.mixin.SceneNodeGroup&...
    matlab.graphics.internal.GraphicsBaseFunctions&...
    matlab.graphics.internal.GraphicsJavaVisible&...
    matlab.graphics.mixin.UIParentable





    properties(SetAccess=private,Hidden=true,Transient=true,NonCopyable=true)
        Camera=matlab.graphics.axis.camera.Camera2D.empty;
        ColorSpace=matlab.graphics.axis.colorspace.MapColorSpace.empty;
    end

    methods
        function hObj=AnnotationPane(varargin)



            doSetup(hObj);

            if~isempty(varargin)
                set(hObj,varargin{:});
            end
        end

        function trueParent=addChild(hObj,newChild)


            if isempty(hObj.Camera)
                doSetup(hObj);
            end


            if isequal(newChild,hObj.Camera)
                trueParent=hObj;
            else
                trueParent=hObj.ColorSpace;
            end
        end

        function firstChild=doGetChildren(hObj)

            hPar=hObj.ColorSpace;
            firstChild=matlab.graphics.primitive.world.Group.empty;
            if isempty(hPar)||~isvalid(hPar)
                return;
            else
                allChil=hgGetTrueChildren(hPar);
                if~isempty(allChil)
                    firstChild=allChil(1);
                end
            end
        end

        function hParent=setParentImpl(hObj,hParentIn)
            hParent=hParentIn;
            if isempty(hParentIn)


            else
                if~isempty(hObj.Parent_I)
                    error(message('MATLAB:scribe:reparent'));
                end
                if isa(hParentIn,'matlab.graphics.shape.internal.ScribeLayer')





                    hObj.Description=hParentIn.Description;
                else


                    hViewer=hParentIn.getCanvas();
                    sm=hViewer.StackManager;
                    if isempty(sm)
                        sm=matlab.graphics.shape.internal.ScribeStackManager.getInstance;
                        hViewer.StackManager=sm;
                    end
                    loadLayer(sm,hViewer,hObj,hObj.Description);

                    if isempty(hgGetTrueChildren(hObj))&&~isempty(hObj.Camera)
                        hObj.addNode(hObj.Camera);
                    end

                    hParent=sm.getLayer(hViewer,hObj.Description);
                end
            end
        end

        function hParent=getParentImpl(~,hParentIn)
            canvas=ancestor(hParentIn,'matlab.graphics.primitive.canvas.Canvas');
            if~isempty(canvas)
                hParent=canvas.Parent;
            else
                hParent=hParentIn;
            end
        end

        function unParent(~)

        end
    end

    methods(Access='private')
        function doSetup(hObj)

            hCamera=matlab.graphics.axis.camera.Camera2D;
            set(hCamera,'XLim',[0,1]);
            set(hCamera,'YLim',[0,1]);
            hObj.Camera=hCamera;
            hObj.addNode(hCamera);


            hColorSpace=matlab.graphics.axis.colorspace.MapColorSpace;
            hObj.ColorSpace=hColorSpace;
            hCamera.addNode(hColorSpace);

            hObj.HandleVisibility='off';

            hObj.Type='annotationpane';
            hObj.Tag='scribeOverlay';
        end
    end
end
