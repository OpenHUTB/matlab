function updatedData=updateData(~,data,indx2remove)


    c=0;
    updatedData=data;

    for indx=1:length(data.SimulinkVariantObject)
        if all(indx~=indx2remove)
            c=c+1;
            updatedSimulinkVariantObject{c}=data.SimulinkVariantObject{indx};

        end
    end

    if(c<1)
        updatedSimulinkVariantObject=cell(0);
    end

    updatedData.SimulinkVariantObject=updatedSimulinkVariantObject;

    if updatedData.NumSimulinkVariantObjects>c
        updatedData.NumSimulinkVariantObjects=c;
    end
end


