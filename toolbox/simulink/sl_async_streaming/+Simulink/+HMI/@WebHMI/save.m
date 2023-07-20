function save(this,filePath,isAutoSave,varargin)









    if~isAutoSave
        sw=warning('off','all');
        tmp=onCleanup(@()warning(sw));
        this.applyRebindingRules();
        delete(tmp);
    end
    widgetIds=locRemoveInvalidWidgetIDs(this,this.WidgetIDs,false);
    libWidgetIds=locRemoveInvalidWidgetIDs(this,this.getLibraryWidgetIdsToSave(),true);
    numWidgets=length(widgetIds);
    numLibWidgets=length(libWidgetIds);
    needsSave=false;


    if numWidgets>0
        needsSave=true;
        if nargin>3
            webhmi.Bindings=locSerialize(this,widgetIds,false,varargin{1});
        else
            webhmi.Bindings=locSerialize(this,widgetIds,false);
        end
    end


    if numLibWidgets>0
        needsSave=true;
        if nargin>3
            webhmi.LibBindings=locSerialize(this,libWidgetIds,true,varargin{1});%#ok<STRNU>
        else
            webhmi.LibBindings=locSerialize(this,libWidgetIds,true);%#ok<STRNU>
        end
    end

    if needsSave
        save(filePath,'-struct','webhmi');
    end

end

function widgetIds=locRemoveInvalidWidgetIDs(webhmiObj,widgetIds,isLibWidget)
    idxToRemove=[];
    for idx=1:length(widgetIds)
        widget=webhmiObj.getWidget(widgetIds{idx},isLibWidget);
        if isempty(widget)
            idxToRemove(end+1)=idx;%#ok<AGROW>
        end
    end

    widgetIds(idxToRemove)=[];
end

function bindings=locSerialize(webhmiObj,widgetIds,isLibWidget,varargin)
    numWidgets=length(widgetIds);
    if isLibWidget
        bindings=struct(...
        'BlockPath',cell([1,numWidgets]),...
        'ShowInitialText',cell([1,numWidgets]),...
        'Widget',cell([1,numWidgets]),...
        'Source',cell([1,numWidgets]),...
        'LibraryWidget',cell([1,numWidgets]),...
        'LibraryName',cell([1,numWidgets]));
    else
        bindings=struct(...
        'BlockPath',cell([1,numWidgets]),...
        'ShowInitialText',cell([1,numWidgets]),...
        'Widget',cell([1,numWidgets]),...
        'Source',cell([1,numWidgets]));
    end
    import Simulink.SimulationData.BlockPath
    for idx=1:numWidgets
        widget=webhmiObj.getWidget(widgetIds{idx},isLibWidget);
        if isa(widget,'Simulink.HMI.SDIScope')
            locUpdateBlockPathOfBoundSignals(webhmiObj.Model,widget);
        end
        if(isLibWidget)
            if nargin>3
                bindings(idx)=webhmiObj.serializeLibraryInstance(widgetIds{idx},varargin{1});
            else
                bindings(idx)=webhmiObj.serializeLibraryInstance(widgetIds{idx});
            end
        else
            if nargin>3
                bindings(idx)=webhmiObj.serialize(widgetIds{idx},varargin{1});
            else
                bindings(idx)=webhmiObj.serialize(widgetIds{idx});
            end
        end


        blockPath=bindings(idx).BlockPath;


        bpath=[webhmiObj.Model,'/',blockPath.getBlock(1)];
        try
            set_param(bpath,'HMISrcModelName',webhmiObj.Model);
        catch me %#ok<NASGU>

        end
    end
end

function locUpdateBlockPathOfBoundSignals(model,scopeWidget)
    boundSignals=scopeWidget.getBoundSignals();
    is=get_param(model,'InstrumentedSignals');
    if(~isempty(boundSignals)&&~isempty(is))
        for sigIdx=1:length(boundSignals)
            for isIdx=1:is.Count
                sig=is.get(isIdx);
                if isequal(boundSignals(sigIdx).SignalId,sig.UUID)
                    if~isempty(sig.CachedBlockHandle_)
                        blockPath=getfullname(sig.CachedBlockHandle_);
                    else
                        blockPath=sig.BlockPath.getBlock(1);
                    end
                    idx=strfind(blockPath,model);
                    boundSignals(sigIdx).BlockPath=...
                    blockPath(idx+length(model)+1:end);
                end
            end
        end
        scopeWidget.bind(boundSignals);
    end
end

