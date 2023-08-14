classdef LineBreak<Advisor.Element

    properties(Access='public')
    end


    methods(Access='public')
        function this=LineBreak
        end


        function outputString=emitHTML(~)
            outputString='<br />';
        end
    end
end