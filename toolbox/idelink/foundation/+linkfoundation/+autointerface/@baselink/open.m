function open(h,filename,filetype,timeout)











































    narginchk(2,4);
    linkfoundation.util.errorIfArray(h);

    if nargin==2
        filetype=[];
    end
    if isempty(filename)
        fpath='';fname='';fext='';
    else
        [fpath,fname,fext]=fileparts(filename);
    end
    if isempty(filetype)&&~isempty(fext)
        filetype=ide_getFileTypeBasedOnExt(h,fext);
    end


    switch(lower(filetype))
    case 'project'
        pjtExt=ide_getFileExt(h,lower(filetype));
        if(isempty(fext))
            filename=fullfile(fpath,[fname,pjtExt]);
        elseif(~strcmpi(fext,pjtExt))
            error(message('ERRORHANDLER:autointerface:InvalidProjectExtension',pjtExt));
        end
    otherwise,
        error(message('ERRORHANDLER:autointerface:UnrecognizedFileType',filetype));
    end


    try
        filename=linkfoundation.util.filenameParser(h,filename);
    catch parserException
        if strfind(parserException.identifier,'FileDoesNotExist')
            DAStudio.error('ERRORHANDLER:autointerface:FileDoesNotExist',filename);
            return;
        elseif strfind(parserException.identifier,'InvalidFilename')
            DAStudio.error('ERRORHANDLER:autointerface:InvalidFileName','load''/''open');
        else
            rethrow(parserException);
        end
    end


    timeoutParamOrder=4;
    if(nargin<timeoutParamOrder)
        timeout=[];
    end
    dtimeout=linkfoundation.util.checkTimeoutParam(nargin,timeoutParamOrder,timeout,h.timeout);


    dtimeoutms=dtimeout*1000;


    try
        switch lower(filetype)

        case 'project',
            IsPrjOpen=isopen(h,filename);
            if~(IsPrjOpen)
                h.mIdeModule.ClearAllRequests();
                h.mIdeModule.OpenProject(filename,0,' ',dtimeoutms);
            else
                warning(message('ERRORHANDLER:autointerface:ProjectExistsInIDE'));
            end

        otherwise

            error(message('ERRORHANDLER:autointerface:Open_InvalidFileType',filetype));
        end

    catch err
        if~h.isvisible,
            h.visible(1);
        end
        rethrow(err);
    end


