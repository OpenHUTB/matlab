classdef SystemSelectorForConfigSet<ModelAdvisor.SystemSelector
    properties(SetAccess=public)

        hHost=[];


        Listener=[];
    end

    methods
        function obj=SystemSelectorForConfigSet(varargin)





            narginchk(2,3);
            if nargin==0
                hMdl='Simulink Root';
            else
                hMdl=varargin{2};
            end



            obj.hHost=varargin{1};
            obj.DialogTitle=DAStudio.message('Simulink:tools:MASystemSelector');
            obj.DialogInstruction=DAStudio.message('Simulink:tools:MASelectSystemDialogTitle');

            if(strcmp(hMdl,'Simulink Root'))
                obj.ModelObj=slroot;
                obj.SelectedSystem=hMdl;
            else
                obj.ModelObj=get_param(bdroot(hMdl),'Object');
                obj.SelectedSystem=getfullname(hMdl);
            end

            obj.Sticky=true;
        end

        closeCB(this,closeAction);
        closeDlg(obj,obj2,obj3);




    end
end
