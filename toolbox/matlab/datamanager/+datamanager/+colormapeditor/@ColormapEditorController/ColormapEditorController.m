classdef ColormapEditorController<handle







    properties
ParentFigure
        ColormapEditor datamanager.colormapeditor.ColormapEditor
    end

    methods

        function this=ColormapEditorController(hFig)
            this.ParentFigure=hFig;
            this.ColormapEditor=datamanager.colormapeditor.ColormapEditor(this.ParentFigure);
        end




        function bringToFront(this)
            this.ColormapEditor.bringToFront();
        end


        function setFigure(this,parentFigure)
            this.ParentFigure=parentFigure;
            this.ColormapEditor.setFigure(parentFigure);
        end

        function setVisible(this)
            this.ColormapEditor.setVisible();
        end

        function hFig=getFigure(this)
            hFig=this.ParentFigure;
        end



        function removeObject(this,~)
            this.ColormapEditor.removeObject();
        end

        function setColorLimits(this,cLim)
            this.ColormapEditor.setColorLimits(cLim);
        end

        function close(this)
            this.ColormapEditor.close();
        end


        function setBestColorMapModel(this,cmap)
            this.ColormapEditor.setBestColormapModel(cmap);
        end




        function setColorLimitsEnabled(this,enableFlag)
            this.ColormapEditor.setColorLimitsEnabled(enableFlag);
        end

        function setCurrentObject(this,hObj)
            this.ColormapEditor.setCurrentObject(hObj);
        end

        function hObj=getCurrentObject(this)
            hObj=this.ColormapEditor.getCurrentObject();
        end


        function currentTitle=getCurrentItemLabel(this)
            currentTitle=this.ColormapEditor.getTitle();
        end


        function setCurrentItemLabel(this,title)
            this.ColormapEditor.setTitle(title);
        end



        function enableResetAxes(this,enableFlag)
            this.ColormapEditor.enableResetAxes(enableFlag);
        end
    end
end

