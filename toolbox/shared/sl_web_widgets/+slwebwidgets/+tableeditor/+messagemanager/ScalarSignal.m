classdef ScalarSignal<slwebwidgets.tableeditor.messagemanager.BaseMessageManager





    methods

        function bool=isSupported(obj,signalID)
            repoUtil=starepository.RepositoryUtility();
            dataFormat=getMetaDataByName(repoUtil,signalID,'dataformat');

            isNDIM=contains(dataFormat,'ndimtimeseries');
            is3D=contains(dataFormat,'multidimtimeseries');
            containsTS=contains(dataFormat,'timeseries');

            isScalarTS=containsTS&&~(isNDIM||is3D);

            IS_NON_SCALAR_TIMETABLE=contains(dataFormat,'non_scalar_sl_timetable');
            conatinsTT=contains(dataFormat,'sl_timetable');

            isScalarTT=conatinsTT&&~IS_NON_SCALAR_TIMETABLE;

            bool=isScalarTS||isScalarTT;
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

            complexStr=getMetaDataByName(repoUtil,signalID,'SignalType');

            warnFlag=warning('query','MATLAB:class:InvalidEnum');
            warning('OFF','MATLAB:class:InvalidEnum');

            if strcmpi(complexStr,DAStudio.message('sl_sta_general:common:Complex'))


                parentID=signalID;
                [timeValues,dataValues]=getSignalTimeAndDataValues(repoUtil,parentID);
            else

                [timeValues,dataValues]=getSignalTimeAndDataValues(repoUtil,signalID);
            end


            fixDtOverride=getMetaDataByName(repoUtil,signalID,'FixDTOverrideType');

            if~isempty(fixDtOverride)
                if~isempty(strfind(fixDtOverride,'fixdt'))
                    fiType=eval(fixDtOverride);
                    dataValues=fi(dataValues,fiType);
                else
                    dataValues=fi(dataValues,fixdt(fixDtOverride));
                end
            end

            warning(warnFlag.state,'MATLAB:class:InvalidEnum');

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
            msg.isdataarray=false;
            IS_FIDATA=isfi(dataValues);

            if IS_FIDATA

                for k=1:length(msg.signaltime)
                    fiVal=dataValues(k);

                    errorMeta=slwebwidgets.AuthorUtility.quantizeRWValues(dataValues(k),fiVal.numerictype,fiVal.OverflowMode,fiVal.RoundMode);

                    fiDataObj=makeFiDataTableStruct(obj,double(dataValues(k)),dataValues(k),errorMeta);
                    msgOut.signaldatavalues{k}={msg.signaltime(k),fiDataObj};

                end

            else
                msg.signaldata=slwebwidgets.tableeditor.makeJsonSafe(dataValues);
                for k=1:length(msg.signaltime)
                    msgOut.signaldatavalues{k}={msg.signaltime(k),msg.signaldata{k}};
                end
            end


        end

    end

end
