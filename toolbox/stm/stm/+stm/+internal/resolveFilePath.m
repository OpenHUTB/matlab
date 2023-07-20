




function[bExists,fullPath]=resolveFilePath(pathStr,varargin)



    [dirPath,fileName,ext]=fileparts(pathStr);
    if strlength(dirPath)==0
        dirPath=pwd;
    end

    if strlength(ext)==0
        if strlength(fileName)==0

            error(message('stm:general:InvalidFile',pathStr));
        else
            if(nargin>1)
                format=varargin{1};
                switch format
                case getString(message('stm:CriteriaView:MatFormat'))
                    ext='.mat';
                case getString(message('stm:CriteriaView:ExcelFormat'))
                    ext='.xlsx';
                case getString(message('stm:CriteriaView:MLDATXFormat'))
                    ext='.mldatx';
                otherwise
                    ext=format;
                end
            else
                ext='.mat';
            end
        end
    end

    fileName=strcat(fileName,ext);

    fullPath=fullfile(dirPath,fileName);
    bExists=isfile(fullPath);
end
