function mlfbCallback(obj,~,evt)


    pkg=evt.data;


    if obj.studio~=pkg.studio
        return;
    end

    msg=pkg.msg;
    switch msg.action
    case 'cursor'
        try
            mdl=bdroot(msg.blockPath);
            tr=RTW.TraceInfo.instance(mdl);
            if~isempty(tr)
                ts1=tr.ModifiedTimeStamp;
                ts2=get_param(mdl,'RTWModifiedTimeStamp');
                if ts1>=ts2
                    obj.publish('mlfb2code',msg);
                end
            end
        catch
        end
    end