function unlocked=isUnlocked(modelH,interactive)

    isLocked=strcmpi(get_param(modelH,'lock'),'on');
    if isLocked
        unlocked=0;
        if interactive
            selection=questdlg(...
            getString(message('Slvnv:rmisl:isUnlocked:LibraryIsLocked_content')),...
            getString(message('Slvnv:rmisl:isUnlocked:LibraryIsLocked')),...
            getString(message('Slvnv:rmisl:isUnlocked:Unlock')),...
            getString(message('Slvnv:rmisl:isUnlocked:Cancel')),...
            getString(message('Slvnv:rmisl:isUnlocked:Unlock')));
            if isempty(selection)
                selection=getString(message('Slvnv:rmisl:isUnlocked:Cancel'));
            end
            if strcmp(selection,getString(message('Slvnv:rmisl:isUnlocked:Unlock')))
                set_param(modelH,'lock','off');
                unlocked=1;
            end
        end
    else
        unlocked=1;
    end
end

