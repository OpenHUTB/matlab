classdef(Sealed)ScribeStackManager<matlab.graphics.Graphics








    methods(Access=public,Static=true)
        function hManager=getInstance
            persistent hObj;

            if isempty(hObj)
                hObj=matlab.graphics.shape.internal.ScribeStackManager;
            end

            hManager=hObj;
        end
    end

    methods(Access=private)
        function hObj=ScribeStackManager




        end
    end

    methods(Access=public)

        function hLayer=getLayer(~,hViewer,layerName)


            try
                layerName=hgcastvalue('matlab.graphics.chart.datatype.OverlayType',layerName);
            catch E %#ok<NASGU>
                warning(message('MATLAB:graphics:scribestackmanager:InvalidLayer',layerName));
                hLayer=matlab.graphics.shape.internal.ScribeLayer.empty;
                return;
            end
            hLayer=matlab.graphics.shape.internal.ScribeStackManager.findLayer(hViewer,layerName);
            if isempty(hLayer)
                hLayer=matlab.graphics.shape.internal.ScribeStackManager.createLayer(hViewer,layerName,[]);
            else
                checkValidity(hLayer);
            end
        end

        function loadLayer(~,hViewer,hPane,layerName)
            if isempty(layerName)||~ismember(layerName,{'overlay','underlay'})






                layerName='overlay';
            end
            if~isa(hPane,'matlab.graphics.shape.internal.AnnotationPane')
                error('Must be an instance of AnnotationPane');
            end
            hLayer=matlab.graphics.shape.internal.ScribeStackManager.findLayer(hViewer,layerName);
            if~isempty(hLayer)


                if(hPane==hLayer.Pane)
                    hLayer.checkValidity();
                else








                    oldPanes=hgGetTrueChildren(hLayer);
                    for i=1:length(oldPanes)
                        oldPanes(i).Parent=[];
                    end
                    hLayer.Pane=hPane;
                    hPane.Parent=hLayer;
                end
            else
                matlab.graphics.shape.internal.ScribeStackManager.createLayer(hViewer,layerName,hPane);
            end
        end

        function hCamera=getDefaultCamera(hObj,hViewer,layerName)



            hLayer=hObj.getLayer(hViewer,layerName);
            hCamera=hLayer.Pane;
        end

    end

    methods(Access=private,Static=true)

        function exists=hasLayers(hViewer)

            exists=~isempty(matlab.graphics.shape.internal.ScribeStackManager.findLayer(hViewer,'overlay'))...
            |~isempty(matlab.graphics.shape.internal.ScribeStackManager.findLayer(hViewer,'middle'))...
            |~isempty(matlab.graphics.shape.internal.ScribeStackManager.findLayer(hViewer,'underlay'));
        end

        function hLayer=findLayer(hViewer,layerName)


            hChil=hgGetTrueChildren(hViewer);
            names=get(hChil,'Description');
            hLayer=hChil(strcmpi(names,layerName));
        end

        function hLayer=createLayer(hViewer,layerName,pane)

            if~matlab.graphics.shape.internal.ScribeStackManager.hasLayers(hViewer)
                if strcmpi(layerName,'middle')
                    hLayer=matlab.graphics.primitive.world.Group.empty;
                    return;
                end

                hChil=hgGetTrueChildren(hViewer);
                if~isempty(hChil)
                    hMiddle=matlab.graphics.shape.internal.ScribeLayer('middle',[]);
                    hMiddle.Parent=hViewer;
                    matlab.graphics.shape.internal.ScribeStackManager.reparentChildren(hChil(end:-1:1),hMiddle);
                end
            end


            hLayer=matlab.graphics.shape.internal.ScribeLayer(layerName,pane);
            hLayer.Parent=hViewer;
            hLayer.Serializable='off';




            hMiddle=matlab.graphics.shape.internal.ScribeStackManager.findLayer(hViewer,'middle');

            set(hMiddle,'Parent',matlab.graphics.primitive.world.Group.empty);
            set(hMiddle,'Parent',hViewer);
            hOverlay=matlab.graphics.shape.internal.ScribeStackManager.findLayer(hViewer,'overlay');

            set(hOverlay,'Parent',matlab.graphics.primitive.world.Group.empty);
            set(hOverlay,'Parent',hViewer);
        end

        function reparentChildren(viewerChildren,hLayer)


            set(viewerChildren,'Parent_I',hLayer);
        end
    end

end
