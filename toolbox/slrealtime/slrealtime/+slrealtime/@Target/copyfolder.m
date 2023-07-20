function copyfolder(this,srcfolder,destfolder)






    narginchk(2,3);
    srcfolder=locRemoveTrailingFilesep(srcfolder);
    if nargin<3
        sparts=strsplit(srcfolder,"/");
        destfolder=fullfile(pwd,sparts{end});
    else
        destfolder=locRemoveTrailingFilesep(destfolder);
    end
    if~this.isfolder(srcfolder)
        error(message('slrealtime:target:folderNotFound',srcfolder));
    end

    this.receiveFile(srcfolder,destfolder);
end

function dir=locRemoveTrailingFilesep(dir)
    dir=convertStringsToChars(dir);
    if dir(end)=='\'||dir(end)=='/'
        dir=dir(1:end-1);
    end
end
