function[B,A]=designVarSlopeFilter(Slope,Fc,varargin)

%#codegen

    narginchk(2,5);
    nargoutchk(0,2);
    coder.allowpcode('plain');

    if nargin<3||nargin==4
        desmode='lo';
        params=audio.internal.designParamEQValidator(varargin{:});
    else
        desmode=varargin{1};
        params=audio.internal.designParamEQValidator(varargin{2:end});
    end

    orientation=params.Orientation;

    validateattributes(Slope,{'numeric'},{'real','finite','scalar','>=',0,'<=',48},...
    'designVarSlopeFilter','Slope',1);
    validateattributes(Fc,{'numeric'},{'real','finite','scalar','>=',0},...
    'designVarSlopeFilter','Fc',2);
    Fc=min(Fc,1);
    desmode=validatestring(desmode,{'lo','hi'},'designShelvingEQ','T',3);

    T=true;
    if~strncmp(desmode,'lo',3)
        T=false;
    end

    Nrows=3;

    Ncols=4;


    Slope=6*round(Slope/6);


    B0=zeros(Nrows,Ncols,'like',Fc);
    B0(1,1:Ncols)=1;
    A0=zeros(Nrows-1,Ncols,'like',B0);

    if Slope~=0
        N=2;
        if Slope==12
            N=4;
        elseif Slope==18
            N=6;
        elseif Slope==24
            N=8;
        elseif Slope==30
            N=10;
        elseif Slope==36
            N=12;
        elseif Slope==42
            N=14;
        elseif Slope==48
            N=16;
        end
        if T

            [Num,Den]=designParamEQ(N,-inf,1,1-Fc);
        else

            [Num,Den]=designParamEQ(N,-inf,0,Fc);
        end
        B0(1:Nrows,1:ceil(N/Ncols))=Num(1:Nrows,1:ceil(N/Ncols));
        A0(1:Nrows-1,1:ceil(N/Ncols))=Den(1:Nrows-1,1:ceil(N/Ncols));
    end

    if strcmp(orientation,'row')
        B=B0';
        A=[ones(size(A0,2),1),A0'];
    else
        B=B0;
        A=A0;
    end