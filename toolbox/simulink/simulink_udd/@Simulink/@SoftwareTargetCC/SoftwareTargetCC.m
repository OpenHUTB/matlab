function this=SoftwareTargetCC(varargin)




    this=Simulink.SoftwareTargetCC;
    if nargin>0
        assert(nargin==1);
        this.TaskConfiguration=varargin{1};
    end


