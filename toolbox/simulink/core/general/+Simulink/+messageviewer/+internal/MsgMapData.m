classdef MsgMapData<handle
    methods
        function obj=MsgMapData()
            obj.m_Records={};
        end

        function add(this,aRecord)
            this.m_Records{end+1}=aRecord;
        end

        function iSize=size(this)
            iSize=length(this.m_Records);
        end

        function aRecords=getRecords(this)
            aRecords=this.m_Records;
        end
    end

    properties(Access=private)
        m_Records;
    end
end

