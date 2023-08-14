classdef SlmleDocumentContext<dig.CustomDocumentContext





    properties(SetAccess=protected)
OrigTypeChain
studio
    end

    methods
        function obj=SlmleDocumentContext(name,typechain,studio,tabName)
            obj@dig.CustomDocumentContext(name);
            obj.studio=studio;
            obj.OrigTypeChain=typechain;
            obj.DefaultTabName=tabName;
        end

        function updateTypeChain(obj)
            obj.TypeChain=[obj.OrigTypeChain];
        end

        function applyLockedStateContext(obj,lock)

            if lock


                disableCxtName='slmleContext_lockedState';
                if~any(strcmp(obj.TypeChain,disableCxtName))
                    obj.TypeChain{end+1}=disableCxtName;
                end
            else
                obj.updateTypeChain;
            end
        end
    end
end
