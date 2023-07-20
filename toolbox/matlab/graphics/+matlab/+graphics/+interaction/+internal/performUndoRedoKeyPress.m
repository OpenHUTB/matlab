function consumekey=performUndoRedoKeyPress(fig,modifier,key)
    consumekey=false;
    if strcmpi(modifier,'control')
        switch(key)
        case 'z'
            hUndoMen=findall(fig,'Type','UIMenu','Tag','figMenuEditUndo');
            if isempty(hUndoMen)

                uiundo(fig,'execUndo');
            end
            consumekey=true;
        case 'y'
            hRedoMen=findall(fig,'Type','UIMenu','Tag','figMenuEditRedo');
            if isempty(hRedoMen)

                uiundo(fig,'execRedo');
            end
            consumekey=true;
        end
    end