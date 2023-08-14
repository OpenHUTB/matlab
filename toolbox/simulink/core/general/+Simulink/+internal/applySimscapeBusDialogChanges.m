

function applySimscapeBusDialogChanges(blockHandle,operation)

    t=DAStudio.ToolRoot;
    dv=t.getOpenDialogs;

    for i=1:length(dv)

        if(isa(dv(i).getDialogSource,'Simulink.SLDialogSource')&&...
            isequal(dv(i).getDialogSource.getBlock.Handle,blockHandle))


            if operation
                dv(i).refresh;
            else
                dv(i).getDialogSource.closeStandaloneDialog;
            end
            break
        end

    end

end