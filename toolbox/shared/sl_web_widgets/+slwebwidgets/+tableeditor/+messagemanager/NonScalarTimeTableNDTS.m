classdef NonScalarTimeTableNDTS<slwebwidgets.tableeditor.messagemanager.BaseMessageManager





    methods

        function bool=isSupported(obj,signalID)
            repoUtil=starepository.RepositoryUtility();
            dataFormat=getMetaDataByName(repoUtil,signalID,'dataformat');

            isNDIM=contains(dataFormat,'ndimtimeseries');
            IS_NON_SCALAR_TIMETABLE=contains(dataFormat,'non_scalar_sl_timetable');

            bool=isNDIM||IS_NON_SCALAR_TIMETABLE;
        end


        function[msgOut,errMsg]=constructMessage(obj,signalID)
            msgOut.signaldatavalues={};
            errMsg=[];

            repoUtil=starepository.RepositoryUtility();
            dataType=getMetaDataByName(repoUtil,signalID,'EnumName');

            IS_ENUM=false;
            if~isempty(dataType)
                IS_ENUM=true;
            end

            childIDsInOrder=getChildrenIds(repoUtil,signalID);

            [timeValues,dataValues]=getSignalTimeAndDataValuesNDim(...
            repoUtil,childIDsInOrder(1),signalID);

            fixDtOverride=getMetaDataByName(repoUtil,signalID,'FixDTOverrideType');
            fiTypeToCast=[];
            if~isempty(fixDtOverride)
                if~isempty(strfind(fixDtOverride,'fixdt'))
                    fiTypeToCast=eval(fixDtOverride);
                    dataValues=fi(dataValues,fiTypeToCast);
                else
                    dataValues=fi(dataValues,fixdt(fixDtOverride));
                end
            end

            IS_ENUM_VALS=isenum(dataValues);
            if IS_ENUM_VALS


                dataValues=dataValues.string;
            elseif IS_ENUM&&~IS_ENUM_VALS
                dataType=getMetaDataByName(repoUtil,signalID,'EnumName');

                errMsg.closeTableView=true;
                errMsg.errorMessage=DAStudio.message('sl_sta:editor:enumModified',dataType);
                return;
            end


            msg.signaltime=timeValues;
            IS_FIDATA=isfi(dataValues);

            if IS_FIDATA

                msg.signaldata0=dataValues;

                NUM_KIDS=length(childIDsInOrder);

                for k=1:NUM_KIDS-1

                    [~,dataValues]=getSignalTimeAndDataValuesNDim(...
                    repoUtil,childIDsInOrder(k+1),signalID);

                    if~isempty(fixDtOverride)
                        dataValues=fi(dataValues,fiTypeToCast);
                    end

                    msg.(['signaldata',num2str(k)])=dataValues;
                end

                for kTime=1:length(msg.signaltime)

                    tmpCell=cell(1,NUM_KIDS+1);
                    tmpCell{1}=msg.signaltime(kTime);

                    for kChild=1:NUM_KIDS
                        msgData=msg.(['signaldata',num2str(kChild-1)])(kTime);

                        fiVal=msgData;
                        aNumericType=fiVal.numerictype;
                        errorMeta=slwebwidgets.AuthorUtility.quantizeRWValues(double(msgData),aNumericType,fiVal.OverflowMode,fiVal.RoundMode);


                        fiDataObj=makeFiDataTableStruct(obj,msgData,msgData,errorMeta);
                        tmpCell{kChild+1}=fiDataObj;
                    end

                    msgOut.signaldatavalues{kTime}=tmpCell;
                end

            else
                msg.signaldata0=slwebwidgets.tableeditor.makeJsonSafe(dataValues);

                NUM_KIDS=length(childIDsInOrder);

                for k=1:NUM_KIDS-1

                    [~,dataValues]=getSignalTimeAndDataValuesNDim(...
                    repoUtil,childIDsInOrder(k+1),signalID);
                    if IS_ENUM_VALS



                        dataValues=dataValues.string;
                    end

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

end
