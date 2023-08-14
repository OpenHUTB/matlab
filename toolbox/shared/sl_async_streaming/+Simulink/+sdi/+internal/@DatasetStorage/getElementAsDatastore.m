function obj=getElementAsDatastore(this,varargin)




    fullFlushIfNeeded(this);

    obj=matlab.io.datastore.SimulationDatastore.empty;
    if~isempty(this.DatasetRef)
        obj=getElementAsDatastore(this.DatasetRef,varargin{:});
    end
end
