classdef StateflowTargetHandler<dependencies.internal.action.DependencyHandler




    properties(Constant)


        Types="StateflowTarget";
    end

    methods
        function unhilite=openUpstream(~,dependency)
            unhilite=@()[];

            [~,modelName,~]=fileparts(dependency.UpstreamNode.Location{1});

            r=sfroot;

            machine=r.find('-isa','Stateflow.Machine','Path',modelName);

            if isempty(machine)
                return;
            end

            types=dependency.Type.Parts;


            if length(types)>1
                target=find(machine,'-isa','Stateflow.Target',...
                'Name',types(2));
            else

                target=find(machine,'-isa','Stateflow.Target');
                target=target(1);
            end
            dlg=DAStudio.Dialog(target);
            dlg.setActiveTab('sfTargetDlg_mainTab',1);
        end
    end
end
