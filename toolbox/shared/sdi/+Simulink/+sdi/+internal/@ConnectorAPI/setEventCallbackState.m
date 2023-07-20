function setEventCallbackState(this,evtName,enableState)
    assert(strcmpi(evtName,'compareRunsEvent')...
    ||strcmpi(evtName,'treeSignalPropertyEvent'));
    if length(this.EventListeners)>5
        switch(evtName)
        case 'compareRunsEvent'
            if isvalid(this.EventListeners{5})
                this.EventListeners{5}.Enabled=enableState;
            end
        case 'treeSignalPropertyEvent'
            if isvalid(this.EventListeners{6})
                this.EventListeners{6}.Enabled=enableState;
            end
        end
    end
end
