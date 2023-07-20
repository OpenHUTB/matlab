classdef SystemSelector<handle




    properties(SetObservable=true)

        SelectedSystem{matlab.internal.validation.mustBeCharRowVector(SelectedSystem,'SelectedSystem')}='';
    end

    properties(SetAccess=public)

        ModelObj={};


        DialogInstruction='';


        DialogTitle='';


        StartDialog={};


        Sticky=false;


        ShowLibraries=true;
    end

    methods
        dlgStruct=getDialogSchema(this,name);
        closeCB(this,closeAction);
    end

    methods
        function set.SelectedSystem(obj,value)
            obj.SelectedSystem=matlab.internal.validation.makeCharRowVector(value);
        end
    end
end
