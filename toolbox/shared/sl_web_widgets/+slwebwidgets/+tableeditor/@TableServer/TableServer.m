classdef TableServer<handle





    properties
Dispatcher
    end

    methods

        function aTableServer=TableServer(varargin)

            if nargin>0
                aTableServer.Dispatcher=varargin{1};
            end

            subscribe(aTableServer.Dispatcher,'getsignaldata',@aTableServer.msgcb_getSignalData);
            subscribe(aTableServer.Dispatcher,'updatesignaldata',@aTableServer.msgcb_updateSignalData);
        end


        function msgcb_getSignalData(aTableServer,msg)

            signalID=msg.signalID;
            appID=msg.appID;
            tableID=msg.tableID;

            slwebwidgets.tableeditor.getSTASignalDataForMW(signalID,appID,tableID);
        end


        function msgcb_updateSignalData(aTableServer,msg)
            workSignalID=msg.signalID;
            appID=msg.appID;
            signalName=msg.signalName;
            rootSignalID=msg.rootSignalID;
            interpValue=msg.interpValue;
            dataTypeVal=msg.dataTypeVal;
            dataToSet=msg.dataToSend;
            isEnum=msg.isENUM;
            isFixDT=msg.isFixDT;
            forceAxesRedraw=true;
            tableID=mag.tableID;
            returnStruct=slwebwidgets.tableeditor.updateSignalDataMW(appID,signalName,rootSignalID,workSignalID,interpValue,dataTypeVal,dataToSet,isEnum,isFixDT,forceAxesRedraw,tableID);
        end


    end
end

