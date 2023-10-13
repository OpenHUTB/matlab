function[B,A]=designShelvingEQ(G,S,Fc,varargin)

%#codegen

    narginchk(3,6);
    nargoutchk(0,2);
    coder.allowpcode('plain');


    if nargin<4||nargin==5
        desmode='lo';
        params=audio.internal.designParamEQValidator(varargin{:});
    else
        desmode=varargin{1};
        params=audio.internal.designParamEQValidator(varargin{2:end});
    end

    orientation=params.Orientation;

    validateattributes(G,{'numeric'},{'real','finite','scalar'},...
    'designShelvingEQ','G',1);
    validateattributes(S,{'numeric'},{'real','finite','scalar'},...
    'designShelvingEQ','S',2);
    validateattributes(Fc,{'numeric'},{'real','finite','scalar','nonnegative'},...
    'designShelvingEQ','Fc',3);
    Fc(Fc>1)=1;

    desmode=validatestring(desmode,{'lo','hi'},'designShelvingEQ','T',4);

    T=true;
    if~strncmp(desmode,'lo',3)
        T=false;
    end

    w0=pi*Fc;

    Ag=10^(G/40);
    v=max((Ag+(1/Ag))*((1/S)-1)+2,0);
    alpha=(sin(w0)/2)*sqrt(v);

    if T

        b0=Ag*((Ag+1)-(Ag-1)*cos(w0)+2*sqrt(Ag)*alpha);
        b1=2*Ag*((Ag-1)-(Ag+1)*cos(w0));
        b2=Ag*((Ag+1)-(Ag-1)*cos(w0)-2*sqrt(Ag)*alpha);
        a0=(Ag+1)+(Ag-1)*cos(w0)+2*sqrt(Ag)*alpha;
        a1=-2*((Ag-1)+(Ag+1)*cos(w0));
        a2=(Ag+1)+(Ag-1)*cos(w0)-2*sqrt(Ag)*alpha;
    else

        b0=Ag*((Ag+1)+(Ag-1)*cos(w0)+2*sqrt(Ag)*alpha);
        b1=-2*Ag*((Ag-1)+(Ag+1)*cos(w0));
        b2=Ag*((Ag+1)+(Ag-1)*cos(w0)-2*sqrt(Ag)*alpha);
        a0=(Ag+1)-(Ag-1)*cos(w0)+2*sqrt(Ag)*alpha;
        a1=2*((Ag-1)-(Ag+1)*cos(w0));
        a2=(Ag+1)-(Ag-1)*cos(w0)-2*sqrt(Ag)*alpha;
    end

    B0=[b0;b1;b2]/a0;
    A0=[a1;a2]/a0;

    if strcmp(orientation,'row')
        B=B0';
        A=[ones(size(A0,2),1),A0'];
    else
        B=B0;
        A=A0;
    end

end