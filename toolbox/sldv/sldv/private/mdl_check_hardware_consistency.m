function compat=mdl_check_hardware_consistency(modelH,compat)







    modelName=get_param(modelH,'Name');
    if Simulink.internal.useFindSystemVariantsMatchFilter()
        [refMdls,~]=find_mdlrefs(modelName,...
        'AllLevels',true,...
        'IncludeProtectedModels',false,...
        'MatchFilter',@Simulink.match.activeVariants,...
        'IncludeCommented','off',...
        'KeepModelsLoaded',true);
    else
        [refMdls,~]=find_mdlrefs(modelName,...
        'AllLevels',true,...
        'IncludeProtectedModels',false,...
        'Variants','ActiveVariants',...
        'IncludeCommented','off',...
        'KeepModelsLoaded',true);
    end



    isHWCCSame=true;

    activeCSTopModel=getActiveConfigSet(modelH);



    if strcmpi(get_param(activeCSTopModel,'ConcurrentTasks'),'on')

        return;
    end

    resolvedCSTopModel=locGetConfigSet(activeCSTopModel);

    hwCCSettingTop=resolvedCSTopModel.getComponent('Hardware Implementation');

    for idx=1:numel(refMdls)
        locModel=refMdls{idx};
        activeConfigSet=getActiveConfigSet(locModel);
        resolvedCSSubModel=locGetConfigSet(activeConfigSet);
        hwCCSetting=resolvedCSSubModel.getComponent('Hardware Implementation');
        if~target.internal.isHWDeviceTypeEq(hwCCSettingTop.ProdHWDeviceType,hwCCSetting.ProdHWDeviceType)



            if~checkIdenticalDetailedSettings(hwCCSettingTop,hwCCSetting)

                isHWCCSame=false;
                break;
            end
        else

            c=Simulink.ModelReference.internal.configset.ParentChildComparator();
            c.compare(modelName,resolvedCSTopModel,locModel,resolvedCSSubModel,'RTW','Component','Hardware Implementation');
            diffset=c.getMismatchedParams();
            if~isempty(diffset)
                if~isequal(diffset,{'ProdHWDeviceType'})
                    isHWCCSame=false;
                    break;
                end
            end
        end
    end

    if~isHWCCSame

        compat='DV_COMPAT_INCOMPATIBLE';
        errMsg=getString(message('Sldv:Compatibility:ModelReferenceHWSettingConsistency'));
        sldvshareprivate('avtcgirunsupcollect','push',get_param(modelH,'Handle'),'simulink',errMsg,...
        'Sldv:Compatibility:ModelReferenceHWSettingConsistency');
    end
end

function resolvedCS=locGetConfigSet(activeCS)

    if isa(activeCS,'Simulink.ConfigSetRef')
        resolvedCS=activeCS.getRefConfigSet;
    else
        resolvedCS=activeCS;
    end
end

function isIdentical=checkIdenticalDetailedSettings(hwCCTop,hwCCLocal)

    PropEnum={'ProdBitPerChar','ProdBitPerShort','ProdBitPerInt','ProdBitPerLong','ProdWordSize'...
    ,'ProdEndianess','ProdIntDivRoundTo','ProdShiftRightIntArith','ProdLongLongMode'...
    ,'ProdBitPerFloat','ProdBitPerDouble','ProdBitPerPointer','ProdBitPerLongLong'...
    ,'ProdLargestAtomicInteger','ProdLargestAtomicFloat','ProdBitPerSizeT','ProdBitPerPtrDiffT'};

    for idx=1:numel(PropEnum)
        if~isequal(hwCCTop.(PropEnum{idx}),hwCCLocal.(PropEnum{idx}))
            isIdentical=false;
            return;
        end
    end

    isIdentical=true;



end

