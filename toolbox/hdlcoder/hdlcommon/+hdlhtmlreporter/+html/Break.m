


classdef Break<hdlhtmlreporter.html.Element
    properties
numBreaks
    end
    methods
        function obj=Break(numBreaks)
            if nargin<1
                numBreaks=1;
            end

            obj=obj@hdlhtmlreporter.html.Element('',{});
            obj.numBreaks=numBreaks;


            obj.buildingTags('br')=true;
        end
    end
    methods(Access=protected)
        function emitStr=emitPreCSSstyledHTML(obj)
            emitStr='';
            for ii=1:obj.numBreaks
                emitStr=[emitStr,sprintf('<br/>')];
            end
            emitStr=[emitStr,sprintf('\n')];
        end
    end
end