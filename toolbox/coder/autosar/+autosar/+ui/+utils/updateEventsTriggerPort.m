
function updateEventsTriggerPort(obj,src)




    arRoot=obj.M3iObject.modelM3I;
    arExplorer=autosar.ui.utils.findExplorer(arRoot);
    assert(~isempty(arExplorer),'explorer should not be empty');
    mappingMgr=arExplorer.MappingManager;
    mapping=mappingMgr.getActiveMappingFor('AutosarTarget');
    if isa(src.MappedTo,'Simulink.AutosarTarget.PortElement')&&...
        strcmp(get_param(src.Block,'BlockType'),'Inport')&&...
        any(strcmp(src.MappedTo.DataAccessMode,...
        {'ImplicitReceive','ExplicitReceive','QueuedExplicitReceive','EndToEndRead','ExplicitReceiveByVal'}))


        if~isempty(findprop(arExplorer,'EventData'))
            eventData=arExplorer.EventData;
            if~isempty(eventData)
                for ii=1:numel(eventData)
                    evt=eventData(ii);
                    if any(strcmp(evt.EventType,{'DataReceivedEvent','DataReceiveErrorEvent'}))
                        modelName=bdroot(src.Block);
                        m3iComponent=autosar.api.Utils.m3iMappedComponent(modelName);
                        receiversCell=[DAStudio.message('RTW:autosar:selectERstr'),...
                        autosar.api.Utils.getDataReceivedEventTriggers(m3iComponent,mapping)];
                        evt.setReceiverCellValues(receiversCell);
                        if~any(ismember(receiversCell,evt.TriggerPort))
                            evt.setTriggerPort(DAStudio.message('RTW:autosar:selectERstr'));
                        end
                    end
                end
            end
        end
    end
end


