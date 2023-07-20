


classdef Body<hdlhtmlreporter.html.GenericSection

    methods
        function obj=Body(id,cssStyles)
            obj=obj@hdlhtmlreporter.html.GenericSection('body',id,cssStyles);
        end

    end

    methods(Static)
        function endtag=addEndTag()
            endtag=hdlhtmlreporter.html.EndTag('body');
        end
    end
end