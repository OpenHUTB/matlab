function errmsg=validateChanges(this,dlg)








    errmsgid=dlg.getWidgetValue('ErrMsgId');
    if~strcmpi(errmsgid,'N/A')
        if regexpi(errmsgid,'Undefined$')
            errmsg=getString(message([errmsgid,'_a'],...
            this.Block.getFullName));
        elseif regexpi(errmsgid,'HarmsTonesUnequal$')
            errmsg=getString(message([errmsgid,'_a'],...
            this.Block.getFullName,dlg.getWidgetValue('Tones'),...
            dlg.getWidgetValue('Harmonics')));
        elseif regexpi(errmsgid,'Tones')
            errmsg=getString(message([errmsgid,'_a'],...
            this.Block.getFullName,dlg.getWidgetValue('Tones')));
        elseif regexpi(errmsgid,'Harms')
            errmsg=getString(message([errmsgid,'_a'],...
            this.Block.getFullName,dlg.getWidgetValue('Harmonics')));
        else
            errmsg='';
        end
    else
        errmsg='';
    end