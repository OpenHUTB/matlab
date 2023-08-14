
function matchedfiles=recursiveDir(dirToSearch,filespec)







    validateattributes(dirToSearch,{'char'},{'nonempty'},'recursiveDir','str');
    validateattributes(filespec,{'char'},{'nonempty'},'recursiveDir','str');
    matchedfiles=processdir(dirToSearch,filespec);



    function fnamelst=processdir(dirname,type)

        fnamelst=[];
        filespec=fullfile(dirname,type);
        d=dir(filespec);
        indx=logical(cat(2,d.isdir));
        files=d(~indx);

        for i=1:length(files),
            fname=fullfile(dirname,files(i).name);
            fnamelst{end+1}=fname;%#ok<*AGROW>
        end

        dirspec=fullfile(dirname);
        d=dir(dirspec);
        indx=logical(cat(2,d.isdir));
        dirs=d(indx);
        for i=1:length(dirs)
            if strcmp(dirs(i).name,'.')||strcmp(dirs(i).name,'..')
                continue;
            end
            newdirname=fullfile(dirname,dirs(i).name);
            fnamelstx=processdir(newdirname,type);
            fnamelst=[fnamelst,fnamelstx];
        end
