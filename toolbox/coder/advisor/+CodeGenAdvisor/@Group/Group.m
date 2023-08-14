classdef(CaseInsensitiveProperties=true,ConstructOnLoad=true)Group<ModelAdvisor.Group
    properties

        model=[];
        Objectives='initial value';
        TaskMap={};
        CGONum=1;
        isERT=false;
        cgirCheckIds={};
        cgirCheckIdx={};
        runMode='';
        ERTObj=[];
    end

    methods
        h=getConfigSet(this);
        ContainerDescription=getDescriptionSchema(this,grouprow);
        objSelect=getObjSelectPanelSchema(this,grouprow);
        grtObjChange(this,dlg);
        initChecks(this);
        refreshCheckList(this);

        function h=Group(varargin)
mlock
            h=h@ModelAdvisor.Group(varargin{:});

            h.HelpMethod='helpview';
            h.HelpArgs={fullfile(docroot,'/toolbox/rtw/helptargets.map'),'scoder_code_gen_advisor'};
        end

    end
end


