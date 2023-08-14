function hObj=PmEditUnit(varargin)






















    hObj=PMDialogs.PmEditUnit;
    hObj.CreateInstanceFcn=PMDialogs.PmCreateInstance;

    if(nargin~=9)&&(nargin~=0)&&(nargin~=8)&&(nargin~=14)
        error('Wrong number of input arguments (need 0 or 8, 9, or 14 arguments)');
    end

    if(ishandle(varargin{1}))
        hObj.BlockHandle=varargin{1};
    else
        error('Expecting handle for first argument.');
    end

    hObj.Label=varargin{2};
    hObj.LabelAttrb=int32(varargin{3});
    eBoxLabel=varargin{4};
    eBoxParamName=varargin{5};
    unitLabel=varargin{6};
    unitParamName=varargin{7};
    unitDefault=varargin{8};

    unitSelectIsEditable=false;

    if nargin>8
        unitSelectIsEditable=varargin{9};
    end

    hPosEdit=PMDialogs.PmEditBox(hObj.BlockHandle,eBoxLabel,eBoxParamName,0);
    if isstruct(unitDefault)
        hUnitsSel=PMDialogs.PmEditDropDown(hObj.BlockHandle,...
        unitLabel,unitParamName,...
        unitDefault.Units,0,unitDefault.Default,...
        '','',@lPreApply);
    elseif unitSelectIsEditable
        hUnitsSel=PMDialogs.PmEditUnitSelect(hObj.BlockHandle,unitLabel,unitParamName,0,unitDefault);
    else
        hUnitsSel=PMDialogs.PmUnitSelect(hObj.BlockHandle,unitLabel,unitParamName,0,unitDefault);
    end

    if nargin==14
        confLabel=varargin{10};
        confParamName=varargin{11};
        confOptions=varargin{12};
        confValue=varargin{13};
        confChoiceVals=varargin{14};
        hConfDropDown=PMDialogs.PmDropDown(hObj.BlockHandle,confLabel,confParamName,confOptions,...
        0,confValue,1:numel(confChoiceVals),confChoiceVals);
        hObj.Items=[hPosEdit,hUnitsSel,hConfDropDown];
    else
        hObj.Items=[hPosEdit,hUnitsSel];
    end

    function[status,messageString]=lPreApply(unitExpression)

        status=true;
        messageString='';
        if~pm_isunit(unitExpression)
            status=false;
            unitExpression=strrep(unitExpression,'<','&lt;');
            unitExpression=strrep(unitExpression,'>','&gt;');
            messageString=pm_message('physmod:common:data:mli:value:InvalidUnit',unitExpression);
        end
