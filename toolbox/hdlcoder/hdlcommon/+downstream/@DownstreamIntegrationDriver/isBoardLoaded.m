function ret=isBoardLoaded(obj)



    ret=~isempty(obj.hTurnkey)&&~isempty(obj.hTurnkey.hBoard);
end
