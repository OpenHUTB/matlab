classdef TableViewTopics<handle





    properties
clientSideRequestTopic
serverSideRequestTopic
serverSideEvalFormulaRequestTopic
serverSideSignalUpdateTopic
appID
REPORT_TABLE_ERROR
    end


    methods


        function obj=TableViewTopics(appID)


            obj.clientSideRequestTopic='/sl_web_widgets/tableview/tableview/request';
            obj.serverSideRequestTopic=['/sl_web_widgets',appID,'/tableview/tableview/request'];
            obj.serverSideEvalFormulaRequestTopic=['/sl_web_widgets',appID,'/tableview/evalUpdate'];
            obj.serverSideSignalUpdateTopic=['/SHARED_TABLEVIEW/',appID,'/signalupdate'];
            obj.appID=appID;
            obj.REPORT_TABLE_ERROR='report_table_error';
        end

    end

end

