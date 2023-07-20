classdef(ConstructOnLoad,Abstract,AllowedSubclasses={...
    ?matlab.graphics.chart.internal.SubplotPositionableChart,...
    ?matlab.graphics.chart.ChartGroup,...
    ?chartsubclasses.TestChart})...
    Chart<matlab.graphics.primitive.world.SealedGroup&...
    matlab.graphics.mixin.UIParentable&...
    matlab.graphics.internal.GraphicsJavaVisible&...
    matlab.graphics.internal.export.GraphicsExportable&...
    matlab.graphics.internal.GraphicsPropertyHandler



    properties(Abstract,Transient,NonCopyable,Hidden,SetAccess=protected)
        Type matlab.internal.datatype.matlab.graphics.datatype.TypeName



    end

    properties(Transient,NonCopyable,Access=protected)
        SelectionHandle matlab.graphics.internal.SelectionHandles=matlab.graphics.internal.SelectionHandles.empty;
    end

    properties(Transient,NonCopyable,Hidden=true,SetAccess=protected)
        Tag=[];
        HitTest matlab.internal.datatype.matlab.graphics.datatype.on_off='on';
    end


    properties(Dependent,Hidden=true,SetObservable)
        Selected matlab.internal.datatype.matlab.graphics.datatype.on_off='off'
    end




    methods(Abstract,Hidden,Access={?ChartUnitTestFriend,?matlab.graphics.chart.Chart,...
        ?matlab.graphics.mixin.Mixin})
        hAx=getAxes(hObj)
    end

    methods
        function set.Selected(hObj,val)
            if(strcmpi(val,'on'))
                if~isscalar(hObj.SelectionHandle)||~isvalid(hObj.SelectionHandle)
                    hObj.SelectionHandle=matlab.graphics.internal.SelectionHandles(hObj);
                end
                hObj.SelectionHandle.Visible='on';
            else
                delete(hObj.SelectionHandle);
                hObj.SelectionHandle=matlab.graphics.internal.SelectionHandles.empty;
            end
        end
        function sel=get.Selected(hObj)
            if isscalar(hObj.SelectionHandle)&&isvalid(hObj.SelectionHandle)
                sel='on';
            else
                sel='off';
            end
        end


        function delete(hObj)
            delete(hObj.SelectionHandle);
        end
    end

    methods(Hidden=true,Access={?ChartUnitTestFriend,...
        ?matlab.internal.editor.figure.ChartAccessor})

    end

    methods(Hidden=true,Access={?ChartUnitTestFriend,...
        ?matlab.graphics.chart.Chart,...
        ?matlab.internal.editor.figure.ChartAccessor,...
        ?matlab.plottools.service.accessor.ChartAccessor})



        function li=GetLayoutInformation(hObj)


            li.PlotBox=hObj.getPixelBoxForToolbar;
            li.is2D=hObj.getIs2DForToolbar;
        end

        function plotBox=getPixelBoxForToolbar(hObj)



            box=[inf,inf,-inf,-inf];
            hAxes=hObj.getAxes();
            if isa(hAxes,'matlab.graphics.axis.AbstractAxes')
                for ax=1:numel(hAxes)


                    if strcmp(hAxes(ax).Visible,'on')
                        pb=hAxes(ax).GetLayoutInformation.PlotBox;
                        box(1:2)=min(box(1:2),pb(1:2));
                        box(3:4)=max(box(3:4),pb(1:2)+pb(3:4));
                    end
                end
            end
            if all(isfinite(box))

                plotBox=[box(1:2),box(3:4)-box(1:2)];
            else

                plotBox=[0,0,1,1];
            end
        end

        function is2D=getIs2DForToolbar(~)


            is2D=true;
        end


        function hObj=getTitleHandle(hObj)
            hAxes=hObj.getAxes();
            if~isempty(hAxes)&&isa(hAxes,'matlab.graphics.axis.AbstractAxes')


                hObj=hAxes(1).Title;
            else
                hObj=gobjects(0);
            end
        end


        function hObj=getSubtitleHandle(hObj)
            hAxes=hObj.getAxes();
            if~isempty(hAxes)&&isa(hAxes,'matlab.graphics.axis.AbstractAxes')


                hObj=hAxes(1).Subtitle;
            else
                hObj=gobjects(0);
            end
        end


        function hObj=getXlabelHandle(hObj)


            hAxes=hObj.getAxes();
            if isscalar(hAxes)&&isa(hAxes,'matlab.graphics.axis.Axes')
                hObj=hAxes.XLabel;
            else
                hObj=gobjects(0);
            end
        end


        function hObj=getYlabelHandle(hObj)


            hAxes=hObj.getAxes();
            if isscalar(hAxes)&&isa(hAxes,'matlab.graphics.axis.Axes')
                hObj=hAxes.YLabel;
            else
                hObj=gobjects(0);
            end
        end


        function hObj=getZlabelHandle(hObj)


            hAxes=hObj.getAxes();
            if isscalar(hAxes)&&isa(hAxes,'matlab.graphics.axis.Axes')
                hObj=hAxes.ZLabel;
            else
                hObj=gobjects(0);
            end
        end
    end



    methods(Hidden)



        function support=supportsGesture(obj,featureString)
            support=false;
            switch lower(featureString)
            case 'title'
                support=true;
            case 'subtitle'
                support=supportsSubtitle;
            case 'legend'
                support=supportsLegend(obj);
            case 'colorbar'
                support=supportsColorbar(obj);
            case{'caxis','clim'}
                support=supportsCLim(obj);
            case 'grid'
                support=supportsGrid(obj);
            case 'xlabel'
                support=supportsXlabel(obj);
            case 'ylabel'
                support=supportsYlabel(obj);
            case 'zlabel'
                support=supportsZlabel(obj);
            end
        end
    end





    methods(Hidden)
        function varargout=title(hObj,varargin)%#ok<STOUT>
            if nargout>0
                error(message('MATLAB:Chart:ConvenienceNoOutputs','title',hObj.Type));
            elseif nargin>3
                error(message('MATLAB:Chart:ConvenienceTooManyInputs','title',hObj.Type));
            else

                if(nargin<2)
                    error(message('MATLAB:Chart:UnsupportedArgument','title',hObj.Type));
                end


                if hObj.supportsTitle()
                    hObj.Title=varargin{1};
                else
                    error(message('MATLAB:Chart:UnsupportedConvenienceFunction','title',hObj.Type));
                end


                if nargin>2
                    if hObj.supportsSubtitle
                        hObj.Subtitle=varargin{2};
                    else
                        error(message('MATLAB:Chart:ConvenienceTooManyInputs','title',hObj.Type));
                    end
                end
            end
        end

        function s=supportsTitle(hObj)
            s=isprop(hObj,'Title');
        end

        function varargout=subtitle(hObj,varargin)%#ok<STOUT>
            if nargout>0
                error(message('MATLAB:Chart:ConvenienceNoOutputs','subtitle',hObj.Type));
            elseif nargin>2
                error(message('MATLAB:Chart:ConvenienceTooManyInputs','subtitle',hObj.Type));
            else

                if(nargin<2)
                    error(message('MATLAB:Chart:UnsupportedArgument','subtitle',hObj.Type));
                end


                if hObj.supportsSubtitle()
                    hObj.Subtitle=varargin{1};
                else
                    error(message('MATLAB:Chart:UnsupportedConvenienceFunction','subtitle',hObj.Type));
                end
            end
        end

        function s=supportsSubtitle(hObj)
            s=isprop(hObj,'Subtitle');
        end

        function varargout=xlabel(hObj,varargin)%#ok<STOUT>
            if nargout>0
                error(message('MATLAB:Chart:ConvenienceNoOutputs','xlabel',hObj(1).Type));
            elseif nargin>2
                error(message('MATLAB:Chart:ConvenienceTooManyInputs','xlabel',hObj(1).Type));
            else

                if(nargin<2)
                    error(message('MATLAB:Chart:UnsupportedArgument','xlabel',hObj(1).Type));
                end



                for i=1:numel(hObj)
                    if hObj(i).supportsXlabel()
                        hObj(i).XLabel=varargin{1};
                    else
                        error(message('MATLAB:Chart:UnsupportedConvenienceFunction','xlabel',hObj(i).Type));
                    end
                end
            end
        end

        function s=supportsXlabel(hObj)
            s=isprop(hObj,'XLabel');
        end

        function varargout=ylabel(hObj,varargin)%#ok<STOUT>
            if nargout>0
                error(message('MATLAB:Chart:ConvenienceNoOutputs','ylabel',hObj(1).Type));
            elseif nargin>2
                error(message('MATLAB:Chart:ConvenienceTooManyInputs','ylabel',hObj(1).Type));
            else

                if(nargin<2)
                    error(message('MATLAB:Chart:UnsupportedArgument','ylabel',hObj(1).Type));
                end


                for i=1:numel(hObj)
                    if hObj(i).supportsYlabel()
                        hObj(i).YLabel=varargin{1};
                    else
                        error(message('MATLAB:Chart:UnsupportedConvenienceFunction','ylabel',hObj(i).Type));
                    end
                end
            end
        end

        function s=supportsYlabel(hObj)
            s=isprop(hObj,'YLabel');
        end

        function varargout=zlabel(hObj,varargin)%#ok<STOUT>
            if nargout>0
                error(message('MATLAB:Chart:ConvenienceNoOutputs','zlabel',hObj(1).Type));
            elseif nargin>2
                error(message('MATLAB:Chart:ConvenienceTooManyInputs','zlabel',hObj(1).Type));
            else

                if(nargin<2)
                    error(message('MATLAB:Chart:UnsupportedArgument','zlabel',hObj(1).Type));
                end


                for i=1:numel(hObj)
                    if hObj(i).supportsZlabel()
                        hObj(i).ZLabel=varargin{1};
                    else
                        error(message('MATLAB:Chart:UnsupportedConvenienceFunction','zlabel',hObj(i).Type));
                    end
                end
            end
        end

        function s=supportsZlabel(hObj)
            s=isprop(hObj,'ZLabel');
        end


        function varargout=xlim(hObj,varargin)%#ok<STOUT>
            error(message('MATLAB:Chart:UnsupportedConvenienceFunction','xlim',hObj(1).Type));
        end

        function varargout=ylim(hObj,varargin)%#ok<STOUT>
            error(message('MATLAB:Chart:UnsupportedConvenienceFunction','ylim',hObj(1).Type));
        end


        function varargout=xticks(hObj,varargin)%#ok<STOUT>
            error(message('MATLAB:Chart:UnsupportedConvenienceFunction','xticks',hObj(1).Type));
        end

        function varargout=yticks(hObj,varargin)%#ok<STOUT>
            error(message('MATLAB:Chart:UnsupportedConvenienceFunction','yticks',hObj(1).Type));
        end

        function varargout=xticklabels(hObj,varargin)%#ok<STOUT>
            error(message('MATLAB:Chart:UnsupportedConvenienceFunction','xticklabels',hObj(1).Type));
        end

        function varargout=yticklabels(hObj,varargin)%#ok<STOUT>
            error(message('MATLAB:Chart:UnsupportedConvenienceFunction','yticklabels',hObj(1).Type));
        end

        function varargout=view(hObj,varargin)%#ok<STOUT>
            error(message('MATLAB:Chart:UnsupportedConvenienceFunction','view',hObj(1).Type));
        end

        function varargout=grid(hObj,varargin)%#ok<STOUT>



            for i=1:numel(hObj)
                if hObj(i).supportsGrid()
                    if nargin==1

                        if strcmp(hObj(i).GridVisible,'off')
                            hObj(i).GridVisible='on';
                        else
                            hObj(i).GridVisible='off';
                        end
                    elseif nargin==2
                        switch varargin{1}
                        case{'on','off'}
                            hObj(i).GridVisible=varargin{1};
                        otherwise
                            error(message('MATLAB:Chart:UnsupportedArgument','grid',hObj(i).Type));
                        end
                    else
                        error(message('MATLAB:Chart:ConvenienceTooManyInputs','grid',hObj(i).Type));
                    end
                else
                    error(message('MATLAB:Chart:UnsupportedConvenienceFunction','grid',hObj(i).Type));
                end
            end
        end

        function s=supportsGrid(hObj)
            s=isprop(hObj,'GridVisible');
        end


        function varargout=caxis(hObj,varargin)

            [varargout{1:nargout}]=clim(hObj,varargin{:});
        end

        function varargout=clim(hObj,varargin)





            if hObj.supportsCLim()
                if nargin==2
                    if~isnumeric(varargin{1})||~(length(varargin{1})==2)
                        error(message('MATLAB:Chart:UnsupportedArgument','clim',hObj.Type));
                    end

                    hObj.ColorLimits=varargin{1};

                elseif nargin>2
                    error(message('MATLAB:Chart:ConvenienceTooManyInputs','clim',hObj.Type));
                else
                    if nargout~=2
                        varargout{1}=hObj.ColorLimits;
                    else
                        varargout{1}=hObj.ColorLimits(1);
                        varargout{2}=hObj.ColorLimits(2);
                    end
                end
            else
                error(message('MATLAB:Chart:UnsupportedConvenienceFunction','clim',hObj.Type));
            end
        end

        function s=supportsCLim(hObj)
            s=isprop(hObj,'ColorLimits');
        end


        function varargout=legend(hObj,varargin)%#ok<STOUT>
            if hObj.supportsLegend()
                if nargout>0
                    error(message('MATLAB:Chart:ConvenienceNoOutputs','legend',hObj.Type));
                elseif nargin==1
                    hObj.LegendVisible='on';
                elseif nargin>2
                    error(message('MATLAB:Chart:ConvenienceTooManyInputs','legend',hObj.Type));
                else
                    arg=varargin{1};
                    switch char(lower(arg))
                    case{'off','hide','deletelegend'}
                        hObj.LegendVisible='off';
                    case 'toggle'
                        lv=hObj.LegendVisible;
                        if strcmp(lv,'off')
                            hObj.LegendVisible='on';
                        else
                            hObj.LegendVisible='off';
                        end
                    case 'show'
                        hObj.LegendVisible='on';
                    otherwise
                        error(message('MATLAB:Chart:UnsupportedArgument','legend',hObj.Type));
                    end
                end
            else
                error(message('MATLAB:Chart:UnsupportedConvenienceFunction','legend',hObj.Type));
            end
        end

        function s=supportsLegend(hObj)
            s=isprop(hObj,'LegendVisible');
        end


        function varargout=colorbar(hObj,varargin)%#ok<STOUT>
            if hObj.supportsColorbar()
                if nargout>0
                    error(message('MATLAB:Chart:ConvenienceNoOutputs','colorbar',hObj.Type));
                elseif nargin>2
                    error(message('MATLAB:Chart:ConvenienceTooManyInputs','colorbar',hObj.Type));
                elseif nargin==1
                    hObj.ColorbarVisible='on';
                elseif nargin==2&&ismember(varargin{1},{'off','hide','delete'})
                    hObj.ColorbarVisible='off';
                else
                    error(message('MATLAB:Chart:UnsupportedArgument','colorbar',hObj.Type));
                end
            else
                error(message('MATLAB:Chart:UnsupportedConvenienceFunction','colorbar',hObj.Type));
            end
        end

        function ignore=mcodeIgnoreHandle(~,~)

            ignore=true;
        end

        function s=supportsColorbar(hObj)
            s=isprop(hObj,'ColorbarVisible');
        end




        function out=hasCameraProperties(~)
            out=false;
        end
    end

    methods(Static,Access=protected)
        function topos=convertUnits(viewport,tounits,fromunits,frompos)



            topos=matlab.graphics.internal.convertUnits(...
            viewport,tounits,fromunits,frompos);
        end

        function todists=convertDistances(viewport,tounits,fromunits,distances)



            todists=matlab.graphics.internal.convertDistances(...
            viewport,tounits,fromunits,distances);
        end
    end
end
