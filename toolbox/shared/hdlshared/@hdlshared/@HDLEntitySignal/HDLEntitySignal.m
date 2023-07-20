function this=HDLEntitySignal(varargin)






















    narginchk(7,9);

    this=hdlshared.HDLEntitySignal;
    this.Name=varargin{1};
    this.System=varargin{2};
    this.Port=varargin{3};
    this.Complex=varargin{4};
    this.Vector=varargin{5};
    this.VType=varargin{6};
    this.SLType=varargin{7};

    if nargin<8
        this.Rate=0;
    else
        this.Rate=varargin{8};
    end

    if nargin<9
        this.Forward=[];
    else
        this.Forward=varargin{9};
    end




