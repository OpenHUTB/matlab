function[wasSuccessful,jsonStruct]=readSessionFileSignals(fileName,downselectstruct,appInstanceID,varargin)




    [dir,~,~]=fileparts(fileName);



    if isempty(dir)
        fileName=which(fileName);
    end



    if isempty(varargin)||isempty(varargin{1})

        treeOrderStart=0;
    else

        allJson=varargin{1};
        treeOrderStart=allJson{end}.TreeOrder;
    end



    if~isempty(varargin)&&length(varargin)>1

        treeOrderStart=varargin{2};
    end



    jsonStruct=import2Repository(fileName,downselectstruct,treeOrderStart);


    outdata.arrayOfListItems=jsonStruct;



    fullChannel=sprintf('/sta%s/%s',appInstanceID,'SignalAuthoring/UIModelData');
    message.publish(fullChannel,outdata);

    wasSuccessful=true;