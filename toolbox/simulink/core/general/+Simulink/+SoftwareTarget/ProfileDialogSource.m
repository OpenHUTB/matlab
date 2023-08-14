



classdef ProfileDialogSource<handle
    properties
        dlg;
    end
    methods(Static)
        function editor=findEditor(model)
            editor=[];
            dlgs=DAStudio.ToolRoot.getOpenDialogs;
            for i=1:length(dlgs)
                src=dlgs(i).getSource;
                if isa(src,'ProfileDialogSource')&&...
                    strcmp(src.model,model)
                    editor=src;
                    return;
                end
            end
        end
        function cmd(cmd,model,varargin)

            load_system(model);

            switch cmd


            case 'showTask'








                e=DeploymentDiagram.explorer(model);

                if isempty(varargin{1})

                    n=e.findNodes('Periodic');
                    for i=1:length(n)
                        trigger=n(i);
                        if isa(trigger,"DAStudio.DAObjectProxy")
                            trigger=trigger.getMCOSObjectReference;
                        end
                        if strcmp(trigger.Name,varargin{2})
                            e.imme.selectTreeViewNode(n(i));
                            break;
                        end
                    end
                else

                    n=e.findNodes('PeriodicTasks');

                    for i=1:length(n)
                        t=n(i);
                        if isa(t,"DAStudio.DAObjectProxy")
                            t=t.getMCOSObjectReference;
                        end
                        if strcmp(t.Name,varargin{2})&&...
                            strcmp(t.ParentTaskGroup.Name,varargin{1})
                            e.imme.selectTreeViewNode(n(i));
                            break;
                        end
                    end
                end


            otherwise
                assert(false,'unhandled command');


            end
        end
        function dlg=launch()
            dialogSrc=Simulink.SoftwareTarget.ProfileDialogSource;
            dlg=DAStudio.Dialog(dialogSrc);
            dialogSrc.dlg=dlg;
        end
    end
    methods
        function dlgstruct=getDialogSchema(~,varargin)

            fileName=fullfile(pwd,'profileReport.html');

            desc.Url=['file:///',fileName];
            desc.Name='ProfileReport';
            desc.Type='webbrowser';
            desc.WebKit=true;
            desc.Tag='profileReport_tag';
            desc.ObjectProperty='stringProp';







            description.Type='panel';
            description.Name='';
            description.Flat=true;
            description.Items={desc};
            description.LayoutGrid=[1,1];
            description.RowStretch=1;
            description.ColStretch=1;
            description.Visible=1;




            dlgstruct.DialogTitle='Profiling report';
            dlgstruct.HelpMethod='doc';
            dlgstruct.HelpArgs={'eig'};
            dlgstruct.Items={description};
            dlgstruct.StandaloneButtonSet={''};
        end

    end
end


