function errorDialog(msgs,title)





    formattedMsgs={};
    if iscell(msgs)
        for i=1:length(msgs)
            if(ischar(msgs{i}))
                formattedMsgs{i}=['\bullet ',msgs{i}];
            end
        end
    elseif ischar(msgs)
        formattedMsgs{1}=['\bullet ',msgs];
    end

    opts.Interpreter='tex';
    opts.WindowStyle='modal';

    errordlg(formattedMsgs,title,opts);