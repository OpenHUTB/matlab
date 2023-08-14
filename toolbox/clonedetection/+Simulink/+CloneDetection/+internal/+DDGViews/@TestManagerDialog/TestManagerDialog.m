classdef TestManagerDialog<handle




    properties(Constant)
        id='TestManager'
    end
    properties
        model;
        title='';
        eventListener=[];
        fDialogHandle=[];
        CheckEquivalencyResult=[];
    end

    methods
        function this=TestManagerDialog(model)
            this.model=model;
            Simulink.CloneDetection.internal.util.gui.setEventHandler(this);
        end


        function closeReportDialog(obj)

            delete(obj.fDialogHandle);
        end

        html=getTestManagerResultsHTML(this,activeObj,resultSet);
        dlgStruct=getDialogSchema(obj);
    end
end
