function ret=hardware(hardwareBoard,varargin)






















    [validBoards,fcnHandles]=ioplayback.util.getValidBoards;
    if nargin==0
        boardsToHide={'STM32 Nucleo F767ZI','TI Piccolo F2806x','TI Delfino F2837xD','Raspberry Pi'};
        ret=setdiff(validBoards,boardsToHide);
    else
        if isempty(validBoards)
            error(message('ioplayback:utils:NoSupportPackages'));
        end
        hardwareBoard=validatestring(hardwareBoard,validBoards);
        theFcnHandle=fcnHandles(startsWith(validBoards,hardwareBoard));
        theFcnHandle=theFcnHandle{1};
        if~isempty(theFcnHandle)


            ret=theFcnHandle(hardwareBoard,varargin{:});
        else
            error(message('ioplayback:utils:NotSupportedYet',hardwareBoard));
        end
    end
end

