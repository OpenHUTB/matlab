classdef SafetyManagerAdapter<slreq.adapters.BaseAdapter


    properties(Constant)

        icon=fullfile(matlabroot,'toolbox','shared','simulinktest','resources','icons','InjectorBolt16px.svg');
    end

    methods
        function this=SafetyManagerAdapter()
            this.domain='linktype_rmi_safetymanager';
        end

        function tf=isResolved(~,artifact,id)
            safetyObject=rmism.getSafetyManagerObj(artifact,id);

            if(isempty(safetyObject))
                tf=false;
            else
                tf=true;
            end
        end

        function str=getSummary(~,artifact,uuid)
            safetyManagerObj=rmism.getSafetyManagerObj(artifact,uuid);
            if(isempty(safetyManagerObj))
                str="Unresolved Safety Manager Object in "+artifact;
            else
                str=safetyManagerObj.getSummaryString();
            end
        end

        function out=getIcon(this,~,~)
            out=this.icon;
        end

        function str=getTooltip(~,artifact,uuid)
            safetyManagerObj=rmism.getSafetyManagerObj(artifact,uuid);
            if(isempty(safetyManagerObj))
                str=strcat('Unresolved Safety Manager Object in',artifact);
            else
                str=safetyManagerObj.getSummaryString();
            end
        end

        function apiObj=getSourceObject(~,artifact,id)
            safetyManagerObj=rmism.getSafetyManagerObj(artifact,id);
            apiObj=safetyManagerObj;
        end

        function success=select(this,artifact,id,~)
            success=true;
            try
                rmi.navigate(this.domain,artifact,id);
            catch
                success=false;
            end
        end

        function success=highlight(this,artifact,id,caller)
            if nargin<4
                caller='';
            end
            success=this.select(artifact,id,caller);
        end

        function success=onClickHyperlink(this,artifact,id,caller)
            if nargin<4
                caller='';
            end
            this.select(artifact,id,caller);
            success=true;
        end

        function cmdStr=getClickActionCommandString(this,artifact,id,caller)
            if nargin<4
                caller='';
            end
            cmdStr=sprintf('rmi.navigate(''%s'',''%s'',''%s'','''',''%s'')',this.domain,artifact,id,caller);
        end

        function path=getFullPathToArtifact(~,artifact,~)
            path=which(artifact);
        end

    end
end