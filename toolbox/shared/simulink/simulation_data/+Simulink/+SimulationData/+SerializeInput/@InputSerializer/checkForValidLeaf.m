function checkForValidLeaf(this,element,~,nodeIdx,isElementOfBus)




    isStructWSigsField=false;
    if isstruct(element)
        isStructWSigsField=isfield(element,'signals');
    end
    if~isa(element,'timeseries')&&...
        ~isa(element,'matlab.io.datastore.SimulationDatastore')&&...
        ~isa(element,'timetable')&&...
        ~isStructWSigsField&&...
        ~(isa(element,'matlab.io.datastore.MDFDatastore')&&...
        isequal(this.slFeatures.slLoadMdf,1))&&...
        ~isa(element,'matlab.io.datastore.ConcolicDatastore')&&...
        ~(isa(element,'matlab.io.datastore.TabularDatastore')&&...
        isequal(this.slFeatures.slLoadTimetableDatastore,1))&&...
        ~isa(element,'matlab.io.datastore.sdidatastore')
        if nodeIdx~=1||...
            ~this.is_valid_numeric_dataset_element(element)
            if isnumeric(element)&&iscolumn(element)&&~isElementOfBus
                this.throwError(...
                false,...
'Simulink:SimInput:LoadingNonFcnCallInportDataTypeMismatch'...
                );
            else
                this.throwErrorForInvalidElementContents;
            end
        end
    end
end


