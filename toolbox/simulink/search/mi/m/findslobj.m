function varargout=findslobj(varargin)




    studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
    activeStudio=studios(1,1);
    activeStudioTag=activeStudio.getStudioTag();
    Action=varargin{1};
    find_slobj(Action,activeStudioTag,varargin{2:end});
end
