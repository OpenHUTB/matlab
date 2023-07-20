function ret = createPath(inpath)
% 
% check input path, create it if it does not exist.

% Copyright 2014-2017 The MathWorks, Inc.
%
    if(exist(inpath,'dir'))
        ret = true;
        return;
    end
    
    exists = '';
    nonexists = [];
    tmppath = inpath;
    while(1)
        [pathstr,name,ext] = fileparts(tmppath);
        
        tmpstr = strcat(name,ext);
        if(~isempty(tmpstr))
            nonexists = [nonexists {tmpstr}];
        end
        if(exist(pathstr,'dir'))
            exists = pathstr;
            break;
        end
        
        [pathstr2,~,~] = fileparts(pathstr);
        if(strcmp(pathstr2,pathstr))
            break;
        end
        tmppath = pathstr;
    end
    nonexists = fliplr(nonexists);
    
    % creat the path
    if(~isempty(exists))
        ipath = exists;
        for k = 1 : length(nonexists)
            opath = fullfile(ipath,nonexists{k});
            [SUCCESS,~,~] = mkdir(opath);
            if(~SUCCESS)
                ret = false;
                return;
            end
            ipath = opath;
        end
    end
    
    ret = true;
    if(isempty(exists))
        ret = false;
    end
end
