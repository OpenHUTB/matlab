function updateParametersForOldModels(hObj)















    cs=hObj.getConfigSet();
    if~isempty(cs)
        h=linkfoundation.pjtgenerator.AdaptorRegistry.manageInstance('get','EmbeddedIDELink');
        depInfoObj=h.getDeprecationInfo(get_param(cs,'AdaptorName'));
        if~isempty(depInfoObj)
            depInfoObj.run(cs);
        end

        if~strcmp(get_param(cs,'buildAction'),'Create_Processor_In_the_Loop_project')&&...
            strcmp(get_param(cs,'configurePIL'),'on')
            cs.setProp('buildAction','Create_Processor_In_the_Loop_project');
        end
        if strcmp(cs.getProp('buildAction'),'Create_Processor_In_the_Loop_project')










            pilConfig=rtw.pil.ConfigureModelForPILBlock(cs);

            pilConfig.configure;


            if~strcmp(cs.getProp('configPILBlockAction'),'None')

                cs.setProp('CreateSILPILBlock','PIL');

                cs.setProp('configPILBlockAction','None');
            end
        end
    end
