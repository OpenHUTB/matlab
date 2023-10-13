function fileNames = getHistoryVersionsForClonesData( path,  ...
    fileNameRegularExpession, fileExtension )

arguments
    path
    fileNameRegularExpession = '*'
    fileExtension = 'mat'
end

fileNames = {  };

if exist( path, 'dir' )
    allMatFilesInPath = dir( [ path, '/', fileNameRegularExpession, '.', fileExtension ] );
    if length( allMatFilesInPath ) >= 1
        matFilesInfo = struct2table( allMatFilesInPath );
        matFilesInfo = sortrows( matFilesInfo, 'date' );
        matFilesInfo = matFilesInfo{ :, 'name' };
        [ ~, fileNames, ~ ] = fileparts( matFilesInfo );
        if length( allMatFilesInPath ) >= 2
            fileNames = fileNames';
        else
            fileNames = { fileNames };
        end
    end
end
end


