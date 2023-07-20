function val=get(A,varargin)





    if nargin==2
        switch varargin{1}
        case 'LowerChild'
            val=A.LowerChild;
        case 'UpperChild'
            val=A.UpperChild;
        case 'Position'
            HG=get(A,'MyHGHandle');
            xdata=get(HG,'XData');
            ydata=get(HG,'YData');
            minx=min(xdata);
            miny=min(ydata);
            maxx=max(xdata);
            maxy=max(ydata);
            val=[minx,miny,maxx-minx,maxy-miny];
        otherwise
            val=get(A.axischild,varargin{:});
        end
    else
        val=get(A.axischild,varargin{:});
    end








