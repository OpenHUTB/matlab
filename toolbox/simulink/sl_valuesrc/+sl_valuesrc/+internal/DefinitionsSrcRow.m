classdef DefinitionsSrcRow<sl_valuesrc.internal.SourceRow






    properties(Access=private)
    end


    methods(Static,Access=public)
    end


    methods(Access=public)
        function thisObj=DefinitionsSrcRow(rowID,srcObj,valsrcMgr)
            thisObj@sl_valuesrc.internal.SourceRow(rowID,srcObj,valsrcMgr);
        end

        function tf=isHierarchical(thisObj)
            tf=false;
        end

        function tf=isHierarchicalChildren(thisObj)
            tf=false;
        end

        function icon=getDisplayIcon(thisObj)
            try

                icon=thisObj.mDefinitionSrcObj.getDisplayIcon();
            catch
                icon='toolbox/shared/dastudio/resources/MatlabArray.png';
            end
        end

        function dlgstruct=getDialogSchema(thisObj,arg1)
            dlgstruct=[];
        end

        function src=getListSource(thisObj)
            src=thisObj.mDefinitionSrcObj;
        end

        function updateDefinitions(thisObj,eventData,op)
            thisObj.mDefinitionSrcObj.updateDefinitions(eventData,op);
        end

        function rtn=cacheUpdateEvent(thisObj,eventData)
            rtn=thisObj.mDefinitionSrcObj.cacheUpdateEvent(eventData);
        end
    end


    methods(Access=private)

    end

end