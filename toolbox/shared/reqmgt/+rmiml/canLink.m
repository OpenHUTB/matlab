function[result,fPath]=canLink(bookmarkStr,inUI)






    if nargin<2
        inUI=false;
    end

    fPath='';

    if isempty(bookmarkStr)
        result=false;

    elseif ischar(bookmarkStr)
        [fPath,remainder]=strtok(bookmarkStr,'|');
        if isempty(remainder)
            result=rmiml.isSupportedFile(fPath);
        elseif~isempty(regexp(remainder,'\|\d+\-\d+','once'))||...
            ~isempty(regexp(remainder,'\|\d+\.\d+','once'))
            result=rmiml.isSupportedFile(fPath);
        else
            result=false;
        end
    else
        result=false;
    end

    if~result

        if inUI
            warndlg(...
            getString(message('Slvnv:rmiml:CodeTraceabilitySupport')),...
            getString(message('Slvnv:rmiml:CodeTraceability')));
        end

    elseif com.mathworks.services.mlx.MlxFileUtils.isMlxEnabled()



        if~isempty(regexp(bookmarkStr,'\.mlx$','once'))
            result=false;
            if inUI
                errordlg(...
                getString(message('Slvnv:rmiml:MlxNotSupportedIn14b')),...
                getString(message('Slvnv:rmiml:MlxNotSupported')),'modal');
            end
        end
    end
end


