function slr=rect(varargin)


















    slr=Simulink.rect;

    switch(nargin),

    case 0,
        slr.left=0;
        slr.top=0;
        slr.right=0;
        slr.bottom=0;

    case 1,

        r=varargin{1};
        if isa(r,'Simulink.rect')
            slr=r;
        else
            LocalCheckArgs(r);

            slr.left=r(1);
            slr.top=r(2);
            slr.right=r(3);
            slr.bottom=r(4);
        end

    case 2,
        p1=varargin{1};
        p2=varargin{2};
        r=[p1(:)',p2(:)'];
        LocalCheckArgs(r);

        slr.left=r(1);
        slr.top=r(2);
        slr.right=r(3);
        slr.bottom=r(4);

    case 4,

        r=[varargin{:}];
        LocalCheckArgs(varargin{:});

        slr.left=r(1);
        slr.top=r(2);
        slr.right=r(3);
        slr.bottom=r(4);

    otherwise,
        LocalCheckArgs(varargin{:});

    end








    function LocalCheckArgs(varargin)

        if length(varargin)==4,
            r=[varargin{:}];
        else
            r=varargin{:};
        end

        if length(r)~=4,
            DAStudio.error('Simulink:tools:dlinmodWrongInputVectorSize',4);
        end
