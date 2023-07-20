classdef ReqSpreadSheetMenu<handle




    properties
        view;


        busy=false;
    end



    properties(Access=private)
        filterViewComboTag='filterViewCombobox';
        filterViewComboValue2Arg=containers.Map('KeyType','int32','ValueType','char');
        filterViewCB;
    end

    methods
        function filterViewComboCB(this,dlg,idx)
            mgr=slreq.app.MainManager.getInstance;
            vm=mgr.viewManager;
            vm.refreshView;
            feval(this.filterViewCB,this.filterViewComboValue2Arg(idx));


            dlg.setWidgetValue(this.filterViewComboTag,1);
        end

        function filterViewCombo=generateFilterViewCombo(this)

            barMark=char(8212);

            menu=slreq.internal.gui.generateFilteredViewPopupMenu();
            this.filterViewCB=menu.callback;
            remove(this.filterViewComboValue2Arg,keys(this.filterViewComboValue2Arg));

            filterViewCombo=struct('Type','combobox','Tag',this.filterViewComboTag,'Graphical',true);

            entries={};
            values=[];
            counter=int32(1);
            for i=1:numel(menu.items)
                item=menu.items{i};
                for j=1:numel(item)
                    entries{end+1}=[item(j).label];
                    values(end+1)=counter;
                    this.filterViewComboValue2Arg(counter)=item(j).callbackArg;
                    counter=counter+1;
                end

                if i~=numel(menu.items)
                    entries{end+1}=char(ones(1,10)*barMark);
                    values(end+1)=counter;
                    this.filterViewComboValue2Arg(counter)='noop';
                    counter=counter+1;
                end
            end
            filterViewCombo.Entries=entries;
            filterViewCombo.Values=values;
            filterViewCombo.ObjectMethod='filterViewComboCB';
            filterViewCombo.MethodArgs={"%dialog","%value"};
            filterViewCombo.ArgDataTypes={'handle','mxArray'};

            filterViewCombo.DialogRefresh=1;
            filterViewCombo.SaveState=0;
        end

    end

    methods
        function this=ReqSpreadSheetMenu(spreadsheet)
            this.view=spreadsheet;
        end

        function dlgStruct=getDialogSchema(this,~)
            dlgStruct=slreq.gui.Toolbar.getDialogSchema(this);
        end
    end
end
