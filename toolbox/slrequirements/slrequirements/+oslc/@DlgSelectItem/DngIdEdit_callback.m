function DngIdEdit_callback(this,dlg)


    origId=this.id;
    givenId=strtrim(dlg.getWidgetValue('DngIdEdit'));
    givenId=strrep(givenId,' ','');
    if isempty(givenId)
        this.id=[];

    elseif~all((givenId>=double('0')&givenId<=double('9'))|givenId==double(','))

        errordlg(getString(message('Slvnv:oslc:PleaseSelectValidId')));
        this.id=[];
        dlg.setWidgetValue('DngIdEdit','');

    else
        this.id=sscanf(givenId,'%d,');
        dlg.setEnabled('DngBacklinkCheckbox',true);
    end

    if isempty(origId)||origId(1)~=this.id(1)
        oslc.selection('','');
    end
end
