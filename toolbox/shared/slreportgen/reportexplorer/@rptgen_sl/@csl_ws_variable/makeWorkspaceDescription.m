function out=makeWorkspaceDescription(this,d,workspaceVar)





    ps=rptgen_sl.propsrc_sl_ws_var();
    adSL=rptgen_sl.appdata_sl();

    if(nargin<2)
        workspaceVar=adSL.CurrentWorkspaceVar;
    end

    if(length(workspaceVar)~=1)
        error(message('Simulink:rptgen_sl:InvalidInputsWorkspace'));
    end

    workspace=ps.getPropValue(workspaceVar,'Workspace');
    workspace=workspace{1};

    workspaceType=ps.getPropValue(workspaceVar,'WorkspaceType');
    workspaceType=workspaceType{1};

    workspaceTitleText=this.msg('WSTitle');
    titleElem=d.createElement('phrase');
    pi=createProcessingInstruction(d,'db2dom',...
    'style-name="rgDDVarSourceTitle"');
    appendChild(titleElem,pi);
    textNode=createTextNode(d,sprintf('%s: ',workspaceTitleText));
    appendChild(titleElem,textNode);

    paraElem=createElement(d,'para');
    appendChild(paraElem,titleElem);

    textElem=createElement(d,'phrase');
    pi=createProcessingInstruction(d,'db2dom',...
    'style-name="rgDDVarSource"');
    appendChild(textElem,pi);

    paraText=workspaceType;
    if~strcmpi(workspaceType,'base workspace')
        paraText=[paraText,' (',workspace,')'];
    end

    textNode=createTextNode(d,paraText);
    appendChild(textElem,textNode);

    appendChild(paraElem,textElem);

    out=paraElem;

