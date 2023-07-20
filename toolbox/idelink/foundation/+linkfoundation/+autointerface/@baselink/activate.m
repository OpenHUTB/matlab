function activate(h,filename,filetype)

















    narginchk(3,3);
    linkfoundation.util.errorIfArray(h);

    if~ischar(filetype),
        error(message('ERRORHANDLER:autointerface:InvalidNonCharFileType'));
    end



    name=filename;
    if isempty(name)
        fpath='';fname='';fext='';
    else
        [fpath,fname,fext]=fileparts(name);
    end

    if strcmpi(filetype,'buildcfg')


        if~ischar(filename),
            error(message('ERRORHANDLER:autointerface:InvalidNonCharBuildConfig'));
        end

        if~isempty(fext)||~isempty(fpath)
            error(message('ERRORHANDLER:autointerface:InvalidBuildConfigValue'));
        end

    else


        if~ischar(filename),
            DAStudio.error('ERRORHANDLER:autointerface:InvalidNonCharFilename');
        end


        if isempty(filetype)&&~isempty(fext)
            filetype=ide_getFileTypeBasedOnExt(h,fext);
        end


        switch(lower(filetype))
        case 'project'
            pjtExt=ide_getFileExt(h,'project');
            if(isempty(fext))
                name=fullfile(fpath,[fname,pjtExt]);
            elseif(~strcmpi(fext,pjtExt))
                error(message('ERRORHANDLER:autointerface:InvalidProjectExt',pjtExt));
            end
        case 'text',

        otherwise,
            DAStudio.error('ERRORHANDLER:autointerface:UnrecognizedFileType',filetype);
        end


        try
            name=linkfoundation.util.filenameParser(h,name);
        catch parserException
            if strfind(parserException.identifier,'FileDoesNotExist')
                MSLDiagnostic('ERRORHANDLER:autointerface:FileDoesNotExist',filename).reportAsWarning;
                return;
            elseif strfind(parserException.identifier,'InvalidFilename')
                DAStudio.error('ERRORHANDLER:autointerface:InvalidFileName','activate');
            else
                rethrow(parserException);
            end
        end

    end

    switch lower(filetype)
    case 'project',
        h.mIdeModule.ActivateProject(name);
    case 'buildcfg',
        h.mIdeModule.ActivateConfig(name);
    otherwise,
        if~isempty(strfind(name,'~'))
            error(message('ERRORHANDLER:autointerface:InvalidTildeInFilename'));
        end
        h.mIdeModule.ActivateText(name);
    end


