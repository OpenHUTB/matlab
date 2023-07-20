function hObj=PmLabelSpinner(varargin)











    hObj=PMDialogs.PmLabelSpinner;
    hObj.CreateInstanceFcn=PMDialogs.PmCreateInstance;

    if(nargin>0&&ishandle(varargin{1}))
        hObj.BlockHandle=varargin{1};
    end



    if(nargin>1&&ischar(varargin{2}))
        hObj.Label=varargin{2};
    end



    if(nargin>2&&ischar(varargin{3}))
        hObj.ValueBlkParam=varargin{3};
    end



    if(nargin>4&&ischar(varargin{4}))
        minmaxVal=varargin{4};
        hObj.MinValue=minmaxVal(1);
        hObj.MaxValue=minmaxVal(2);
    end
