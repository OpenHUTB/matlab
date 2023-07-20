function hdllink_autotimescale_cb

    RunAutoTimescale=get_param(gcb,'RunAutoTimescale');



    if(strcmp(RunAutoTimescale,'on'))
        rb=get_param(gcbh,'ReferenceBlock');
        switch rb
        case 'vivadosimlib/HDL Cosimulation'
            h=hdllinkddg.CoSimBlockDialogXSI(gcbh);
        otherwise
            h=hdllinkddg.CoSimBlockDialog(gcbh);
        end
        msg=sprintf(['The simulation has been stopped because you have '...
        ,'selected to determine the timescale before simulation. '...
        ,'Restart the simulation after determining the timescale.']);
        msgh=msgbox(msg,'Note');
        uiwait(msgh);
        set_param(gcb,'RunAutoTimescale','off');

        h.AutotimescaleCb;

        set_param(gcb,'TimingScaleFactor',h.TimingScaleFactor);
        set_param(gcb,'TimingMode',h.TimingMode);

    end

end

