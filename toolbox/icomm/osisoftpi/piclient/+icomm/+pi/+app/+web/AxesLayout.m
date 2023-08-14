classdef AxesLayout<icomm.pi.app.AxesLayout






    properties(GetAccess=public,SetAccess=public,Dependent)
NumAxes
    end

    methods

        function value=get.NumAxes(this)
            value=numel(this.Axes);
        end

        function set.NumAxes(this,value)
            if value==this.NumAxes
                return
            else
                delete(this.UiContainer.Children);
                this.Axes=matlab.graphics.axis.Axes.empty;

                if value==0
                    numColumns=0;
                    numRows=0;
                else
                    numColumns=ceil(sqrt(value));
                    numRows=ceil(value/numColumns);
                end
                this.UiContainer.ColumnWidth=repmat({'1x'},1,numColumns);
                this.UiContainer.RowHeight=repmat({'1x'},1,numRows);

                for axesIndex=1:value
                    this.Axes(end+1)=axes(...
                    'Parent',uipanel(this.UiContainer,'BorderType','none'));
                end
            end
        end

    end

    methods(Access=public)

        function this=AxesLayout(varargin)
            box=uigridlayout(...
            'Parent',[]);
            this@icomm.pi.app.AxesLayout(box,varargin{:});
        end

    end

    methods(Access=public)

        function thisAxes=getAxes(this,rowIndex,columnIndex)
            if nargin==2

                thisAxes=this.Axes(rowIndex);
            elseif nargin==3

                panels=[this.Axes.Parent];
                layouts=[panels.Layout];
                axesIndex=...
                [layouts.Row]==rowIndex&...
                [layouts.Column]==columnIndex;
                thisAxes=this.Axes(axesIndex);
            end
        end

    end

end