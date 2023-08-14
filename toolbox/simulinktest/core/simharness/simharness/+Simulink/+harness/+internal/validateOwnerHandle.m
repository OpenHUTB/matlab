function[harnessType,harnessFullPath]=validateOwnerHandle(systemMdl,ownerH)







    if get_param(systemMdl,'handle')==ownerH
        harnessType='Simulink.BlockDiagram';
        harnessFullPath=systemMdl;
    else
        type=get_param(ownerH,'type');
        if~strcmp(type,'block')
            DAStudio.error('Simulink:Harness:InvalidHarnessOwnerHandle');
        elseif strcmp(get_param(ownerH,'Tag'),'__SL_testing_harness_stub_')
            DAStudio.error('Simulink:Harness:InvalidHarnessOwnerHandle');
        end
        blockType=get_param(ownerH,'BlockType');
        switch blockType
        case 'SubSystem'
            SubSystemSubDomain=...
            get_param(ownerH,'SimulinkSubDomain');




            if~strcmpi(SubSystemSubDomain,'Simulink')
                if any(strcmpi(SubSystemSubDomain,{'Architecture','SoftwareArchitecture','AUTOSARArchitecture'}))



                    if(Simulink.internal.isArchitectureModel(bdroot(ownerH),'SoftwareArchitecture')||...
                        Simulink.internal.isArchitectureModel(bdroot(ownerH),'AUTOSARArchitecture'))&&...
                        isequal(slfeature('TestHarnessInlineComps'),0)
                        results=find_system(Simulink.ID.getFullName(ownerH),'MatchFilter',@isModelReferenceInSoftwareOrAUTOSARDomain);
                        if~isempty(results)
                            DAStudio.error('Simulink:Harness:UnsupportedSubsystemHandle');
                        end
                    end
                else
                    DAStudio.error('Simulink:Harness:UnsupportedSubsystemHandle');
                end
            end

            harnessType='Simulink.SubSystem';
            harnessFullPath=getfullname(ownerH);
        case 'S-Function'
            harnessType='Simulink.SFunction';
            harnessFullPath=getfullname(ownerH);
        case 'M-S-Function'
            harnessType='Simulink.MSFunction';
            harnessFullPath=getfullname(ownerH);
        case 'MATLABSystem'
            harnessType='Simulink.MATLABSystem';
            harnessFullPath=getfullname(ownerH);
        case 'FMU'
            harnessType='Simulink.FMU';
            harnessFullPath=getfullname(ownerH);
        case 'CCaller'
            if slfeature('CustomCodeIntegrationHarness')
                harnessType='Simulink.CCaller';
                harnessFullPath=getfullname(ownerH);
            else
                DAStudio.error('Simulink:Harness:InvalidHarnessOwnerHandle');
            end
        case 'CFunction'
            if slfeature('CFunctionBlockHarness')
                harnessType='Simulink.CFunction';
                harnessFullPath=getfullname(ownerH);
            else
                DAStudio.error('Simulink:Harness:InvalidHarnessOwnerHandle');
            end
        case 'ModelReference'
            harnessType='Simulink.ModelReference';
            harnessFullPath=getfullname(ownerH);
        case 'SimscapeBlock'
            if slfeature('SimscapeBlockHarness')
                harnessType='Simulink.SimscapeBlock';
                harnessFullPath=getfullname(ownerH);
            else
                DAStudio.error('Simulink:Harness:InvalidHarnessOwnerHandle');
            end
        otherwise

            DAStudio.error('Simulink:Harness:InvalidHarnessOwnerHandle');
        end
    end
end

function tf=isModelReferenceInSoftwareOrAUTOSARDomain(h)

    tf=false;
    if strcmp(get_param(h,'BlockType'),'ModelReference')&&(strcmp(get_param(get_param(h,'Parent'),'SimulinkSubDomain'),'SoftwareArchitecture')||...
        strcmp(get_param(get_param(h,'Parent'),'SimulinkSubDomain'),'AUTOSARArchitecture'))
        tf=true;
    end
end
