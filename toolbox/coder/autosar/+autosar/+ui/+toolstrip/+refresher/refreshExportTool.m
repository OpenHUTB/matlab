function refreshExportTool(cbinfo,action)




    if isvalid(action)
        block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);






        enabled=true;
        newActionDescr=DAStudio.message('autosarstandard:toolstrip:exportRootArchitectureDescription');

        if~SLStudio.Utils.objectIsValidBlock(block)

            if isempty(cbinfo.getSelection())


            else



                enabled=false;
            end
        elseif~isempty(autosar.bsw.ServiceComponent.find(block.handle))

            enabled=autosar.composition.studio.ActionStateGetter.getStateForAction('autosarExportComponentAction',cbinfo);
            newActionDescr=DAStudio.message('autosarstandard:toolstrip:exportComponentDescription');
        elseif autosar.composition.Utils.isComponentBlock(block.handle)

            enabled=autosar.composition.studio.ActionStateGetter.getStateForAction('autosarExportComponentAction',cbinfo);
            newActionDescr=DAStudio.message('autosarstandard:toolstrip:exportComponentDescription');
        elseif autosar.composition.Utils.isCompositionBlock(block.handle)

            enabled=autosar.composition.studio.ActionStateGetter.getStateForAction('autosarExportCompositionAction',cbinfo);
            newActionDescr=DAStudio.message('autosarstandard:toolstrip:exportCompositionDescription');
        end


        action.enabled=enabled;
        action.description=newActionDescr;
    end


