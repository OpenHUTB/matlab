classdef DownlinkFSPLVisual<matlabshared.application.Component




    properties(Hidden)
        hAxes;
    end

    methods
        function this=DownlinkFSPLVisual(varargin)
            this@matlabshared.application.Component(varargin{:});
            update(this);
        end

        function name=getName(~)
            name=getString(message('comm_demos:LinkBudgetApp:DownlinkFSPL'));
        end
        function tag=getTag(~)
            tag='downlinkFSPL';
        end

        function update(this)
            model=this.Application.DataModel;
            downLink=model.DownlinkLink;
            downResults=model.DownlinkResults;
            fspl=downResults.FreeSpaceLoss;

            if fspl>0
                freq=downLink.Frequency;
                a=log10(freq);
                pow10=floor(a);
                nonPow10=10^(a-pow10);
                stepSize=nonPow10/5;
                freqVec=(stepSize:stepSize:nonPow10+(4*stepSize))'*10^pow10;
                lambdaVec=computeWavelength(freqVec);
                fsplVec=computeFSPL(downResults.Distance*1e3,lambdaVec);

                hAx=this.hAxes;
                plot(hAx,freqVec,fsplVec,'b-');
                hold(hAx,'on');
                plot(hAx,freq,fspl,'r*');
                hold(hAx,'off');
                xLimMin=(stepSize/2)*10^pow10;
                xLimMax=(nonPow10+(5*stepSize))*10^pow10;
                set(hAx,'XLim',[xLimMin,xLimMax],...
                'YLim',[floor(min(fsplVec))-1,ceil(max(fsplVec))+1],...
                'XGrid','on',...
                'YGrid','on');
                hAx.XLabel.String=getString(message('comm_demos:LinkBudgetApp:Frequency'));
                hAx.YLabel.String=getString(message('comm_demos:LinkBudgetApp:FreeSpaceLoss'));
            end
        end
    end

    methods(Access=protected)
        function hFig=createFigure(this,varargin)
            hFig=createFigure@matlabshared.application.Component(this,varargin{:});

            hAx=axes('Parent',hFig);
            grid(hAx,'on');
            hAx.XLabel.String=getString(message('comm_demos:LinkBudgetApp:Frequency'));
            hAx.YLabel.String=getString(message('comm_demos:LinkBudgetApp:FreeSpaceLoss'));
            this.hAxes=hAx;
        end
    end
end


