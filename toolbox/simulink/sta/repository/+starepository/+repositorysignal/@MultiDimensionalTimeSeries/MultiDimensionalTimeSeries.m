classdef MultiDimensionalTimeSeries<starepository.repositorysignal.NonScalarLeafInterface






    properties
        SUPPORTED_FORMATS={'multidimtimeseries','simulinkmultidimtimeseries','datasetElement:multidimtimeseries','datasetElement:simulinkmultidimtimeseries'};
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


            format=obj.repoUtil.getMetaDataByName(dbId,'dataformat');


            Name=obj.repoUtil.getSignalLabel(dbId);


            kidDbId=obj.repoUtil.getChildrenIDsInSiblingOrder(dbId);



            for kChild=1:length(kidDbId)


                childName=obj.repoUtil.getVariableName(kidDbId(kChild));


                [timeValues,dataValues]=obj.repoUtil.getSignalTimeAndDataValues(kidDbId(kChild));%#ok<*ASGLU>



                idx_paren=strfind(childName,'(');

                evalMultiDim(obj,childName(idx_paren(end):end));

            end

            isSL=strcmpi(format,'simulinkmultidimtimeseries')||strcmpi(format,'datasetElement:simulinkmultidimtimeseries');

            if exist('multiDimData','var')
                multiDimData=castIfFixedOverride(obj,kidDbId(1),multiDimData);%#ok<NODEF>
            end

            isFixdt=obj.repoUtil.getMetaDataByName(kidDbId(1),'isFixDT');


            if isFixdt
                if obj.repoUtil.getMetaDataByName(kidDbId(1),'isfimathlocal')

                    fiMathStruct=obj.repoUtil.getMetaDataByName(kidDbId(1),'fimath');
                    multiDimData=setFiMathFromStruct(fiMathStruct,multiDimData);
                end
            end




            isComplex=strcmpi(obj.repoUtil.getMetaDataByName(dbId,'SignalType'),getString(message('sl_sta_general:common:Complex')));
            if isComplex&&isreal(multiDimData)
                multiDimData=complex(multiDimData);
            end



            if isSL
                varValue=Simulink.Timeseries;

                varValue.Name=obj.repoUtil.getMetaDataByName(dbId,'TimeseriesName');
                varValue.BlockPath=obj.repoUtil.getMetaDataByName(dbId,'signalBlockPath');
                varValue.SignalName=obj.repoUtil.getMetaDataByName(dbId,'signalSignalName');
                varValue.ParentName=obj.repoUtil.getMetaDataByName(dbId,'signalParentName');

                portIdx=obj.repoUtil.getMetaDataByName(dbId,'signalPortIndex');

                if ischar(portIdx)
                    portIdx=str2num(portIdx);%#ok<ST2NM> 
                end

                varValue.PortIndex=portIdx;

                varValue.Time=timeValues;
                varValue.Data=multiDimData;
            else
                varValue=timeseries(multiDimData,timeValues);
                varValue.Name=obj.repoUtil.getMetaDataByName(dbId,'TimeseriesName');
            end

            varName=Name;

            if isa(varValue,'timeseries')
                varValue.DataInfo.Units=obj.repoUtil.getUnit(dbId);
            end
            varValue.DataInfo.Interpolation=tsdata.interpolation(obj.repoUtil.getInterpMethod(dbId));

            if~isempty(varargin)&&isstruct(varargin{1})

                varValue.Time=varargin{1}.Time;
                varValue.Data=varargin{1}.Data;
            end
        end


        function editPropStruct=updateChildrenSignalNames(obj,dbId,nameOfParent,oldParentFullName,...
            newFullNameOfParent,editPropStruct)

            signalType=getMetaDataByName(obj.repoUtil,dbId,'SignalType');


            IS_COMPLEX=strcmp(signalType,getString(message('sl_sta_general:common:Complex')));




            if IS_COMPLEX

                childSignals=getSignalChildren(obj.repoUtil.repo,dbId);
            else

                childSignals=getChildrenIDsInSiblingOrder(obj.repoUtil,dbId);
            end


            for kChild=1:length(childSignals)


                signalLabel=getSignalLabel(obj.repoUtil,childSignals(kChild));

                idxArrayStart=strfind(signalLabel,'(');

                oldName=signalLabel;
                newName=[nameOfParent,signalLabel(idxArrayStart:end)];
                oldFullLabel=[oldParentFullName,signalLabel(idxArrayStart:end)];
                signalLabel=[newFullNameOfParent,signalLabel(idxArrayStart:end)];

                tempID=double(childSignals(kChild));
                if IS_COMPLEX

                    childSignalsChildren=getChildrenIDsInSiblingOrder(obj.repoUtil,childSignals(kChild));
                    tempID=double(childSignalsChildren(1));

                end

                setSignalLabel(obj.repoUtil,childSignals(kChild),signalLabel);


                oldFullName=oldFullLabel;
                newFullName=signalLabel;


                tempStruct(1).id=tempID;
                tempStruct(1).propertyname='name';
                tempStruct(1).oldValue=oldName;
                tempStruct(1).newValue=newName;


                setMetaDataByName(obj.repoUtil,childSignals(kChild),'ParentName',nameOfParent);


                tempStruct(2).id=tempID;
                tempStruct(2).propertyname='FullName';
                tempStruct(2).oldValue=oldFullName;
                tempStruct(2).newValue=newFullName;


                editPropStruct=[editPropStruct,tempStruct];%#ok<AGROW> NOTE: size structs unknown due to recursive nature

                tempStruct=[];

            end
        end


        function jsonStruct=jsonStructFromID(obj,dbId)
            jsonStruct={};

            jsonStruct{1}.ID=dbId;
            jsonStruct{1}.Name=obj.repoUtil.getSignalLabel(dbId);

            parentID=obj.repoUtil.getParent(dbId);
            parentName=[];

            if parentID~=0
                parentName=obj.repoUtil.getSignalLabel(parentID);
            else
                parentID='input';
            end

            jsonStruct{1}.ParentName=parentName;
            jsonStruct{1}.ParentID=parentID;

            signalMetaData=obj.repoUtil.getMetaDataStructure(dbId);

            jsonStruct{1}.DataSource=signalMetaData.FileName;
            jsonStruct{1}.FullDataSource=signalMetaData.LastKnownFullFile;
            jsonStruct{1}.Icon='signal.gif';
            jsonStruct{1}.Type='MultiDimensionalTimeSeries';
            jsonStruct{1}.isEnum=signalMetaData.isEnum;
            jsonStruct{1}.isString=signalMetaData.isString;
            jsonStruct{1}.TreeOrder=signalMetaData.TreeOrder;
            jsonStruct{1}.DataType=signalMetaData.DataType;


            jsonStruct{1}.Units=obj.repoUtil.getUnit(dbId);
            boolInfo=strcmp(signalMetaData.DataType,'boolean')||strcmp(signalMetaData.DataType,'logical');
            if jsonStruct{1}.isEnum||boolInfo
                jsonStruct{1}.Interpolation='zoh';
            else
                jsonStruct{1}.Interpolation=obj.repoUtil.getInterpMethod(dbId);
            end

            isReal=strcmpi(signalMetaData.SignalType,getString(message('sl_sta_general:common:Real')));
            IS_COMPLEX=~isReal;

            sdiRepo=sdi.Repository(true);
            kids=sdiRepo.getSignalChildren(dbId);

            if IS_COMPLEX

                childStruct=cell(1,length(kids));
            else

                childStruct=cell(1,length(kids));
            end

            treeOrderCount=jsonStruct{1}.TreeOrder+1;



            siblingOrderCount=1;

            for kChild=1:length(kids)

                childStruct{siblingOrderCount}.ID=double(kids(kChild));
                childStruct{siblingOrderCount}.Name=obj.repoUtil.getSignalLabel(kids(kChild));
                childStruct{siblingOrderCount}.ParentName=jsonStruct{1}.ParentName;
                childStruct{siblingOrderCount}.ParentID=dbId;
                childStruct{siblingOrderCount}.DataSource=jsonStruct{1}.DataSource;
                childStruct{siblingOrderCount}.FullDataSource=jsonStruct{1}.FullDataSource;
                childStruct{siblingOrderCount}.DataType=jsonStruct{1}.DataType;
                childStruct{siblingOrderCount}.Icon='signal.gif';

                if IS_COMPLEX
                    childStruct{siblingOrderCount}.Type='ComplexTimeSeries';
                else
                    childStruct{siblingOrderCount}.Type='Signal';
                end

                childStruct{siblingOrderCount}.isEnum=jsonStruct{1}.isEnum;
                childStruct{siblingOrderCount}.isString=jsonStruct{1}.isString;


                childMetaData=obj.repoUtil.getMetaDataStructure(kids(kChild));
                childStruct{siblingOrderCount}.MinTime=childMetaData.MinTime;
                childStruct{siblingOrderCount}.MaxTime=childMetaData.MaxTime;

                if~isreal(childMetaData.Min)
                    childStruct{siblingOrderCount}.MinData='[]';
                    childStruct{siblingOrderCount}.MaxData='[]';
                else
                    childStruct{siblingOrderCount}.MinData='[]';
                    childStruct{siblingOrderCount}.MaxData='[]';
                end


                childStruct{siblingOrderCount}.Units=jsonStruct{1}.Units;
                childStruct{siblingOrderCount}.Interpolation=jsonStruct{1}.Interpolation;

                if isfield(signalMetaData,'BlockPath')
                    blkPathToUse=[];
                else
                    blkPathToUse=[];
                end

                childStruct{siblingOrderCount}.BlockPath=blkPathToUse;
                childStruct{siblingOrderCount}.TreeOrder=treeOrderCount;



                treeOrderCount=treeOrderCount+1;
                siblingOrderCount=siblingOrderCount+1;

                if IS_COMPLEX

                    realImgKids=sdiRepo.getSignalChildren(kids(kChild));
                    childStruct{siblingOrderCount-1}.ComplexID=childStruct{siblingOrderCount-1}.ID;
                    childStruct{siblingOrderCount-1}.ID=realImgKids(1);
                    childStruct{siblingOrderCount-1}.ImagID=realImgKids(2);
                end

            end

            jsonStruct=[jsonStruct,childStruct];
















        end


        function plottableIDs=getPlottableSignalIDs(obj,rootSigID)

            signalType=getMetaDataByName(obj.repoUtil,rootSigID,'SignalType');
            WAS_REAL=strcmp(signalType,getString(message('sl_sta_general:common:Real')));

            if WAS_REAL
                plottableIDs=obj.repoUtil.getChildrenIDsInSiblingOrder(rootSigID);
            else

                sliceContainers=obj.repoUtil.getChildrenIDsInSiblingOrder(rootSigID);
                plottableIDs=zeros(1,2*length(sliceContainers));

                indexesToModify=[1,2];

                for kChild=1:length(sliceContainers)

                    complexChildren=obj.repoUtil.getChildrenIDsInSiblingOrder(sliceContainers(kChild));
                    plottableIDs(indexesToModify)=complexChildren;
                    indexesToModify=indexesToModify+2;
                end

            end
        end


        function propertyUpdateIDs=getIDsForPropertyUpdates(obj,rootSigID)
            signalType=getMetaDataByName(obj.repoUtil,rootSigID,'SignalType');
            WAS_REAL=strcmp(signalType,getString(message('sl_sta_general:common:Real')));

            if WAS_REAL
                propertyUpdateIDs=obj.repoUtil.getChildrenIDsInSiblingOrder(rootSigID);
            else

                sliceContainers=obj.repoUtil.getChildrenIDsInSiblingOrder(rootSigID);
                propertyUpdateIDs=zeros(1,length(sliceContainers));

                for kChild=1:length(sliceContainers)

                    complexChildren=obj.repoUtil.getChildrenIDsInSiblingOrder(sliceContainers(kChild));
                    propertyUpdateIDs(kChild)=complexChildren(1);
                end

            end
        end


        function dataOut=getDataForSetByIDImpl(obj,signalIDForData)

            kidDbId=obj.repoUtil.getChildrenIds(signalIDForData);
            N_KIDS=length(kidDbId);
            kidValues(N_KIDS).dataValues=[];

            for kKiddo=1:N_KIDS
                [timeValues,kidValues(kKiddo).dataValues]=obj.repoUtil.getSignalTimeAndDataValues(kidDbId(kKiddo));
            end

            dataOut.Time=timeValues;
            dataOut.Data=[kidValues(:).dataValues];
        end


        function dataToSet=getTimeAndDataByID(obj,rootSigID)
            varout=obj.extractValue(rootSigID);
            dataToSet.Time=varout.Time;
            dataToSet.Data=varout.Data;
        end


        function addDataPointByTime(obj,rootSigID,timeValues,dataValues)

            signalType=getMetaDataByName(obj.repoUtil,rootSigID,'SignalType');
            WAS_REAL=strcmp(signalType,getString(message('sl_sta_general:common:Real')));

            if WAS_REAL
                replotIDs=getPlottableSignalIDs(obj,rootSigID);
                [numPoints,numCol]=size(timeValues);




                for k=1:numPoints
                    for kID=1:length(replotIDs)

                        addDataPointAtTime(obj.repoUtil,replotIDs(kID),timeValues(k),dataValues(k,kID));
                    end
                end
            else
                sliceContainers=obj.repoUtil.getChildrenIDsInSiblingOrder(rootSigID);
                [numPoints,numCol]=size(timeValues);

                if isfi(dataValues)

                    for k=1:numPoints
                        for kChild=1:length(sliceContainers)

                            complexChildren=obj.repoUtil.getChildrenIDsInSiblingOrder(sliceContainers(kChild));

                            addDataPointAtTime(obj.repoUtil,complexChildren(1),timeValues(k),dataValues(k,kChild));
                        end

                    end

                else

                    for k=1:numPoints
                        for kChild=1:length(sliceContainers)

                            complexChildren=obj.repoUtil.getChildrenIDsInSiblingOrder(sliceContainers(kChild));

                            addDataPointAtTime(obj.repoUtil,complexChildren(1),timeValues(k),[real(dataValues(k,kChild)),imag(dataValues(k,kChild))]);
                        end

                    end
                end

            end
        end
    end


    methods(Access='private')


        function evalMultiDim(~,indexStr)
            evalStr=sprintf('%s = dataValues;',['multiDimData',indexStr]);
            evalin('caller',evalStr);
        end


        function multiDataOut=castIfFixedOverride(obj,dbId,Vals)
            fixDtOverride=obj.repoUtil.getMetaDataByName(dbId,'FixDTOverrideType');

            if~isempty(fixDtOverride)
                if~isempty(strfind(fixDtOverride,'fixdt'))%#ok<STREMP>
                    fiType=eval(fixDtOverride);
                    multiDataOut=fi(Vals,fiType);
                else
                    multiDataOut=fi(Vals,fixdt(fixDtOverride));
                end
            else
                multiDataOut=Vals;
            end
        end

    end

    methods(Access='protected')

        function makeDataEdits(obj,rootSigID,WAS_REAL,dataToSet)
            if WAS_REAL

                kidIDs=obj.repoUtil.getChildrenIDsInSiblingOrder(rootSigID);

                dataForSet.Time=dataToSet.Time;
                for kChild=1:length(kidIDs)

                    dataForSet.Data=dataToSet.Data(:,kChild);

                    obj.repoUtil.repo.setSignalDataValues(kidIDs(kChild),dataForSet);
                end

            else
                kidIDs=obj.repoUtil.getChildrenIDsInSiblingOrder(rootSigID);

                dataForSet.Time=dataToSet.Time;

                columnToSend=1;
                for kChild=1:length(kidIDs)

                    complexChildren=obj.repoUtil.getChildrenIDsInSiblingOrder(kidIDs(kChild));

                    dataForSet.Data=real(dataToSet.Data(:,columnToSend));

                    obj.repoUtil.repo.setSignalDataValues(complexChildren(1),dataForSet);

                    dataForSet.Data=imag(dataToSet.Data(:,columnToSend));

                    obj.repoUtil.repo.setSignalDataValues(complexChildren(2),dataForSet);
                    columnToSend=columnToSend+1;
                end
            end
        end


        function doCast(obj,rootSigID,WAS_REAL,newDataType)



            setMetaDataByName(obj.repoUtil,rootSigID,'DataType',newDataType);

            if WAS_REAL

                kidIDs=obj.repoUtil.getChildrenIDsInSiblingOrder(rootSigID);
                for kChild=1:length(kidIDs)
                    editDataType(obj.repoUtil,kidIDs(kChild),newDataType);
                end
            else

                kidIDs=obj.repoUtil.getChildrenIDsInSiblingOrder(rootSigID);

                for kChild=1:length(kidIDs)

                    complexChildren=obj.repoUtil.getChildrenIDsInSiblingOrder(kidIDs(kChild));


                    editDataType(obj.repoUtil,complexChildren(1),newDataType);
                    editDataType(obj.repoUtil,complexChildren(2),newDataType);

                end
            end

        end


        function indexString=getSignalIndexAsString(obj,dbId)


            childName=obj.repoUtil.getVariableName(dbId);



            idx_paren=strfind(childName,'(');
            indexString=childName(idx_paren(end):end);
        end
    end
end


