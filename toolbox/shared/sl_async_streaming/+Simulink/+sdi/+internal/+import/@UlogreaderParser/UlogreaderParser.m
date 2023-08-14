classdef UlogreaderParser<Simulink.sdi.internal.import.VariableParser





    properties
    end


    methods


        function ret=supportsType(~,obj)
            ret=isa(obj,'ulogreader')&&isscalar(obj);
        end


        function ret=getRootSource(this)
            ret=this.VariableName;
        end


        function ret=getTimeSource(~)
            ret='';
        end


        function ret=getDataSource(~)
            ret='';
        end


        function ret=getBlockSource(~)
            ret='';
        end


        function ret=getSID(~)
            ret='';
        end


        function ret=getModelSource(~)
            ret='';
        end


        function ret=getSignalLabel(this)
            ret=char(this.VariableValue.FileName);
        end


        function ret=getPortIndex(~)
            ret=[];
        end


        function ret=getHierarchyReference(~)
            ret='';
        end


        function ret=getTimeDim(~)
            ret=[];
        end


        function ret=getSampleDims(~)
            ret=[];
        end


        function ret=getInterpolation(~)
            ret='';
        end


        function ret=getUnit(~)
            ret='';
        end


        function ret=getMetaData(~)
            ret=[];
        end


        function ret=getTimeValues(~)
            ret=[];
        end


        function ret=getDataValues(~)
            ret=[];
        end


        function ret=isHierarchical(~)
            ret=true;
        end


        function ret=getChildren(this)

            data=readTopicMsgs(this.VariableValue);
            numRows=height(data);
            vars(numRows)=struct('VarName','','VarSignalName','','VarValue',[]);
            for idx=1:numRows
                vars(idx).VarName=[this.getSignalLabel(),'.',char(data{idx,"TopicNames"})];
                vars(idx).VarSignalName=char(data{idx,"TopicNames"});
                vars(idx).VarValue=data{idx,"TopicMessages"}{1};
            end

            ret=parseVariables(this.WorkspaceParser,vars);
            for idx=1:numel(ret)
                ret{idx}.Parent=this;
                ret{idx}.UseColumnNames=true;
            end
        end


        function ret=allowSelectiveChildImport(~)
            ret=true;
        end


        function ret=isVirtualNode(~)
            ret=true;
        end


        function ret=getRepresentsRun(~)
            ret=true;
        end


        function setRunMetaData(this,~,runID)
            si=readSystemInformation(this.VariableValue);
            si=table(si{:,2},'RowNames',si{:,1});

            r=Simulink.sdi.getRun(runID);
            r.Description=this.VariableValue.FileName;
            if any(strcmp(si.Row,'sys_name'))
                r.MachineName=si{'sys_name',1};
            end
            if any(strcmp(si.Row,'sys_os_name'))
                r.Platform=si{'sys_os_name',1};
            end
        end
    end
end
