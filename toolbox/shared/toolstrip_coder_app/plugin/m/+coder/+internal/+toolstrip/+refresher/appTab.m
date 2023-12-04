function appTab(cbInfo,action)

    if coderdictionary.data.feature.getFeature('CodeGenIntent')
        mdl=coder.internal.toolstrip.util.getCodeGenRoot(cbInfo.studio.App.getActiveEditor);
        if isempty(mdl)
            action.text='Coder';
            return;
        end
    else
        mdl=cbInfo.model.handle;
    end

    cp=simulinkcoder.internal.CodePerspective.getInstance;
    [app,~,lang]=cp.getInfo(mdl);

    if strcmp(app,'Autosar')
        action.text=DAStudio.message('ToolstripCoderApp:toolstrip:AutosarTabTitle');
    elseif strcmp(app,'DDS')
        action.text=DAStudio.message('ToolstripCoderApp:toolstrip:DDSTabTitle');
    elseif strcmp(lang,'cpp')
        action.text=DAStudio.message('ToolstripCoderApp:toolstrip:CppTabTitle');
    else
        action.text=DAStudio.message('ToolstripCoderApp:toolstrip:SimulinkCoderTabTitle');
    end

