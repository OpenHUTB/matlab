function ofile=filenameParser(h,ifile,resolvePath)










    if~ischar(ifile),
        error(message('ERRORHANDLER:autointerface:InvalidNonCharFilename'));
    elseif isempty(ifile),
        error(message('ERRORHANDLER:autointerface:InvalidEmptyFilename'));
    end

    if(nargin<3)
        resolvePath=true;
    end

    ifile=strtrim(ifile);
    if(~resolvePath)
        ofile=ifile;
        return;
    end

    fpath=fileparts(ifile);
    if isempty(fpath),





        try
            idePath=cd(h);
            ofile=fullfile(idePath,ifile);
            if FileExists(ofile),
                return;
            end
        catch


        end


        ofile=which(ifile);
        if~isempty(ofile),
            return;
        end



        error(message('ERRORHANDLER:autointerface:FileDoesNotExistOnIdeAndMlPaths',ifile));

    elseif(ispc()&&...
        (~isempty(strfind(ifile,':'))||...
        strcmp(ifile(1:2),'\\')||...
        strcmp(ifile(1:2),'//'))),






        ofile=ifile;
        if~FileExists(ofile),
            error(message('ERRORHANDLER:autointerface:FileDoesNotExistOnPath',ifile));
        end
    elseif(~ispc()&&(ifile(1)=='/')),





        ofile=ifile;
        if~FileExists(ofile),
            DAStudio.error('ERRORHANDLER:autointerface:FileDoesNotExistOnPath',ifile);
        end
    else





        try
            idePath=cd(h);
            ofile=fullfile(idePath,ifile);
            if FileExists(ofile),
                return;
            else
                error(message('ERRORHANDLER:autointerface:FileDoesNotExistOnIdePath',ifile));
            end
        catch


            error(message('ERRORHANDLER:autointerface:FileDoesNotExist',ifile));
        end

    end


    function resp=FileExists(ofile)
        resp=(exist(ofile,'file')==2);


