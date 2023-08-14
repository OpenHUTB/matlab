function launchEditorForBlock(block)






    if ischar(block)
        blockH=getSimulinkBlockHandle(block);
        if blockH==-1

            if ishandle(str2double(block))
                blockH=str2double(block);
            else
                error('Signal Editor block is no longer valid.');
            end
        end
    elseif ishandle(block)
        blockH=block;
    else

    end
    fullfileName=Simulink.signaleditorblock.FileUtil.getFullFileNameForBlock(blockH);
    [~,~,ext]=fileparts(fullfileName);
    if~strcmpi(ext,'.mat')
        throw(MException(message('sl_sta_editor_block:message:NotMATFile',fullfileName)));
    end
    if~exist(fullfileName,'file')&&...
        ~strcmp(fullfileName,'untitled.mat')
        throw(MException(message('sl_sta_editor_block:message:NonExistentFile',fullfileName)));
    end
    if exist(fullfileName,'file')
        map=Simulink.signaleditorblock.ListenerMap.getInstance;
        editorUIControl=map.getListenerMap(fullfileName);
        if isempty(editorUIControl)
            editorUIControl=Simulink.signaleditorblock.EditorUIControl;
            map.addListener(fullfileName,editorUIControl);
        end
        editorUIControl.showEditorUI(blockH);
    elseif strcmp(fullfileName,'untitled.mat')
        map=Simulink.signaleditorblock.ListenerMap.getInstance;
        editorUIControl=map.getListenerMap([num2str(blockH,32),'untitled.mat']);
        if isempty(editorUIControl)
            editorUIControl=Simulink.signaleditorblock.EditorUIControl;
            map.addListener([num2str(blockH,32),'untitled.mat'],editorUIControl);
        end
        editorUIControl.showUntitledEditorUI(blockH);
    else


    end
end

