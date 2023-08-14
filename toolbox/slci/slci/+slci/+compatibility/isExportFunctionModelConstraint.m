

classdef isExportFunctionModelConstraint<slci.compatibility.Constraint


    methods


        function out=getDescription(aObj)%#ok
            out='Modelreference block is not permitted to be isExportFunction Model';
        end


        function obj=isExportFunctionModelConstraint()
            obj.setEnum('isExportFunctionModel');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end


        function out=check(aObj)
            out=[];
            blk_type=aObj.ParentBlock().getParam('BlockType');
            assert(strcmpi(blk_type,'ModelReference'));





            is_protected=aObj.ParentBlock().getParam('ProtectedModel');
            if strcmpi(is_protected,'off')
                mdl_name=...
                aObj.ParentBlock().getParam('ModelName');



                mdl_manager=slci.internal.ModelStateMgr(mdl_name);
                is_loaded=mdl_manager.isLoaded;
                if~is_loaded
                    mdl_manager.loadModel
                end


                isExportFunctionModel=get_param(mdl_name,'isExportFunctionModel');
                if strcmpi(isExportFunctionModel,'on')
                    out=slci.compatibility.Incompatibility(aObj,'isExportFunctionModel');
                    return
                end


                if~is_loaded
                    mdl_manager.closeModel;
                end
            end
        end
    end
end
