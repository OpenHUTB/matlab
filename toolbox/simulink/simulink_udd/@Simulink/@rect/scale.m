function slr=scale(slr,varargin)








    switch nargin,
    case 2,
        scaleVector=varargin{1};
        if length(scaleVector)==1,
            hScale=scaleVector(1);
            vScale=scaleVector(1);
        else
            hScale=scaleVector(1);
            vScale=scaleVector(2);
        end

    case 3,
        hScale=varargin{1};
        vScale=varargin{2};

    otherwise,
        DAStudio.error('Simulink:utility:invNumArgsWithRange',mfilename,2,3);

    end

    slr.left=int32(round(slr.left*hScale));
    slr.top=int32(round(slr.top*vScale));
    slr.right=int32(round(slr.right*hScale));
    slr.bottom=int32(round(slr.bottom*vScale));
