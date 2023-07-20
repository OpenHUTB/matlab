function slr=offset(slr,varargin)










    switch nargin,
    case 2,
        offVector=varargin{1};
        if length(offVector)==1,
            hOffset=offVector(1);
            vOffset=offVector(1);
        else
            hOffset=offVector(1);
            vOffset=offVector(2);
        end

    case 3,
        hOffset=varargin{1};
        vOffset=varargin{2};

    otherwise,
        DAStudio.error('Simulink:utility:invNumArgsWithRange',mfilename,2,3);
    end

    slr.left=slr.left+hOffset;
    slr.top=slr.top+vOffset;
    slr.right=slr.right+hOffset;
    slr.bottom=slr.bottom+vOffset;
