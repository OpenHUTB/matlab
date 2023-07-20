classdef ValueSrcMgrContext<dig.ContextProvider
    properties(SetObservable=true)
        mController;
    end

    properties(SetAccess=private)
    end

    methods
        function obj=ValueSrcMgrContext()
            obj.TypeChain={'NoSelection'};
        end

        function setTypeChain(thisObj,typeChain)
            thisObj.TypeChain=typeChain;
        end

        function setSelected(thisObj,selection)
            if~isempty(selection)
                objSelected=class(selection{1});
            else
                objSelected='';
            end
            switch objSelected
            case 'sl_valuesrc.internal.ValueGroupRow'
                thisObj.TypeChain={'Group'};
            case 'sl_valuesrc.internal.ValueGroupEntry'
                thisObj.TypeChain={'GroupEntry'};
            case 'sl_valuesrc.internal.ValueSrcRow'
                thisObj.TypeChain={'Source'};
            case 'sl_valuesrc.internal.ValueSrcEntry'
                thisObj.TypeChain={'SourceEntry'};
            otherwise
                thisObj.TypeChain={'NoSelection'};
            end
        end

        function setController(thisObj,objController)
            thisObj.mController=objController;
        end

        function objController=getController(thisObj)
            objController=thisObj.mController;
        end
    end
end
