function fileExt=getFileExt(fileType)




    narginchk(1,1);
    if isempty(fileType)
        error(message('TICCSEXT:autointerface:InvalidFileType'));
    end

    switch lower(fileType)
    case 'workspace'
        fileExt='.wks';
    case{'project','projlib','projext'}
        fileExt='.pjt';
    case 'program'
        fileExt='.out';
    case 'gel'
        fileExt='.gel';
    case 'mapfile'
        fileExt='.map';
    case 'library'
        fileExt='.lib';
    otherwise
        error(message('ERRORHANDLER:utils:InvalidFileType'));
    end
end