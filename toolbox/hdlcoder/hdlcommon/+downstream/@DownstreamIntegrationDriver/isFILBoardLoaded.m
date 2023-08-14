function ret=isFILBoardLoaded(obj)



    ret=~isempty(obj.hFilBuildInfo)&&~isempty(obj.hFilBuildInfo.Board);
end