function hObj=PmGroupPanel(varargin)




    hObj=PMDialogs.PmGroupPanel;
    hObj.CreateInstanceFcn=PMDialogs.PmCreateInstance;

    hObj.BlockHandle=[];
    if(nargin>0&&ishandle(varargin{1}))
        hObj.BlockHandle=varargin{1};
    end

    hObj.Label='';
    if(nargin>1&&ischar(varargin{2}))
        hObj.Label=varargin{2};
    end

    hObj.Style='Box';
    if(nargin>2&&ischar(varargin{3}))
        hObj.Style=varargin{3};
    end

    hObj.StdLayoutCfg='Unset';
    if(nargin>3&&ischar(varargin{4}))
        hObj.StdLayoutCfg=varargin{4};
    end


    hObj.BoxStretch=false;
    if(nargin>4&&islogical(varargin{5}))
        hObj.BoxStretch=varargin{5};
    end

end
