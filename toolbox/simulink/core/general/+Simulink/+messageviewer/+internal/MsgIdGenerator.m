classdef MsgIdGenerator<handle



    methods
        function obj=MsgIdGenerator()
            obj.m_SequenceNo=0;
            obj.m_MarkerCheck=0;
        end

        function aSequenceNo=GetSequenceNo(this)
            aSequenceNo=this.m_SequenceNo;
        end

        function IncrementMessageSequenceNo(this)
            this.m_SequenceNo=this.m_SequenceNo+1;
            this.m_MarkerCheck=0;
        end

        function IncrementInfoSequenceNo(this)
            if(~(this.m_MarkerCheck))
                this.m_SequenceNo=this.m_SequenceNo+1;
            end
            this.m_MarkerCheck=1;
        end
    end

    properties(Access=private)
        m_SequenceNo;
        m_MarkerCheck;
    end

end

