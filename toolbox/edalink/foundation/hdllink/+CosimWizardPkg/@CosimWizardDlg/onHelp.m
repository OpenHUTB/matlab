function onHelp(this,~)


    isSysObjWorkflow=strcmpi(this.UserData.Workflow,'MATLAB System Object');

    switch(this.StepID)
    case 1
        l_helpview('HDLCosimAssist_Type');
    case 2
        l_helpview('HDLCosimAssist_Files');
    case 3
        l_helpview('HDLCosimAssist_Compile');
    case 4
        l_helpview('HDLCosimAssist_Modules');
    case 5
        if isSysObjWorkflow
            l_helpview('HDLCosimAssistML_SOIO');
        else
            l_helpview('HDLCosimAssistSL_Ports');
        end
    case 6
        if isSysObjWorkflow
            l_helpview('HDLCosimAssistML_SOPorts');
        else
            l_helpview('HDLCosimAssistSL_Outputs');
        end
    case 7
        if isSysObjWorkflow
            l_helpview('HDLCosimAssistML_SOClocks');
        else
            l_helpview('HDLCosimAssistSL_ClocksResets');
        end
    case 8
        if isSysObjWorkflow
            l_helpview('HDLCosimAssistML_SOStartTime');
        else
            l_helpview('HDLCosimAssistSL_Time');
        end
    case 9
        l_helpview('HDLCosimAssistSL_GenBlock');
    case 10
        l_helpview('HDLCosimAssistML_Callback');
    case 11
        l_helpview('HDLCosimAssistML_GenScripts');
    case 12
        l_helpview('HDLCosimAssistML_GenSystemObject');
    end

end

function l_helpview(anchor)
    helpview(fullfile(docroot,'toolbox','hdlverifier','helptargets.map'),anchor)
end

