function Blocks(obj)





    bswCallers=autosar.bsw.BasicSoftwareCaller.find(obj.modelName);
    if~isempty(bswCallers)
        impl=cellfun(@(x)eval(get_param(x,'ServiceImpl')),bswCallers,'UniformOutput',false);

        for idx=1:numel(bswCallers)

            impl{idx}.exportToPrevious(obj.ver,bswCallers{idx});
        end
    end

    if isR2021bOrEarlier(obj.ver)
        [demOverrideBlocks,demInjectBlocks]=autosar.bsw.DemStatusValidator.findDemStatusBlocks(obj.modelName);
        if~isempty(demOverrideBlocks)
            for blk=demOverrideBlocks
                obj.replaceWithEmptySubsystem(blk,'Dem Status Override');
            end
        end

        if~isempty(demInjectBlocks)
            for blk=demInjectBlocks
                obj.replaceWithEmptySubsystem(blk,'Dem Status Inject');
            end
        end
    end

    if isR2018bOrEarlier(obj.ver)

        eventReceiveBlks=findEventReceiveBlocks(obj.modelName);
        if~isempty(eventReceiveBlks)
            for blk=eventReceiveBlks
                obj.replaceWithEmptySubsystem(blk,'Event Receive');
            end
        end


        eventSendBlks=findEventSendBlocks(obj.modelName);
        if~isempty(eventSendBlks)
            for blk=eventSendBlks
                obj.replaceWithEmptySubsystem(blk,'Event Send');
            end
        end


        routineBlocks=autosar.routines.RoutineBlock.find(obj.modelName);
        if~isempty(routineBlocks)

            autosarRoutineLibrary='autosarlibiflifx';
            load_system(autosarRoutineLibrary);
            set_param(autosarRoutineLibrary,'Lock','off');
            set_param(autosarRoutineLibrary,'LockLinksToLibrary','off');
            for ii=1:numel(routineBlocks)
                routineBlock=routineBlocks{ii};

                isIFX=autosar.routines.RoutineBlock.isConfiguredForIFX(routineBlock);


                set_param(routineBlock,'LinkStatus','none');
                maskObj=Simulink.Mask.get(routineBlock);
                routineType=maskObj.Type;
                maskObj.delete;


                attribString=get_param(routineBlock,'AttributesFormatString');
                if strcmp(attribString,'%<TargetedRoutine>')
                    set_param(routineBlock,'AttributesFormatString','');
                end


                set_param(routineBlock,'InitFcn','');


                if strcmp(routineType,'Prelookup')
                    if isIFX
                        set_param(routineBlock,'OutputBusDataTypeStr','Bus: Ifx_DPResultU16_Type');
                    else
                        set_param(routineBlock,'OutputBusDataTypeStr','Bus: Ifl_DPResultF32_Type');
                    end
                end
            end
            bdclose(autosarRoutineLibrary);

            iflBusStr=createIFLBusStr();
            ifxBusStr=createIFXBusStr();

            preLoadStr=get_param(obj.modelName,'PreLoadFcn');
            set_param(obj.modelName,'PreLoadFcn',[iflBusStr,ifxBusStr,preLoadStr]);
        end
    end

    if isR2015aOrEarlier(obj.ver)

        sigInvBlks=findSignalInvalidationBlocks(obj.modelName);
        if~isempty(sigInvBlks)



            for blk=sigInvBlks
                obj.replaceWithEmptySubsystem(blk,'Signal Invalidation');
            end
        end
    end

end

function eventReceiveBlks=findEventReceiveBlocks(model)


    eventReceiveBlks=find_system(model,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks','on',...
    'LookUnderMasks','all',...
    'BlockType','Receive',...
    'MaskType','Event Receive');
end

function eventSendBlks=findEventSendBlocks(model)
    eventSendBlks=find_system(model,...
    'MatchFilter',@Simulink.match.allVariants,...
    'FollowLinks','on',...
    'LookUnderMasks','all',...
    'BlockType','Send',...
    'MaskType','Event Send');
end

function sigInvBlks=findSignalInvalidationBlocks(model)
    sigInvBlks=find_system(model,...
    'MatchFilter',@Simulink.match.allVariants,...
    'FollowLinks','on',...
    'LookUnderMasks','all',...
    'BlockType','SignalInvalidation');
end

function str=createIFLBusStr()
    str=[...
    'elems(1) = Simulink.BusElement;',...
    'elems(1).Name = ''Index'';',...
    'elems(1).DataType = ''fixdt(0,32,0)'';',...
    '',...
    'elems(2) = Simulink.BusElement;',...
    'elems(2).Name = ''Ratio'';',...
    'elems(2).DataType = ''single'';',...
    '',...
    'Ifl_DPResultF32_Type = Simulink.Bus;',...
    'Ifl_DPResultF32_Type.Elements = elems;',...
    'Ifl_DPResultF32_Type.HeaderFile = ''Rte_Type.h'';',...
    'clear(''elems'');'];
end

function str=createIFXBusStr()
    str=[...
    'elems(1) = Simulink.BusElement;',...
    'elems(1).Name = ''Index'';',...
    'elems(1).DataType = ''fixdt(0,16,0)'';',...
    '',...
    'elems(2) = Simulink.BusElement;',...
    'elems(2).Name = ''Ratio'';',...
    'elems(2).DataType = ''fixdt(0,16,16)'';',...
    '',...
    'Ifx_DPResultU16_Type = Simulink.Bus;',...
    'Ifx_DPResultU16_Type.Elements = elems;',...
    'Ifx_DPResultU16_Type.HeaderFile = ''Rte_Type.h'';',...
    'clear(''elems'');'];
end


