function idpDlgCBRedirect(dlg,idp,val,tag)



    switch tag
    case 'Size'

        if ischar(val)
            ok=idp.setSize(val);
        else
            ok=false;
        end
        size=idp.Size;
        if isempty(size)
            size=[1,1];
        end
        size=['[',num2str(size),']'];
        dlg.setWidgetValue(tag,size)
        if~ok
            error(message('Coder:common:InvalidSize',val));
        end
    otherwise
        error(message('Coder:common:UnknownTag',tag));
    end