function[status,errstr]=postApplyCallback(this,dlg)




    status=false;
    errstr='';

    try


        if~isempty(this.nameTag)
            this.filterName=dlg.getWidgetValue(this.nameTag);
        end
        if~isempty(this.descriptionTag)
            this.filterDescr=dlg.getWidgetValue(this.descriptionTag);
        end


        if isempty(this.fileName)||this.isUnknownFile
            this.saveFilterCallback(dlg,true);
        else
            this.save(this.fileName,true);
        end



        if~this.isUnknownFile&&~this.needSave
            this.updateResults();
        end


        if this.hasUnappliedChanges&&~this.needSave
            this.hasUnappliedChanges=false;
            this.lastFilterElement={};
        end
        dlg.refresh();

        status=true;

    catch MEx
        errstr=getString(message(MEx.identifier));
    end
