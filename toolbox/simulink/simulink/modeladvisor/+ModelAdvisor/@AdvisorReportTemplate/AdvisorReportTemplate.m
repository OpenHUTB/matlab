classdef(CaseInsensitiveProperties=true)AdvisorReportTemplate<ModelAdvisor.AdvisorReportBase




    properties(Access=public,Hidden)
        TemplateFile='';
    end

    properties(Access=protected)
        isLicenseAvailable=false;
        counterStructure;
    end

    methods(Access=public)

        function obj=AdvisorReportTemplate()
            if license('checkout','SL_Verification_Validation')
                obj.isLicenseAvailable=true;
            end
            obj.setTemplate();
        end
    end

    methods(Access=protected)

        domObjs=emitDOMforTaskNode(obj,rpt);
        domObjs=emitDOMforChecks(obj,rpt);

        function result=createNodeStructure(obj,TaskNode)
            result=true;
            obj.counterStructure=modeladvisorprivate('modeladvisorutil2','getNodeSummaryInfo',TaskNode);
            obj.TaskNode=TaskNode;
        end

        function result=createCheckStructure(obj,CheckList)
            result=true;
            maObj=Simulink.ModelAdvisor.getModelAdvisor(obj.ModelName);
            orderedCheckIndex=maObj.getExecutionOrder(CheckList,1,'');
            obj.counterStructure=modeladvisorprivate('modeladvisorutil2','getNodeSummaryInfo','',maObj.CheckCellArray,orderedCheckIndex);
            obj.CheckList=CheckList;
        end

        function result=createReport(obj,reportName,reportFormat)
            result='';
            if~obj.isLicenseAvailable
                DAStudio.error('ModelAdvisor:engine:CustomRptLicenseFailed');
                return;
            end



            if connector.internal.Worker.isMATLABOnline
                DAStudio.error('ModelAdvisor:engine:ReportNotSupportedOnline');
            end

            import mlreportgen.dom.*
            try
                rpt=ModelAdvisor.ReportDocument(reportName,reportFormat,obj.TemplateFile);

                while~strcmp(rpt.CurrentHoleId,'#end#')
                    switch rpt.CurrentHoleId
                    case 'ModelName'
                        [~,mdlname,mdlext]=fileparts(get_param(bdroot(obj.ModelName),'fileName'));
                        Value=Text([mdlname,mdlext]);
                        Value.Color='#800000';
                        append(rpt,Value);
                    case 'SimulinkVersion'
                        Value=ver('Simulink');
                        Value=Text(Value.Version);
                        Value.Color='#800000';
                        append(rpt,Value);
                    case 'ModelVersion'
                        Value=Text(get_param(bdroot(obj.ModelName),'ModelVersion'));
                        Value.Color='#800000';
                        append(rpt,Value);
                    case 'SystemName'
                        Value=Text(obj.ModelName);
                        Value.Color='#800000';
                        append(rpt,Value);
                    case 'TreatAsMdlref'
                        MAObj=Simulink.ModelAdvisor.getModelAdvisor(obj.ModelName);
                        if MAObj.treatAsMdlref
                            Value=Text('on');
                        else
                            Value=Text('off');
                        end
                        Value.Color='#800000';
                        append(rpt,Value);
                    case 'CurrentRun'
                        if obj.counterStructure.generateTime~=0
                            Value=Text(modeladvisorprivate(...
                            'modeladvisorutil2','getDateString',obj.counterStructure.generateTime));
                        else
                            Value=Text(DAStudio.message('Simulink:tools:MANotApplicable'));
                        end
                        Value.Color='#800000';
                        append(rpt,Value);
                    case 'noSyncCheckCount'
                        if isa(obj.TaskNode,'ModelAdvisor.Node')
                            [~,noSyncCounter]=modeladvisorprivate('modeladvisorutil2','emitHTMLforTaskNode',obj.TaskNode,obj.TaskNode.MAObj.CheckCellArray);
                            if noSyncCounter~=0
                                if noSyncCounter==1
                                    noSyncCheckCountString=[' ',DAStudio.message('Simulink:tools:MAOneCheckNotSyncRpt',...
                                    modeladvisorprivate('modeladvisorutil2','getDateString',obj.counterStructure.generateTime))];
                                else
                                    noSyncCheckCountString=[' ',DAStudio.message('Simulink:tools:MAMoreCheckNotSyncRpt',num2str(noSyncCounter),...
                                    modeladvisorprivate('modeladvisorutil2','getDateString',obj.counterStructure.generateTime))];
                                end
                                groupObj=Group();
                                Value=Text(noSyncCheckCountString);


                                groupObj.append(Value);
                                append(rpt,groupObj);
                            end
                        end
                    case 'PassCount'
                        append(rpt,num2str(obj.counterStructure.passCt));
                    case 'FailCount'
                        append(rpt,num2str(obj.counterStructure.failCt));
                    case 'WarningCount'
                        append(rpt,num2str(obj.counterStructure.warnCt));
                    case 'JustifiedCount'
                        append(rpt,num2str(obj.counterStructure.JustifiedCt));
                    case 'IncompleteCount'
                        append(rpt,num2str(obj.counterStructure.IncompleteCt));
                    case 'NrunCount'
                        append(rpt,num2str(obj.counterStructure.nrunCt));
                    case 'TotalCount'
                        append(rpt,num2str(obj.counterStructure.allCt));
                    case 'CheckResults'
                        if isa(obj.TaskNode,'ModelAdvisor.Node')
                            domObjs=obj.emitDOMforTaskNode(rpt);
                        else
                            domObjs=obj.emitDOMforChecks(rpt);
                        end
                        for i=1:length(domObjs)
                            append(rpt,domObjs{i});
                        end
                    end
                    moveToNextHole(rpt);
                end
                result=rpt.OutputPath;
                close(rpt);
            catch err
                throw(err);
            end
        end
    end

    methods(Access=private)

        function setTemplate(obj)
            if isempty(obj.TemplateFile)
                locale=feature('locale');
                lang=locale.messages;
                if strncmpi(lang,'ja',2)
                    obj.TemplateFile=fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','resources','templates','default_ja.dotx');
                else
                    obj.TemplateFile=fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','resources','templates','default.dotx');
                end
            end
        end

    end

end

