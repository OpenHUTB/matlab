function[status,message]=connectionelementddg_cb(dlg,action,varargin)



    if~isempty(dlg)
        h=dlg.getDialogSource;
    end

    switch action
    case 'doApply'
        h.Name=dlg.getWidgetValue('name_tag');
        h.Type=dlg.getWidgetValue('typetag');
        h.Description=dlg.getWidgetValue('description_tag');
    end

    status=true;
    message='';
