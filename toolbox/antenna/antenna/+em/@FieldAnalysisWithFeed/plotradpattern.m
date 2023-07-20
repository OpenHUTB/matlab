function plottype=plotradpattern(MagE,theta,phi,frequency,coord,...
    slice,slicestyle,optype,u,v,varargin)



    if nargin==10
        minval=min(MagE);
    elseif nargin==12
        if(strcmpi(varargin{1},'MagnitudeScale'))
            MagnitudeScale=varargin{2};
            if(isempty(MagnitudeScale))
                minval=min(MagE);
            else
                minval=MagnitudeScale(1);
                maxval=MagnitudeScale(2);
                MagE(MagE<=minval)=minval;
                MagE(MagE>=maxval)=maxval;
            end
        else

        end
    else

    end

    plottype='3D';
    if isscalar(theta)||isscalar(phi)||strcmpi(slice,'azimuth')||...
        strcmpi(slice,'elevation')||~isscalar(frequency)||...
        isscalar(u)||isscalar(v)
        plottype='2D';
    end

    if strcmpi(coord,'polar')
        if strcmpi(plottype,'2D')
            plottype=em.internal.radiationpattern2D(MagE,theta,phi,...
            frequency,slice);
        else
            if(strcmpi(optype,'phase'))
                antennashared.internal.radiationpattern3D(MagE,theta,phi,...
                'offset',minval,'spherical',true,'plottype',optype);
            else
                antennashared.internal.radiationpattern3D(MagE,theta,phi,...
                'offset',minval,'plottype',optype);
            end

        end
    elseif strcmpi(coord,'rectangular')
        em.internal.radiationpatternrect(MagE,theta,phi,frequency,...
        plottype,slice,slicestyle,optype);

        hfig=gcf;
        ax=findall(hfig.Children,'Type','Axes');
        set(ax,'tag','rectangular');

    elseif strcmpi(coord,'uv')
        em.internal.radiationpatternuv(MagE,theta,phi,frequency,...
        plottype,slice,slicestyle,optype);
    end
end

