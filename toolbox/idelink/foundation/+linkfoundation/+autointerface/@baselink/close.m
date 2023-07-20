function close(h,filename,filetype)




























    narginchk(2,3);
    linkfoundation.util.errorIfArray(h);


    if~ischar(filename)&&~isempty(filename)
        error(message('ERRORHANDLER:autointerface:CloseProject_InvalidSecondArg'));
    end


    [filenameIsSpecified,all]=IsFilenameSpecified(filename);

    if filenameIsSpecified


        if nargin==2
            filetype=[];
        end
        [fpath,fname,fext]=fileparts(filename);
        if isempty(filetype)&&~isempty(fext)
            filetype=ide_getFileTypeBasedOnExt(h,fext);
        end


        switch(lower(filetype))
        case 'project'
            pjtExt=ide_getFileExt(h,'project');
            if(isempty(fext))
                filename=fullfile(fpath,[fname,pjtExt]);
            elseif(~strcmpi(fext,pjtExt))
                error(message('ERRORHANDLER:autointerface:InvalidProjectExt',pjtExt));
            end
        otherwise,
            error(message('ERRORHANDLER:autointerface:UnrecognizedFileType',filetype));
        end


        try
            filename=linkfoundation.util.filenameParser(h,filename);
        catch parserException
            if strfind(parserException.identifier,'FileDoesNotExist')
                MSLDiagnostic('ERRORHANDLER:autointerface:FileDoesNotExist',filename).reportAsWarning;
                return;
            elseif strfind(parserException.identifier,'InvalidFilename')
                DAStudio.error('ERRORHANDLER:autointerface:InvalidFileName','close');
            else
                rethrow(parserException);
            end
        end
    end


    if strcmpi(filetype,'project'),

        if filenameIsSpecified
            IsPrjOpen=isopen(h,fname);
            if IsPrjOpen
                h.mIdeModule.CloseAnyProject(1,filename);
            else
                warning(message('ERRORHANDLER:autointerface:ProjectNotOpen'));
            end
        else
            h.mIdeModule.CloseProject(1,all);
        end
    else
        error(message('ERRORHANDLER:autointerface:CloseProject_InvalidFileTypeOption'));
    end


    function[resp,all]=IsFilenameSpecified(filename)
        if isempty(filename)
            filename='active';
        end
        active=strcmpi(filename,'active');
        all=strcmpi(filename,'all');
        resp=~(isempty(filename)||all||active);


