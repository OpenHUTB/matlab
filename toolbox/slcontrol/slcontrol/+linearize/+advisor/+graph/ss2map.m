function M=ss2map(varargin)




    switch nargin
    case 1
        sys=varargin{1};
        A=sys.a;
        B=sys.b;
        C=sys.c;
        D=sys.d;
    case 4
        A=varargin{1};
        B=varargin{2};
        C=varargin{3};
        D=varargin{4};
    end
    A=logical(A);
    B=logical(B);
    C=logical(C);
    D=logical(D);

    ny=size(C,1);
    nx=size(A,1);
    nu=size(B,2);

    M=[A,zeros(nx,ny),B;
    C,zeros(ny,ny),D;
    zeros(nu,ny+nx+nu)];