classdef ddgDialogHelp<handle





    properties(Constant)
        id=DAStudio.message('sl_pir_cpp:creator:helpDialogTitle');
        title=DAStudio.message('sl_pir_cpp:creator:helpDialogTitle');
        comp='GLUE2:DDG Component';

    end
    properties
        model;
        cloneUIObj;
    end
    methods
        function this=ddgDialogHelp(cloneUIObj)
            this.cloneUIObj=cloneUIObj;
            this.model=cloneUIObj.m2mObj.mdlName;
        end

        dlgStruct=getDialogSchema(this);
        html=getHelpHtml(this)
    end

end

