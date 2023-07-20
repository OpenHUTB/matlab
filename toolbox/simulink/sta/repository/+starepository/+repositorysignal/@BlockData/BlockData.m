classdef BlockData<starepository.repositorysignal.RepositorySignal





    properties
        SUPPORTED_FORMATS={'loggedsignal:timeseries','datasetElement:loggedsignal:timeseries'...
        ,'loggedsignal:busstructure','loggedsignal:aobbusstructure'...
        ,'datasetElement:loggedsignal:aobbusstructure','datasetElement:loggedsignal:busstructure'...
        ,'loggedsignal:multidimtimeseries','datasetElement:loggedsignal:multidimtimeseries'...
        ,'loggedsignal:ndimtimeseries','datasetElement:loggedsignal:ndimtimeseries'};
    end


    methods

        function bool=isSupported(obj,~,dataFormat)




            bool=any(strcmpi(dataFormat,obj.SUPPORTED_FORMATS));
        end


        function[varValue,varName]=extractValue(obj,dbId,varargin)

            if isempty(dbId)
                varValue=[];
                varName=[];
                return;
            end


            varName=obj.repoUtil.getVariableName(dbId);
            varValue=createSimulinkSimulationDataSignal(obj,dbId);


            format=obj.repoUtil.getMetaDataByName(dbId,'dataformat');

            switch(lower(format))
            case 'loggedsignal:timeseries'
                extractor=starepository.repositorysignal.Timeseries();
            case lower('datasetElement:loggedsignal:timeseries')
                extractor=starepository.repositorysignal.Timeseries();
            case 'loggedsignal:busstructure'
                extractor=starepository.repositorysignal.Bus();
            case lower('datasetElement:loggedsignal:busstructure')
                extractor=starepository.repositorysignal.Bus();
            case 'loggedsignal:aobbusstructure'
                extractor=starepository.repositorysignal.AoB();
            case lower('datasetElement:loggedsignal:aobbusstructure')
                extractor=starepository.repositorysignal.AoB();
            case lower('loggedsignal:multidimtimeseries')
                extractor=starepository.repositorysignal.MultiDimensionalTimeSeries();
            case lower('datasetelement:loggedsignal:multidimtimeseries')
                extractor=starepository.repositorysignal.MultiDimensionalTimeSeries();
            case lower('loggedsignal:ndimtimeseries')
                extractor=starepository.repositorysignal.NDimensionalTimeSeries();
            case lower('datasetelement:loggedsignal:ndimtimeseries')
                extractor=starepository.repositorysignal.NDimensionalTimeSeries();
            end

            [varValue.Values,~]=extractor.extractValue(dbId,varargin{:});

        end



        function editPropStruct=updateChildrenSignalNames(obj,dbId,nameOfParent,oldParentFullName,...
            newFullNameOfParent,editPropStruct)


            format=obj.repoUtil.getMetaDataByName(dbId,'dataformat');
            idx=strfind(format,':');

            format=lower(format(idx(end)+1:end));

            switch format

            case 'timeseries'
                extractor=starepository.repositorysignal.Timeseries();
            case 'busstructure'
                extractor=starepository.repositorysignal.Bus();
            case 'aobbusstructure'
                extractor=starepository.repositorysignal.AoB();
            case 'multidimtimeseries'
                extractor=starepository.repositorysignal.MultiDimensionalTimeSeries();
            case 'ndimtimeseries'
                extractor=starepository.repositorysignal.NDimensionalTimeSeries();
            end

            editPropStruct=updateChildrenSignalNames(extractor,dbId,nameOfParent,oldParentFullName,...
            newFullNameOfParent,editPropStruct);
        end


        function jsonStruct=jsonStructFromID(obj,dbId)
            jsonStruct={};%#ok<NASGU>



            format=obj.repoUtil.getMetaDataByName(dbId,'dataformat');

            switch(lower(format))
            case 'loggedsignal:timeseries'
                extractor=starepository.repositorysignal.Timeseries();
            case lower('datasetElement:loggedsignal:timeseries')
                extractor=starepository.repositorysignal.Timeseries();
            case 'loggedsignal:busstructure'
                extractor=starepository.repositorysignal.Bus();
            case lower('datasetElement:loggedsignal:busstructure')
                extractor=starepository.repositorysignal.Bus();
            case 'loggedsignal:aobbusstructure'
                extractor=starepository.repositorysignal.AoB();
            case lower('datasetElement:loggedsignal:aobbusstructure')
                extractor=starepository.repositorysignal.AoB();
            case lower('loggedsignal:multidimtimeseries')
                extractor=starepository.repositorysignal.MultiDimensionalTimeSeries();
            case lower('datasetelement:loggedsignal:multidimtimeseries')
                extractor=starepository.repositorysignal.MultiDimensionalTimeSeries();
            case lower('loggedsignal:ndimtimeseries')
                extractor=starepository.repositorysignal.NDimensionalTimeSeries();
            case lower('datasetelement:loggedsignal:ndimtimeseries')
                extractor=starepository.repositorysignal.NDimensionalTimeSeries();
            end

            jsonStruct=jsonStructFromID(extractor,dbId);
        end


        function possibleParentID=findFirstPossibleParent(obj,idOfSignal,dbIdParent)
            possibleParentID=dbIdParent;


            format=obj.repoUtil.getMetaDataByName(idOfSignal,'dataformat');

            switch(lower(format))
            case 'loggedsignal:timeseries'
                extractor=starepository.repositorysignal.Timeseries();
            case lower('datasetElement:loggedsignal:timeseries')
                extractor=starepository.repositorysignal.Timeseries();
            case 'loggedsignal:busstructure'
                extractor=starepository.repositorysignal.Bus();
            case lower('datasetElement:loggedsignal:busstructure')
                extractor=starepository.repositorysignal.Bus();
            case 'loggedsignal:aobbusstructure'
                extractor=starepository.repositorysignal.AoB();
            case lower('datasetElement:loggedsignal:aobbusstructure')
                extractor=starepository.repositorysignal.AoB();
            case lower('loggedsignal:multidimtimeseries')
                extractor=starepository.repositorysignal.MultiDimensionalTimeSeries();
            case lower('datasetelement:loggedsignal:multidimtimeseries')
                extractor=starepository.repositorysignal.MultiDimensionalTimeSeries();
            case lower('loggedsignal:ndimtimeseries')
                extractor=starepository.repositorysignal.NDimensionalTimeSeries();
            case lower('datasetelement:loggedsignal:ndimtimeseries')
                extractor=starepository.repositorysignal.NDimensionalTimeSeries();
            end

            possibleParentID=findFirstPossibleParent(extractor,idOfSignal,possibleParentID);
        end



        function editSignalData(obj,rootSigID,sigID,newDataType,dataToSet)

            extractor=getExtractor(obj,rootSigID);

            editSignalData(extractor,rootSigID,sigID,newDataType,dataToSet);
        end


        function plottableIDs=getPlottableSignalIDs(obj,rootSigID)



            extractor=getExtractor(obj,rootSigID);

            plottableIDs=getPlottableSignalIDs(extractor,rootSigID);
        end


        function propertyUpdateIDs=getIDsForPropertyUpdates(obj,rootSigID)
            extractor=getExtractor(obj,rootSigID);

            propertyUpdateIDs=getIDsForPropertyUpdates(extractor,rootSigID);
        end


        function setDataByID(obj,rootSigID,idToOriginalValues)

            extractor=getExtractor(obj,rootSigID);
            setDataByID(extractor,rootSigID,idToOriginalValues);
        end


        function dataValue=getADataValue(obj,rootSigID)

            extractor=getExtractor(obj,rootSigID);
            dataValue=getADataValue(extractor,rootSigID);
        end


        function dataToSet=getDataForSetByID(obj,rootSigID)
            extractor=getExtractor(obj,rootSigID);
            dataToSet=getDataForSetByID(extractor,rootSigID);
        end


        function removeDataPointByTime(obj,rootSigID,timeValues)


            extractor=getExtractor(obj,rootSigID);
            removeDataPointByTime(extractor,rootSigID,timeValues);
        end


        function addDataPointByTime(obj,rootSigID,timeValues,dataValues)
            extractor=getExtractor(obj,rootSigID);
            addDataPointByTime(extractor,rootSigID,timeValues,dataValues);
        end
    end


    methods(Access='protected')


        function doCast(obj,rootSigID,WAS_REAL,newDataType)
            extractor=getExtractor(obj,rootSigID);
            cast(extractor,rootSigID,WAS_REAL,newDataType);
        end


        function extractor=getExtractor(obj,rootSigID)

            format=obj.repoUtil.getMetaDataByName(rootSigID,'dataformat');

            switch(lower(format))
            case 'loggedsignal:timeseries'
                extractor=starepository.repositorysignal.Timeseries();
            case lower('datasetElement:loggedsignal:timeseries')
                extractor=starepository.repositorysignal.Timeseries();
            case 'loggedsignal:busstructure'
                extractor=starepository.repositorysignal.Bus();
            case lower('datasetElement:loggedsignal:busstructure')
                extractor=starepository.repositorysignal.Bus();
            case 'loggedsignal:aobbusstructure'
                extractor=starepository.repositorysignal.AoB();
            case lower('datasetElement:loggedsignal:aobbusstructure')
                extractor=starepository.repositorysignal.AoB();
            case lower('loggedsignal:multidimtimeseries')
                extractor=starepository.repositorysignal.MultiDimensionalTimeSeries();
            case lower('datasetelement:loggedsignal:multidimtimeseries')
                extractor=starepository.repositorysignal.MultiDimensionalTimeSeries();
            case lower('loggedsignal:ndimtimeseries')
                extractor=starepository.repositorysignal.NDimensionalTimeSeries();
            case lower('datasetelement:loggedsignal:ndimtimeseries')
                extractor=starepository.repositorysignal.NDimensionalTimeSeries();
            case lower('groundorpartialspecifiedbus')
                extractor=starepository.repositorysignal.GroundValue();
            case lower('datasetElement:groundorpartialspecifiedbus')
                extractor=starepository.repositorysignal.GroundValue();
            end
        end
    end
end
