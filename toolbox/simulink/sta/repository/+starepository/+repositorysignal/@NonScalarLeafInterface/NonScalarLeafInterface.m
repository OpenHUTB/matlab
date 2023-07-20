classdef NonScalarLeafInterface<starepository.repositorysignal.LeafSignalInterface



    properties

    end

    methods


        function editSignalData(obj,rootSigID,sigID,newDataType,dataToSet)


            signalType=getMetaDataByName(obj.repoUtil,rootSigID,'SignalType');
            WAS_REAL=strcmp(signalType,getString(message('sl_sta_general:common:Real')));

            oldDataType=getMetaDataByName(obj.repoUtil,sigID,'DataType');
            oldRootDataType=getMetaDataByName(obj.repoUtil,rootSigID,'DataType');

            if~isempty(oldRootDataType)
                oldDataType=oldRootDataType;
            end




            if strcmp(oldDataType,newDataType)
                makeDataEdits(obj,rootSigID,WAS_REAL,dataToSet);
            else


                try

                    doCast(obj,rootSigID,WAS_REAL,newDataType);

                catch ME_CAST_DT %#ok<NASGU>

                end

                try
                    if strcmpi(newDataType,'boolean')
                        newDataType='logical';
                    end
                    fcnHandle=str2func(newDataType);
                    dataToSet.Data=fcnHandle(dataToSet.Data);
                    dataToSet.Time=dataToSet.Time;
                    makeDataEdits(obj,rootSigID,WAS_REAL,dataToSet);
                catch ME_SETDATA_AFTER_CAST %#ok<NASGU>

                end
            end


        end


        function dataToSet=getDataForSetByID(obj,signalIDForData)





            dataToSet=getDataForSetByIDImpl(obj,signalIDForData);
        end


        function dataOut=getDataForSetByIDImpl(obj,signalIDForData)





            kidDbId=obj.repoUtil.getChildrenIds(signalIDForData);
            N_KIDS=length(kidDbId);
            kidValues(N_KIDS).dataValues=[];

            for kKiddo=1:N_KIDS
                [timeValues,kidValues(kKiddo).dataValues]=obj.repoUtil.getSignalTimeAndDataValuesNDim(kidDbId(kKiddo),signalIDForData);
            end

            dataOut.Time=timeValues;
            dataOut.Data=[kidValues(:).dataValues];
        end


        function dataVal=getADataValue(obj,rootSigID)




            kidDbId=obj.repoUtil.getChildrenIds(rootSigID);

            [~,Vals]=obj.repoUtil.getSignalTimeAndDataValues(kidDbId(1));
            dataVal=Vals(1);
        end


        function addDataPointByTime(obj,rootSigID,timeValues,dataValues)
            replotIDs=getPlottableSignalIDs(obj,rootSigID);
            [numPoints,numCol]=size(timeValues);
            for k=1:numPoints
                for kID=1:length(replotIDs)

                    addDataPointAtTime(obj.repoUtil,replotIDs(kID),timeValues(k),dataValues(k,kID));
                end
            end

        end
    end
end

