function addTargetHardwareResourceComponent(hObj,hBlock,action)




    cs=hObj.getConfigSet();
    if isa(cs,'Simulink.ConfigSetRef')
        cs=cs.getRefConfigSet();
    end

    if isempty(cs.getComponent('Target Hardware Resources'))
        comp=pjtgeneratorpkg.TargetHardwareResources;
        cs.attachComponent(comp);
    end

    if~isempty(get_param(cs,'TargetHardwareResources'))
        i_setFromCS(cs);
        if isequal(action,'load')
            linkfoundation.util.setTargetHardwareResourcesFromBlock(cs,hBlock);
        end
    elseif isequal(action,'load')
        linkfoundation.util.setTargetHardwareResourcesFromBlock(cs,hBlock);
    elseif isequal(action,'switch')
        linkfoundation.util.setDefaultTargetHardwareResources(cs);
        if~i_isSavedControllerValid(cs)
            hBlock=i_resetTargetHardwareResourcesController(cs,hBlock);
        end
        csProps=i_getConfigSetSettings();
        targetpref.checkAndSetActiveConfigSetSettings(cs,csProps,true);
    else

    end

    if~isempty(get_param(cs,'TargetHardwareResources'))
        controller=get_param(cs,'TargetHardwareResourcesController');
        if isempty(controller)
            controller=targetpref.Controller.get(cs,hBlock,'emptyFcn');
            set_param(cs,'TargetHardwareResourcesController',controller);
        end
    end

end



function i_setFromCS(cs)
    info=get_param(cs,'TargetHardwareResources');
    adaptorName=linkfoundation.util.convertTPTagToAdaptorName(info.tag);
    if cs.isValidParam('AdaptorName')
        set_param(cs,'AdaptorName',adaptorName);
    end
    hTgt=cs.getComponent('Code Generation').getComponent('Target');
    if hTgt.isValidProperty('AdaptorName')&&~isequal(hTgt.AdaptorName,adaptorName)...
        &&~i_isModelREfBuild(cs)&&~i_isSubsystemBuild()
        hTgt.setAdaptor(adaptorName);
    end
end



function ret=i_isModelREfBuild(cs)
    mdlRefTgtType=get_param(cs.getModel(),'ModelReferenceTargetType');
    ret=~isequal(mdlRefTgtType,'NONE');
end



function ret=i_isSubsystemBuild()
    tmpstk=dbstack;
    ret=(any(strcmp({tmpstk.name},'ss2mdl'))||...
    (any(strcmp({tmpstk.name},'makehdl'))));
end



function ret=i_isSavedControllerValid(cs)
    ret=false;
    if cs.isValidParam('TargetHardwareResourcesController')
        controller=get_param(cs,'TargetHardwareResourcesController');
        ret=isempty(controller)||~isempty(controller.getData());
    end
end


function hBlock=i_resetTargetHardwareResourcesController(cs,hBlock)
    set_param(cs,'TargetHardwareResourcesController',[]);


    blk=find_system(cs.getModel(),'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'MaskType','Target Preferences');
    if~isempty(blk)
        tgtInfo=get_param(cs,'TargetHardwareResources');
        set_param(blk,'Tag',tgtInfo.tag);
        set_param(bdroot(blk),'TargetHardwareResources',tgtInfo);
        set_param(bdroot(blk),'AdaptorName',get_param(cs,'AdaptorName'));
        set_param(bdroot(blk),'TargetHardwareResourcesController',[]);
        hBlock=blk;
    end
end

function prop=i_getConfigSetSettings()

    Fields={'Name','Method','Value'};
    Settings={'ProdHWDeviceType','setPropEnabled','on';
    'ProdHWDeviceType','set_param','Texas Instruments->C2000';...
    'Solver','setProp','FixedStepDiscrete';...
    'ProfileGenCode','setPropEnabled','on';...
    'ProdEndianess','setPropEnabled','on';...
    'ProdEndianess','set_param','LittleEndian';...
    'PositivePriorityOrder','setPropEnabled','on';...
    'PositivePriorityOrder','setProp','off';...
    'PositivePriorityOrder','setPropEnabled','off';...
    'EnableMultiTasking','setProp','on';...
    'ZeroInternalMemoryAtStartup','setPropEnabled','on';...
    'ZeroInternalMemoryAtStartup','setProp','on';...
    'ZeroInternalMemoryAtStartup','setPropEnabled','off';...
    'systemStackSize','setProp',512};

    prop=cell2struct(Settings,Fields,2);
end
