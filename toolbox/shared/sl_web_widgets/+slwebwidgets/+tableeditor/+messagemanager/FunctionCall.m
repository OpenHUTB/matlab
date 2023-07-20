classdef FunctionCall<slwebwidgets.tableeditor.messagemanager.BaseMessageManager





    methods

        function bool=isSupported(obj,signalID)
            repoUtil=starepository.RepositoryUtility();
            dataFormat=getMetaDataByName(repoUtil,signalID,'dataformat');
            bool=contains(dataFormat,'functioncall');
        end


        function[msgOut,errMsg]=constructMessage(obj,signalID)
            errMsg=[];
            repoUtil=starepository.RepositoryUtility();
            [timeValues,dataValues]=getSignalTimeAndDataValues(repoUtil,signalID);


            uniqueVals=unique(dataValues);
            newDataVals=zeros(length(uniqueVals),1);


            for k=1:length(uniqueVals)

                sumOfTimeVal=cumsum(dataValues==uniqueVals(k));

                newDataVals(k)=sumOfTimeVal(end);

            end

            timeValues=uniqueVals;
            dataValues=newDataVals;


            msg.signaltime=timeValues;
            msg.signaldata=slwebwidgets.tableeditor.makeJsonSafe(dataValues);
            msg.isdataarray=false;


            for k=1:length(msg.signaltime)
                msgOut.signaldatavalues{k}={msg.signaltime(k),msg.signaldata{k}};
            end
        end
    end

end
