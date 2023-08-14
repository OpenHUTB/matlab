function ccsaddsource(boardnum,procnum,srcfile)















    narginchk(3,3);

    if isempty(fileparts(srcfile)),

        fsrcfile=which(srcfile);
    else
        fsrcfile=srcfile;
    end

    if isempty(fsrcfile)||(exist(fsrcfile,'file')~=2),
        error(message('ERRORHANDLER:utils:NonExistentSourceFile',srcfile));
    end

    cc=ticcs('boardnum',boardnum,'procnum',procnum);
    cc.visible(1);
    cc.openText(srcfile);
    clear cc;
