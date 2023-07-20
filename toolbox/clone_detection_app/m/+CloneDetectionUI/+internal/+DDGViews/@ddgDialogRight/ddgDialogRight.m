classdef ddgDialogRight<handle





    properties(Constant)
        id=DAStudio.message('sl_pir_cpp:creator:ddgRightTitle')
        title=DAStudio.message('sl_pir_cpp:creator:ddgRightTitle')
        comp='GLUE2:DDG Component'

    end
    properties
        model;
        cloneUIObj;
        blockdiffHtml='';
    end
    methods
        function this=ddgDialogRight(cloneUIObj)
            this.cloneUIObj=cloneUIObj;
            this.model=get_param(cloneUIObj.m2mObj.mdlName,'Handle');
        end

        dlgStruct=getDialogSchema(obj)

    end

end


