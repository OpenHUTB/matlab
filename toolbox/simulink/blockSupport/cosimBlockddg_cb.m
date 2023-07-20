function varargout=cosimBlockddg_cb(action,varargin)



    try
        out=loc_callbackSwitchYard(action,varargin{:});
        for i=1:length(out)
            varargout{i}=out{i};%#ok<AGROW>
        end
    catch E


        throwAsCaller(E);
    end
end


function out=loc_callbackSwitchYard(action,varargin)
    out={};


    dialogH=varargin{1};

    if strncmp(action,'do',2)&&~isempty(dialogH)
        source=dialogH.getDialogSource;
        block=source.getBlock;
    end

    switch action
    case 'doOpen'
        i_doOpen(dialogH,'CosimulationTargetNameDialog');
    case 'doBrowse'
        tag=varargin{2};
        i_doBrowse(dialogH,tag);
    case 'doPreApply'

        try
            out=loc_doPreApply(dialogH,block,source);
        catch me
            out{1}=false;
            out{2}=me.message;
        end
    case 'doClose'
        i_doClose(dialogH);
    case 'EnableBrowse'
        out{1}=i_ShouldBrowseButtonBeEnabled(varargin{:});
    case 'EnableOpen'
        out{1}=i_ShouldOpenButtonBeEnabled(varargin{:});
    case 'EnableTargetName'
        out{1}=i_ShouldTargetNameBoxBeEnabled(varargin{:});
    case 'EnableSimulationMode'
        out{1}=i_ShouldSimModeBeEnabled(varargin{:});
    case 'EnableParamArgValues'
        out{1}=i_ShouldParamArgValuesBeEnabled(varargin{:});
    case 'SetInstSpecModelArgs'
        loc_SetInstSpecArguVals(varargin{:});
    end
end



function isEnabled=i_ShouldBrowseButtonBeEnabled(h)
    isEnabled=~(h.isHierarchySimulating||h.isLinked||...
    (Simulink.harness.internal.isHarnessCUT(h.handle)&&...
    ~Simulink.harness.internal.isActiveHarnessCUTPropEditable(h.handle)));
end





function isEnabled=i_ShouldOpenButtonBeEnabled(~,~)
    isEnabled=true;
end



function isEnabled=i_ShouldTargetNameBoxBeEnabled(source,block)
    isEnabled=~(source.UserData.DisableWholeDialog||block.isLinked||...
    block.isHierarchySimulating||(Simulink.harness.internal.isHarnessCUT(block.handle)&&...
    ~Simulink.harness.internal.isActiveHarnessCUTPropEditable(block.handle)));
end



function isEnabled=i_ShouldSimModeBeEnabled(source,modelName)
    isEnabled=true;

    if(source.UserData.DisableWholeDialog||...
        source.isHierarchySimulating||source.isLinked)
        isEnabled=false;
        return;
    end


end



function isEnabled=i_ShouldParamArgValuesBeEnabled(source)
    isEnabled=~source.UserData.DisableWholeDialog;
end


function i_doOpen(dialogH,tag)

    if isempty(dialogH)||~ishandle(dialogH)
        DAStudio.error('Simulink:dialog:DDGInvalidDialogHandle','cosimBlockddg_cb.m');
    end


    modelName=dialogH.getWidgetValue(tag);
    if isempty(modelName)||~ischar(modelName)
        return;
    end

    if~isempty(modelName)

    end

    loc_OpenModel(dialogH,modelName);
end


function loc_OpenModel(dialogH,modelName)



    blockH=dialogH.getDialogSource.getBlock.Handle;


    [~,dialogName]=fileparts(get_param(blockH,'CosimulationTargetName'));
    [~,modelNameNoExt]=fileparts(modelName);
    differentName=~strcmp(dialogName,modelNameNoExt);


    isDefaultName=strcmp(get_param(blockH,'CosimulationTargetNameDialog'),'<Enter Target Name>');

    if(differentName||isDefaultName)
        warning("Target can not be opened.");
    else
        open_system(modelNameNoExt);
    end
end


function i_doBrowse(dialogH,tag,varargin)

    browser=ModelReferenceBrowser();
    browser.browse(dialogH,tag,false,varargin{:});
end


function loc_set_inst_spec_argument_values(block,spreadsheetData)
    paramVal=[];
    for ii=1:numel(spreadsheetData)
        paramVal(ii).Name=spreadsheetData(ii).m_Name;
        paramVal(ii).Value=spreadsheetData(ii).m_Value;
        paramVal(ii).Path=Simulink.BlockPath(spreadsheetData(ii).m_RealPath);
        if strcmp(spreadsheetData(ii).m_InstanceSpecific,'on')||strcmp(spreadsheetData(ii).m_InstanceSpecific,'1')
            boolVal=true;
        end
        if strcmp(spreadsheetData(ii).m_InstanceSpecific,'off')||strcmp(spreadsheetData(ii).m_InstanceSpecific,'0')
            boolVal=false;
        end
        paramVal(ii).Argument=boolVal;
    end
    if(~isempty(paramVal))
        set_param(block.handle,'InstanceParameters',paramVal);
    end
end


function loc_SetInstSpecArguVals(source)
    block=source.getBlock;
    if isfield(source.UserData,'spreadsheetData')
        toSetInstSpecVal=source.UserData.spreadsheetData;
        loc_set_inst_spec_argument_values(block,toSetInstSpecVal);
    end
end



function out=loc_doPreApply(dialogH,block,source)
    out={};
    if~block.isHierarchyReadonly
        if isfield(source.UserData,'spreadsheetData')
            toSetInstSpecVal=source.UserData.spreadsheetData;
            loc_set_inst_spec_argument_values(block,toSetInstSpecVal);
        end


        [noErr,msg]=source.preApplyCallback(dialogH);

        if noErr
            [noErr,msg]=i_doPreApply(dialogH,block,source);
        end
    else
        msg='';noErr=true;
    end

    out{2}=msg;
    out{1}=noErr;
end


function[success,err]=i_doPreApply(H,block,dialogSource)
    err='';success=true;



    modelName=block.CosimulationTargetNameDialog;






    H.setEnabled('TargetOpen',i_ShouldOpenButtonBeEnabled('',modelName));

    H.refresh;

end



function i_doClose(H)

    source=H.getSource;


    if isempty(DAStudio.ToolRoot.getOpenDialogs(H.getSource))
        source.UserData=[];
    end
end







