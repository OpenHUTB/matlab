


classdef SubsystemPopup<handle


    properties(Access=private)

        HConfigBlock=0;

        PopupType='Info';
        IsGraphBadge=false;

        Latency double=0;
        OptimumLatency double=0;
        NumThreadsStr='';

        ShowSuggested=false;
        ShowAccept=false;
        ShowUpdate=false;
        ShowLatency=true;

Dialog
    end

    methods(Access=public)

        function this=SubsystemPopup(badgeType,isGraph,hConfigBlock,evalLatency)


            this.PopupType=badgeType;
            this.IsGraphBadge=isGraph;
            this.HConfigBlock=hConfigBlock;
            this.Latency=evalLatency;

            init(this);
        end

        function show(this,dlg)


            this.Dialog=dlg;


            if(this.IsGraphBadge)
                dlg.position=Simulink.harness.internal.calcDialogGeometry(...
                dlg.position(3),...
                dlg.position(4),...
                'Model');
                dlg.position(2)=dlg.position(2)-dlg.position(4);
            else
                dlg.position=Simulink.harness.internal.calcDialogGeometry(...
                dlg.position(3),...
                dlg.position(4),...
                'Block',gcb);
                dlg.position(2)=dlg.position(2)+25;
            end

            dlg.show();
        end

        function accept(this)


            set_param(this.HConfigBlock,'Latency',num2str(this.OptimumLatency));

            if~isempty(this.Dialog)
                this.Dialog.hide();
            end
        end

        function openConfigBlkDialog(this)


            open_system(this.HConfigBlock,'parameter');


            blkName=get_param(this.HConfigBlock,'name');
            blkDlgTitle=DAStudio.message('Simulink:dialog:BlockParameters',blkName);
            blkDlg=findDDGByTitle(blkDlgTitle);
            imd=DAStudio.imDialog.getIMWidgets(blkDlg);
            tab=imd.find('tag','ParameterTabContainerVar');
            blkDlg.setActiveTab(tab.tag,2);

            if~isempty(this.Dialog)
                this.Dialog.hide();
            end
        end

        function findConfigBlk(this)


            hilite_system(this.HConfigBlock,'find');

            if~isempty(this.Dialog)
                this.Dialog.hide();
            end
        end

        function updateModel(this)


            if~isempty(this.Dialog)
                this.Dialog.hide();
            end

            try
                set_param(bdroot(this.HConfigBlock),'SimulationCommand','update');
            catch E
                msld=MSLDiagnostic(E);
                msld.reportAsError(getfullname(bdroot(this.HConfigBlock)),true);
            end

        end

        function openHelp(this)





            if~isempty(this.Dialog)
                this.Dialog.hide();
            end
        end

    end

    methods(Access=private)

        function init(this)


            if contains(this.PopupType,'Info')



                stopped=strcmp(get_param(bdroot(this.HConfigBlock),"SimulationStatus"),"stopped");



                this.ShowLatency=~contains(this.PopupType,'Limited');


                ui=get_param(bdroot(this.HConfigBlock),'DataflowUI');

                if~isempty(ui)
                    mappingData=ui.getBlkMappingData(this.HConfigBlock);
                    if mappingData.Attributes>0
                        this.OptimumLatency=mappingData.OptimalLatency;
                        this.NumThreadsStr=num2str(mappingData.NumberOfThreads);

                        this.ShowUpdate=(mappingData.SpecifiedLatency~=this.Latency)&&stopped;

                        if((this.Latency~=this.OptimumLatency)&&this.ShowLatency)
                            this.ShowSuggested=true;

                            latencyStr=get_param(this.HConfigBlock,'Latency');
                            this.ShowAccept=isempty(regexp(latencyStr,'\D','once'))&&stopped;
                        end
                    else

                        this.ShowUpdate=stopped;
                    end
                end
            end
        end

    end

end


