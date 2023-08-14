classdef BaseAxesAccessor<matlab.plottools.service.accessor.BaseAccessor



    methods
        function obj=BaseAxesAccessor()
            obj=obj@matlab.plottools.service.accessor.BaseAccessor();
        end

        function id=getIdentifier(~)
            id='matlab.graphics.axis.Axes';
        end
    end


    methods(Access='protected')
        function result=supportsTitle(obj)
            result=matlab.graphics.internal.supportsGesture(obj.ReferenceObject,'title');
        end

        function result=supportsXLabel(obj)
            result=matlab.graphics.internal.supportsGesture(obj.ReferenceObject,'xlabel');
        end

        function result=supportsYLabel(obj)
            result=matlab.graphics.internal.supportsGesture(obj.ReferenceObject,'ylabel');
        end

        function result=supportsZLabel(obj)
            result=matlab.graphics.internal.supportsGesture(obj.ReferenceObject,'zlabel')&&~is2D(obj.ReferenceObject);
        end

        function result=supportsGrid(obj)
            result=matlab.graphics.internal.supportsGesture(obj.ReferenceObject,'grid');
        end

        function result=supportsXGrid(obj)
            result=matlab.graphics.internal.supportsGesture(obj.ReferenceObject,'xgrid');
        end

        function result=supportsYGrid(obj)
            result=matlab.graphics.internal.supportsGesture(obj.ReferenceObject,'ygrid');
        end

        function result=supportsZGrid(obj)
            result=matlab.graphics.internal.supportsGesture(obj.ReferenceObject,'zlabel')&&~is2D(obj.ReferenceObject);
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

        function result=supportsColorbar(obj)
            result=matlab.graphics.internal.supportsGesture(obj.ReferenceObject,'colorbar');
        end

        function result=supportsBasicFitting(obj)
            result=is2D(obj.ReferenceObject);
        end

        function result=supportsDataStats(obj)
            result=is2D(obj.ReferenceObject);
        end

        function result=supportsDataLinking(obj)
            result=is2D(obj.ReferenceObject);
        end

        function result=supportsCameraTools(obj)
            result=~is2D(obj.ReferenceObject);
        end
    end


    methods(Access='protected')

        function title=getTitle(obj)
            title=obj.ReferenceObject.Title;
        end

        function result=getXLabel(obj)
            result=obj.ReferenceObject.XLabel;
        end

        function result=getYLabel(obj)
            result=obj.ReferenceObject.YLabel;
        end

        function result=getZLabel(obj)
            result=obj.ReferenceObject.ZLabel;
        end

        function result=getGrid(obj)
            result='off';

            if strcmpi(obj.ReferenceObject.XGrid,'on')&&...
                strcmpi(obj.ReferenceObject.YGrid,'on')

                if~is2D(obj.ReferenceObject)
                    if strcmpi(obj.ReferenceObject.ZGrid,'on')
                        result='on';
                    end
                else
                    result='on';
                end
            end
        end

        function result=getXGrid(obj)
            result=obj.ReferenceObject.XGrid;
        end

        function result=getYGrid(obj)
            result=obj.ReferenceObject.YGrid;
        end

        function result=getZGrid(obj)
            result=obj.ReferenceObject.ZGrid;
        end

        function result=getLegend(obj)
            result=obj.ReferenceObject.Legend;

            if isempty(result)
                result='off';
            else
                result=obj.ReferenceObject.Legend.Visible;
            end
        end

        function result=getColorbar(obj)
            result='off';

            cbar=getColorbarforAxes(obj.ReferenceObject);

            if~isempty(cbar)
                result='on';
            end
        end
    end



    methods(Access='protected')

        function setTitle(obj,value)
            obj.ReferenceObject.Title.String=value;
        end

        function setXLabel(obj,value)
            obj.ReferenceObject.XLabel.String=value;
        end

        function setYLabel(obj,value)
            obj.ReferenceObject.YLabel.String=value;
        end

        function setZLabel(obj,value)
            obj.ReferenceObject.ZLabel.String=value;
        end

        function setGrid(obj,value)
            obj.ReferenceObject.XGrid=value;
            obj.ReferenceObject.YGrid=value;
            obj.ReferenceObject.ZGrid=value;
        end

        function setXGrid(obj,value)
            obj.ReferenceObject.XGrid=value;

            if obj.ReferenceObject.XGrid==matlab.lang.OnOffSwitchState.on
                obj.ReferenceObject.YGrid=matlab.lang.OnOffSwitchState.off;
                obj.ReferenceObject.ZGrid=matlab.lang.OnOffSwitchState.off;
            end
        end

        function setYGrid(obj,value)
            obj.ReferenceObject.YGrid=value;

            if obj.ReferenceObject.YGrid==matlab.lang.OnOffSwitchState.on
                obj.ReferenceObject.XGrid=matlab.lang.OnOffSwitchState.off;
                obj.ReferenceObject.ZGrid=matlab.lang.OnOffSwitchState.off;
            end
        end

        function setZGrid(obj,value)
            obj.ReferenceObject.ZGrid=value;

            if obj.ReferenceObject.ZGrid==matlab.lang.OnOffSwitchState.on
                obj.ReferenceObject.YGrid=matlab.lang.OnOffSwitchState.off;
                obj.ReferenceObject.XGrid=matlab.lang.OnOffSwitchState.off;
            end
        end

        function setLegend(obj,value)
            if strcmpi(value,'on')
                legend(obj.ReferenceObject,'show');
            else
                delete(obj.ReferenceObject.Legend);
            end
        end

        function setColorbar(obj,value)
            if strcmpi(value,'on')
                colorbar(obj.ReferenceObject);
            else
                cbar=getColorbarforAxes(obj.ReferenceObject);

                delete(cbar);
            end
        end
    end
end

function colorbarObj=getColorbarforAxes(ax)
    colorbarObj=[];


    cbars=findobj(ancestor(ax,'figure'),'-isa','matlab.graphics.illustration.ColorBar');
    for i=1:numel(cbars)
        cbar=cbars(i);


        if cbar.Axes==ax
            colorbarObj=cbar;
        end
    end
end
