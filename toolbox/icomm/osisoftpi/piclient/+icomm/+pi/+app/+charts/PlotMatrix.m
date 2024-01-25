classdef PlotMatrix<icomm.pi.app.charts.Chart

    methods(Access=public)

        function this=PlotMatrix(varargin)
            this@icomm.pi.app.charts.Chart(varargin{:});
            this.NumAxes=1;
        end

    end


    methods(Access=protected)

        function update(this)
            numTags=width(this.Data_);
            this.NumAxes=numTags^2;
            for rowIndex=1:numTags
                for columnIndex=1:numTags
                    thisAxes=this.getAxes(rowIndex,columnIndex);
                    cla(thisAxes);
                    if rowIndex==columnIndex
                        histogram(thisAxes,this.Data_{:,rowIndex});
                    else
                        plot(thisAxes,this.Data_{:,columnIndex},this.Data_{:,rowIndex},'.');
                    end

                    if columnIndex==1
                        ylabel(thisAxes,this.Data_.Properties.VariableNames{rowIndex},...
                        'Interpreter','none');
                    end
                    if rowIndex==numTags
                        xlabel(thisAxes,this.Data_.Properties.VariableNames{columnIndex},...
                        'Interpreter','none');
                    end
                end
            end
        end

    end

end