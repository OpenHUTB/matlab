function dlgStruct=getDialogSchema(this,name)





    dlgStruct=this.dlgMain(name,{
    this.dlgFormatWidget(...
    'ColSpan',[1,1],...
    'RowSpan',[1,1])
    this.dlgStylesheetWidget(...
    'ColSpan',[2,2],...
    'RowSpan',[1,1])
    },...
    'LayoutGrid',[1,2]);

    if strcmpi(name,'panel')
        dlgStruct.Type='group';

        if 1==regexp(this.Format,'dom-')
            dlgStruct.Name=getString(message('rptgen:rx_db_output:formatTemplateLabel'));
        else
            if strcmp(this.Format,'db')
                dlgStruct.Name=getString(message('rptgen:rx_db_output:formatOutputTypeLabel'));
            else
                dlgStruct.Name=getString(message('rptgen:rx_db_output:formatStylesheetLabel'));
            end
        end
    end


