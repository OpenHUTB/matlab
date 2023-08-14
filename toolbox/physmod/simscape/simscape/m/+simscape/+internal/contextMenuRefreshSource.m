function schema=contextMenuRefreshSource(cbInfo)
    schema=sl_action_schema;
    schema.label='&Refresh source code';
    schema.tag='Simscape:RefreshSource';
    schema.callback=@lRefreshSource;
    schema.state='Hidden';
    schema.statustip=...
    'Refresh Simscape source file for the selected block in MATLAB Editor.';
    if(numel(cbInfo.getSelection)==1)&&...
        strcmpi(cbInfo.getSelection.Type,'block')
        showRefresh=nesl_private('nesl_choosesourcewidget');
        if showRefresh(cbInfo.getSelection.Handle)
            if lIsInLockedLibrary(cbInfo.getSelection.Handle)
                schema.state='Disabled';
            else
                schema.state='Enabled';
            end
        end
    end
end


function lRefreshSource(cbInfo)
    simscape.refreshBlockComponent(cbInfo.getSelection.Handle);
end

function result=lIsInLockedLibrary(block)
    rootModel=bdroot(block);
    result=bdIsLibrary(rootModel)&&...
    strcmp(get_param(rootModel,'Lock'),'on');
end
