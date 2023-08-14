



























function configs=dngGetProjectConfig(varargin)

    if nargin>0
        if mod(nargin,2)>0
            error(message('Slvnv:oslc:ConfigContextIncorrectUsage',['slreq.',mfilename,'()'],['>> help slreq.',mfilename]));
        end
        [varargin{:}]=convertStringsToChars(varargin{:});
    end


    isProjName=find(strcmpi(varargin,'project'));
    if~isempty(isProjName)
        projName=varargin{isProjName(end)+1};
        currentProj=oslc.Project.currentProject();
        if~strcmp(projName,currentProj)
            oslc.Project.currentProject(projName);
            oslc.config.mgr('refresh');
        end
    end



    isFilterName=find(strcmpi(varargin,'name'));
    if~isempty(isFilterName)
        name=varargin{isFilterName(end)+1};
        configs=oslc.config.mgr('get',name);
        return;
    end

    isFilterId=find(strcmpi(varargin,'id'));
    if~isempty(isFilterId)
        id=varargin{isFilterId(end)+1};
        configs=oslc.config.mgr('get',id);
        return;
    end



    isType=find(strcmpi(varargin,'type'));
    if~isempty(isType)
        type=varargin{isType(end)+1};
        configsArray=oslc.config.mgr(type);
    else
        configsArray=oslc.config.mgr('all');
    end

    if isempty(configsArray)
        configs=[];
    else

        configs=cell2mat(configsArray);
    end

end

