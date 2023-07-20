function propagateCallback(h)




    task=[];
    if h.Mode==0||h.Mode==4
        dlg=h.Dialog;
        dlg.setEnabled('Buttons',false);


        title=getString(message('configset:util:PropagationConfirmation'));
        str=sprintf('%s\n%s',...
        getString(message('configset:util:PropagationConfirmationDescription')),...
        getString(message('configset:util:RestoreConfirmationDescription3')));
        yes=getString(message('configset:util:OK'));
        no=getString(message('configset:util:Cancel'));
        a=questdlg(str,title,yes,no,yes);

        dlg.setEnabled('Buttons',true);
        if strcmp(a,yes)
            if h.Mode==4
                h.stopProcess();
            end
            task=@h.propagate;
        end
    elseif h.Mode==3
        h.Dialog.setEnabled('Buttons',false);


        title=getString(message('configset:util:PropagationConfirmation'));
        str=sprintf('%s\n%s',...
        getString(message('configset:util:PropagationContinue')));
        cont=getString(message('configset:util:Continue'));
        startover=getString(message('configset:util:StartOver'));
        cancel=getString(message('configset:util:Cancel'));
        a=questdlg(str,title,cont,startover,cancel,cancel);

        h.Dialog.setEnabled('Buttons',true);
        if strcmp(a,cont)
            task=@h.conti;
        elseif strcmp(input,startover)
            h.stopProcess();
            task=@h.propagate;
        end
    end

    if~isempty(task)


        start(timer('TimerFcn',@(t,~)timerCallback(t,task),'StartDelay',0.1));
    end

    function timerCallback(t,task)



        task();


        stop(t);
        delete(t);
