


classdef CompatibilityDialog<slci.view.gui.Dialog
    properties(Constant)
        id='SLCICompatibility';
        title='Compatibility Checker'
        comp='GLUE2:DDG Component'
        tag='Tag_Compatibility'
    end

    methods

        function obj=CompatibilityDialog(st)
            obj@slci.view.gui.Dialog(st);




        end


        function delete(obj)




        end
    end

    methods
        receive(obj,msg);
        runCompatibilityChecker(obj);
        msg=loadData(obj,modelName);
        reloadData(obj,modelName,msgID);
        loadModelAdvisor(obj,modelName);
    end

    methods(Access=protected)
        init(obj);
    end

end