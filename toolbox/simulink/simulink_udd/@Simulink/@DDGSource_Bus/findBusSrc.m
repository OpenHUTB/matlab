function[src]=findBusSrc(this,busStruct,signal)








    src=[];

    [signal,signalStruct]=strtok(signal,'.');

    if~isempty(busStruct)
        for i=1:length(busStruct)
            if strcmp(busStruct(i).name,signal)
                if isempty(signalStruct)
                    src=busStruct(i).src;
                    if isnumeric(src)

                        src=get_param(src,'Object');
                    end
                    return;
                else
                    subBusStruct=busStruct(i).signals;
                    src=findBusSrc(this,subBusStruct,signalStruct);
                    if~isempty(src)
                        if isnumeric(src)

                            src=get_param(src,'Object');
                        end
                        return;
                    end
                end
            end
        end
    end
end

