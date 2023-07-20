function str=setBackupStr(h,name,i)

    if nargin==3

        if h.Mode==1
            str=DAStudio.message('configset:util:Propagating',name,floor(i*100/h.Number));
        elseif h.Mode==3
            str=DAStudio.message('configset:util:PropagatingPause',name,floor(i*100/h.Number));
        end
    else
        if isempty(h.Time)&&~h.IsPropagated

            str=DAStudio.message('configset:util:PropagationNotPerformed');
        else

            str=DAStudio.message('configset:util:PropagationPerformed',h.Time);
        end
    end
