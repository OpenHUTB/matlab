function refreshSimscapeBusDialog(blockHandle)

    t=DAStudio.ToolRoot;
    dv=t.getOpenDialogs;

    for i=1:length(dv)

        if(isa(dv(i).getDialogSource,'Simulink.SLDialogSource')&&...
            isequal(dv(i).getDialogSource.getBlock.Handle,blockHandle))

            dv(i).refresh;
            break
        end

    end

end