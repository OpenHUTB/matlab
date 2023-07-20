function scopesContainer=HelperCreateScopesContainer(ScopesOrModel,varargin)






























































    if isdeployed

        error(message('Spcuilib:container:ScopesContainerDeployed'));
    end

    import matlab.internal.lang.capability.Capability;
    Capability.require(Capability.LocalClient);

    if ischar(ScopesOrModel)&&~isobject(ScopesOrModel)

        Model=ScopesOrModel;
        if bdIsLoaded(Model)&&strcmp(get_param(Model,'Shown'),'on')





            Scopes=findAllScopes(Model);
        else


            open_system(Model);
            Scopes=findAllScopes(Model);
        end
    elseif iscell(ScopesOrModel)&&isobject(ScopesOrModel{1})

        Scopes=ScopesOrModel;
    else

        return;
    end
    numScopes=numel(Scopes);
    p=inputParser;

    defaultName='Scopes Container';
    defaultPosition=[320,100,800,600];
    if numScopes<=4

        defaultLayout=[numScopes,1];
    else

        possibleProducts=[1:4].'*[1:4];%#ok<NBRAK>
        [r,c]=find(possibleProducts==numScopes);
        if isempty(r)&&isempty(c)
            if mod(numScopes,2)==0

                [r,c]=find(possibleProducts==(numScopes+2));
            else

                [r,c]=find(possibleProducts==(numScopes+1));
            end
        end
        defaultLayout=[r(1),c(1)];
    end
    defaultExpandToolstrip=true;

    addRequired(p,'Scopes',@iscell)
    addParameter(p,'Name',defaultName,@ischar)
    addParameter(p,'Position',defaultPosition,@isnumeric)
    addParameter(p,'Layout',defaultLayout,@isnumeric);
    addParameter(p,'ExpandToolstrip',defaultExpandToolstrip,@islogical);

    parse(p,Scopes,varargin{:});

    if isempty(p.Results.Name)||(~ischar(p.Results.Name)&&(isscalar(p.Results.Name)))
        error(message('Spcuilib:scopes:ErrorInputMustBeString'));
    end

    if isequal(p.Results.Name,'Scopes')||isequal(p.Results.Name,'Figures')


        error(message('Spcuilib:container:DisallowScopesContainer',p.Results.Name));
    end

    scopesContainer=matlabshared.scopes.Container.getInstance(p.Results.Name);
    scopesContainer.Layout=p.Results.Layout;

    scopesContainer.Position=p.Results.Position;
    if~isobject(Scopes{1})

        for idx=1:numScopes
            scopeConfig=get_param(Scopes{idx},'ScopeConfiguration');
            scopeConfig.launchScope;
            scopesContainer.add(Scopes{idx});
        end
    else

        scopesContainer.add(Scopes);





        for idx=1:length(Scopes)
            Scopes{idx}.show;
        end
        scopesContainer.show

        scopesContainer.undockContainer;
    end
    scopesContainer.ExpandToolstrip=p.Results.ExpandToolstrip;

    function Scopes=findAllScopes(Model)

        Scopes=find_system(Model,...
        'MatchFilter',@Simulink.match.allVariants,...
        'LookUnderMasks','all',...
        'RegExp','on',...
        'BlockType','\<ArrayPlot\>|\<SpectrumAnalyzer\>|\<Scope\>');
