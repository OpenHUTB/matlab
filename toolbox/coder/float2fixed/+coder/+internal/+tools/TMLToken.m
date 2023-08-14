
















classdef TMLToken
    properties(SetAccess=protected)
type
value
line
col
    end

    methods
        function disp(this)
            disp(this.tostr())
        end

        function str=tostr(this)
            str=sprintf('%s | L %d, C %d | %s',char(this.type),this.line,this.col,this.value(1:min(5,length(this.value))));
        end



        function this=TMLToken(m_type,varargin)


            this.line=0;
            this.col=0;

            switch(m_type)
            case{coder.internal.tools.TMLTypes.END_TAG,'%>'}
                m_value='%>';
                m_type=coder.internal.tools.TMLTypes.END_TAG;
            case{coder.internal.tools.TMLTypes.IMMEDIATE_TAG,'<%'}
                m_value='<%';
                m_type=coder.internal.tools.TMLTypes.IMMEDIATE_TAG;
            case{coder.internal.tools.TMLTypes.DELAYED_TAG,'<%-'}
                m_value='<%-';
                m_type=coder.internal.tools.TMLTypes.DELAYED_TAG;
            case{coder.internal.tools.TMLTypes.INCLUDE_TAG,'<%+'}
                m_value='<%+';
                m_type=coder.internal.tools.TMLTypes.INCLUDE_TAG;
            case{coder.internal.tools.TMLTypes.INCLUDE_TAG,'<%='}
                m_value='<%=';
                m_type=coder.internal.tools.TMLTypes.VERBATIM_TAG;
            otherwise
                assert(nargin>=2)
                m_value=varargin{1};
                m_type=coder.internal.tools.TMLTypes.TEXT;
            end

            this.value=m_value;
            this.type=m_type;

            if(nargin>=3)
                this.line=varargin{2};
            end

            if(nargin>=4)
                this.col=varargin{3};
            end
        end
    end

end
