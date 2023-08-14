

function[fileLocation,fileTimeStamp]=systemFindUnique(this,fileName,fileDescription,customDiagsSuffix)

    if nargin<4
        customDiagsSuffix='';
    end


    fileLocation=dir(['**/',fileName]);


    if isempty(fileLocation)
        error('HDLReadStatistics:couldNotFindFile',['Could not find ',fileDescription,': ''',fileName,''' in the specified target directory: ''',strrep(this.targetDir,'\','\\'),'''. Please ensure that the specified target directory contains the generated file: ''',fileName,'''. ',customDiagsSuffix]);
    else

        if length(fileLocation)==1
            index=1;


        else
            [~,index]=max([fileLocation(:).datenum]);
            warning('HDLReadStatistics:multipleFiles',['Multiple instances of ',fileDescription,': ''',fileName,''' were detected in the specified target directory: ''',strrep(this.targetDir,'\','\\'),'''. Please note that the parser will use the last modified file on the path: ''',strrep(fullfile(fileLocation(index).folder,fileLocation(index).name),'\','\\'),'''.']);
        end
    end

    fileTimeStamp=fileLocation(index).datenum;
    fileLocation=fullfile(fileLocation(index).folder,fileLocation(index).name);
end