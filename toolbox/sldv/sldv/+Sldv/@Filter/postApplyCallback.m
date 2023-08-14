function[status,errstr]=postApplyCallback(this,dlg)




    try
        status=true;
        errstr='';

        if this.hasUnappliedChanges
            this.hasUnappliedChanges=false;
            this.lastFilterElement={};

            this.updateResults;
        end
        dlg.refresh;
    catch MEx
        status=false;
        errstr=getString(message(MEx.identifier));
    end
end
