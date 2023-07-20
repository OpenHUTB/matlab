classdef Timeseries<icomm.pi.app.charts.Chart






    methods(Access=public)

        function this=Timeseries(varargin)
            this@icomm.pi.app.charts.Chart(varargin{:});
        end

    end

    methods(Access=protected)

        function update(this)
            if this.Overlay_
                this.NumAxes=1;
                thisAxes=this.getAxes(1);
                cla(thisAxes);
                if isempty(this.Data_)
                    return
                end
                thisAxes.NextPlot='add';
                for tagIndex=1:width(this.Data_)
                    plot(thisAxes,this.Data_.Time,this.Data_{:,tagIndex},'.');
                end
                legend(thisAxes,this.Data_.Properties.VariableNames,...
                'Interpreter','none');
            else
                this.NumAxes=width(this.Data_);
                for tagIndex=1:width(this.Data_)
                    thisAxes=this.getAxes(tagIndex);
                    cla(thisAxes);
                    plot(thisAxes,this.Data_.Time,this.Data_{:,tagIndex},'.');
                    xlabel(thisAxes,'Time');
                    ylabel(thisAxes,this.Data_.Properties.VariableNames{tagIndex},...
                    'Interpreter','none');
                end
            end
        end

    end

end