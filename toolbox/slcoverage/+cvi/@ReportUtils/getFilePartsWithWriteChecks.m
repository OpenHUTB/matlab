function[path,fileName,ext,msg]=getFilePartsWithWriteChecks(filename,neededExt,varargin)




    ui=false;
    if~isempty(varargin)
        ui=varargin{1};
    end
    path='';
    msg='';

    fullFilename=cvi.ReportUtils.appendFileExtAndPath(filename,neededExt);
    [filePath,fileName,ext]=fileparts(fullFilename);
    if~isempty(filePath)&&~exist(filePath,'dir')
        msg=message('Slvnv:simcoverage:ioerrors:FolderDoesNotExist');
        msg=checkErr(msg,ui,false);
        return;
    end

    if~strcmpi(ext,neededExt)
        msg=message('Slvnv:simcoverage:ioerrors:BadExtensionWrite',neededExt);
        msg=checkErr(msg,ui,true);
        ext=neededExt;
        return;
    end

    [~,userWrite]=cvi.ReportUtils.checkUserWrite(filePath);
    if~userWrite
        msg=message('Slvnv:simcoverage:ioerrors:ReadOnlyDirectory');
        msg=checkErr(msg,ui,false);
        return;
    end

    if exist(fullFilename,'file')
        existingFullFilename=which(fullFilename);
        [existingfilePath,~,~,]=fileparts(existingFullFilename);

        if strcmpi(existingfilePath,pwd)
            [~,userWrite]=cvi.ReportUtils.checkUserWrite(existingFullFilename);
            if~userWrite
                msg=message('Slvnv:simcoverage:ioerrors:ReadOnlyFile');
                msg=checkErr(msg,ui,false);
                return;
            end
        end
    end
    path=get_full_path(filePath);

    function msg=checkErr(msg,ui,throwWarn)
        if~ui
            if throwWarn
                warning(msg);
            else
                error(msg);
            end
            msg='';
        end


        function fullPath=get_full_path(relPath)

            if isempty(relPath)
                fullPath=pwd;
                return;
            end

            if ispc
                if(strcmp(relPath(2:3),':\'))
                    fullPath=relPath;
                else
                    if relPath(1)=='\'
                        if relPath(2)=='\'
                            fullPath=relPath;
                        else
                            currDir=pwd;
                            fullPath=[currDir(1:2),relPath];
                        end
                    else
                        fullPath=fullfile(pwd,relPath);
                    end
                end
            else
                if(relPath(1)=='/')
                    fullPath=relPath;
                else
                    fullPath=fullfile(pwd,relPath);
                end
            end
