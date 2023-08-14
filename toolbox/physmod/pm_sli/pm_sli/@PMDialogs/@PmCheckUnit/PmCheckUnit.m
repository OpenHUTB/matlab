function hObj=PmCheckUnit(varargin)























    hObj=PMDialogs.PmCheckUnit;
    hObj.CreateInstanceFcn=PMDialogs.PmCreateInstance;

    if((nargin~=0)&&(nargin~=9))
        error('Wrong number of input arguments (need 0 or 9 arguments)');
    end

    if(ishandle(varargin{1}))
        hObj.BlockHandle=varargin{1};
    else
        error('Expecting handle for first argument.');
    end

    hObj.Label=varargin{2};
    hObj.LabelAttrb=int32(varargin{3});
    chkBoxLabel=varargin{4};
    chkBoxParamName=varargin{5};
    unitLabel=varargin{6};
    unitParamName=varargin{7};
    unitHideName=varargin{8};
    unitDefault=varargin{9};

    hPosEdit=PMDialogs.PmCheckBox(hObj.BlockHandle,chkBoxLabel,chkBoxParamName,0);
    hUnitsSel=PMDialogs.PmUnitSelect(hObj.BlockHandle,unitLabel,unitParamName,0,unitDefault,unitHideName);


    hObj.Items=[hPosEdit,hUnitsSel];





