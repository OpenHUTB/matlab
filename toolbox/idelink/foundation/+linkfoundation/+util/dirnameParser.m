function ofile=dirnameParser(h,ifile)







    if~ischar(ifile),
        error(message('ERRORHANDLER:autointerface:InvalidNonCharDirName'));
    elseif isempty(ifile),
        error(message('ERRORHANDLER:autointerface:InvalidEmptyDirName'));
    end

    ifile=strtrim(ifile);
    fpath=fileparts(ifile);

    if isempty(fpath),





        try
            idePath=cd(h);
            ofile=fullfile(idePath,ifile);
            if DirExists(ofile),
                return;
            end
        catch


        end


        ofile=which(ifile);
        if~isempty(ofile),
            return;
        end



        DAStudio.error('ERRORHANDLER:autointerface:FileDoesNotExistOnIdeAndMlPaths',ifile);

    elseif(ispc()&&...
        (~isempty(strfind(ifile,':'))||...
        strcmp(ifile(1:2),'\\')||...
        strcmp(ifile(1:2),'//'))),






        ofile=ifile;
        if~DirExists(ofile),
            DAStudio.error('ERRORHANDLER:autointerface:FileDoesNotExistOnPath',ifile);
        end
    elseif(~ispc()&&(ifile(1)=='/')),





        ofile=ifile;
        if~DirExists(ofile),
            DAStudio.error('ERRORHANDLER:autointerface:FileDoesNotExistOnPath',ifile);
        end
    else





        try
            idePath=cd(h);
            ofile=fullfile(idePath,ifile);
            if DirExists(ofile),
                return;
            else
                DAStudio.error('ERRORHANDLER:autointerface:FileDoesNotExistOnIdePath',ifile);
            end
        catch


            DAStudio.error('ERRORHANDLER:autointerface:FileDoesNotExist',ifile);
        end

    end


    function resp=DirExists(ofile)
        resp=(exist(ofile,'file')==7);


