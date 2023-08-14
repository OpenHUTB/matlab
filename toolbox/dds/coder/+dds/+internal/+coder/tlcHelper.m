function ret=tlcHelper(name,varargin)





    ret=feval(name,varargin{:});
end


function ret=cellaccess(varargin)
    array=varargin{1};
    idx=varargin{2};
    ret=strtrim(array(idx+1,:));
end


function ret=cmakefilesep(aPath)
    ret=strrep(aPath,'\','/');
end


function ret=cellpath(varargin)
    ret=cmakefilesep(cellaccess(varargin{:}));
end


function ret=len(varargin)
    if isempty(varargin{1})
        ret=0;
    else
        ret=size(varargin{1},1);
    end
end


function ret=datetime(varargin)
    ret=datestr(now);
end
