classdef TestManagerDialog<handle


    properties(Constant)
        id='TestManager'
    end
    properties
        model;
        title='';
        eventListener=[];
        fDialogHandle=[];
    end

    methods
        function this=TestManagerDialog(model)
            this.model=model;
            CloneDetectionUI.internal.util.setEventHandler(this);
        end


        function closeReportDialog(obj)

            delete(obj.fDialogHandle);
        end

        html=getTestManagerResultsHTML(this,activeObj);
        dlgStruct=getDialogSchema(obj);
    end
end
