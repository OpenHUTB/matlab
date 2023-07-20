classdef DataManager<handle



    properties
        DataStore=timetable();
    end

    methods

        function storeData(obj,topic,value)

            obj.DataStore=[obj.DataStore;
            timetable(datetime('now'),string(topic),string(value),'VariableNames',{'Topic','Data'})];
        end

        function data=read(obj,topic)





            drawnow;

            data=timetable();

            topicLogicalIdx=getTopicLogicalIdx(obj.DataStore,topic);
            if(~isempty(topicLogicalIdx))

                data=obj.DataStore(topicLogicalIdx,:);


                data=sortrows(data,{'Time','Topic'});

                obj.DataStore(topicLogicalIdx,:)=[];
            end
        end

        function data=peek(obj,topic)





            drawnow;

            dataTemp=timetable();


            topicLogicalIdx=getTopicLogicalIdx(obj.DataStore,topic);
            if(~isempty(topicLogicalIdx))

                dataTemp=obj.DataStore(topicLogicalIdx,:);
            end


            if isempty(dataTemp)
                data=dataTemp;
                warnState=warning('backtrace','off');
                warning(message("icomm_mqtt:DataManager:NoDataToPeek",topic));
                warning(warnState);
                return
            end


            catArray=categorical(dataTemp.Topic);
            catSet=categories(catArray);



            data=timetable();
            for i=1:length(catSet)
                rows=dataTemp.Topic==catSet{i};
                dataCatI=dataTemp(rows,:);
                dataCatI=sortrows(dataCatI);
                data=[data;dataCatI(end,:)];
            end



            if~isempty(data)
                data=sortrows(data,{'Time','Topic'});
            end
        end

        function flush(obj,topic)





            drawnow;


            topicLogicalIdx=getTopicLogicalIdx(obj.DataStore,topic);
            if(~isempty(topicLogicalIdx))


                obj.DataStore(topicLogicalIdx,:)=[];
            end
        end
    end
end

function topicLogicalIdx=getTopicLogicalIdx(dataStore,topic)



    if isempty(dataStore)
        topicLogicalIdx=[];
        return
    end


    topicLogicalIdx=dataStore.Topic==topic;

    if any(topicLogicalIdx)
        return
    end



    if contains(topic,'+')
        topics=strsplit(topic,'+');
        topicIndex=regexp(dataStore.Topic,[topics{1},'\w*',topics{2}]);
        if isnumeric(topicIndex)
            topicIndex={topicIndex};
        end

        topicLogicalIdx=cellfun(@(x)~isempty(x),topicIndex,'UniformOutput',true);

    elseif contains(topic,'#')
        topicOfinterest=strsplit(topic,'#');
        topicLogicalIdx=contains(dataStore.Topic,topicOfinterest{1});
    end

end