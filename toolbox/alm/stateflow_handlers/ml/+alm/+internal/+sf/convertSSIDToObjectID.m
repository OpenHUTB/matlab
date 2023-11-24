function objIds=convertSSIDToObjectID(ssids)


    ssids=string(ssids);
    objIds=zeros(size(ssids),'int32');

    for i=1:numel(ssids)

        ssid=ssids(i);

        try
            handle=Simulink.ID.getHandle(ssid);
            if~isempty(handle)
                if isa(handle,'Stateflow.Object')
                    objIds(i)=handle.Id;
                elseif isnumeric(handle)&&...
                    slprivate('is_stateflow_based_block',handle)
                    objIds(i)=sfprivate('block2chart',handle);
                else

                end
            end

        catch

        end
    end

end
