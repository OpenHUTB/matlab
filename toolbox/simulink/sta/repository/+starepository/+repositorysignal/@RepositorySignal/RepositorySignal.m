classdef RepositorySignal<handle




    properties(Abstract)


SUPPORTED_FORMATS
    end


    properties(Access='protected')
        repoUtil=starepository.RepositoryUtility();
    end


    properties(Access='public')






        castData=true;
    end


    methods(Abstract)



        bool=isSupported(dbId,dataFormat);


        [varValue,varName]=extractValue(obj,dbId,varargin);
    end


    methods


        function varValue=createSimulinkSimulationDataSignal(obj,dbId)


            BlockDataProperties=obj.repoUtil.getMetaDataStructure(dbId);

            if isfield(BlockDataProperties,'TreeOrder')
                BlockDataProperties=rmfield(BlockDataProperties,'TreeOrder');
            end

            if isfield(BlockDataProperties,'ParentID')
                BlockDataProperties=rmfield(BlockDataProperties,'ParentID');
            end

            if~isfield(BlockDataProperties,'BlockDataSubClass')
                BlockDataProperties=BlockDataProperties.BlockDataProperties;
            end

            varValue=eval(BlockDataProperties.BlockDataSubClass);

            fieldsNamesBlockData=fieldnames(BlockDataProperties);
            for id=1:length(fieldsNamesBlockData)
                if~strcmp(fieldsNamesBlockData{id},'BlockDataSubClass')
                    varValue.(fieldsNamesBlockData{id})=BlockDataProperties.(fieldsNamesBlockData{id});
                end
            end

            BlockPathLength=obj.repoUtil.getMetaDataByName(dbId,'BlockPathLength');
            BlockPathCellArray=cell(1,BlockPathLength);
            if BlockPathLength>0
                BlockPathCellArray{1}=obj.repoUtil.getMetaDataByName(dbId,'BlockPath');

                for id=2:BlockPathLength
                    BlockPathCellArray{id}=obj.repoUtil.getMetaDataByName(dbId,sprintf('BlockPath%d',id));
                end

                blockPathType=obj.repoUtil.getMetaDataByName(dbId,'BlockPathLengthType');

                varValue.BlockPath=eval(sprintf('%s(BlockPathCellArray)',blockPathType));

                SubPath=obj.repoUtil.getMetaDataByName(dbId,'SubPath');

                if~isempty(SubPath)
                    varValue.BlockPath.SubPath=SubPath;
                end
            end
        end


        function editNamePayLoad=updateSignalName(obj,dbId,sigFullName,newSignalName,namesCantBeUsed)
            eng=sdi.Repository(true);

            existingName=eng.getSignalName(dbId);


            parentID=eng.getSignalParent(dbId);

            if parentID~=0

                parentFormat=obj.repoUtil.getMetaDataByName(parentID,'dataformat');

            else
                parentFormat='';
            end


            if~strcmpi('dataset',parentFormat)


                if~isvarname(newSignalName)


                    newSignalName=matlab.lang.makeValidName(newSignalName);

                end


                aStrUtil=sta.StringUtil();
                for k=1:length(namesCantBeUsed)
                    aStrUtil.addNameContext(namesCantBeUsed{k});
                end

                newSignalName=aStrUtil.getUniqueName(newSignalName);

            end

            editNamePayLoad=doNameChange(obj,dbId,newSignalName,sigFullName,existingName);

        end


        function editNamePayLoad=doNameChange(obj,dbId,newSignalName,sigFullName,existingName)
            eng=sdi.Repository(true);



            eng.setSignalLabel(dbId,newSignalName);
            eng.setSignalMetaData(dbId,'Name',newSignalName);

            editNamePayLoad(1).id=dbId;
            editNamePayLoad(1).propertyname='name';
            editNamePayLoad(1).oldValue=existingName;
            editNamePayLoad(1).newValue=newSignalName;

            editNamePayLoad(2).id=dbId;
            editNamePayLoad(2).propertyname='FullName';


            editNamePayLoad(2).oldValue=sigFullName;


            newFullName=newSignalName;
            idxDot=strfind(sigFullName,'.');

            if~isempty(idxDot)
                newFullName=[sigFullName(1:idxDot(end)),newSignalName];
            end

            editNamePayLoad(2).newValue=newFullName;


            oldestParent=obj.repoUtil.getOldestRelative(dbId);


            obj.repoUtil.setMetaDataByName(dbId,'IS_EDITED',1);


            if oldestParent~=0
                obj.repoUtil.setMetaDataByName(oldestParent,'IS_EDITED',1);
            end

            editNamePayLoad=updateChildrenSignalNames(obj,dbId,newSignalName,...
            sigFullName,newFullName,editNamePayLoad);
        end


        function editPropStruct=updateChildrenSignalNames(obj,dbId,nameOfParent,oldParentFullName,...
            newFullNameOfParent,editPropStruct)%#ok<INUSL> WANT BASE API SIGNATURE

        end


        function[realNameNew,realNameOld,imgNameNew,ImgNameOld]=updateRealAndImgNames(~,newFullNameOfParent,oldParentFullName)


            realNameNew=getString(message('simulation_data_repository:sdr:RealSignalName',newFullNameOfParent));
            realNameOld=getString(message('simulation_data_repository:sdr:RealSignalName',oldParentFullName));

            imgNameNew=getString(message('simulation_data_repository:sdr:ImagSignalName',newFullNameOfParent));
            ImgNameOld=getString(message('simulation_data_repository:sdr:ImagSignalName',oldParentFullName));

        end


        function jsonStruct=jsonStructFromID(obj,dbId)%#ok<INUSD> WANT BASE API SIGNATURE
            jsonStruct={};
        end


        function possibleParentID=findFirstPossibleParent(obj,idOfSignal,dbIdParent)%#ok<INUSL> WANT BASE API SIGNATURE






            possibleParentID=dbIdParent;


            while possibleParentID~=0

                if strcmpi(obj.repoUtil.getMetaDataByName(possibleParentID,...
                    'dataformat'),'dataset')
                    break;
                end

                possibleParentID=obj.repoUtil.getParent(possibleParentID);


            end

        end


        function[idToOriginalValues,replacementJsonStruct]=cast(obj,rootSigID,WAS_REAL,newDataType)










            replacementJsonStruct={};


            [IS_VALID,NEWTTYPE_META_STRUCT]=starepository.DataTypeHelper.isSignalDataTypeStringValid(newDataType);%#ok<ASGLU> IN CASE IN FUTURE NEED THIS VAR 

            repo=starepository.RepositoryUtility();
            IS_SIGNAL_AN_ENUM=repo.getMetaDataByName(rootSigID,'isEnum');

            if NEWTTYPE_META_STRUCT.IS_ENUM||IS_SIGNAL_AN_ENUM


                idToOriginalValues=rootSigID;


                dataToSet=getTimeAndDataByID(obj,rootSigID);


                try
                    if NEWTTYPE_META_STRUCT.IS_FIXDT




                        castedDataVals=fi(int64(dataToSet.Data),eval(newDataType));

                    else
                        castH=str2func(newDataType);

                        if NEWTTYPE_META_STRUCT.IS_ENUM&&islogical(dataToSet.Data)

                            castedDataVals=castH(double(dataToSet.Data));
                        else
                            castedDataVals=castH(dataToSet.Data);
                        end
                    end
                    dataToSet.Data=castedDataVals;
                catch ME_CAST

                    switch ME_CAST.identifier
                    case 'MATLAB:class:InvalidEnum'


                        try
                            [enumMembers,~]=enumeration(newDataType);
                            ENUM_DEFAULT=enumMembers(1);


                            if islogical(dataToSet.Data)
                                dataToSet.Data=double(dataToSet.Data);
                            end

                            dataToSet.Data(:)=ENUM_DEFAULT;

                            castedDataVals=castH(dataToSet.Data);
                            dataToSet.Data=castedDataVals;

                        catch ME_NOW_WHAT
                            DAStudio.error('sl_sta_repository:data_type_cast:unexpectedEnumFail',newDataType);
                        end
                    case 'MATLAB:class:CannotConvert'


                        try
                            [enumMembers,~]=enumeration(newDataType);
                            ENUM_DEFAULT=enumMembers(1);




                            dataToSet.Data=repmat(ENUM_DEFAULT,size(dataToSet.Data));

                            castedDataVals=castH(dataToSet.Data);
                            dataToSet.Data=castedDataVals;

                        catch ME_NOW_WHAT
                            DAStudio.error('sl_sta_repository:data_type_cast:unexpectedEnumFail',newDataType);
                        end
                    otherwise
                        DAStudio.error('sl_sta_repository:data_type_cast:unexpectedEnumFail',newDataType);
                    end

                end

                signalNameToCopy=getVariableName(repo,rootSigID);
                simulinkSignal=getSimulinkSignalByID(repo,rootSigID,dataToSet);


                itemFactory=starepository.factory.createSignalItemFactory(signalNameToCopy,simulinkSignal);

                item=itemFactory.createSignalItem;

                eng=sdi.Repository(true);
                replacementJsonStruct=eng.safeTransaction(@starepository.ioitem.initStreaming,{item},'junkfile',0);
                return;
            end





            repo=starepository.RepositoryUtility();





            signalNameToCopy=getVariableName(repo,rootSigID);
            simulinkSignal=getSimulinkSignalByID(repo,rootSigID);


            itemFactory=starepository.factory.createSignalItemFactory(signalNameToCopy,simulinkSignal);

            item=itemFactory.createSignalItem;

            eng=sdi.Repository(true);
            jsonStruct=eng.safeTransaction(@starepository.ioitem.initStreaming,{item},'junkfile',0);

            idToOriginalValues=jsonStruct{1}.ID;

            if isfield(jsonStruct{1},'ComplexID')
                idToOriginalValues=jsonStruct{1}.ComplexID;
            end

            doCast(obj,rootSigID,WAS_REAL,newDataType);
            setMetaDataByName(obj.repoUtil,rootSigID,'DataType',newDataType);

            if contains(newDataType,'fixdt')

                aDataVal=getADataValue(obj,rootSigID);


                metaData_struct=starepository.ioitem.DataDump.appendFiDataToMetaDataStruct(aDataVal,struct);

                metaName=fieldnames(metaData_struct);


                for kField=1:length(metaName)
                    setMetaDataByName(obj.repoUtil,rootSigID,metaName{kField},metaData_struct.(metaName{kField}));
                end
            else
                setMetaDataByName(obj.repoUtil,rootSigID,'isFixDT',false);
            end

        end


        function idToOriginalValues=castAndSetDataByID(obj,rootSigID,WAS_REAL,newDataType,signalIDForData)

            idToOriginalValues=cast(obj,rootSigID,WAS_REAL,newDataType);


            setDataByID(obj,rootSigID,signalIDForData);
        end


        function setDataByID(obj,rootSigID,signalIDForData)%#ok<INUSD> WANT BASE API SIGNATURE            
            DAStudio.error('sl_sta_repository:sta_repository:setDataByIDImplement')
        end


        function editSignalData(obj,rootSigID,sigID,newDataType,dataToSet)%#ok<INUSD> WANT BASE API SIGNATURE
            DAStudio.error('sl_sta_repository:sta_repository:editnotsupported');
        end


        function metaDataValue=getMetaDataByName(~,rootSigID,metaDataName)
            repo=starepository.RepositoryUtility();

            metaDataValue=getMetaDataByName(repo,rootSigID,metaDataName);
        end


        function plottableIDs=getPlottableSignalIDs(~,rootSigID)


            plottableIDs=rootSigID;
        end


        function propertyUpdateIDs=getIDsForPropertyUpdates(~,rootSigID)


            propertyUpdateIDs=rootSigID;
        end


        function dataToSet=getTimeAndDataByID(obj,rootSigID)
            dataToSet=getDataForSetByID(obj,rootSigID);
        end


        function castNoBackUp(obj,rootSigID,WAS_REAL,newDataType)
            doCast(obj,rootSigID,WAS_REAL,newDataType);
        end


        function removeDataPointByTime(obj,rootSigID,timeValues)


            replotIDs=getPlottableSignalIDs(obj,rootSigID);

            [numPoints,~]=size(timeValues);
            for k=1:length(replotIDs)
                for kRow=1:numPoints
                    timeToRemove=timeValues(kRow,1);
                    removeDataAtTime(obj.repoUtil,replotIDs(k),timeToRemove);
                end
            end
        end


        function addDataPointByTime(obj,rootSigID,timeValues,dataValues)
            [numPoints,~]=size(timeValues);

            signalType=getMetaDataByName(obj.repoUtil,rootSigID,'SignalType');
            IS_COMPLEX=strcmp(signalType,getString(message('sl_sta_general:common:Complex')));

            if~IS_COMPLEX
                for k=1:numPoints
                    addDataPointAtTime(obj.repoUtil,rootSigID,timeValues(k),dataValues(k,:));
                end
            else


                replotIDs=getPlottableSignalIDs(obj,rootSigID);

                if isfi(dataValues)
                    for k=1:numPoints
                        addDataPointAtTime(obj.repoUtil,replotIDs(1),timeValues(k),dataValues(k,:));
                    end
                else
                    for k=1:numPoints
                        addDataPointAtTime(obj.repoUtil,replotIDs(1),timeValues(k),[real(dataValues(k,:)),imag(dataValues(k,:))]);
                    end
                end

            end

        end

    end


    methods


        function jsonStruct=copy(obj,sigIDToCopy)


            repo=starepository.RepositoryUtility();

            newSigID=copySignalMetaDataByIDRecursive(repo,sigIDToCopy);

            jsonStruct=obj.jsonStructFromID(newSigID);

        end

    end


    methods(Access='protected')


        function doCast(obj,rootSigID,WAS_REAL,newDataType)%#ok<INUSD> WANT BASE API SIGNATURE
            DAStudio.error('sl_sta_repository:sta_repository:castnotsupported');
        end

    end
end

