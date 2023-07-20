function jsonStruct=publishStaSignals(jsonStructStr,appInstanceID,varargin)



    outdata=jsondecode(jsonStructStr);



    for kStruct=1:length(outdata.arrayOfListItems)
        if~isnumeric(outdata.arrayOfListItems(kStruct).TreeOrder)
            outdata.arrayOfListItems(kStruct).TreeOrder=...
            str2double(outdata.arrayOfListItems(kStruct).TreeOrder);
        end


    end

    if~isempty(varargin)&&~isempty(varargin{1})

        allJson=varargin{1};
        startingTreeOrder=allJson{end}.TreeOrder;

        repoUtil=starepository.RepositoryUtility;

        for kStruct=1:length(outdata.arrayOfListItems)
            outdata.arrayOfListItems(kStruct).TreeOrder=startingTreeOrder+kStruct;
            setMetaDataByName(repoUtil,str2double(outdata.arrayOfListItems(kStruct).ID),'TreeOrder',startingTreeOrder+kStruct);

        end

    end



    fullChannel=sprintf('/sta%s/%s',appInstanceID,'SignalAuthoring/UIModelData');


    message.publish(fullChannel,outdata);


    if~iscell(outdata.arrayOfListItems)
        numSignals=length(outdata.arrayOfListItems);
        jsonStruct=cell(1,numSignals);


        for k=1:length(jsonStruct)
            jsonStruct{k}=outdata.arrayOfListItems(k);

            jsonStruct{k}.ID=str2double(jsonStruct{k}.ID);

            if~strcmpi(jsonStruct{k}.ParentID,'input')

                jsonStruct{k}.ParentID=str2double(jsonStruct{k}.ParentID);

            end
        end
    else
        jsonStruct=outdata.arrayOfListItems;
    end
end