classdef CustomColormapSettings<handle




    properties
Dialog
ColorMapFunction
    end


    properties(Dependent)
Colormap
    end

    events
CustomColormapRequest
CustomVariationRequest
    end

    properties
    end

    methods

        function this=CustomColormapSettings()
            this.ColorMapFunction=getString(message('lidar:lidarViewer:Linear'));
        end

        function open(this,cmap,variation,colormapVal,colormapText,colormapValText)
            this.Dialog=lidar.internal.lidarViewer.view.dialog.CustomColorVariationDialog(cmap,variation,colormapVal,colormapText,colormapValText);
            addlistener(this.Dialog,'CustomColormapRequest',@(src,evt)colormapChanged(this,evt));
            if strcmp(this.ColorMapFunction,getString(message('lidar:lidarViewer:Custom')))
                this.Dialog.customColorMap(true);
            end
            this.Dialog.ColorMappingDropdown.Value=this.ColorMapFunction;
            open(this.Dialog);
        end

        function colormapChanged(this,evt)
            if evt.DialogState==2
                this.ColorMapFunction=this.Dialog.ColorMappingDropdown.Value;
            end
            notify(this,'CustomColormapRequest',evt)
        end

        function resetSettings(this)
            this.ColorMapFunction=getString(message('lidar:lidarViewer:Linear'));
        end

        function close(this)
            try %#ok<TRYNC>
                delete(this.Dialog);
                this.Dialog=[];
            end
        end

        function delete(this)
            close(this);
            delete(this);
        end


    end


end
