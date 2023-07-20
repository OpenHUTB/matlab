function hObj=PmCheckBox(varargin)


















    hObj=PMDialogs.PmCheckBox;
    hObj.CreateInstanceFcn=PMDialogs.PmCreateInstance;

    if((nargin<3)||(nargin>5))
        error('Wrong number of input arguments (need 3 or 5 arguments)');
    end

    if(ishandle(varargin{1}))
        hObj.BlockHandle=varargin{1};
    else
        error('Expecting handle for first argument.');
    end



    hObj.Label=varargin{2};
    hObj.ValueBlkParam=varargin{3};
    hObj.LabelAttrb=0;
    hObj.Value=0;

    if((nargin>3)&&isnumeric(varargin{4})&&(varargin{4}>=0&&varargin{4}<4))
        hObj.LabelAttrb=int32(varargin{4});
    end

    if(nargin>4)
        hObj.Value=varargin{5};
    end


