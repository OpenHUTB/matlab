function update(this,~,eventdata)









    dlg=LocalGetDialog(this);

    if~isempty(dlg)
        tc=eventdata.Source;

        setWidgetValue(dlg,'sigselector_filterEdit',tc.getFilterText);
        setWidgetValue(dlg,'sigselector_filterOptsRegExp',tc.getRegularExpression);
        setWidgetValue(dlg,'sigselector_filterOptsFlatList',tc.getFlatList);

        dlg.refresh;

        opts=tc.getOptions;
        if opts.AutoSelect
            curitem=tc.getItems;
            if~isempty(curitem)

                sel=regexprep(curitem{1}.Name,{'/'},{'//'});
                setWidgetValue(dlg,'sigselector_signalsTree',sel);
            end
        end



        istreevisible=~opts.FilterVisible||isempty(tc.getFilterText)||~tc.getFlatList;
        [treeitems,treename,listname,listitems]=constructTreeItems(this);
        if istreevisible

            if~isempty(treeitems)
                selectSignalInTree(this,dlg);
            else
                this.TCPeer.applyTreeSelections([]);
            end
        else

            if~isempty(listitems)
                selectSignalInList(this,dlg);
            else
                this.TCPeer.applyTreeSelections([]);
            end
        end
    end

    function dlg=LocalGetDialog(this)
        dlg=[];
        if~isempty(this.Parent)&&ishandle(this.Parent)
            if isa(this.Parent,'Simulink.SLDialogSource')
                dlg=this.Parent.getOpenDialogs();
                if~isempty(dlg)
                    dlg=dlg{1};
                end
            else
                dlg=DAStudio.ToolRoot.getOpenDialogs(this.Parent);
            end
        end





