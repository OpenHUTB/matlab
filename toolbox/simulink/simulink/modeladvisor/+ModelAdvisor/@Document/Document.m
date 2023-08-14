classdef(CaseInsensitiveProperties=true,TruncatedProperties=true)Document<Advisor.Document

    methods(Access='public')
        function this=Document

            this.FramesetItem=ModelAdvisor.Frameset;
            this.BodyItem=ModelAdvisor.Element;
            this.BodyItem.setTag('body');
        end
    end
end

