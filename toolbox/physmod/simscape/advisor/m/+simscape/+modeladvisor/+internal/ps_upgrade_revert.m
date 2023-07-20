function ps_upgrade_revert(action,sids)












    handles=get_param(sids,'Handle');

    for i=1:numel(handles)
        lDoBlock(action,handles{i});
    end
end

function lDoBlock(action,handle)
    list=simscape.compiler.mli.internal.PSLegacyList;

    srcFile=get_param(handle,'SourceFile');

    switch action
    case 'upgrade'
        oldIdx=find(strcmp({list.oldPth},srcFile));
        if isscalar(oldIdx)
            lDisableLink(handle);

            lSwapBlock(handle,list(oldIdx).newLib,...
            list(oldIdx).newPth,...
            list(oldIdx).unitUpgrade);
        end
    case 'revert'
        newIdx=find(strcmp({list.newPth},srcFile));
        if isscalar(newIdx)


            warnId='Simulink:Commands:ParamUnknown';
            warnStat=warning('query',warnId);
            warnRevert=@()warning(warnStat.state,warnId);
            warning('off',warnId);
            try

                lSwapBlock(handle,list(newIdx).legacyLib,...
                list(newIdx).oldPth,...
                list(newIdx).unitRevert);
            catch ME
                warnRevert();
                rethrow(ME);
            end
            warnRevert();
        end
    end
end

function lSwapBlock(handle,refBlk,srcFile,params)
    if strcmp(get_param(handle,'BlockType'),'SimscapeBlock')

        set_param(handle,'ReferenceBlock',refBlk);
    end
    set_param(handle,'SourceFile',srcFile);
    for i=1:size(params,1)
        set_param(handle,params{i,1},params{i,2});
    end
end

function lDisableLink(blk)

    parent=get_param(blk,'Parent');
    parentType=get_param(parent,'Type');
    if~strcmp(parentType,'block')
        return;
    end
    linkStatus=get_param(parent,'LinkStatus');
    switch linkStatus
    case 'resolved'

        set_param(parent,'LinkStatus','inactive');
    case 'implicit'

        lDisableLink(parent);
    end
end