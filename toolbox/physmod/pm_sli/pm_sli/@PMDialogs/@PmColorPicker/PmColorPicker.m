function hObj=PmColorPicker(varargin)










    hObj=PMDialogs.PmColorPicker;
    hObj.CreateInstanceFcn=PMDialogs.PmCreateInstance;

    if((nargin~=3)&&(nargin~=4))
        error('Wrong number of input arguments (need 2 or 3 inputs)');
    end

    if(ishandle(varargin{1}))
        hObj.BlockHandle=pmsl_getdoublehandle(varargin{1});
    else
        error('Expecting handle for first argument.');
    end

    hObj.ColorLabel=varargin{2};
    hObj.ColorParamName=varargin{3};

    [r,c]=size(varargin{4});
    if((nargin==4)&&((r==3&&c==1)||(r==1&&c==3))&&(max(varargin{4})<=1))
        colorVec=varargin{4};
        hObj.ColorVector=['[',num2str(colorVec(1)),' ',num2str(colorVec(2)),' ',num2str(colorVec(3)),']'];
    else
        error('Incorrect Color Vector Specified');
    end









