classdef DataArray<slwebwidgets.tableeditor.messagemanager.BaseMessageManager





    methods

        function bool=isSupported(obj,signalID)
            repoUtil=starepository.RepositoryUtility();
            dataFormat=getMetaDataByName(repoUtil,signalID,'dataformat');
            bool=contains(dataFormat,'dataarray');
        end


        function[msgOut,errMsg]=constructMessage(obj,signalID)

            errMsg=[];
            repoUtil=starepository.RepositoryUtility();


            childIDsInOrder=getChildrenIDsInSiblingOrder(repoUtil,signalID);


            [timeValues,dataValues]=getSignalTimeAndDataValues(...
            repoUtil,childIDsInOrder(1));


            msg.signaltime=timeValues;
            msg.signaldata0=slwebwidgets.tableeditor.makeJsonSafe(dataValues);

            NUM_KIDS=length(childIDsInOrder);

            for k=1:NUM_KIDS-1

                [~,dataValues]=getSignalTimeAndDataValues(...
                repoUtil,childIDsInOrder(k+1));

                msg.(['signaldata',num2str(k)])=slwebwidgets.tableeditor.makeJsonSafe(dataValues);
            end

            for kTime=1:length(msg.signaltime)

                tmpCell=cell(1,NUM_KIDS+1);
                tmpCell{1}=msg.signaltime(kTime);

                for kChild=1:NUM_KIDS
                    tmpCell{kChild+1}=msg.(['signaldata',num2str(kChild-1)]){kTime};
                end

                msgOut.signaldatavalues{kTime}=tmpCell;
            end
        end
    end

end
