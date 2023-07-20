
classdef Base<handle

    properties(Access=protected)
        system;
        messageDirectory;
        messageFile;
        messagePrefix;
        rootSystem;
        modelAdvisorObject;

        localResultStatus;
        localResultStatusDetails;
        flaggedObjects;
        justifiedObjects;
        reportObjects;
    end

    methods(Access=protected)

        function message=getMessage(this,shortID,varargin)
            fullID=[...
            this.messageDirectory,':',...
            this.messageFile,':',...
            this.messagePrefix,shortID];
            message=DAStudio.message(fullID,varargin{:});
        end

        function message=getCommonMessage(this,shortID,varargin)
            fullID=[...
            this.messageDirectory,':',...
            this.messageFile,':',...
            'Common_',shortID];
            message=DAStudio.message(fullID,varargin{:});
        end

        function value=isMisra(this)
            if strcmp(this.messageFile,'misra')
                value=true;
            else
                value=false;
            end
        end

        function result=isExcludedByModelAdvisor(this,object)
            result=false;
            maObject=this.modelAdvisorObject;
            if isstruct(object)
                if isfield(object,'sid')
                    maObjects=object.sid;
                    sid=maObjects(1).Content;
                    kept=maObject.filterResultWithExclusion(sid);
                    if isempty(kept)
                        result=true;
                    end
                end
            else
                kept=maObject.filterResultWithExclusion(object);
                if isempty(kept)
                    result=true;
                end
            end
        end

        function[remaining,filtered]=filterResultWithExclusion(...
            this,objects,isCGIR)

            if nargin==2
                isCGIR=false;
            end

            if isCGIR
                numObjects=numel(objects);
                keep=true(numObjects,1);
                for i=1:numObjects
                    thisObject=objects{i};
                    maObjects=thisObject.sid;
                    sid=maObjects(1).Content;
                    after=...
                    this.modelAdvisorObject.filterResultWithExclusion(...
                    sid);
                    if isempty(after)
                        keep(i)=false;
                    else
                        keep(i)=true;
                    end
                end
                remaining=objects(keep);
                if nargout==2
                    filtered=objects(~keep);
                end
            else
                remaining=...
                this.modelAdvisorObject.filterResultWithExclusion(...
                objects);
                if nargout==2
                    filtered=setdiff(objects,remaining);
                end
            end
        end

        function sid=makeSid(~,object)
            sid=[];
            if ischar(object)
                if Simulink.ID.isValid(object)
                    sid=object;
                else
                    try
                        sid=Simulink.ID.getSID(object);
                    catch
                        return;
                    end
                end
            elseif isstruct(object)
                if isfield(object,'sid')
                    maObjects=object.sid;
                    potentialSid=maObjects(1).Content;
                    if Simulink.ID.isValid(potentialSid)
                        sid=potentialSid;
                    else
                        return;
                    end
                else
                    return;
                end
            else
                return;
            end
        end

        function justification=getPolyspaceJustification(this,object)

            justification=struct(...
            'type',{},...
            'guidelines',{},...
            'status',{},...
            'severity',{},...
            'comment',{});

            sid=this.makeSid(object);
            if isempty(sid)
                return;
            end

            handle=Simulink.ID.getHandle(sid);

            if isa(handle,'double')
                if strcmp(get_param(handle,'BlockType'),'Subsystem')
                    return;
                end
            else
                simulinkParent=Simulink.ID.getSimulinkParent(sid);
                handle=Simulink.ID.getHandle(simulinkParent);
            end
            try
                psStartComment=get_param(handle,'PolySpaceStartComment');
                psEndComment=get_param(handle,'PolySpaceEndComment');
            catch
                return;
            end

            patternBegin='polyspace:begin<(.*):(.*):(.*):(.*)>(.*)';
            patternEnd='polyspace:end<(.*):(.*):(.*):(.*)>';

            tokensBegin=regexp(psStartComment,patternBegin,'tokens');
            tokensEnd=regexp(psEndComment,patternEnd,'tokens');

            if~isempty(tokensBegin)&&~isempty(tokensEnd)
                tokensBegin=tokensBegin{1};
                tokensEnd=tokensEnd{1};
                if strcmp(tokensBegin{1},tokensEnd{1})&&...
                    strcmp(tokensBegin{2},tokensEnd{2})&&...
                    strcmp(tokensBegin{3},tokensEnd{3})&&...
                    strcmp(tokensBegin{4},tokensEnd{4})

                    justification(1).type=tokensBegin{1};
                    justification(1).guidelines=tokensBegin{2};
                    justification(1).severity=tokensBegin{3};
                    justification(1).status=tokensBegin{4};
                    justification(1).comment=tokensBegin{5};
                end
            end
        end

        function result=isJustifiedCorrectly(~,justification,guideline)
            result=false;
            if isempty(justification)
                return;
            end
            if~strcmp(justification.type,'MISRA-C3')
                return;
            end
            guidelineList=strsplit(justification.guidelines,',');
            for index=1:numel(guidelineList)
                thisGuideline=strtrim(guidelineList{index});
                if strcmp(thisGuideline,guideline)
                    result=true;
                    break;
                end
            end
        end

        function justifiedTable=createJustifiedTable(this)
            justifiedTable=ModelAdvisor.FormatTemplate('TableTemplate');
            justifiedTable.setSubBar(false);
            justifiedTable.setColTitles({...
            this.getCommonMessage('JustifiedTableLocation'),...
            this.getCommonMessage('JustifiedTableStandard'),...
            this.getCommonMessage('JustifiedTableGuidelines'),...
            this.getCommonMessage('JustifiedTableStatus'),...
            this.getCommonMessage('JustifiedTableSeverity'),...
            this.getCommonMessage('JustifiedTableComment')});
            for i=1:this.getNumJustifiedObjects()
                justifiedObject=this.getJustifiedObjects(i);
                if isstruct(justifiedObject.uuid)
                    uuid=justifiedObject.uuid.sid;
                else
                    uuid=justifiedObject.uuid;
                end
                justifiedTable.addRow({...
                uuid,...
                justifiedObject.standard,...
                justifiedObject.guidelines,...
                justifiedObject.status,...
                justifiedObject.severity,...
                justifiedObject.comment});
            end
        end

        function res=cgirCheckAlgorithm(this,cgirNode,misraRules)

            removeOutOfScope=true;
            mdlAdvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;

            if isequal(mdlAdvObj.ActiveCheck.ID,'mathworks.hism.hisf_0004')
                removeOutOfScope=false;
            end
            parsedOutput=...
            Advisor.RegisterCGIRInspectorResults.getInstance.parseCGIRResults(...
            cgirNode,removeOutOfScope,this.system);

            if isempty(parsedOutput)
                tags={};
            else
                tags=parsedOutput.tag;
            end
            for i=1:numel(tags)
                if~this.isExcludedByModelAdvisor(tags{i})
                    if strcmp(this.messageFile,'misra')
                        justification=this.getPolyspaceJustification(...
                        tags{i});
                        if ischar(misraRules)
                            justifiedCorrectly=...
                            this.isJustifiedCorrectly(...
                            justification,misraRules);
                        else
                            justifiedCorrectly=true;
                            for j=1:numel(misraRules)
                                justifiedCorrectly=...
                                justifiedCorrectly&&...
                                this.isJustifiedCorrectly(...
                                justification,misraRules{j});
                            end
                        end
                        if justifiedCorrectly
                            this.addJustifiedObject(tags{i},justification);
                        else
                            this.addFlaggedObject(tags{i});
                        end
                    else
                        this.addFlaggedObject(tags{i});
                    end
                end
            end

            if this.getNumFlaggedObjects()==0
                this.localResultStatus=true;
            else
                this.localResultStatus=false;
            end

            res=this.flaggedObjects;
        end

        function cgirCheckReport(this)

            resultTable=ModelAdvisor.FormatTemplate('TableTemplate');
            resultTable.setCheckText(this.getMessage('CheckText'));
            resultTable.setSubBar(false);
            resultTable.setColTitles({...
            this.getMessage('ResultTableHeader_Location')});
            for i=1:this.getNumFlaggedObjects()
                flaggedObject=this.getFlaggedObjects(i);
                if isstruct(flaggedObject.uuid)
                    resultTable.addRow({flaggedObject.uuid.sid});
                else
                    resultTable.addRow({flaggedObject.uuid});
                end
            end

            if this.getNumFlaggedObjects()==0
                resultTable.setSubResultStatus('pass');
                if this.getNumJustifiedObjects()==0
                    resultTable.setSubResultStatusText(this.getMessage(...
                    'SubResultStatusText_Pass'));
                else
                    resultTable.setSubResultStatusText(this.getMessage(...
                    'SubResultStatusText_PassWithAnnotation'));
                end
            else
                resultTable.setSubResultStatus('warn');
                resultTable.setSubResultStatusText(this.getMessage(...
                'SubResultStatusText_Fail'));
                resultTable.setRecAction(this.getMessage(...
                'RecAction'));
            end

            this.addReportObject(resultTable);

            if this.getNumJustifiedObjects()>0
                justifiedTable=this.createJustifiedTable();
                header=ModelAdvisor.Text(this.getCommonMessage(...
                'JustifiedBlocks'));
                header.IsBold=1;
                this.addReportObject(header);
                this.addReportObject(justifiedTable);
            end

        end

        function addFlaggedObject(this,uuid)
            this.flaggedObjects(end+1)=struct('uuid',uuid);
        end

    end

    methods(Access=public)

        function this=Base(system,messagePrefix)
            colonIndex=find(messagePrefix==':');
            this.system=system;
            this.messageDirectory=messagePrefix(1:colonIndex(1)-1);
            this.messageFile=messagePrefix(colonIndex(1)+1:colonIndex(2)-1);
            this.messagePrefix=messagePrefix(colonIndex(2)+1:end);
            this.rootSystem=bdroot(system);
            this.modelAdvisorObject=Simulink.ModelAdvisor.getModelAdvisor(...
            this.system);
            this.localResultStatus=true;
            this.localResultStatusDetails='';
            this.flaggedObjects=struct('uuid',{});
            this.justifiedObjects=struct(...
            'uuid',{},...
            'standard',{},...
            'guidelines',{},...
            'status',{},...
            'severity',{},...
            'comment',{});
            this.reportObjects={};
        end

        function addJustifiedObject(this,uuid,justification)
            this.justifiedObjects(end+1)=struct(...
            'uuid',uuid,...
            'standard','MISRA C:2012',...
            'guidelines',justification.guidelines,...
            'status',justification.status,...
            'severity',justification.severity,...
            'comment',justification.comment);
        end

        function addReportObject(this,reportObject)
            this.reportObjects{end+1}=reportObject;
        end

        function localResultStatus=getLocalResultStatus(this)
            localResultStatus=this.localResultStatus;
        end

        function setCheckResultStatus(this,checkResultStatus)
            if nargin==1
                this.modelAdvisorObject.setCheckResultStatus(...
                this.localResultStatus);
                if~this.localResultStatus
                    this.modelAdvisorObject.setActionEnable(true);
                end
            else
                this.modelAdvisorObject.setCheckResultStatus(...
                checkResultStatus);
            end
        end

        function numFlaggedObjects=getNumFlaggedObjects(this)
            numFlaggedObjects=numel(this.flaggedObjects);
        end

        function numJustifiedObjects=getNumJustifiedObjects(this)
            numJustifiedObjects=numel(this.justifiedObjects);
        end

        function numReportObjects=getNumReportObjects(this)
            numReportObjects=numel(this.reportObjects);
        end

        function flaggedObjects=getFlaggedObjects(this,index)
            if nargin==1
                flaggedObjects=this.flaggedObjects;
            else
                flaggedObjects=this.flaggedObjects(index);
            end
        end

        function justifiedObjects=getJustifiedObjects(this,index)
            if nargin==1
                justifiedObjects=this.justifiedObjects;
            else
                justifiedObjects=this.justifiedObjects(index);
            end
        end

        function reportObjects=getReportObjects(this,index)
            if nargin==1
                reportObjects=this.reportObjects;
            else
                reportObjects=this.reportObjects{index};
            end
        end

    end

    methods(Access=public,Abstract)
        algorithm(this);
        report(this);
    end

end

