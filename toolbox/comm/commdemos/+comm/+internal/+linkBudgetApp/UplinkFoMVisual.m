classdef UplinkFoMVisual<matlabshared.application.Component




    properties(Hidden)
        hAxes;
    end

    methods
        function this=UplinkFoMVisual(varargin)
            this@matlabshared.application.Component(varargin{:});
            update(this);
        end

        function name=getName(~)
            name=getString(message('comm_demos:LinkBudgetApp:UplinkGT'));
        end
        function tag=getTag(~)
            tag='uplinkGT';
        end

        function update(this)

            model=this.Application.DataModel;
            upLink=model.UplinkLink;
            rxSat=model.RxSatellite;
            upResults=model.UplinkResults;
            fom=upResults.FigureOfMerit;

            if fom>0
                dia=rxSat.AntennaDiameter;
                stepSize=dia/5;
                diaVec=(stepSize:stepSize:dia+(4*stepSize))';
                n=numel(diaVec);
                antEff=repmat(rxSat.AntennaEfficiency,n,1);
                wavelength=repmat(getWavelength(upLink),n,1);
                antGain=computeAntennaGain(wavelength,diaVec,antEff);
                fomVec=antGain-10*log10(rxSat.SystemTemperature);

                hAx=this.hAxes;
                plot(hAx,diaVec,fomVec,'b-');
                hold(hAx,'on');
                plot(hAx,dia,fom,'r*');
                hold(hAx,'off');
                set(hAx,'XLim',[0,ceil(diaVec(n)+stepSize)],...
                'YLim',[floor(min(fomVec))-1,ceil(max(fomVec))+1],...
                'XGrid','on',...
                'YGrid','on');
                hAx.XLabel.String=getString(message('comm_demos:LinkBudgetApp:RxAntDiameter'));
                hAx.YLabel.String=getString(message('comm_demos:LinkBudgetApp:GTwithUnits'));
            end
        end
    end

    methods(Access=protected)
        function hFig=createFigure(this,varargin)
            hFig=createFigure@matlabshared.application.Component(this,varargin{:});

            hAx=axes('Parent',hFig);
            grid(hAx,'on');
            hAx.XLabel.String=getString(message('comm_demos:LinkBudgetApp:RxAntDiameter'));
            hAx.YLabel.String=getString(message('comm_demos:LinkBudgetApp:GTwithUnits'));
            this.hAxes=hAx;
        end
    end
end


