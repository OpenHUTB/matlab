function hObj=PmEditBox(varargin)

















    hObj=PMDialogs.PmEditBox;
    hObj.CreateInstanceFcn=PMDialogs.PmCreateInstance;

    if(nargin<3)||(nargin>10)||(nargin==6)||(nargin==7)
        error('Wrong number of input arguments (need 3 to 5 or 8 to 10 arguments)');
    end

    if(ishandle(varargin{1}))
        hObj.BlockHandle=varargin{1};
    else
        error('Expecting handle for first argument.');
    end



    hObj.Label=varargin{2};
    hObj.ValueBlkParam=varargin{3};
    hObj.LabelAttrb=0;
    hObj.Value='';

    if((nargin>3)&&isnumeric(varargin{4})&&(varargin{4}>=0&&varargin{4}<4))
        hObj.LabelAttrb=int32(varargin{4});
    end

    if(nargin==5)
        hObj.Value=varargin{5};
    end

    if(nargin>5)
        confLabel=varargin{nargin-4};
        confParamName=varargin{nargin-3};
        confOptions=varargin{nargin-2};
        confValue=varargin{nargin-1};
        confChoiceVals=varargin{nargin};
        hConfDropDown=PMDialogs.PmDropDown(hObj.BlockHandle,confLabel,confParamName,confOptions,...
        0,confValue,1:numel(confChoiceVals),confChoiceVals);
        hObj.Items=hConfDropDown;
    end


