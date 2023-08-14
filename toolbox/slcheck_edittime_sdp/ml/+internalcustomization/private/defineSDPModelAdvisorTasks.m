function defineSDPModelAdvisorTasks()
    mdladvRoot=ModelAdvisor.Root;




    if slfeature('cgsl_0401')
        rec=ModelAdvisor.FactoryGroup('FunctionPlatform');
        rec.DisplayName=DAStudio.message('ModelAdvisor:sdp:SDP_group');
        rec.Description=DAStudio.message('ModelAdvisor:sdp:SDP_group_desc');
        rec.CSHParameters.MapKey='';
        rec.CSHParameters.TopicID='';
        rec.addCheck('mathworks.codegen.cgsl_0401');
        rec.addCheck('mathworks.codegen.cgsl_0402');
        rec.addCheck('mathworks.codegen.cgsl_0414');

        mdladvRoot.publish(rec);
    end
end
