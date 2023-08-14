classdef MessageManager



    properties(Constant)
        AvailableManagers=[
        slwebwidgets.tableeditor.messagemanager.ScalarSignal,...
        slwebwidgets.tableeditor.messagemanager.NonScalarTS,...
        slwebwidgets.tableeditor.messagemanager.NonScalarTimeTableNDTS,...
        slwebwidgets.tableeditor.messagemanager.FunctionCall,...
        slwebwidgets.tableeditor.messagemanager.DataArray

        ];
    end

    methods(Static)


        function aManager=getMessageManager(signalID)
            aManager=[];


            for kManager=1:length(slwebwidgets.tableeditor.messagemanager.MessageManager.AvailableManagers)

                if slwebwidgets.tableeditor.messagemanager.MessageManager.AvailableManagers(kManager).isSupported(signalID)
                    aManager=slwebwidgets.tableeditor.messagemanager.MessageManager.AvailableManagers(kManager);
                    return;
                end

            end

        end


        function fiDataObj=makeFiDataTableStruct(idealSignalValue,fiSignalValue,errorMetaData)

            jsonSafeIdeal=slwebwidgets.tableeditor.makeJsonSafe(idealSignalValue);
            jsonSafeFixdt=slwebwidgets.tableeditor.makeJsonSafe(double(fiSignalValue));

            fiDataObj.value=jsonSafeIdeal{1};

            fiDataObj.fixdtvalue=jsonSafeFixdt{1};



            fiDataObj.isoverflow=errorMetaData.numOverflows;
            fiDataObj.isunderflow=errorMetaData.numUnderflows;

            if isfield(errorMetaData,'realOverflow')
                fiDataObj.isoverflowreal=errorMetaData.realOverflow;
                fiDataObj.isoverflowimag=errorMetaData.imagOverflow;
                fiDataObj.isunderflowreal=errorMetaData.realUnderflow;
                fiDataObj.isunderflowimag=errorMetaData.imagUnderflow;
            end



            jsonSafeError=slwebwidgets.tableeditor.makeJsonSafe(errorMetaData.error);
            jsonSafeAbsError=slwebwidgets.tableeditor.makeJsonSafe(errorMetaData.absError);
            jsonSafeRelError=slwebwidgets.tableeditor.makeJsonSafe(errorMetaData.relError);
            fiDataObj.errorabs=jsonSafeAbsError{1};
            fiDataObj.error=jsonSafeError{1};
            fiDataObj.errorrel=jsonSafeRelError{1};

        end


        function complexInt64Str=stringifyComplexInt64(inVal)

            complexInt64Str=datacreation.internal.stringifyComplexInt64(inVal);

        end


        function msgOut=sendSignalDataMessage(signalID,appID,tableID)


            aManager=slwebwidgets.tableeditor.messagemanager.MessageManager.getMessageManager(signalID);


            [msgOut,errMsg]=constructMessage(aManager,signalID);

            tableTopics=slwebwidgets.tableeditor.TableViewTopics(appID,tableID);
            baseMsg='staeditor';

            if~isempty(errMsg)

                fullChannel=sprintf('/staeditor%s/%s',appID,tableTopics.REPORT_TABLE_ERROR);
                message.publish(fullChannel,errMsg);

                fullChannel=sprintf('/%s%s/%s',baseMsg,...
                appID,...
                tableTopics.SPINNER);
                msgOutSpinner.spinnerID='TableViewRequestSpinner';
                msgOutSpinner.spinnerOn=false;
                message.publish(fullChannel,msgOutSpinner);
                return;
            end


            fullChannel=tableTopics.serverSideSignalUpdateTopic;
            message.publish(fullChannel,msgOut);

        end

    end
end

