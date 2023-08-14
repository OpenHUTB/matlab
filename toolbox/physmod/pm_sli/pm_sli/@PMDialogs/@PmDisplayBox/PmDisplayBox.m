function hObj=PmDisplayBox(varargin)

















    hObj=PMDialogs.PmDisplayBox;
    hObj.CreateInstanceFcn=PMDialogs.PmCreateInstance;

    if((nargin<2)||(nargin>4))
        error('Wrong number of input arguments (need 3 or 5 arguments)');
    end

    if(ishandle(varargin{1}))
        hObj.BlockHandle=varargin{1};
    else
        error('Expecting handle for first argument.');
    end

    hObj.Label=varargin{2};
    hObj.LabelAttrb=0;
    hObj.Value='';

    if((nargin>2)&&isnumeric(varargin{3})&&(varargin{3}>=0&&varargin{3}<4))
        hObj.LabelAttrb=int32(varargin{3});
    end

    if(nargin>3)
        hObj.Value=varargin{4};
    end


