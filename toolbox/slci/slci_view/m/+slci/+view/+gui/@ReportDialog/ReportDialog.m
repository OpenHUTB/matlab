


classdef ReportDialog<slci.view.gui.Dialog
    properties(Constant)
        id='SLCIReport';
        title='Report'
        comp='GLUE2:DDG Component'
        tag='Tag_Report'
    end

    methods

        function obj=ReportDialog(st)
            obj@slci.view.gui.Dialog(st);




        end

        function delete(obj)




        end
    end

    methods
        receive(obj,msg);
        msg=loadData(obj,modelName);
        reloadData(obj,modelName,msgID);
    end

    methods(Access=protected)
        init(obj);

    end

end