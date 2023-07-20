



function commentCB(userdata,cbinfo)
    blockHandles=SLStudio.Utils.getSelectedBlockHandles(cbinfo);
    numBlocks=length(blockHandles);
    editor=[];
    editorDomain=[];
    if slfeature('SelectiveParamUndoRedo')>0
        if(numBlocks>0)
            editor=cbinfo.studio.App.getActiveEditor;
            if(~isempty(editor))
                editorDomain=editor.getStudio.getActiveDomain();
            end
        end
    end

    if~isempty(editorDomain)

        editorDomain.createParamChangesCommand(...
        editor,...
        'Simulink:studio:BlockCommenting',...
        DAStudio.message('Simulink:studio:BlockCommenting'),...
        @CommentCB_Impl,...
        {userdata,cbinfo,editorDomain},...
        false,...
        false,...
        false,...
        true,...
        true);
    else
        CommentBlocksCB_Impl(cbinfo,[]);
    end
end

function[success,noop]=CommentCB_Impl(userdata,cbinfo,editorDomain)
    success=true;
    noop=false;%#ok
    blockHandles=SLStudio.Utils.getSelectedBlockHandles(cbinfo);
    errBlkH=[];
    numBlocks=length(blockHandles);

    desiredValue='off';
    if~isempty(cbinfo.EventData)

        if cbinfo.EventData==1
            if strcmp(userdata,'out')
                desiredValue='on';
            elseif strcmp(userdata,'through')
                desiredValue='through';
            end
        end
    else

        [~,commOut,commThrough]=loc_getCommentedStateOfBlocks(cbinfo);
        if strcmp(userdata,'out')
            if commOut~=numBlocks
                desiredValue='on';
            end
        elseif strcmp(userdata,'through')
            if commThrough~=numBlocks
                desiredValue='through';
            end
        end
    end


    for index=1:numBlocks
        blockH=blockHandles(index);
        if~isempty(editorDomain)
            editorDomain.paramChangesCommandAddObject(blockH);
        end
        try
            set_param(blockH,'Commented',desiredValue);
        catch e
            errBlkH(end+1)=blockH;%#ok
            msg=e.message;
        end
    end


    if length(errBlkH)==1
        dp=DAStudio.DialogProvider;
        dp.warndlg(msg,'',true);
    elseif~isempty(errBlkH)
        if strcmp(desiredValue,'off')
            tag='Simulink:studio:UncommentNotSupported';
        elseif strcmp(desiredValue,'on')
            tag='Simulink:studio:CommentNotSupported';
        else
            tag='Simulink:studio:CommentThruNotSupported';
        end
        message=[DAStudio.message(tag),newline,newline];
        for index=1:length(errBlkH)
            message=[message,strrep(getfullname(errBlkH(index)),sprintf('\n'),' '),sprintf('\n')];%#ok
        end
        dp=DAStudio.DialogProvider;
        dp.warndlg(message,'',true);
    end

    noop=length(errBlkH)==numBlocks;
end
function[uncomm,commOut,commThru]=loc_getCommentedStateOfBlocks(cbinfo)
    blockHandles=SLStudio.Utils.getSelectedBlockHandles(cbinfo);

    uncomm=0;commOut=0;commThru=0;

    for i=1:length(blockHandles)
        switch get_param(blockHandles(i),'Commented')
        case 'off'
            uncomm=uncomm+1;
        case 'on'
            commOut=commOut+1;
        case 'through'
            commThru=commThru+1;
        end
    end
end


