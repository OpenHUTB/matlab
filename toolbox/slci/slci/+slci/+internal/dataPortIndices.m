

function indices=dataPortIndices(obj)


    numInputs=numel(obj.PortHandles.Inport);

    dataPortOrder=obj.DataPortOrder;
    if strcmpi(dataPortOrder,'One-based contiguous')
        indices=1:numInputs;
    elseif strcmpi(dataPortOrder,'Zero-based contiguous')
        indices=0:numInputs-1;
    else
        try
            portIndices=slResolve(obj.DataPortIndices,get_param(obj.Parent,'handle'));
        catch
            portIndices=[];
        end

        if(isrow(portIndices))
            portIndices=portIndices';
        end
        if iscell(portIndices)
            dt=class(portIndices{1});
        else
            dt=class(portIndices(1));
        end
        if Simulink.data.isSupportedEnumClass(dt)
            portHandle=obj.PortHandles;
            numDataInports=numel(portHandle.Inport)-1;
            indices=zeros(1,numDataInports);
            for i=1:numDataInports



                if i>numel(portIndices)
                    indices(i)=0;
                elseif iscell(portIndices)


                    indices(i)=portIndices{i}(1).double();
                else
                    indices(i)=portIndices(i,1).double();
                end
            end
        else
            indices=cell2mat(portIndices);
        end
    end

end
