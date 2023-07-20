function attribs=getDataAttributes(data)




    if isa(data,'matlab.io.datastore.SimulationDatastore')


        data=data(1).getSimImplProps();
        attribs.complexity=data.SignalAttributesData_.Complexity;
        attribs.dims=data.SignalAttributesData_.Dimension;
        attribs.ndims=numel(attribs.dims);
    else
        attribs.complexity=false;
        attribs.dims=1;
        attribs.ndims=1;
    end


    attribs.dims=int32(attribs.dims);
    attribs.ndims=int32(attribs.ndims);
end


