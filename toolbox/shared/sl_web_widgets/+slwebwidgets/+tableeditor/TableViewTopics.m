classdef TableViewTopics<handle





    properties
clientSideRequestTopic
serverSideRequestTopic
serverSideEvalFormulaRequestTopic
serverSideSignalUpdateTopic
appID
REPORT_TABLE_ERROR
SPINNER
REPLACE_SIGNAL

        TABLE_ID='';
    end


    methods


        function obj=TableViewTopics(appID,inTableID)

            if~ischar(inTableID)
                inTableID=num2str(inTableID);
            end

            obj.TABLE_ID=inTableID;
            obj.appID=appID;

            obj.clientSideRequestTopic=['/sl_web_widgets/tableview/tableview/request',inTableID];
            obj.serverSideRequestTopic=['/sl_web_widgets',appID,'/tableview/tableview/request',inTableID];
            obj.serverSideEvalFormulaRequestTopic=['/sl_web_widgets',appID,'/tableview/evalUpdate',inTableID];
            obj.serverSideSignalUpdateTopic=['/SHARED_TABLEVIEW/',appID,'/signalupdate',inTableID];

            obj.SPINNER='spinner';
            obj.REPORT_TABLE_ERROR='report_table_error';

            obj.REPLACE_SIGNAL=['signalreplacefromedit',inTableID];

        end

    end

end

