classdef ddslibCustomContext<dig.ContextProvider




    properties(SetObservable=true)
        DDSLibraryUIObj;
    end

    methods
        function obj=ddslibCustomContext()
            obj.TypeChain={'Tab_1'};
        end

        function setTypeChain(thisObj,typeChain)
            thisObj.TypeChain=typeChain;
        end

        function setSelected(thisObj,selection)
            thisObj.TypeChain=selection{1}.getTypeChain();
        end

        function setDDSLibraryUIObj(thisObj,DDSLibraryUIObj)
            thisObj.DDSLibraryUIObj=DDSLibraryUIObj;
        end
    end
end
