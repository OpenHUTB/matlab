function new(h,filename,filetype)













































    narginchk(2,3);
    linkfoundation.util.errorIfArray(h);

    if~ischar(filename)||isempty(filename)
        error(message('ERRORHANDLER:autointerface:New_InvalidFilename'));
    end


    if nargin==2
        filetype=[];
    end

    name=filename;
    if isempty(name)
        fpath='';fname='';fext='';
    else
        [fpath,fname,fext]=fileparts(name);
    end

    if strcmpi(filetype,'buildcfg')


        if~ischar(filename),
            DAStudio.error('ERRORHANDLER:autointerface:InvalidNonCharBuildConfig');
        end

        if~isempty(fext)||~isempty(fpath)
            DAStudio.error('ERRORHANDLER:autointerface:InvalidBuildConfigValue');
        end

    else

        if~ischar(filename),
            DAStudio.error('ERRORHANDLER:autointerface:InvalidNonCharFilename');
        end


        if isempty(filetype)&&~isempty(fext)
            filetype=ide_getFileTypeBasedOnExt(h,fext);
        end


        switch(lower(filetype))
        case{'project','projlib','projext'}
            pjtExt=ide_getFileExt(h,lower(filetype));
            if(isempty(fext))
                name=fullfile(fpath,[fname,pjtExt]);
            elseif(~strcmpi(fext,pjtExt))
                DAStudio.error('ERRORHANDLER:autointerface:InvalidProjectExtension',pjtExt);
            end
        otherwise,
            DAStudio.error('ERRORHANDLER:autointerface:UnrecognizedFileType',filetype);
        end


        if isempty(fpath)
            name=fullfile(h.cd,name);
        end

    end

    switch(lower(filetype))
    case 'project',
        h.mIdeModule.NewProject(name,0);
    case 'projlib',
        h.mIdeModule.NewProject(name,1);
    case 'projext',
        h.mIdeModule.NewProject(name,2);
    case 'buildcfg',
        h.mIdeModule.NewConfig(name);
    otherwise,
        DAStudio.error('ERRORHANDLER:autointerface:UnrecognizedFileType',filetype);
    end


