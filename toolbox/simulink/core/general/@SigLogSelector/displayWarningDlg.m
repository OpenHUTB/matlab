function displayWarningDlg(msgId,msg,~,errorType)





    if nargin<3
        errorType='warning';
    end


    if strcmp(errorType,'error')
        title=DAStudio.message(...
        'Simulink:Logging:SigLogDlgErrorTitle');
    else
        title=DAStudio.message(...
        'Simulink:Logging:SigLogDlgWarningTitle');
    end



    me=SigLogSelector.getExplorer;
    if isempty(me)
        me.isTesting=true;
    end


    dlg=[];
    switch errorType

    case{'error'}

        if me.isTesting
            ex=MException(msgId,msg);
            throw(ex);
        else
            dlg=errordlg(msg,title,'modal');
        end

    otherwise

        if me.isTesting
            warning(msgId,msg);
        else
            dlg=warndlg(msg,title,'modal');
        end

    end



    if~isempty(dlg)
        if~isempty(me)&&~me.isTesting&&~isstruct(me)


            idxToRemove=[];
            for idx=1:length(me.cachedWarningDlgs)
                if~isgraphics(me.cachedWarningDlgs(idx))
                    idxToRemove=[idxToRemove,idx];%#ok<AGROW>
                end
            end
            if~isempty(idxToRemove)
                me.cachedWarningDlgs(idxToRemove)=[];
            end


            if isgraphics(dlg)
                if isempty(me.cachedWarningDlgs)
                    me.cachedWarningDlgs=double(dlg);
                else
                    me.cachedWarningDlgs(end+1)=double(dlg);
                end
            end

        end
    end

end


