classdef RepositoryUtility








    properties
repo
    end


    methods


        function obj=RepositoryUtility(varargin)


            if isempty(varargin)
                obj.repo=sdi.Repository(true);
            elseif isa(varargin{1},'Simulink.sdi.internal.Engine')
                obj.repo=varargin{1}.sigRepository;
            elseif isa(varargin{1},'sdi.Repository')
                obj.repo=varargin{1};
            else
                obj.repo=[];
            end
        end


        function dataFormat=getSignalDataFormat(obj,dbId)

            dataFormat=obj.getMetaDataByName(dbId,'dataformat');
        end


        function varName=getVariableName(obj,dbId)





            varName=obj.repo.getSignalName(dbId);
        end


        function varName=getSignalLabel(obj,dbId)

            s=Simulink.sdi.Signal(obj.repo,dbId);
            varName=s.Name;
        end


        function setSignalLabel(obj,dbId,sigLabel)


            obj.repo.setSignalLabel(dbId,char(sigLabel));
        end


        function dataValues=getSignalDataValues(obj,dbId)
            dataValues=obj.repo.getSignalDataValues(dbId);
        end


        function childIds=getChildrenIds(obj,dbId)
            childIds=obj.repo.getSignalChildren(dbId);
        end


        function metaValue=getMetaDataByName(obj,dbId,metaName)
            try
                s=Simulink.sdi.Signal(obj.repo,dbId);
                metaStruct=s.getMetaData();


                if isfield(metaStruct,metaName)
                    metaValue=metaStruct.(metaName);
                else

                    metaValue=s.getMetaData(metaName);
                end
            catch
                metaValue=[];
            end
        end


        function metaValue=getMetaDataStructure(obj,dbId)
            try
                s=Simulink.sdi.Signal(obj.repo,dbId);
                metaValue=s.getMetaData();
            catch
                metaValue=[];
            end
        end


        function setMetaDataByName(obj,dbId,metaName,metaVal)

            s=Simulink.sdi.Signal(obj.repo,dbId);
            metaValue=s.getMetaData();
            metaValue.(metaName)=metaVal;
            s.setMetaData(metaValue);

        end


        function[timeValues,dataValues]=getSignalTimeAndDataValues(obj,dbId)
            timeValues=[];
            dataValues=[];

            isComplex=strcmpi(obj.getMetaDataByName(dbId,'SignalType'),getString(message('sl_sta_general:common:Complex')));

            if isComplex
                kidIDs=obj.getChildrenIds(dbId);


                dataValreal=obj.getSignalDataValues(kidIDs(1));
                dataValimg=obj.getSignalDataValues(kidIDs(2));

                if~isempty(dataValreal)&&~isempty(dataValimg)
                    dataVals.Time=dataValreal.Time;
                    vals=complex(dataValreal.Data,dataValimg.Data);
                    dataVals.Data=vals;
                end

            else

                dataVals=obj.getSignalDataValues(dbId);
            end

            if~isempty(dataVals)







                dataValues=dataVals.Data;

                timeValues=dataVals.Time;
            end
        end


        function[timeValues,dataValues]=getSignalTimeAndDataValuesNDim(obj,dbId,dbIdParent)
            timeValues=[];
            dataValues=[];

            isComplex=strcmpi(obj.getMetaDataByName(dbIdParent,'SignalType'),getString(message('sl_sta_general:common:Complex')));

            if isComplex
                kidIDs=obj.getChildrenIds(dbId);


                dataValreal=obj.getSignalDataValues(kidIDs(1));
                dataValimg=obj.getSignalDataValues(kidIDs(2));

                if~isempty(dataValreal)&&~isempty(dataValimg)
                    dataVals.Time=dataValreal.Time;
                    vals=complex(dataValreal.Data,dataValimg.Data);
                    dataVals.Data=vals;
                end

            else

                dataVals=obj.getSignalDataValues(dbId);
            end

            if~isempty(dataVals)







                dataValues=dataVals.Data;

                timeValues=dataVals.Time;
            end
        end


        function simulinkSignal=getSimulinkSignalByID(~,dbId,varargin)

            aFactory=starepository.repositorysignal.Factory;

            try

                concreteExtractor=aFactory.getSupportedExtractor(dbId);

                [simulinkSignal,~]=concreteExtractor.extractValue(dbId,varargin{:});
            catch ME
                rethrow(ME);
            end
        end


        function units=getUnit(obj,dbId)


            try
                s=Simulink.sdi.Signal(obj.repo,dbId);
                unitstr=s.Units;


                if(getMetaDataByName(obj,dbId,'UnitsIsObject'))
                    units=Simulink.SimulationData.Unit(unitstr);
                else
                    units=unitstr;
                end

            catch

                units='';
            end
        end


        function setUnit(obj,dbId,newUnitValue)

            if isStringScalar(newUnitValue)
                newUnitValue=char(newUnitValue);
            end

            s=Simulink.sdi.Signal(obj.repo,dbId);

            if ischar(newUnitValue)
                setMetaDataByName(obj,dbId,'UnitsIsObject',0);
                s.Units=newUnitValue;
            elseif isa(newUnitValue,'Simulink.SimulationData.Unit')
                setMetaDataByName(obj,dbId,'UnitsIsObject',1);
                s.Units=newUnitValue.Name;
            end
        end


        function Signals=getSignalValuesAndNames(~,dbIds)

            aFactory=starepository.repositorysignal.Factory;

            Signals.Data={};
            Signals.Names={};

            for k=1:length(dbIds)


                concreteExtractor=aFactory.getSupportedExtractor(dbIds(k));
                [Signals.Data{k},Signals.Names{k}]=concreteExtractor.extractValue(dbIds(k));

            end


        end


        function setInterpMethod(obj,dbId,interpMethod)

            if isStringScalar(interpMethod)
                interpMethod=char(interpMethod);
            end

            s=Simulink.sdi.Signal(obj.repo,dbId);
            s.InterpMethod=interpMethod;
        end

        function interpMethod=getInterpMethod(obj,dbId)
            s=Simulink.sdi.Signal(obj.repo,dbId);
            interpMethod=s.InterpMethod;
        end


        function setParent(~,childSigID,parentSigID,varargin)

            sdiRepo=sdi.Repository(true);


            sdiRepo.setParent(childSigID,parentSigID);



            if(parentSigID~=0)

                sibManager=sta.ChildManager();

                if~isempty(varargin)
                    nChildren=varargin{1};
                else
                    childrenOfParent=sibManager.getChildIDs(parentSigID);
                    nChildren=length(childrenOfParent)+1;
                end


                sibOrder=sta.ChildOrder();
                sibOrder.ParentID=parentSigID;
                sibOrder.ChildID=childSigID;
                sibOrder.SignalOrder=nChildren;
            end

        end


        function parentID=getParent(obj,sigID)

            parentID=getSignalParent(obj.repo,sigID);

        end


        function removeParent(~,childSigID)



            sdiRepo=sdi.Repository(true);


            sdiRepo.setParent(childSigID,0);

            sibManager=sta.ChildManager();

            sibManager.remove(childSigID);
        end


        function childIDs=getChildrenIDsInSiblingOrder(~,parentID)
            sibManager=sta.ChildManager();

            try
                childIDs=sibManager.getChildIDs(parentID);
            catch ME

                if strcmp(ME.identifier,'MATLAB:class:RequireScalar')
                    DAStudio.error('sl_sta_repository:sta_repository:mustBeNumericScalar');
                end

            end
        end


        function replaceChild(obj,childToReplaceID,childID)

            parentSigID=obj.repo.getSignalParent(childToReplaceID);

            sdiRepo=sdi.Repository(true);


            sdiRepo.setParent(childID,parentSigID);
            sdiRepo.setParent(childToReplaceID,0);


            sibManager=sta.ChildManager();
            sibManager.replaceChild(childToReplaceID,childID);
        end


        function insertChildAtTop(~,childIDToAdd,parentID)




            childMgr=sta.ChildManager();
            childIDs=getChildOrderIDs(childMgr,parentID);

            sdiRepo=sdi.Repository(true);


            sdiRepo.setParent(childIDToAdd,parentID);


            sibOrder=sta.ChildOrder();
            sibOrder.ParentID=parentID;
            sibOrder.ChildID=childIDToAdd;
            sibOrder.SignalOrder=1;

            for k=1:length(childIDs)
                sibToMove=sta.ChildOrder(childIDs(k));
                sibToMove.SignalOrder=k+1;

            end



        end


        function insertChildAtBottom(~,childIDToAdd,parentID)




            childMgr=sta.ChildManager();
            childIDs=getChildOrderIDs(childMgr,parentID);

            sdiRepo=sdi.Repository(true);


            sdiRepo.setParent(childIDToAdd,parentID);


            sibOrder=sta.ChildOrder();
            sibOrder.ParentID=parentID;
            sibOrder.ChildID=childIDToAdd;
            sibOrder.SignalOrder=length(childIDs)+1;









        end


        function topMostRelativeID=getOldestRelative(obj,sigID)

            parentID=getParent(obj,sigID);

            if(parentID==0)
                topMostRelativeID=sigID;
            else
                topMostRelativeID=getOldestRelative(obj,parentID);
            end
        end




        function addDataPointAtTime(~,sigIDToEdit,time,data)




            sdiRepo=sdi.Repository(true);
            addSignalTimePoint(sdiRepo,...
            sigIDToEdit,...
            time,...
            data);
        end


        function removeDataBetweenTimes(~,sigIDToEdit,startTime,stopTime)








            sdiRepo=sdi.Repository(true);


            removeSignalTimePoints(sdiRepo,...
            sigIDToEdit,...
            startTime,...
            stopTime);

        end


        function removeDataAtTime(~,sigIDToEdit,startTime)






            sdiRepo=sdi.Repository(true);


            removeSignalTimePoints(sdiRepo,...
            sigIDToEdit,...
            startTime,...
            startTime);

        end


        function editDataType(~,sigIDToEdit,newType)


            sdiRepo=sdi.Repository(true);

            try
                changeSignalDataType(sdiRepo,sigIDToEdit,newType);
            catch ME



                if strcmp(ME.identifier,'simulation_data_repository:sdr:ChangeSignalTypeInvalid')
                    DAStudio.error('sl_sta_repository:sta_repository:conversionNotSupported',newType);
                else
                    throwAsCaller(ME);
                end
            end
        end


        function newSigID=copySignalAndMetaDataByID(~,signalID)






            repoManager=sta.RepositoryManager();
            newSigID=repoManager.copySignalByID(signalID);
        end


        function newSigID=copySignalMetaDataByIDRecursive(obj,signalID)

            newSigID=copySignalAndMetaDataByID(obj,signalID);

            copySiblingOrder(obj,newSigID);

        end


        function copySiblingOrder(obj,newSigID)

            childIds=obj.repo.getSignalChildren(newSigID);

            for k=1:length(childIds)

                setParent(obj,childIds(k),newSigID,k);

                copySiblingOrder(obj,childIds(k));
            end

        end


        function[newJsonStruct,newSigIDs,newExternalSourceIDs]=copyAndReplaceEditorScenario(obj,jsonStructIn,scenarioid)
            newJsonStruct=jsonStructIn;
            signalOrderOfSiblings=1;
            currentParentID=0;%#ok<NASGU>

            newSigIDs=-1*ones(1,length(jsonStructIn));
            newExternalSourceIDs=-1*ones(1,length(jsonStructIn));
            oldSigIDs=-1*ones(1,length(jsonStructIn));

            for k=1:length(jsonStructIn)


                newSigID=copySignalAndMetaDataByID(obj,jsonStructIn{k}.ID);
                newSigIDs(k)=newSigID;
                oldSigIDs(k)=jsonStructIn{k}.ID;


                newJsonStruct{k}.ID=newSigID;


                if ischar(newJsonStruct{k}.ParentID)&&...
                    strcmp(newJsonStruct{k}.ParentID,'input')


                    currentParentID=newJsonStruct{k}.ID;%#ok<NASGU>


                    signalOrderOfSiblings=1;


                    repoManager=sta.RepositoryManager();
                    removeExternalSourceFromScenario(repoManager,scenarioid,jsonStructIn{k}.ID);


                    aNewExternalSource=sta.ExternalSource;
                    aNewExternalSource.ScenarioID=scenarioid;
                    aNewExternalSource.SignalID=newJsonStruct{k}.ID;


                    newExternalSourceIDs(k)=aNewExternalSource.ID;
                else

                    currentParentID=newSigIDs(oldSigIDs==newJsonStruct{k}.ParentID);


                    setParent(obj,newJsonStruct{k}.ID,currentParentID,signalOrderOfSiblings);


                    signalOrderOfSiblings=signalOrderOfSiblings+1;


                    newJsonStruct{k}.ParentID=currentParentID;
                    obj.setMetaDataByName(newJsonStruct{k}.ID,'ParentID',currentParentID);
                end
            end



            newExternalSourceIDs(newExternalSourceIDs==-1)=[];

        end


        function boolAOB=hasAoBLineage(obj,dbId)
            boolAOB=false;
            if dbId==0
                return
            end

            if strcmp(obj.getMetaDataByName(dbId,'dataformat'),'aobbusstructure')
                boolAOB=true;
                return;
            end

            while dbId~=0

                dbId=obj.getParent(dbId);

                if dbId~=0&&strcmp(obj.getMetaDataByName(dbId,'dataformat'),'aobbusstructure')
                    boolAOB=true;
                    break;
                end

            end

        end


        function arrayOfProps=rearrangeTreeOrder(obj,signalIDs,arrayOfProps,treeOrderCount)

            for kID=1:length(signalIDs)

                signalType=obj.getMetaDataByName(signalIDs(kID),'SignalType');
                IS_COMPLEX=strcmp(signalType,getString(message('sl_sta_general:common:Complex')));


                if IS_COMPLEX

                    dataformat=obj.getMetaDataByName(signalIDs(kID),'dataformat');
                    IS_MULTIDIM=contains(dataformat,'multidimtimeseries');
                    IS_NON_SCALAR_TT=contains(dataformat,'non_scalar_sl_timetable');
                    IS_NDIM=contains(dataformat,'ndimtimeseries');

                    treeOrderCount=treeOrderCount+1;
                    kProp=length(arrayOfProps)+1;

                    if IS_NON_SCALAR_TT||IS_NDIM
                        signalChildrenIDs=getChildrenIds(obj,signalIDs(kID));
                        arrayOfProps(kProp).id=signalIDs(kID);
                        arrayOfProps(kProp).propertyname='TreeOrder';
                        arrayOfProps(kProp).newValue=treeOrderCount;
                        kProp=kProp+1;

                        obj.repo.safeTransaction(@obj.setMetaDataByName,signalIDs(kID),...
                        'TreeOrder',...
                        treeOrderCount);

                        for kMultiKid=1:length(signalChildrenIDs)
                            mutlicomplexID=getChildrenIDsInSiblingOrder(obj,signalChildrenIDs(kMultiKid));
                            arrayOfProps(kProp).id=mutlicomplexID(1);
                            arrayOfProps(kProp).propertyname='TreeOrder';
                            arrayOfProps(kProp).newValue=treeOrderCount;

                            obj.repo.safeTransaction(@obj.setMetaDataByName,mutlicomplexID(1),...
                            'TreeOrder',...
                            treeOrderCount);

                            treeOrderCount=treeOrderCount+1;
                            kProp=length(arrayOfProps)+1;
                        end

                    elseif IS_MULTIDIM
                        signalChildrenIDs=getChildrenIDsInSiblingOrder(obj,signalIDs(kID));

                        arrayOfProps(kProp).id=signalIDs(kID);
                        arrayOfProps(kProp).propertyname='TreeOrder';
                        arrayOfProps(kProp).newValue=treeOrderCount;
                        kProp=kProp+1;

                        obj.repo.safeTransaction(@obj.setMetaDataByName,signalIDs(kID),...
                        'TreeOrder',...
                        treeOrderCount);

                        for kMultiKid=1:length(signalChildrenIDs)
                            treeOrderCount=treeOrderCount+1;
                            mutlicomplexID=getChildrenIDsInSiblingOrder(obj,signalChildrenIDs(kMultiKid));
                            arrayOfProps(kProp).id=mutlicomplexID(1);
                            arrayOfProps(kProp).propertyname='TreeOrder';
                            arrayOfProps(kProp).newValue=treeOrderCount;
                            obj.repo.safeTransaction(@obj.setMetaDataByName,mutlicomplexID(1),...
                            'TreeOrder',...
                            treeOrderCount);

                            kProp=length(arrayOfProps)+1;
                        end


                    else
                        signalChildrenIDs=getChildrenIDsInSiblingOrder(obj,signalIDs(kID));
                        arrayOfProps(kProp).id=signalChildrenIDs(1);
                        arrayOfProps(kProp).propertyname='TreeOrder';
                        arrayOfProps(kProp).newValue=treeOrderCount;
                        obj.repo.safeTransaction(@obj.setMetaDataByName,signalIDs(kID),...
                        'TreeOrder',...
                        treeOrderCount);
                        obj.repo.safeTransaction(@obj.setMetaDataByName,signalChildrenIDs(1),...
                        'TreeOrder',...
                        treeOrderCount);
                    end

                else
                    treeOrderCount=treeOrderCount+1;
                    kProp=length(arrayOfProps)+1;
                    arrayOfProps(kProp).id=signalIDs(kID);
                    arrayOfProps(kProp).propertyname='TreeOrder';
                    arrayOfProps(kProp).newValue=treeOrderCount;

                    obj.repo.safeTransaction(@obj.setMetaDataByName,signalIDs(kID),...
                    'TreeOrder',...
                    treeOrderCount);


                    signalChildrenIDs=getChildrenIDsInSiblingOrder(obj,signalIDs(kID));

                    if~isempty(signalChildrenIDs)

                        arrayOfProps=rearrangeTreeOrder(obj,signalChildrenIDs,arrayOfProps,treeOrderCount);
                        IS_TREEORDER=strcmpi({arrayOfProps(:).propertyname},'treeorder');

                        lastidx=find(IS_TREEORDER==1,1,'last');

                        treeOrderCount=arrayOfProps(lastidx).newValue;
                    end
                end

            end

        end


        function transformLoggedSignalsForContainer(obj,sourceID,destID)
            sourceFormatType=getMetaDataByName(obj,sourceID,'dataformat');
            destFormatType=getMetaDataByName(obj,destID,'dataformat');

            foundSLTSIdx=strfind(sourceFormatType,'simulinktimeseries');

            foundLoggedSignalIdx=strfind(sourceFormatType,'loggedsignal');


            isDEST_BUS=false;
            foundanyBusFormIDX=strfind(destFormatType,'busstructure');

            if~isempty(foundanyBusFormIDX)%#ok<STREMP>
                isDEST_BUS=true;
            end


            if~isempty(foundSLTSIdx)&&isDEST_BUS


                newSourceFormat=strrep(sourceFormatType,'simulinktimeseries','timeseries');
                obj.repo.safeTransaction(@obj.setMetaDataByName,sourceID,'dataformat',newSourceFormat);
            end

            if~isempty(foundLoggedSignalIdx)&&isDEST_BUS %#ok<STREMP>


                foundSL_Signal_TS=strfind(sourceFormatType,'timeseries');

                if~isempty(foundSLTSIdx)||~isempty(foundSL_Signal_TS)%#ok<STREMP>
                    obj.repo.safeTransaction(@obj.setMetaDataByName,sourceID,'dataformat','timeseries');
                end


                foundSL_Signal_MULTIDIMTS=strfind(sourceFormatType,'multidimtimeseries');

                if~isempty(foundSLTSIdx)||~isempty(foundSL_Signal_MULTIDIMTS)%#ok<STREMP>
                    obj.repo.safeTransaction(@obj.setMetaDataByName,sourceID,'dataformat','multidimtimeseries');
                end


                foundSL_Signal_NDIMTS=strfind(sourceFormatType,'ndimtimeseries');

                if~isempty(foundSLTSIdx)||~isempty(foundSL_Signal_NDIMTS)%#ok<STREMP>
                    obj.repo.safeTransaction(@obj.setMetaDataByName,sourceID,'dataformat','ndimtimeseries');
                end


                foundSL_Signal_AOB=strfind(sourceFormatType,'aobbusstructure');

                if~isempty(foundSL_Signal_AOB)
                    obj.repo.safeTransaction(@obj.setMetaDataByName,sourceID,'dataformat','aobbusstructure');
                end


                foundSL_Signal_BUS=strfind(sourceFormatType,'busstructure');

                if~isempty(foundSL_Signal_BUS)&&isempty(foundSL_Signal_AOB)%#ok<STREMP>
                    obj.repo.safeTransaction(@obj.setMetaDataByName,sourceID,'dataformat','busstructure');
                end

            end
        end


        function signalNames=getSignalNames(obj,topLevelSignalIDs)
            N_IDS=length(topLevelSignalIDs);
            signalNames=cell(1,N_IDS);
            for k=1:N_IDS
                signalNames{k}=obj.getSignalLabel(topLevelSignalIDs(k));
            end
        end
    end


    methods

        function topIDsOrdered=getTopLevelIDsInTreeOrder(obj,scenarFileID)

            rimScenarioFile=sta.Scenario(scenarFileID);
            allScenario_IDS=getSignalIDs(rimScenarioFile);

            treeOrders=-1*ones(1,length(allScenario_IDS));

            for k=1:length(allScenario_IDS)
                treeOrders(k)=getMetaDataByName(obj,allScenario_IDS(k),'TreeOrder');
            end

            [~,idx]=sort(treeOrders);

            topIDsOrdered=allScenario_IDS(idx);
        end

    end


    methods

        function idForDisplays=resolveSignalIdForProperties(obj,suspectID)

            idForDisplays=suspectID;

            signalType=getMetaDataByName(obj,suspectID,'SignalType');

            if~isempty(signalType)
                IS_COMPLEX=strcmp(signalType,getString(message('sl_sta_general:common:Complex')));

                if IS_COMPLEX
                    realImagIDs=getChildrenIDsInSiblingOrder(obj,suspectID);
                    idForDisplays=double(realImagIDs(1));
                end
            end
        end
    end
end

