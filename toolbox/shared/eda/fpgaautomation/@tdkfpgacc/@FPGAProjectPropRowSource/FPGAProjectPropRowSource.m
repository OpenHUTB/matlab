function this=FPGAProjectPropRowSource(varargin)




    this=tdkfpgacc.FPGAProjectPropRowSource;


    if(nargin==1&&ishandle(varargin{1}))
        s=varargin{1};
        this.name=s.name;
        this.value=s.value;
        this.process=s.process;

    elseif(nargin==3)
        [name,value,process]=deal(varargin{:});
        this.name=name;
        this.value=value;
        this.process=process;
    elseif(nargin==0)
        this.name='';
        this.value='';
        this.process='';
    else
        error(message('EDALink:FPGAProjectPropRowSource:BadCtor'));
    end




