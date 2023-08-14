classdef assessmentEditorHandle<handle
    properties(SetAccess=protected)
statusChannel
serializeChannel
clientId
ddgHandle
assessmentDefinition
debugVerbose
    end
    methods
        function obj=assessmentEditorHandle(varargin)
            p=inputParser();
            p.addRequired('clientId',@(x)validateattributes(x,{'char','string'},{'scalartext'}));
            p.addParameter('assessmentDefinition','[]',@(x)validateattributes(x,{'char','string'},{'scalartext'}));
            p.addParameter('debug',false,@(x)validateattributes(x,{'logical'},{'scalar'}));
            p.addParameter('verbose',false,@(x)validateattributes(x,{'logical'},{'scalar'}));
            p.parse(varargin{:});


            obj.clientId=p.Results.clientId;

            obj.statusChannel=message.subscribe(strcat('/RequirementAssessmentEditor/',obj.clientId,'/status'),@(msg)obj.handleReady(msg));

            obj.serializeChannel=message.subscribe(strcat('/RequirementAssessmentEditor/',obj.clientId,'/serializeAssessmentDefinition'),@(msg)obj.handleSerialize(msg));
            obj.assessmentDefinition=jsondecode(p.Results.assessmentDefinition);
            obj.debugVerbose=p.Results.verbose;
            if p.Results.debug
                url='index-requirement-debug.html?debug=1';
            else
                url='index-requirement.html?debug=0';
            end
            url=connector.getUrl(['/toolbox/simulinktest/core/assessments_editor/assessments_editor_ui/',url,'&clientId=',obj.clientId]);


            connector.ensureServiceOn;
            import com.mathworks.services.clipboardservice.ConnectorClipboardService;

            ConnectorClipboardService.getInstance();


            obj.ddgHandle=sltest.assessments.internal.Requirements.DDGWebKitWindow.create('Assessment Editor',url,'geometry',[10,10,1024,520]);
        end


        function cleanup(obj)
            if~isempty(obj.statusChannel)
                if(obj.debugVerbose)
                    fprintf('** cleanup **\n');
                end
                message.unsubscribe(obj.statusChannel);
                obj.ddgHandle=[];
                obj.statusChannel=[];
                obj.serializeChannel=[];
                obj.clientId='';
                obj.assessmentDefinition=[];
                obj.debugVerbose=false;
            end
        end


        function handleReady(obj,msg)
            if strcmp(msg,'start')

                if(obj.debugVerbose)
                    fprintf('** Assesment editor widget is ready **\n');
                end

                obj.setAssessmentDefinition(jsonencode(obj.assessmentDefinition));
            elseif strcmp(msg,'stop')
                if(obj.debugVerbose)
                    fprintf('** Assesment editor widget is stopped **\n');
                end
                obj.cleanup;
            end
        end


        function handleSerialize(obj,msg)
            data=jsondecode(msg);
            obj.assessmentDefinition=data.assessmentInfo;
            if(obj.debugVerbose)
                fprintf('Serialize assessments\nUUID:%s\nASSESSMENTS\n',data.clientId);
                for i=1:numel(obj.assessmentDefinition.AssessmentsInfo)
                    if obj.assessmentDefinition.AssessmentsInfo{i}.parent==-1
                        fprintf('\t%s\n',obj.assessmentDefinition.AssessmentsInfo{i}.assessmentName);
                    end
                end
            end
        end


        function setAssessmentDefinition(obj,def)
            message.publish(strcat('/RequirementAssessmentEditor/',obj.clientId,'/setAssessmentDefinition'),def);
        end
    end
end

