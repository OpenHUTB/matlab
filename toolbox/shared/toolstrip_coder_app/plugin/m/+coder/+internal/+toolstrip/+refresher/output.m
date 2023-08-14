function output(data,cbInfo,action)



    if slfeature('SDPToolStrip')
        mdl=cbInfo.studio.App.getActiveEditor.blockDiagramHandle;
    else
        mdl=cbInfo.model.handle;
    end

    type=coder.internal.toolstrip.util.getOutputType(mdl);
    supportedTypes=coder.internal.toolstrip.util.explicitlySupportedTypes;
    if strcmp(data,'custom')||strcmp(data,'dropdown')
        if isempty(intersect(type,supportedTypes))
            action.selected=true;
            action.setPropertyValue('description',[type,'.tlc']);
        else
            action.selected=false;
            action.setPropertyValue('description',DAStudio.message('SimulinkCoderApp:toolstrip:CustomSTFSelectionNoneEmbeddedCoderActionText'));
        end

    else
        action.selected=strcmp(data,type);
    end



    if~action.selected
        cs=getActiveConfigSet(mdl);
        if isa(cs,'Simulink.ConfigSetRef')
            action.enabled=false;
        end
    end


    cgb=get_param(mdl,'CodeGenBehavior');
    if strcmp(cgb,'None')
        action.selected=false;
    end


    if strcmp(data,'dropdown')
        action.enabled=true;
    end
