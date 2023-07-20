classdef SignaturePlotter<handle

    properties
        Mode='azimuth'
    end

    properties(SetAccess=protected,Hidden)
PolarAxes
Axes
    end

    properties(Access=protected)
Pattern
Azimuth
Elevation
Frequency
SignatureClass
        Signature=matlab.graphics.primitive.Line.empty;
Legend
    end

    methods
        function this=SignaturePlotter(hAxes)
            if isa(hAxes,'matlab.graphics.axis.PolarAxes')
                this.PolarAxes=hAxes;
            elseif isa(hAxes,'matlab.graphics.axis.Axes')
                this.Axes=hAxes;
            end
            this.PolarAxes.ThetaZeroLocation='top';
            this.PolarAxes.ThetaDir='clockwise';

            this.SignatureClass='rcsSignature';
        end

    end


    methods
        function plotSignature(this,signature,varargin)
            narginchk(2,4);
            if isempty(signature)
                clear(this);
            else

                switch this.SignatureClass
                case 'rcsSignature'
                    plotAzimuthRCSDiagram(this,signature,varargin{:});
                otherwise

                end
                refreshAxesProperties(this);
            end

        end

        function clear(this)
            delete(this.Signature);
            delete(this.PolarAxes.Legend);
            this.Signature=matlab.graphics.primitive.Line.empty;
        end

        function rlim(this,rmin,rmax)
            this.PolarAxes.RLim=[rmin,rmax];
        end
    end

    methods(Hidden)
        function plotAzimuthRCSDiagram(this,signature,el0,freq0)
            rangeAz=signature.Azimuth([1,end]);
            rangeEl=signature.Elevation([1,end]);
            azimuth=linspace(rangeAz(1),rangeAz(2),100);
            elevation=linspace(rangeEl(1),rangeEl(2),100);

            if nargin<4||isempty(freq0)
                freq0=mean(signature.Frequency);
            end
            if nargin<3||isempty(el0)
                el0=mean(rangeEl);
            end

            if strcmp(this.Mode,'elevation')
                az0=mean(rangeAz);
                vals=value(signature,az0,elevation,freq0);
                theta=deg2rad(elevation);
            elseif strcmp(this.Mode,'azimuth')
                vals=value(signature,azimuth,el0,freq0);
                theta=deg2rad(azimuth);
            end
            if isempty(this.Signature)||~ishghandle(this.Signature)
                this.Signature=polarplot(this.PolarAxes,theta,vals);
            else
                set(this.Signature,'ThetaData',theta,'RData',vals);
            end
            this.Legend=getString(message(...
            'fusion:trackingScenarioApp:Component:PlatformPropertySignaturePlotTitle',el0,num2str(freq0)));
        end

        function plotAzimuthIRDiagram(this,signature)
            rangeAz=signature.Azimuth([1,end]);
            rangeEl=signature.Elevation([1,end]);
            azimuth=linspace(rangeAz(1),rangeAz(2),100);
            elevation=linspace(rangeEl(1),rangeEl(2),100);
            az0=mean(rangeAz);
            el0=mean(rangeEl);
            if strcmp(this.Mode,'elevation')
                vals=value(signature,az0,elevation);
                theta=deg2rad(elevation);
            elseif strcmp(this.Mode,'azimuth')
                vals=value(signature,azimuth,el0);
                theta=deg2rad(azimuth);
            end
            if isempty(this.Signature)||~ishghandle(this.Signature)
                this.Signature=polarplot(this.PolarAxes,theta,vals);
            end
            this.Legend='Azimuth IR diagram (dBsm)';
        end

        function refreshAxesProperties(this)
            this.PolarAxes.ThetaZeroLocation='top';
            this.PolarAxes.ThetaDir='clockwise';
            this.PolarAxes.RLim=[-40,50];
            this.PolarAxes.RAxisLocation=180;
            legend(this.PolarAxes,this.Legend);
            this.PolarAxes.Legend.Location='north outside';
            this.PolarAxes.Legend.Box='off';
        end

    end

end