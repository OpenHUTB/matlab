classdef(Abstract)ViewModel<handle




    properties(SetAccess=immutable)
Axes
    end

    methods
        function this=ViewModel(axes)






            validateattributes(axes,{'matlab.ui.control.UIAxes'},{'scalar'});
            this.Axes=axes;
            disableDefaultInteractivity(this.Axes);
        end
    end

    methods
        function plot(this,varargin)









            narginchk(3,4)
            cellfun(@(x)validateattributes(x,{'numeric','embedded.fi','logical'},{'vector'}),varargin(1:end-1));
            validateattributes(varargin{end},{'numeric','embedded.fi','logical'},{'2d'});
            independentVariables=cellfun(@(x)double(x),varargin(1:end-1),'UniformOutput',false);
            dependentVariable=double(varargin{end});

            arrayfun(@delete,this.Axes.Children);
            this.plotImpl(independentVariables{:},dependentVariable);
            this.Axes.set(...
            'XGrid','on','XLimMode','Auto',...
            'YGrid','on','YLimMode','Auto',...
            'ZGrid','on','ZLimMode','Auto');
        end

        function updateSelectionMark(this,coords)






            this.updateSelectionMarkImpl(coords);
        end

        function updateIndependentVariableLabel(this,index,name,unit)




            validateattributes(index,{'double'},{'integer','scalar','>',0,'<=',2});
            validateattributes(name,{'char'},{'scalartext'});
            validateattributes(unit,{'char'},{'scalartext'});
            this.updateIndependentVariableLabelImpl(index,this.createLabel(name,unit));
        end

        function updateDependentVariableLabel(this,name,unit)




            validateattributes(name,{'char'},{'scalartext'});
            validateattributes(unit,{'char'},{'scalartext'});
            this.updateDependentVariableLabelImpl(this.createLabel(name,unit));
        end

        function updateIndependentVariableData(this,index,data)







            validateattributes(index,{'double'},{'integer','scalar','>',0,'<=',2});
            validateattributes(data,{'numeric','embedded.fi','logical'},{'vector'});
            this.updateIndependentVariableDataImpl(index,double(data));
        end

        function updateDependentVariableData(this,data)







            validateattributes(data,{'numeric','embedded.fi','logical'},{'2d'});
            this.updateDependentVariableDataImpl(double(data));
        end
    end

    methods(Abstract,Access=protected)
        plotImpl(this,varargin);

        updateSelectionMarkImpl(this,selection);

        updateIndependentVariableLabelImpl(this,index,label)

        updateDependentVariableLabelImpl(this,label)

        updateIndependentVariableDataImpl(this,index,data);

        updateDependentVariableDataImpl(this,data);
    end

    methods(Static,Access=protected)
        function label=createLabel(name,unit)
            switch(strlength(name)>0)+2*(strlength(unit)>0)
            case 1
                label=name;
            case 2
                label=sprintf('(%s)',unit);
            case 3
                label=sprintf('%s (%s)',name,unit);
            otherwise
                label='';
            end
        end
    end
end
