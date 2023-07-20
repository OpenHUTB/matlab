classdef(CaseInsensitiveProperties=true)Text<Advisor.Text

    methods(Access='public')
        function this=Text(varargin)
            this=this@Advisor.Text(varargin{:});
        end

    end
end
