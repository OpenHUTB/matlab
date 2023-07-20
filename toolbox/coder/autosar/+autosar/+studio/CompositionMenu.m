function schema=CompositionMenu(fncname,cbinfo,eventData)




    fnc=str2func(fncname);

    if nargout(fnc)
        schema=fnc(cbinfo);
    else
        schema=[];
        if nargin==3
            fnc(cbinfo,eventData);
        else
            fnc(cbinfo);
        end
    end
end

function schema=ExportCompositionBlock(cbinfo)
    schema=DAStudio.ActionSchema;
    schema.tag='Composition:ExportCompositionBlock';
    schema.label=DAStudio.message('autosarstandard:editor:ExportCompositionMenuItem');

    schema.state='Enabled';
    schema.callback=@ExportCompositionBlockCB;

    if autosar.composition.studio.ActionStateGetter.getStateForAction('autosarExportCompositionAction',cbinfo)
        schema.state='Enabled';
    else
        hideOrDisableMenuItem(cbinfo,schema);
    end
    schema.autoDisableWhen='Busy';
end

function ExportCompositionBlockCB(cbinfo,~)
    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
    if SLStudio.Utils.objectIsValidBlock(block)
        blkH=block.handle;
        autosar.composition.studio.CreateAndLink.exportCompositionBlock(blkH);
    end
end

function schema=CreateModel(cbinfo)
    schema=DAStudio.ActionSchema;
    schema.tag='Composition:CreateModel';
    schema.Label=DAStudio.message('autosarstandard:editor:CreateModelMenuItem');
    schema.callback=@CreateModelCB;

    if autosar.composition.studio.ActionStateGetter.getStateForAction('autosarCreateModelAction',cbinfo)
        schema.state='Enabled';
    else
        hideOrDisableMenuItem(cbinfo,schema);
    end
    schema.autoDisableWhen='Busy';
end

function CreateModelCB(cbinfo,~)
    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
    autosar.composition.studio.CreateAndLink.createModelForComp(block.handle);
end

function schema=LinkToModel(cbinfo)
    schema=DAStudio.ActionSchema;
    schema.tag='Composition:LinkToModel';
    schema.Label=DAStudio.message('autosarstandard:editor:LinkToModelMenuItem');
    schema.callback=@LinkToModelCB;

    if autosar.composition.studio.ActionStateGetter.getStateForAction('autosarLinkToModelAction',cbinfo)
        schema.state='Enabled';
    else
        hideOrDisableMenuItem(cbinfo,schema);
    end
    schema.autoDisableWhen='Busy';
end

function LinkToModelCB(cbinfo,~)
    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
    blkH=block.handle;
    autosar.composition.studio.CreateAndLink.linkCompToModel(blkH);
end

function schema=ImportModelFromARXML(cbinfo)
    schema=DAStudio.ActionSchema;
    schema.tag='Composition:ImportModelFromARXML';
    schema.Label=DAStudio.message('autosarstandard:editor:ImportModelFromARXMLMenuItem');
    schema.callback=@ImportModelFromARXMLCB;

    if autosar.composition.studio.ActionStateGetter.getStateForAction('autosarImportFromARXMLAction',cbinfo)
        schema.state='Enabled';
    else
        hideOrDisableMenuItem(cbinfo,schema);
    end
    schema.autoDisableWhen='Busy';
end

function ImportModelFromARXMLCB(cbinfo,~)
    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
    blkH=block.handle;
    autosar.composition.studio.CreateAndLink.importCompFromARXML(blkH);
end

function schema=ExportComponent(cbinfo)
    schema=DAStudio.ActionSchema;
    schema.tag='Composition:ExportComponent';
    schema.Label=DAStudio.message('autosarstandard:editor:ExportComponentMenuItem');
    schema.callback=@ExportComponentCB;

    if autosar.composition.studio.ActionStateGetter.getStateForAction('autosarExportComponentAction',cbinfo)
        schema.state='Enabled';
    else
        hideOrDisableMenuItem(cbinfo,schema);
    end
    schema.autoDisableWhen='Busy';
end

function ExportComponentCB(cbinfo,~)
    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
    if SLStudio.Utils.objectIsValidBlock(block)
        blkH=block.handle;
        autosar.composition.studio.CreateAndLink.exportComponentBlock(blkH);
    end
end


function hideOrDisableMenuItem(cbinfo,schema)





    if cbinfo.isContextMenu
        schema.state='Hidden';
    else
        schema.state='Disabled';
    end
end



