function hObj=PmNeVariableTargets(varargin)






















    hObj=NetworkEngine.PmNeVariableTargets;
    hObj.CreateInstanceFcn=PMDialogs.PmCreateInstance;

    if(nargin~=2)
        error('Wrong number of input arguments (need 2)');
    end

    if(ishandle(varargin{1}))
        hObj.BlockHandle=varargin{1};
    else
        error('Expecting handle for first argument.');
    end

    varStruct=varargin{2};
    hObj.DefaultTargets=varStruct;
    nVars=numel(varStruct);
    items=repmat(PMDialogs.PmGuiObj,nVars,4);
    for idx=1:nVars
        baseName=varStruct(idx).ID;
        baseLabel=varStruct(idx).Label;
        hOverride=NetworkEngine.PmNeCheckBox(hObj.BlockHandle,[baseName,'_specify'],'',1);
        hPriority=PMDialogs.PmDropDown(hObj.BlockHandle,baseLabel,[baseName,'_priority'],{'High','Low','None'},0);
        hPosEdit=PMDialogs.PmEditBox(hObj.BlockHandle,baseLabel,baseName,0);
        hUnitsSel=PMDialogs.PmEditUnitSelect(hObj.BlockHandle,'Unit',[baseName,'_unit'],0,varStruct(idx).Default.Value.Unit);
        items(idx,:)=[hOverride,hPriority,hPosEdit,hUnitsSel];
    end
    hObj.Items=items(:);

end








