
classdef FunctionInfoTable<handle

    methods

        function this=FunctionInfoTable()
            this.m_Keys1=strings(0,1);
            this.m_Keys2=[];
            this.m_Objects=ModelAdvisor.Common.CsEml.FunctionInfo.empty(0,1);
        end

        function functionInfo=getFunctionInfo(this,irFunction,scriptInfo)

            key1=scriptInfo.getPath();
            key2=irFunction.TextStart;
            index=find(...
            strcmp(key1,this.m_Keys1)&...
            key2==this.m_Keys2);
            if isempty(index)
                functionInfo=ModelAdvisor.Common.CsEml.FunctionInfo(irFunction,scriptInfo);
                this.m_Keys1(end+1,1)=key1;
                this.m_Keys2(end+1,1)=key2;
                this.m_Objects(end+1,1)=functionInfo;
            else
                functionInfo=this.m_Objects(index);
            end
        end

    end

    properties(Access=private)
        m_Keys1;
        m_Keys2;
        m_Objects;
    end

end

