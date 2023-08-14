classdef(Abstract)BaseTask<handle




    properties(Constant,Abstract)
ID
    end

    methods(Abstract)
        result=turnOn(obj,client,varargin);
        turnOff(obj,client);
    end

    methods
        function bool=isAvailable(obj,type)%#ok<INUSD>
            bool=true;
        end
        function bool=isAutoOn(obj,input)
            src=simulinkcoder.internal.util.getSource(input);
            if coderdictionary.data.feature.getFeature('CodeGenIntent')
                h=src.editor.blockDiagramHandle;
                cgb=get_param(h,'CodeGenBehavior');
                if strcmp(cgb,'None')
                    bool=false;
                    return;
                end
            end

            top=src.modelH;
            cp=simulinkcoder.internal.CodePerspective.getInstance;
            [~,type]=cp.getInfo(top);
            bool=obj.isAvailable(type);
        end
        function refresh(obj,studio)%#ok<INUSD>
        end
        function reset(obj,cps)%#ok<INUSD>
        end
    end
    methods
        function result=turnOnByCodePerspective(obj,input)
            result=true;
            if obj.isAutoOn(input)
                if slfeature('CodePerspectiveMinimize')
                    result=obj.turnOn(input,true);
                else
                    result=obj.turnOn(input);
                end
            end
        end
        function turnOffByCodePerspective(obj,input)
            obj.turnOff(input);
        end
    end
end


