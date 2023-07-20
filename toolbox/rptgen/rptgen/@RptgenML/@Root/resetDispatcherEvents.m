function resetDispatcherEvents(this)





    if(~isempty(this.Editor)&&isa(this.Editor,'DAStudio.Explorer'))

        this.Editor.setDispatcherEvents(...
        {'HierarchyChangedEvent',...
        'FocusChangedEvent',...
        'ListChangedEvent',...
        'PropertyChangedEvent'});





    end
