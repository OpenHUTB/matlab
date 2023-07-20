function schema=contextMenuViewSource(cbInfo)
    schema=sl_action_schema;
    schema.label=getString(message('physmod:simscape:simscape:menus:ViewSourceCode'));
    schema.tag='Simscape:ViewSource';
    schema.callback=@lViewSource;
    schema.state='Hidden';
    schema.autoDisableWhen='Never';
    schema.statustip=...
    'View Simscape source file for the selected block in MATLAB Editor.';
    if(numel(cbInfo.getSelection)==1)&&...
        strcmpi(cbInfo.getSelection.Type,'block')
        showSourceWidget=nesl_private('nesl_showsourcewidget');
        if showSourceWidget(cbInfo.getSelection.Handle)
            schema.state='Enabled';
        end
    end
end


function lViewSource(cbInfo)
    openSource=nesl_private('nesl_opensourcefile');
    openSource(cbInfo.getSelection.Handle);
end

