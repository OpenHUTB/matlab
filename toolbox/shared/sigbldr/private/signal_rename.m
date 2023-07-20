function[UD,modified]=signal_rename(UD,newLabel,currLabel,sigIdx)







    if ischar(newLabel)
        if isempty(newLabel)
            errordlg('A signal''s name cannot be empty');
            if UD.current.channel==sigIdx
                set(UD.hgCtrls.chDispProp.labelEdit,'String',currLabel);
            end
            modified=0;
            return;
        end


        UD.sbobj.groupSignalRename(sigIdx,{newLabel});
        newName=UD.sbobj.Groups(1).Signals(sigIdx).Name;

        UD=G_signal_rename(UD,sigIdx,newName);
        UD=update_undo(UD,'rename','channel',sigIdx,currLabel);
        modified=1;
    else

        modified=0;
    end
