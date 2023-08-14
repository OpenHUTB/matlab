function state=axesPreparation(state,varargin)




    switch state
    case 'prepare'
        parent=varargin{1};
        exportInclude=varargin{2};
        exportExclude=varargin{3};
        exportKeepVisible=varargin{4};
        state=prepareAxes(parent,exportInclude,exportExclude,exportKeepVisible);
    case 'restore'
        state=varargin{1};
        restoreAxes(state);
    end
end

function state=prepareAxes(parent,exportInclude,toHide,keepVisible)
    if~ismember(parent,exportInclude)
        exportInclude(end+1)=parent;
    end

    for idx=1:length(exportInclude)
        if isa(exportInclude(idx),'matlab.graphics.internal.export.GraphicsExportable')
            alsoHide=exportInclude(idx).getExcludedContent;
            if~isempty(alsoHide)
                toHide=[toHide(:),alsoHide(:)];
            end
        end
    end
    toHide=unique(setdiff(toHide,keepVisible));

    contentsVisible=unique(findall(toHide,'-depth',1,'ContentsVisible','on','type','axes'));

    visible=unique(findall(toHide,'-depth',1,'Visible','on'));


    state.visible=visible;
    state.contentsVisible=contentsVisible;


    set(contentsVisible,'ContentsVisible','off');
    set(visible,'Visible','off');
end

function restoreAxes(state)
    set(state.contentsVisible,'ContentsVisible','on')
    set(state.visible,'visible','on')
end