classdef ControlsPlotAccessor<matlab.plottools.service.accessor.BaseAxesAccessor



    methods
        function obj=ControlsPlotAccessor()
            obj=obj@matlab.plottools.service.accessor.BaseAxesAccessor();
        end

        function id=getIdentifier(~)
            id={'step','bode','impulse','initial','iopzmap','hsv','lsim',...
            'nichols','nyquist','pzmap','sigma','rlocus','noisespectrum',...
            'diskmargin','sectorplot','dirindex'};
        end

        function refObj=applyReferenceObject(~,ax)
            refObj=gcr(ax);
        end
    end


    methods(Access='protected')
        function result=supportsTitle(~)
            result=true;
        end

        function result=supportsXLabel(~)
            result=true;
        end

        function result=supportsYLabel(obj)
            result=~strcmpi(class(obj.ReferenceObject),'resppack.bodeplot');
        end

        function result=supportsZLabel(~)
            result=false;
        end

        function result=supportsGrid(~)
            result=true;
        end

        function result=supportsXGrid(~)
            result=false;
        end

        function result=supportsYGrid(~)
            result=false;
        end

        function result=supportsZGrid(~)
            result=false;
        end

        function result=supportsRGrid(~)
            result=false;
        end

        function result=supportsThetaGrid(~)
            result=false;
        end

        function result=supportsLegend(obj)
            result=matlab.graphics.internal.supportsGesture(obj.ReferenceObject,'legend');
        end

        function result=supportsColorbar(~)
            result=false;
        end

        function result=supportsBasicFitting(~)
            result=false;
        end

        function result=supportsDataStats(~)
            result=false;
        end

        function result=supportsDataLinking(~)
            result=false;
        end

        function result=supportsCameraTools(~)
            result=false;
        end
    end


    methods(Access='protected')
        function result=getTitle(obj)
            if strcmpi(class(obj.ReferenceObject),'resppack.hsvplot')
                result=obj.ReferenceObject.AxesGrid.getaxes.Title;
            else
                result=obj.ReferenceObject.AxesGrid.BackgroundAxes.Title;
            end
        end

        function result=getXLabel(obj)
            if strcmpi(class(obj.ReferenceObject),'resppack.hsvplot')
                result=obj.ReferenceObject.AxesGrid.getaxes.XLabel;
            else
                result=obj.ReferenceObject.AxesGrid.BackgroundAxes.XLabel;


                result.String=obj.ReferenceObject.AxesGrid.XLabel;
            end
        end

        function result=getYLabel(obj)
            if strcmpi(class(obj.ReferenceObject),'resppack.hsvplot')
                result=obj.ReferenceObject.AxesGrid.getaxes.YLabel;
            else
                result=obj.ReferenceObject.AxesGrid.BackgroundAxes.YLabel;


                result.String=obj.ReferenceObject.AxesGrid.YLabel;
            end
        end

        function result=getGrid(obj)
            options=obj.ReferenceObject.getoptions;
            result=options.Grid;
        end
    end


    methods(Access='protected')
        function setTitle(obj,value)
            options=obj.ReferenceObject.getoptions;
            options.Title.String=value;

            obj.ReferenceObject.setoptions(options);
        end

        function setXLabel(obj,value)
            options=obj.ReferenceObject.getoptions;
            options.XLabel.String=value;


            obj.ReferenceObject.setoptions(options);
        end

        function setYLabel(obj,value)
            options=obj.ReferenceObject.getoptions;
            options.YLabel.String=value;


            obj.ReferenceObject.setoptions(options);
        end

        function setGrid(obj,value)


            options=obj.ReferenceObject.getoptions;
            options.Grid=char(value);

            obj.ReferenceObject.setoptions(options);
        end
    end
end

