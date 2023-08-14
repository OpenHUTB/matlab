function[appName,varargin]=parseAppName(varargin)

    appName='sdi';
    delIdx=[];
    if nargin>1
        for idx=1:length(varargin)
            if ischar(varargin{idx})&&strcmpi(varargin{idx},'appName')
                appName=varargin{idx+1};
                delIdx=idx;
                break;
            end
        end
    end

    varargin([delIdx,delIdx+1])=[];
end

