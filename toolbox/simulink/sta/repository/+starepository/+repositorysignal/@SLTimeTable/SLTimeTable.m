classdef SLTimeTable<starepository.repositorysignal.LeafSignalInterface






    properties
        SUPPORTED_FORMATS={...
'sl_timetable'...
        ,'loggedsignal:sl_timetable'...
        ,'datasetElement:sl_timetable'...
        ,'datasetElement:loggedsignal:sl_timetable'...
        ,'datasetElement:loggedstate:sl_timetable'...
        ,'loggedstate:sl_timetable'...
        ,'non_scalar_sl_timetable'...
        ,'loggedsignal:non_scalar_sl_timetable'...
        ,'datasetElement:non_scalar_sl_timetable'...
        ,'datasetElement:loggedsignal:non_scalar_sl_timetable'...
        ,'datasetElement:loggedstate:non_scalar_sl_timetable'...
        ,'loggedstate:non_scalar_sl_timetable'...
        }
    end


    methods

        function bool=isSupported(obj,dbId,dataFormat)




            bool=any(strcmpi(dataFormat,obj.SUPPORTED_FORMATS))||...
            (isempty(dataFormat)&&isempty(obj.repoUtil.getChildrenIds(dbId)));
        end



        function dataVal=getADataValue(obj,rootSigID)

            fullDimsStr=obj.repoUtil.getMetaDataByName(rootSigID,'FullDimensions');
            sigDims=str2num(fullDimsStr);%#ok<ST2NM>

            IS_NOT_SCALAR=any(sigDims(2:end)>1);

            if(IS_NOT_SCALAR)
                kidDbId=obj.repoUtil.getChildrenIds(rootSigID);

                [~,Vals]=obj.repoUtil.getSignalTimeAndDataValuesNDim(kidDbId(1),rootSigID);
                dataVal=Vals(1);
            else
                dataVal=getADataValue@starepository.repositorysignal.LeafSignalInterface(obj,rootSigID);
            end
        end


        function[varValue,varName]=extractValue(obj,dbId,varargin)
            if isempty(dbId)
                varValue=[];
                varName=[];
                return;
            end

            kidDbId=obj.repoUtil.getChildrenIds(dbId);

            fullDimsStr=obj.repoUtil.getMetaDataByName(dbId,'FullDimensions');
            sigDims=str2num(fullDimsStr);%#ok<ST2NM>

            IS_NOT_SCALAR=any(sigDims(2:end)>1);
            Time=[];
            if~IS_NOT_SCALAR

                [Time,Vals]=obj.repoUtil.getSignalTimeAndDataValues(dbId);
            else

                for kChild=1:length(kidDbId)






                    childName=obj.repoUtil.getSignalLabel(kidDbId(kChild));





                    childName=strrep(childName,')',',1,:)');

                    NDimIdxStr=obj.repoUtil.getMetaDataByName(kidDbId(kChild),'NDimIdxStr');
                    idxOpenParenth=strfind(childName,'(');
                    childName=[childName(1:idxOpenParenth-1),NDimIdxStr];%#ok<NASGU> recusive name unknown size.



                    [Time,dataValues]=obj.repoUtil.getSignalTimeAndDataValuesNDim(kidDbId(kChild),dbId);%#ok<ASGLU>


                    idxStr=obj.repoUtil.getMetaDataByName(kidDbId(kChild),'NDimIdxStr');



                    evalMultiDim(obj,idxStr);

                end

                isComplex=strcmpi(obj.repoUtil.getMetaDataByName(dbId,'SignalType'),getString(message('sl_sta_general:common:Complex')));

                if isComplex&&isreal(multiDimData)%#ok<NODEF>

                    multiDimData=complex(multiDimData,multiDimData);
                end

                Vals=multiDimData;
            end


            varName=obj.repoUtil.getVariableName(dbId);


            if isempty(Vals)

                theType=obj.repoUtil.getMetaDataByName(dbId,'DataType');


                Time=double.empty(0,1);
                Vals=resolveEmptyValues(obj,Vals,theType);

            end

            castToDt=obj.repoUtil.getMetaDataByName(dbId,'CastToDataType');

            if~isempty(castToDt)&&obj.castData
                Vals=starepository.slCastData(Vals,castToDt);
            end


            format=obj.repoUtil.getMetaDataByName(dbId,'dataformat');
            fixDtOverride=obj.repoUtil.getMetaDataByName(dbId,'FixDTOverrideType');

            if~isempty(fixDtOverride)
                if contains(fixDtOverride,'fixdt')
                    fiType=eval(fixDtOverride);
                    Vals=fi(Vals,fiType);
                else
                    Vals=fi(Vals,fixdt(fixDtOverride));
                end
            end

            isFixdt=obj.repoUtil.getMetaDataByName(dbId,'isFixDT');


            if isFixdt
                if obj.repoUtil.getMetaDataByName(dbId,'isfimathlocal')

                    fiMathStruct=obj.repoUtil.getMetaDataByName(dbId,'fimath');
                    Vals=setFiMathFromStruct(fiMathStruct,Vals);%#ok<NASGU>
                end
            end


            if isempty(format)||~isempty(strfind(format,'structElementIndex:'))%#ok<STREMP>
                format='sl_timetable';
            end

            timevalueUnits=obj.repoUtil.getMetaDataByName(dbId,'TimeObjectClass');
            fcnH=str2func(timevalueUnits);
            Time_Vals=fcnH(Time);%#ok<NASGU>


            VariableNames=obj.repoUtil.getMetaDataByName(dbId,'VariableNames');%#ok<NASGU>
            repoUnits=obj.repoUtil.getUnit(dbId);
            VariableUnits={};

            if~isempty(repoUnits)
                VariableUnits={repoUnits};
            end
            dimNames=obj.repoUtil.getMetaDataByName(dbId,'DimensionNames');
            evalTimeVals(obj,dimNames{1});

            evalCmd=sprintf('timetable(%s, Vals, ''VariableNames'', VariableNames)',dimNames{1});
            timeTableValue=eval(evalCmd);


            timeTableDescription=obj.repoUtil.getMetaDataByName(dbId,'Description');

            if isempty(timeTableDescription)
                timeTableDescription='';
            end


            timeTableVariableDescriptions=obj.repoUtil.getMetaDataByName(dbId,'VariableDescriptions');

            if isempty(timeTableVariableDescriptions)
                timeTableVariableDescriptions={};
            end
            VariableContinuity=matlab.tabular.Continuity.continuous;
            if strcmp(obj.repoUtil.getInterpMethod(dbId),'linear')
                VariableContinuity=matlab.tabular.Continuity.continuous;
            else
                VariableContinuity=matlab.tabular.Continuity.step;
            end


            if isempty(VariableContinuity)
                VariableContinuity={};
            end

            UserData=obj.repoUtil.getMetaDataByName(dbId,'UserData');

            if~isempty(varargin)&&isstruct(varargin{1})
                timeTableValue.(timeTableValue.Properties.VariableNames{1})=varargin{1}.Data;
            end



            switch lower(format)
            case 'sl_timetable'

                varValue=timeTableValue;
                varValue.Properties.VariableUnits=VariableUnits;
                varValue.Properties.Description=timeTableDescription;
                varValue.Properties.VariableDescriptions=timeTableVariableDescriptions;
                varValue.Properties.VariableContinuity=VariableContinuity;
                varValue.Properties.UserData=UserData;
            case lower('datasetElement:sl_timetable')

                varValue=timeTableValue;
                varValue.Properties.VariableUnits=VariableUnits;
                varValue.Properties.Description=timeTableDescription;
                varValue.Properties.VariableDescriptions=timeTableVariableDescriptions;
                varValue.Properties.VariableContinuity=VariableContinuity;
                varValue.Properties.UserData=UserData;
            case lower('loggedsignal:sl_timetable')
                varValue=createSimulinkSimulationDataSignal(obj,dbId);
                varValue.Values=timeTableValue;
                varValue.Values.Properties.VariableUnits=VariableUnits;
                varValue.Values.Properties.Description=timeTableDescription;
                varValue.Values.Properties.VariableDescriptions=timeTableVariableDescriptions;
                varValue.Values.Properties.VariableContinuity=VariableContinuity;
                varValue.Values.Properties.UserData=UserData;
            case lower('loggedstate:sl_timetable')

                varValue=timeTableValue;
                varValue.Values.Properties.VariableUnits=VariableUnits;
                varValue.Values.Properties.Description=timeTableDescription;
                varValue.Values.Properties.VariableDescriptions=timeTableVariableDescriptions;
                varValue.Values.Properties.VariableContinuity=VariableContinuity;
                varValue.Values.Properties.UserData=UserData;
            case lower('datasetElement:loggedsignal:sl_timetable')
                varValue=Simulink.SimulationData.Signal;
                varValue.Values=timeTableValue;
                varValue.Values.Properties.VariableUnits=VariableUnits;
                varValue.Values.Properties.Description=timeTableDescription;
                varValue.Values.Properties.VariableDescriptions=timeTableVariableDescriptions;
                varValue.Values.Properties.VariableContinuity=VariableContinuity;
                varValue.Values.Properties.UserData=UserData;
            end


            switch lower(format)
            case 'non_scalar_sl_timetable'

                varValue=timeTableValue;
                varValue.Properties.VariableUnits=VariableUnits;
                varValue.Properties.Description=timeTableDescription;
                varValue.Properties.VariableDescriptions=timeTableVariableDescriptions;
                varValue.Properties.VariableContinuity=VariableContinuity;
                varValue.Properties.UserData=UserData;
            case lower('datasetElement:non_scalar_sl_timetable')

                varValue=timeTableValue;
                varValue.Properties.VariableUnits=VariableUnits;
                varValue.Properties.Description=timeTableDescription;
                varValue.Properties.VariableDescriptions=timeTableVariableDescriptions;
                varValue.Properties.VariableContinuity=VariableContinuity;
                varValue.Properties.UserData=UserData;
            case lower('loggedsignal:non_scalar_sl_timetable')
                varValue=createSimulinkSimulationDataSignal(obj,dbId);
                varValue.Values=timeTableValue;
                varValue.Values.Properties.VariableUnits=VariableUnits;
                varValue.Values.Properties.Description=timeTableDescription;
                varValue.Values.Properties.VariableDescriptions=timeTableVariableDescriptions;
                varValue.Values.Properties.VariableContinuity=VariableContinuity;
                varValue.Values.Properties.UserData=UserData;
            case lower('loggedstate:non_scalar_sl_timetable')

                varValue=timeTableValue;
                varValue.Values.Properties.VariableUnits=VariableUnits;
                varValue.Values.Properties.Description=timeTableDescription;
                varValue.Values.Properties.VariableDescriptions=timeTableVariableDescriptions;
                varValue.Values.Properties.VariableContinuity=VariableContinuity;
                varValue.Values.Properties.UserData=UserData;
            case lower('datasetElement:loggedsignal:non_scalar_sl_timetable')
                varValue=Simulink.SimulationData.Signal;
                varValue.Values=timeTableValue;
                varValue.Values.Properties.VariableUnits=VariableUnits;
                varValue.Values.Properties.Description=timeTableDescription;
                varValue.Values.Properties.VariableDescriptions=timeTableVariableDescriptions;
                varValue.Values.Properties.VariableContinuity=VariableContinuity;
                varValue.Values.Properties.UserData=UserData;
            end



        end



        function editNamePayLoad=doNameChange(obj,dbId,newSignalName,sigFullName,existingName)
            eng=sdi.Repository(true);



            eng.setSignalLabel(dbId,newSignalName);
            eng.setSignalMetaData(dbId,'Name',newSignalName);


            signalType=getMetaDataByName(obj.repoUtil,dbId,'SignalType');
            IS_COMPLEX=strcmp(signalType,getString(message('sl_sta_general:common:Complex')));
            dataFormat=getMetaDataByName(obj.repoUtil,dbId,'dataformat');

            if IS_COMPLEX&&~contains(dataFormat,'non_scalar_sl_timetable')
                editNamePayLoad(1).id=obj.repoUtil.resolveSignalIdForProperties(dbId);
                editNamePayLoad(1).propertyname='name';
                editNamePayLoad(1).oldValue=existingName;
                editNamePayLoad(1).newValue=newSignalName;

                editNamePayLoad(2).id=obj.repoUtil.resolveSignalIdForProperties(dbId);
                editNamePayLoad(2).propertyname='FullName';

            else
                editNamePayLoad(1).id=double(dbId);
                editNamePayLoad(1).propertyname='name';
                editNamePayLoad(1).oldValue=existingName;
                editNamePayLoad(1).newValue=newSignalName;

                editNamePayLoad(2).id=double(dbId);
                editNamePayLoad(2).propertyname='FullName';

            end
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
            newFullNameOfParent,editPropStruct)

            signalType=getMetaDataByName(obj.repoUtil,dbId,'SignalType');

            IS_COMPLEX=strcmp(signalType,getString(message('sl_sta_general:common:Complex')));
            dataFormat=getMetaDataByName(obj.repoUtil,dbId,'dataformat');


            if contains(dataFormat,'non_scalar_sl_timetable')


                editPropStruct=updateNonScalar(obj,dbId,nameOfParent,...
                oldParentFullName,newFullNameOfParent,editPropStruct,IS_COMPLEX);

            end
        end


        function editPropStruct=updateScalarComplex(obj,dbId,nameOfParent,oldParentFullName,...
            newFullNameOfParent,editPropStruct)


            childSignals=getChildrenIDsInSiblingOrder(obj.repoUtil,dbId);

            for kChild=1:length(childSignals)

                signalLabel=getSignalLabel(obj.repoUtil,childSignals(kChild));


                oldName=signalLabel;
                newName=signalLabel;

                if kChild==1
                    signalLabel=getString(message('simulation_data_repository:sdr:RealSignalName',newFullNameOfParent));
                    oldFullLabel=getString(message('simulation_data_repository:sdr:RealSignalName',oldParentFullName));
                else
                    signalLabel=getString(message('simulation_data_repository:sdr:ImagSignalName',newFullNameOfParent));
                    oldFullLabel=getString(message('simulation_data_repository:sdr:ImagSignalName',oldParentFullName));
                end


                oldFullName=oldFullLabel;
                newFullName=signalLabel;


                tempStruct(1).id=double(childSignals(kChild));
                tempStruct(1).propertyname='name';
                tempStruct(1).oldValue=oldName;
                tempStruct(1).newValue=newName;


                setMetaDataByName(obj.repoUtil,childSignals(kChild),'ParentName',nameOfParent);


                tempStruct(2).id=double(childSignals(kChild));
                tempStruct(2).propertyname='FullName';
                tempStruct(2).oldValue=oldFullName;
                tempStruct(2).newValue=newFullName;


                editPropStruct=[editPropStruct,tempStruct];%#ok<AGROW> recursive lineage size unknown

                tempStruct=[];
            end

        end


        function editPropStruct=updateNonScalar(obj,dbId,nameOfParent,oldParentFullName,...
            newFullNameOfParent,editPropStruct,IS_COMPLEX)%#ok<INUSL> KEEP API SIGNATURE

            if IS_COMPLEX

                childSignals=getSignalChildren(obj.repoUtil.repo,dbId);
            else

                childSignals=getChildrenIDsInSiblingOrder(obj.repoUtil,dbId);
            end


            for kChild=1:length(childSignals)

                signalLabel=getSignalLabel(obj.repoUtil,childSignals(kChild));
                NDimIdxStr=obj.repoUtil.getMetaDataByName(childSignals(kChild),'NDimIdxStr');%#ok<NASGU>

                oldName=signalLabel;
                newName=overrideLabel(obj,childSignals(kChild));


                oldFullName=oldName;
                newFullName=newName;


                tempStruct(1).id=double(childSignals(kChild));
                tempStruct(1).propertyname='name';
                tempStruct(1).oldValue=oldName;
                tempStruct(1).newValue=newName;


                setMetaDataByName(obj.repoUtil,childSignals(kChild),'ParentName',nameOfParent);


                tempStruct(2).id=double(childSignals(kChild));
                tempStruct(2).propertyname='FullName';
                tempStruct(2).oldValue=oldFullName;
                tempStruct(2).newValue=newFullName;

                if IS_COMPLEX
                    realImgIDs=getChildrenIDsInSiblingOrder(obj.repoUtil,childSignals(kChild));
                    tempStruct(1).id=realImgIDs(1);
                    tempStruct(2).id=realImgIDs(1);
                end


                editPropStruct=[editPropStruct,tempStruct];%#ok<AGROW> recursive lineage unknown

                tempStruct=[];

            end

        end


        function staLabel=overrideLabel(obj,id)


            staLabel=obj.repoUtil.getSignalLabel(id);
            NDimIdxStr=obj.repoUtil.getMetaDataByName(id,'NDimIdxStr');
            staLabel=constructLabel(obj,staLabel,NDimIdxStr);






        end


        function staLabel=constructLabel(~,staLabel,NDimIdxStr)



            staLabel=strrep(staLabel,')',',1,:)');

            idxOpenParenth=strfind(staLabel,'(');
            idxParen=idxOpenParenth(end);
            staLabel=[staLabel(1:idxParen-1),NDimIdxStr];
        end


        function jsonStruct=jsonStructFromID(obj,dbId)
            jsonStruct={};
            metaStruct=obj.repoUtil.getMetaDataStructure(dbId);


            isReal=strcmpi(metaStruct.SignalType,getString(message('sl_sta_general:common:Real')));
            IS_COMPLEX=~isReal;
            parentID=obj.repoUtil.getParent(dbId);

            if parentID==0
                parentID='input';
            end

            if isReal

                itemStruct.Name=getSignalLabel(obj.repoUtil,dbId);

                if isempty(metaStruct.ParentName)
                    metaStruct.ParentName=[];
                end

                itemStruct.ParentName=metaStruct.ParentName;
                itemStruct.ParentID=parentID;

                itemStruct.DataSource=metaStruct.FileName;
                itemStruct.FullDataSource=metaStruct.LastKnownFullFile;
                itemStruct.Icon='signal.gif';
                itemStruct.Type='SLTimeTable';

                itemStruct.isEnum=metaStruct.isEnum;
                itemStruct.isString=metaStruct.isString;
                itemStruct.DataType=metaStruct.DataType;

                itemStruct.MinTime=metaStruct.MinTime;
                itemStruct.MaxTime=metaStruct.MaxTime;
                itemStruct.MinData='[]';
                itemStruct.MaxData='[]';
                itemStruct.Units=obj.repoUtil.getUnit(dbId);


                if isfield(metaStruct,'BlockPath')
                    itemStruct.BlockPath={metaStruct.BlockPath};
                else
                    itemStruct.BlockPath=[];
                end

                if~itemStruct.isString
                    itemStruct.Interpolation=obj.repoUtil.getInterpMethod(dbId);
                else
                    itemStruct.Interpolation='zoh';
                end

                itemStruct.TreeOrder=metaStruct.TreeOrder;
                itemStruct.ID=dbId;

                itemStruct.ExternalSourceID=0;

                jsonStruct{1}=itemStruct;

                if~strcmp(metaStruct.Dimension,'1')


                    jsonStruct{1}.Type='NonScalarSLTimeTable';
                    parentSigStruct{1}=jsonStruct{1};

                    tempStruct=parentSigStruct{1};




                    sdiRepo=sdi.Repository(true);
                    kids=sdiRepo.getSignalChildren(dbId);



                    childStruct=cell(1,length(kids));

                    treeOrderCount=2;
                    kidCount=1;


                    for kKid=1:length(kids)


                        staLabel=overrideLabel(obj,kids(kKid));

                        tempStruct.Name=staLabel;


                        tempStruct.Type='SLTimeTable';
                        tempStruct.isEnum=parentSigStruct{1}.isEnum;


                        tempStruct.ParentID=parentSigStruct{1}.ID;
                        tempStruct.ID=kids(kKid);

                        tempStruct.TreeOrder=treeOrderCount;
                        treeOrderCount=treeOrderCount+1;

                        childStruct{kidCount}=tempStruct;
                        kidCount=kidCount+1;
                    end
                    jsonStruct=[parentSigStruct,childStruct];

                end

            else
                jsonStruct=getComplexJsonFromID(obj,dbId);
            end
        end


        function jsonStruct=getComplexJsonFromID(obj,dbId)

            metaStruct=obj.repoUtil.getMetaDataStructure(dbId);


            parentID=obj.repoUtil.getParent(dbId);

            if parentID==0
                parentID='input';
            end

            containerStruct.Name=getSignalLabel(obj.repoUtil,dbId);
            if isempty(metaStruct.ParentName)
                containerStruct.ParentName=[];
            else
                containerStruct.ParentName=metaStruct.ParentName;
            end
            containerStruct.ID=dbId;
            containerStruct.ParentID=parentID;
            containerStruct.DataSource=metaStruct.FileName;
            containerStruct.FullDataSource=metaStruct.LastKnownFullFile;
            containerStruct.MinTime=metaStruct.MinTime;
            containerStruct.MaxTime=metaStruct.MaxTime;


            containerStruct.Icon='signal.gif';

            containerStruct.Type='ComplexTimeSeries';
            containerStruct.Units=obj.repoUtil.getUnit(dbId);
            containerStruct.Interpolation='linear';
            containerStruct.DataType=metaStruct.DataType;
            containerStruct.TreeOrder=metaStruct.TreeOrder;
            containerStruct.ID=dbId;

            if isfield(metaStruct,'BlockPath')
                containerStruct.BlockPath={metaStruct.BlockPath};
            else
                containerStruct.BlockPath=[];
            end

            containerStruct.isString=false;
            containerStruct.ExternalSourceID=0;

            if~strcmp(metaStruct.Dimension,'1')
                containerStruct.isEnum=false;
                containerStruct.Type='NonScalarSLTimeTable';
                kids=getSignalChildren(obj.repoUtil.repo,dbId);

                childStruct=cell(1,length(kids));
                childrenIDX=1;
                for kChild=1:length(kids)

                    overridenLabel=overrideLabel(obj,kids(kChild));
                    childStruct{childrenIDX}.ID=double(kids(kChild));
                    childStruct{childrenIDX}.Name=overridenLabel;
                    childStruct{childrenIDX}.ParentName=[];
                    childStruct{childrenIDX}.ParentID=dbId;
                    childStruct{childrenIDX}.DataSource=containerStruct.DataSource;
                    childStruct{childrenIDX}.FullDataSource=containerStruct.FullDataSource;
                    childStruct{childrenIDX}.Icon='signal.gif';
                    childStruct{childrenIDX}.Type='ComplexTimeSeries';
                    childStruct{childrenIDX}.Units=containerStruct.Units;
                    childStruct{childrenIDX}.Interpolation=containerStruct.Interpolation;
                    childStruct{childrenIDX}.isString=false;
                    childStruct{childrenIDX}.DataType=metaStruct.DataType;
                    childStruct{childrenIDX}.TreeOrder=containerStruct.TreeOrder+childrenIDX;
                    childStruct{childrenIDX}.isEnum=false;
                    childStruct{childrenIDX}.BlockPath=containerStruct.BlockPath;
                    childStruct{childrenIDX}.MinTime=containerStruct.MinTime;
                    childStruct{childrenIDX}.MaxTime=containerStruct.MaxTime;
                    gkids=getSignalChildren(obj.repoUtil.repo,kids(kChild));

                    childStruct{childrenIDX}.ComplexID=childStruct{childrenIDX}.ID;
                    childStruct{childrenIDX}.ID=double(gkids(1));
                    childStruct{childrenIDX}.ImagID=double(gkids(2));

                    childrenIDX=childrenIDX+1;

                end

                jsonStruct=[{containerStruct},childStruct];
            else
                realStruct.ParentName=containerStruct.ParentName;
                realStruct.ParentID=dbId;
                realStruct.DataSource=containerStruct.DataSource;
                realStruct.FullDataSource=containerStruct.FullDataSource;


                realStruct.Icon='signal.gif';
                realStruct.Type='SLTimeTable';

                realStruct.MinTime=metaStruct.MinTime;
                realStruct.MaxTime=metaStruct.MaxTime;


                realStruct.MinData='[]';
                realStruct.MaxData='[]';%#ok<STRNU>


                containerStruct.Units='';
                containerStruct.Interpolation='linear';
                containerStruct.BlockPath=[];
                containerStruct.MinTime=metaStruct.MinTime;
                containerStruct.MaxTime=metaStruct.MaxTime;
                containerStruct.isString=metaStruct.isString;
                containerStruct.DataType=metaStruct.DataType;

                boolInfo=strcmpi(metaStruct.DataType,'boolean')||strcmpi(metaStruct.DataType,'logical');
                if contains(metaStruct.dataformat,'timeseries')
                    containerStruct.Units=obj.repoUtil.getUnit(dbId);

                    if boolInfo
                        containerStruct.Interpolation='zoh';
                    else
                        containerStruct.Interpolation=obj.repoUtil.getInterpMethod(dbId);
                    end
                elseif contains(metaStruct.dataformat,'Simulink.Timeseries')

                    if boolInfo||containerStruct.isString
                        containerStruct.Interpolation='zoh';
                    else
                        containerStruct.Interpolation=obj.repoUtil.getInterpMethod(dbId);
                    end
                end

                childIDs=getChildrenIDsInSiblingOrder(obj.repoUtil,dbId);

                containerStruct.ComplexID=dbId;
                containerStruct.ID=double(childIDs(1));
                containerStruct.ImagID=double(childIDs(2));

                jsonStruct={containerStruct};
            end
        end


        function editSignalData(obj,rootSigID,sigID,newDataType,dataToSet)


            dataFormat=getMetaDataByName(obj.repoUtil,rootSigID,'dataformat');
            signalType=getMetaDataByName(obj.repoUtil,rootSigID,'SignalType');
            WAS_REAL=strcmp(signalType,getString(message('sl_sta_general:common:Real')));

            if contains(lower(dataFormat),lower('non_scalar_sl_timetable'))


                oldDataType=getMetaDataByName(obj.repoUtil,sigID,'DataType');
                oldRootDataType=getMetaDataByName(obj.repoUtil,rootSigID,'DataType');

                if~isempty(oldRootDataType)
                    oldDataType=oldRootDataType;
                end




                if strcmp(oldDataType,newDataType)
                    makeDataEditsNonScalar(obj,rootSigID,WAS_REAL,dataToSet);
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
                        makeDataEditsNonScalar(obj,rootSigID,WAS_REAL,dataToSet);
                    catch ME_SETDATA_AFTER_CAST %#ok<NASGU>

                    end
                end
            else

                oldDataType=getMetaDataByName(obj.repoUtil,rootSigID,'DataType');
                oldRootDataType=getMetaDataByName(obj.repoUtil,rootSigID,'DataType');

                if~isempty(oldRootDataType)
                    oldDataType=oldRootDataType;
                end

                if~strcmp(oldDataType,newDataType)
                    doCast(obj,rootSigID,WAS_REAL,newDataType);
                    if strcmpi(newDataType,'boolean')
                        newDataType='logical';
                    end
                    fcnHandle=str2func(newDataType);
                    dataToSet.Data=fcnHandle(dataToSet.Data);
                end

                makeDataEdits(obj,rootSigID,WAS_REAL,dataToSet);
            end
        end


        function plottableIDs=getPlottableSignalIDs(obj,rootSigID)
            dataFormat=getMetaDataByName(obj.repoUtil,rootSigID,'dataformat');
            signalType=getMetaDataByName(obj.repoUtil,rootSigID,'SignalType');
            WAS_REAL=strcmp(signalType,getString(message('sl_sta_general:common:Real')));

            if contains(lower(dataFormat),lower('non_scalar_sl_timetable'))

                if WAS_REAL
                    plottableIDs=obj.repoUtil.getChildrenIDsInSiblingOrder(rootSigID);
                else
                    sliceContainers=obj.repoUtil.getChildrenIds(rootSigID);
                    plottableIDs=zeros(1,2*length(sliceContainers));
                    indexesToModify=[1,2];

                    for kChild=1:length(sliceContainers)

                        complexChildren=obj.repoUtil.getChildrenIds(sliceContainers(kChild));
                        plottableIDs(indexesToModify)=complexChildren;
                        indexesToModify=indexesToModify+2;
                    end
                end
            else

                if WAS_REAL
                    plottableIDs=rootSigID;
                else
                    plottableIDs=obj.repoUtil.getChildrenIDsInSiblingOrder(rootSigID);
                end


            end
        end


        function propertyUpdateIDs=getIDsForPropertyUpdates(obj,rootSigID)
            dataFormat=getMetaDataByName(obj.repoUtil,rootSigID,'dataformat');
            signalType=getMetaDataByName(obj.repoUtil,rootSigID,'SignalType');
            WAS_REAL=strcmp(signalType,getString(message('sl_sta_general:common:Real')));

            if contains(lower(dataFormat),lower('non_scalar_sl_timetable'))

                if WAS_REAL
                    propertyUpdateIDs=obj.repoUtil.getChildrenIDsInSiblingOrder(rootSigID);
                else
                    sliceContainers=obj.repoUtil.getChildrenIds(rootSigID);
                    propertyUpdateIDs=zeros(1,length(sliceContainers));

                    for kChild=1:(length(sliceContainers))

                        complexChildren=obj.repoUtil.getChildrenIds(sliceContainers(kChild));
                        propertyUpdateIDs(kChild)=complexChildren(1);
                    end
                end
            else

                if WAS_REAL
                    propertyUpdateIDs=rootSigID;
                else
                    propertyUpdateIDs=obj.repoUtil.getChildrenIDsInSiblingOrder(rootSigID);
                    propertyUpdateIDs=propertyUpdateIDs(1);
                end

            end
        end


        function dataToSet=getDataForSetByID(obj,signalIDForData)
            varout=obj.extractValue(signalIDForData);

            dataFormat=getMetaDataByName(obj.repoUtil,signalIDForData,'dataformat');

            timevalueUnits=obj.repoUtil.getMetaDataByName(signalIDForData,'TimeObjectClass');
            fcnH=str2func(timevalueUnits);


            dataToSet.Time=double(fcnH(varout.(varout.Properties.DimensionNames{1})));

            if contains(lower(dataFormat),lower('non_scalar_sl_timetable'))

                tmpData=varout.(varout.Properties.VariableNames{1});
                dataDims=size(tmpData);

                dataToSet.Data=reshape(tmpData,dataDims(1),prod(dataDims(2:end)));
            else
                dataToSet.Data=varout.(varout.Properties.VariableNames{1});
            end
        end


        function dataToSet=getTimeAndDataByID(obj,rootSigID)

            dataFormat=getMetaDataByName(obj.repoUtil,rootSigID,'dataformat');

            if contains(lower(dataFormat),lower('non_scalar_sl_timetable'))
                varout=obj.extractValue(rootSigID);

                timevalueUnits=obj.repoUtil.getMetaDataByName(rootSigID,'TimeObjectClass');
                fcnH=str2func(timevalueUnits);

                dataToSet.Time=double(fcnH(varout.(varout.Properties.DimensionNames{1})));
                dataToSet.Data=varout.(varout.Properties.VariableNames{1});
            else
                dataToSet=getDataForSetByID(obj,rootSigID);
            end
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

                complexSliceRootID=zeros(1,length(sliceContainers));
                for kChild=1:length(sliceContainers)
                    complexSliceRootID(kChild)=obj.repoUtil.getParent(sliceContainers(kChild));
                end

                sliceContainers=unique(complexSliceRootID);

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


        function evalTimeVals(~,the_time_valsName)
            evalStr=sprintf('%s = Time_Vals;',the_time_valsName);
            evalin('caller',evalStr);
        end

    end

    methods(Access='protected')

        function makeDataEditsNonScalar(obj,rootSigID,WAS_REAL,dataToSet)
            if WAS_REAL

                kidIDs=obj.repoUtil.getChildrenIDsInSiblingOrder(rootSigID);

                dataForSet.Time=dataToSet.Time;
                for kChild=1:length(kidIDs)

                    dataForSet.Data=dataToSet.Data(:,kChild);

                    obj.repoUtil.repo.setSignalDataValues(kidIDs(kChild),dataForSet);
                end

            else
                kidIDs=obj.repoUtil.getChildrenIds(rootSigID);

                dataForSet.Time=dataToSet.Time;

                columnToSend=1;
                for kChild=1:length(kidIDs)

                    complexChildren=obj.repoUtil.getChildrenIds(kidIDs(kChild));

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

            dataFormat=getMetaDataByName(obj.repoUtil,rootSigID,'dataformat');
            if WAS_REAL

                if contains(lower(dataFormat),lower('non_scalar_sl_timetable'))

                    kidIDs=obj.repoUtil.getChildrenIDsInSiblingOrder(rootSigID);
                    for kChild=1:length(kidIDs)
                        editDataType(obj.repoUtil,kidIDs(kChild),newDataType);
                    end
                else
                    editDataType(obj.repoUtil,rootSigID,newDataType);
                end


            else

                kidIDs=obj.repoUtil.getChildrenIDsInSiblingOrder(rootSigID);

                for kChild=1:length(kidIDs)
                    editDataType(obj.repoUtil,kidIDs(kChild),newDataType);
                    editDataType(obj.repoUtil,kidIDs(2),newDataType);

                end
            end

        end

    end
end
