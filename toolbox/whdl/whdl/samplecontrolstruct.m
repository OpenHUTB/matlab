function samplecontrol=samplecontrolstruct(varargin)






%#codegen

    narginchk(0,3);


    samplecontrol=struct('start',true,'end',false,...
    'valid',true);

    if nargin>0
        samplecontrol.start=logical(varargin{1});
    end
    if nargin>1
        samplecontrol.end=logical(varargin{2});
    end
    if nargin>2
        samplecontrol.valid=logical(varargin{3});
    end

end
