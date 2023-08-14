function validAltPaths=validateFilePaths(alternateFilePaths)



    if iscell(alternateFilePaths)&&isempty(alternateFilePaths)
        return;
    end

    if ischar(alternateFilePaths)||~iscell(alternateFilePaths)||(iscellstr(alternateFilePaths)&&numel(alternateFilePaths)<2)...
        ||(iscell(alternateFilePaths)&&any(~cellfun(@(x)isStringPathVector(x)||isCharPath(x)||isCellCharPath(x),alternateFilePaths)))%#ok<ISCLSTR>
        error(message('vision:groundTruth:invalidAlternatePathsType'));
    end

    if iscell(alternateFilePaths)&&isstring(alternateFilePaths{1})
        alternateFilePaths=cellfun(@cellstr,alternateFilePaths,'UniformOutput',false);
    end

    if iscellstr(alternateFilePaths)%#ok<ISCLSTR>
        alternateFilePaths={alternateFilePaths};
    end

    validAltPaths=validateAlternatePaths(alternateFilePaths);
end


function validAltPaths=validateAlternatePaths(alternateFilePaths)




    numRows=numel(alternateFilePaths);
    validAltPaths={};

    for rowNum=1:numRows
        row=alternateFilePaths{rowNum};


        if regexp(row{1}(end),'[\\/]')
            row{1}(end)='';
        end

        for pathNum=2:numel(row)
            if~exist(row{pathNum})%#ok<EXIST>
                row(pathNum)=[];
            else

                if regexp(row{pathNum}(end),'[\\/]')
                    row{pathNum}(end)='';
                end
            end
        end

        if numel(row)>1
            validAltPaths{end+1}=row;%#ok<AGROW>
        end
    end
end


function tf=isStringPathVector(pth)
    tf=isstring(pth)&&isvector(pth)&&numel(pth)>1&&all(strlength(pth)>0);
end



function tf=isCellCharPath(pth)
    tf=iscell(pth)&&all(cellfun(@isCharPath,pth))&&numel(pth)>0;
end



function tf=isCharPath(pth)
    tf=ischar(pth)&&isrow(pth)&&numel(pth)>0;
end