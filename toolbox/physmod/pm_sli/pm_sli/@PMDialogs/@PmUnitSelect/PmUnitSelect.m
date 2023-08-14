function hObj=PmUnitSelect(varargin)



















    hObj=PMDialogs.PmUnitSelect;
    hObj.CreateInstanceFcn=PMDialogs.PmCreateInstance;

    if((nargin~=5)&&(nargin~=6)&&(nargin~=7))
        error('Wrong number of input arguments (need 5, 6 or 7 arguments)');
    end

    if(ishandle(varargin{1}))
        hObj.BlockHandle=varargin{1};
    else
        error('Expecting handle for first argument.');
    end



    hObj.Label=varargin{2};
    hObj.ValueBlkParam=varargin{3};
    hObj.LabelAttrb=0;
    if(isnumeric(varargin{4})&&(varargin{4}>=0&&varargin{4}<4))
        hObj.LabelAttrb=int32(varargin{4});
    end
    hObj.UnitDefault=varargin{5};

    hObj.HideName=true;
    if(nargin>5)
        hObj.HideName=varargin{6};
    end

    hObj.Value='';
    if(nargin>6)
        hObj.Value=varargin{7};
    end
