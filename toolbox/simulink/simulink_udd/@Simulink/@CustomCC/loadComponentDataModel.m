function dm=loadComponentDataModel(obj,varargin)



















    narginchk(1,2);
    if nargin>1
        componentPath=varargin{1};
    else
        componentPath='';
    end

    id=class(obj);
    configset.internal.data.MetaConfigSet.registerComponent(id,componentPath);

    loaded=configset.internal.data.MetaConfigSet.isLoaded;
    if loaded

        mcs=configset.internal.getConfigSetStaticData;
        [dm,loadComponent]=mcs.loadComponent(id,componentPath);

        if loadComponent
            layout=configset.internal.getConfigSetCategoryLayout;
            layout.loadComponent(id,componentPath);
        end
    end

    for i=1:length(obj.Components)
        subComp=obj.Components(i);
        subComp.loadComponentDataModel;
    end