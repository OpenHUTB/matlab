function[state,messageStr]=dpiSystemSelectorStateFcn(obj,cbinfo)















    messageStr="";
    state='supported';

    generateTestbench=strcmp(get_param(cbinfo.model.name,'DPIGenerateTestBench'),'on');
    isSubsystem=isa(obj,'Simulink.SubSystem');
    isModelReference=isa(obj,'Simulink.ModelReference');
    isGCSModel=isa(obj,"Simulink.BlockDiagram");

    if~isSubsystem&&~isGCSModel
        state='nonsupported';
        if isModelReference
            messageStr=message('EDALink:SLToolstrip:DPIC:dpiSysSelectMdlRefNotSupported').string;
        else
            messageStr=message('EDALink:SLToolstrip:DPIC:dpiSysSelectRequirement').string;
        end
    else
        if isSubsystem&&generateTestbench

            dutEnablePorts=find_system(obj.handle,'SearchDepth','1','BlockType','EnablePort');
            dutTriggerPorts=find_system(obj.handle,'SearchDepth','1','BlockType','TriggerPort');
            dutActionPorts=find_system(obj.handle,'SearchDepth','1','BlockType','ActionPort');
            if~isempty(cat(1,dutEnablePorts,dutTriggerPorts,dutActionPorts))
                state='nonsupported';
                messageStr=message('EDALink:SLToolstrip:DPIC:dpiSysSelectTrigEnActNotSupported').string;
            end
        end

    end

end
