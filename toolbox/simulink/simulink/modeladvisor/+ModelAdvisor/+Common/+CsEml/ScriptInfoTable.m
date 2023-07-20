
classdef ScriptInfoTable<handle

    methods

        function this=ScriptInfoTable()
            this.m_Keys=strings(0,1);
            this.m_Objects=ModelAdvisor.Common.CsEml.ScriptInfo.empty(0,1);
        end

        function scriptInfo=getScriptInfo(this,irScript)
            key=irScript.ScriptPath;
            index=find(strcmp(key,this.m_Keys));
            if isempty(index)
                scriptInfo=ModelAdvisor.Common.CsEml.ScriptInfo(irScript);
                this.m_Keys(end+1,1)=key;
                this.m_Objects(end+1,1)=scriptInfo;
            else
                scriptInfo=this.m_Objects(index);
            end
        end

    end

    properties
        m_Keys;
        m_Objects;
    end

end

