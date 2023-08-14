classdef AxesContainer





    properties
Axes
        AxesType='Spectrum';
hVisual

    end

    properties(Dependent,SetAccess='private')
Lines
ViewMode
    end

    methods
        function obj=AxesContainer(varargin)
            obj.Axes=varargin{1,1};
            obj.AxesType=varargin{1,2};
            obj.hVisual=varargin{1,3};
        end

        function x=get.Lines(this)
            x=this.hVisual.Lines;
        end

        function extents=getDataExtents(this,axesToBeScaled)
            hPlotter=this.hVisual.Plotter;
            if isempty(hPlotter)
                xyzExtents=[NaN,NaN;[NaN,NaN];-1,1];
            else
                xyzExtents=getXYZExtents(hPlotter);
            end
            extents.X=xyzExtents(1,:);
            if strcmp(this.AxesType,'Spectrum')&&any(axesToBeScaled=='Y')
                extents.Y=xyzExtents(2,:);
                extents.C=[NaN,NaN];
            elseif strcmp(this.AxesType,'Spectrogram')&&any(axesToBeScaled=='C')
                extents.Y=[NaN,NaN];
                extents.C=this.hVisual.PowerColorExtents;
            else
                extents.Y=[NaN,NaN];
                extents.C=[NaN,NaN];
            end
        end
    end
end

