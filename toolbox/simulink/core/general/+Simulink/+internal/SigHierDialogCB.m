



function[status,errMsg]=SigHierDialogCB(SigHierDialog,action)
    status=1;
    errMsg='';

    switch(action)
    case 'applyCB'
        portHandle=SigHierDialog.portHandle;
        modelHandle=SigHierDialog.modelHandle;
        selectedSignals=SigHierDialog.selectedSignals';
        sparkline=SigHierDialog.sparkline;

        if slfeature('SignalsSparklines')>0&&sparkline
            SLM3I.SLCommonDomain.setSparklinesStreams(modelHandle,portHandle,selectedSignals);
        else
            existingSignals=get_param(portHandle,'BusSignalsForValueLabels');

            if isempty(selectedSignals)

                set_param(portHandle,'ShowValueLabel','off');
                set_param(portHandle,'BusSignalsForValueLabels',{});
            else
                if isequal(selectedSignals,existingSignals)
                    set_param(portHandle,'ShowValueLabel','on');
                    return;
                end

                set_param(portHandle,'BusSignalsForValueLabels',selectedSignals);
                pvdStatus=get_param(portHandle,'ShowValueLabel');
                if(strcmp(pvdStatus,'on'))

                    set_param(portHandle,'ShowValueLabel','off');
                end
                set_param(portHandle,'ShowValueLabel','on');
            end
        end
    end

    if isa(SigHierDialog.Dialog,'DAStudio.Dialog')
        delete(SigHierDialog.Dialog);
    end
end
