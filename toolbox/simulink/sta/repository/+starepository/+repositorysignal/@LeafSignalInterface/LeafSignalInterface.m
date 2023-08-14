classdef LeafSignalInterface<starepository.repositorysignal.RepositorySignal




    methods

        function possibleParentID=findFirstPossibleParent(obj,idOfSignal,dbIdParent)%#ok<INUSL>
            possibleParentID=dbIdParent;

            while possibleParentID~=0


                if~isempty(obj.repoUtil.getMetaDataByName(possibleParentID,...
                    'dataformat'))
                    IS_BUS_PARENT=contains(obj.repoUtil.getMetaDataByName(possibleParentID,...
                    'dataformat'),'bus')&&~contains(obj.repoUtil.getMetaDataByName(possibleParentID,...
                    'dataformat'),'aob')&&~contains(obj.repoUtil.getMetaDataByName(possibleParentID,...
                    'dataformat'),'groundorpartialspecifiedbus');
                    HAS_AOB_LINEAGE=obj.repoUtil.hasAoBLineage(possibleParentID);
                    if strcmpi(obj.repoUtil.getMetaDataByName(possibleParentID,...
                        'dataformat'),'dataset')||...
                        (IS_BUS_PARENT&&~HAS_AOB_LINEAGE)

                        break;
                    end
                end

                possibleParentID=obj.repoUtil.getParent(possibleParentID);
            end

        end


        function editSignalData(obj,rootSigID,sigID,newDataType,dataToSet)


            signalType=getMetaDataByName(obj.repoUtil,rootSigID,'SignalType');
            WAS_REAL=strcmp(signalType,getString(message('sl_sta_general:common:Real')));

            oldDataType=getMetaDataByName(obj.repoUtil,sigID,'DataType');
            oldRootDataType=getMetaDataByName(obj.repoUtil,rootSigID,'DataType');

            if~isempty(oldRootDataType)
                oldDataType=oldRootDataType;
            end




            nospaceDT=newDataType;
            nospaceDT(isspace(nospaceDT))=[];
            if strcmp(oldDataType,nospaceDT)

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

                    if~isfi(dataToSet.Data)
                        fcnHandle=str2func(newDataType);
                        dataToSet.Data=fcnHandle(dataToSet.Data);
                    else
                        dataToSet.Data=fi(dataToSet.Data,eval(newDataType));
                    end

                    dataToSet.Time=dataToSet.Time;


                    makeDataEdits(obj,rootSigID,WAS_REAL,dataToSet);

                catch ME_SETDATA_AFTER_CAST %#ok<NASGU>

                end
            end


        end


        function addSignalDataPoint(obj,rootSigID,sigID,dataToSet)%#ok<INUSL>            




            signalType=getMetaDataByName(obj.repoUtil,rootSigID,'SignalType');
            WAS_REAL=strcmp(signalType,getString(message('sl_sta_general:common:Real')));


            makeDataEdits(obj,rootSigID,WAS_REAL,dataToSet);
        end



        function setDataByID(obj,rootSigID,signalIDForData)





            sigID=rootSigID;

            dataType=getMetaDataByName(obj.repoUtil,rootSigID,'DataType');


            dataToSet=getDataForSetByID(obj,signalIDForData);
            obj.editSignalData(rootSigID,sigID,dataType,dataToSet);

        end


        function dataVal=getADataValue(obj,rootSigID)




            [~,Vals]=obj.repoUtil.getSignalTimeAndDataValues(rootSigID);
            dataVal=Vals(1);
        end


        function Vals=resolveEmptyValues(obj,Vals,theType)%#ok<INUSL>


            if(~isfi(Vals)||~contains(theType,'fixdt'))&&(~isfi(Vals)&&~contains(theType,'fixdt'))

                Vals=eval([theType,'.empty(0,1)']);
            else
                Vals=fi(double.empty(0,1),eval(theType));
            end
        end
    end

    methods(Access='protected')


        function makeDataEdits(obj,rootSigID,WAS_REAL,dataToSet)
            if WAS_REAL

                obj.repoUtil.repo.setSignalDataValues(rootSigID,dataToSet);

            else

                complexChildren=int32(obj.repoUtil.getChildrenIDsInSiblingOrder(rootSigID));

                columnToSend=1;

                realPartSigID=complexChildren(1);
                imgPartSigID=complexChildren(2);

                dataForSetReal.Time=dataToSet.Time;
                dataForSetReal.Data=real(dataToSet.Data(:,columnToSend));

                dataForSetImag.Time=dataToSet.Time;
                dataForSetImag.Data=imag(dataToSet.Data(:,columnToSend));

                Simulink.sdi.internal.legacySetSignalValues(realPartSigID,dataForSetReal);
                Simulink.sdi.internal.legacySetSignalValues(imgPartSigID,dataForSetImag);
            end
        end


        function doCast(obj,rootSigID,WAS_REAL,newDataType)
            if WAS_REAL

                editDataType(obj.repoUtil,rootSigID,newDataType);
                setMetaDataByName(obj.repoUtil,rootSigID,'DataType',newDataType);

            else

                complexChildren=int32(obj.repoUtil.getChildrenIDsInSiblingOrder(rootSigID));


                sdiRepo=sdi.Repository(true);
                realPartSigID=complexChildren(1);
                imagPartSigID=complexChildren(2);

                changeSignalDataType(sdiRepo,realPartSigID,newDataType);
                changeSignalDataType(sdiRepo,imagPartSigID,newDataType);

                setMetaDataByName(obj.repoUtil,rootSigID,'DataType',newDataType);
                setMetaDataByName(obj.repoUtil,realPartSigID,'DataType',newDataType);
                setMetaDataByName(obj.repoUtil,imagPartSigID,'DataType',newDataType);


            end

        end
    end
end

