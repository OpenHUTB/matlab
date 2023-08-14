function postInvokeModelTemplate(modelHandle,pathToTemplate,extractedSLX)




    try



        i_resetMetadata(modelHandle,pathToTemplate);


        Simulink.addBlockDiagramCallback(modelHandle,'PreDestroy',...
        'InvokeModelTemplateCleanup',@i_deleteExtractedSLX);

        assert(...
        slfeature('EnhancedNormalMode')==0||...
        slfeature('EnhancedNormalMode')==1...
        );
        assert(...
        slsvTestingHook('EnhancedNormalFSpec')==0||...
        slsvTestingHook('EnhancedNormalFSpec')==1...
        );
        if slfeature('EnhancedNormalMode')==1&&...
            slsvTestingHook('EnhancedNormalFSpec')==1
            pd=Simulink.PreserveDirtyFlag(modelHandle,'blockDiagram');
            set_param(modelHandle,'SimulationMode','auto');
            delete(pd);
        end

    catch E
        warning(E.identifier,'%s',E.message);
    end

    function i_deleteExtractedSLX
        if~isempty(Simulink.loadsave.resolveFile(extractedSLX))
            delete(extractedSLX);
        end
    end

end


function i_resetMetadata(sys,pathToTemplate)
    pd=Simulink.PreserveDirtyFlag(sys,'blockDiagram');
    set_param(sys,'Lock','off');
    set_param(sys,'Creator',sltemplate.internal.utils.getCurrentUser);
    set_param(sys,'Created',sltemplate.internal.utils.getCurrentTime);
    set_param(sys,'ModelVersionFormat','%<AutoIncrement:1.0>');
    set_param(sys,"TemplateFilePath",pathToTemplate);
    delete(pd);
end
