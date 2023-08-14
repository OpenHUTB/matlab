classdef StackPruner<handle




    properties
Base
    end

    methods(Static)
        function obj=getInstance()
            import matlab.internal.editor.StackPruner;
            mlock;
            persistent instance;
            if isempty(instance)
                instance=StackPruner();
            end
            obj=instance;
        end
    end

    methods
        function setBase(obj,base)
            obj.Base=base;
        end

        function clear(obj)
            obj.Base=[];
        end

        function prunedStack=pruneStack(obj,stackToPrune)
            import matlab.internal.editor.EvaluatorException
            import matlab.internal.editor.EODataStore


            if isempty(stackToPrune)
                prunedStack=[];
                return;
            end

            prunedStack=stackToPrune;

            baseStack=obj.Base;


            if isempty(baseStack)
                return;
            end

            currentMatchIndexInBase=1;
            possibleMatchStartIndex=1;

            numStackToPrune=numel(stackToPrune);
            numBaseStack=numel(baseStack);



























            while true

                currentMatchIndexInStackToPrune=possibleMatchStartIndex+currentMatchIndexInBase-1;




                if currentMatchIndexInBase>numBaseStack||currentMatchIndexInStackToPrune>numStackToPrune
                    break
                end

                if strcmp(baseStack(currentMatchIndexInBase).file,stackToPrune(currentMatchIndexInStackToPrune).file)

                    currentMatchIndexInBase=currentMatchIndexInBase+1;
                else



                    possibleMatchStartIndex=possibleMatchStartIndex+1;
                    currentMatchIndexInBase=1;




                    if possibleMatchStartIndex>numStackToPrune
                        return;
                    end
                end
            end



            prunedStack=stackToPrune(1:possibleMatchStartIndex-1);




            prunedStack=reshape(prunedStack,numel(prunedStack),1);
        end
    end
end

