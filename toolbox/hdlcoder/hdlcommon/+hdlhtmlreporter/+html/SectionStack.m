


classdef SectionStack<handle
    properties
stack
topPos
    end

    methods
        function obj=SectionStack()
            obj.stack={};
            obj.topPos=0;
        end

        function elemOut=top(obj)
            if obj.topPos>0
                elemOut=obj.stack{obj.topPos};
            else
                elemOut='';
            end
        end

        function elemOut=pop(obj)
            if obj.topPos>0
                elemOut=obj.stack{obj.topPos};
                obj.stack=obj.stack(1:end-1);
                obj.topPos=obj.topPos-1;
            else
                elemOut='';
            end
        end

        function push(obj,elemIn)
            obj.stack{end+1}=elemIn;
            obj.topPos=obj.topPos+1;
        end

        function status=isEmpty(obj)
            if obj.topPos==0
                status=1;
            else
                status=0;
            end
        end

        function numElem=Count(obj)
            numElem=obj.topPos;
        end

        function clear(obj)
            obj.stack={};
            obj.topPos=0;
        end
    end
end

