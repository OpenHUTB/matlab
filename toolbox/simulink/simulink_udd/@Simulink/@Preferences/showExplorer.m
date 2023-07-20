function e=showExplorer(this)







    e=this.Explorer;
    if isempty(e)||~ishandle(e)
        e=DAStudio.Explorer(this,'Simulink Preferences',false);
        this.Explorer=e;
        e.Title=DAStudio.message('Simulink:prefs:WindowTitle');
        e.Icon=fullfile(matlabroot,'toolbox','shared','dastudio',...
        'resources','SimulinkRoot.png');
        e.setTreeTitle('');
        e.showListView(false);
        e.showTreeView(true);
        e.showDialogView(true);

        e.alwaysShowUnappliedChangesDlg=true;

        e.setDispatcherEvents({
'HierarchyChangedEvent'
'FocusChangedEvent'
'ListChangedEvent'
'PropertyChangedEvent'
        });


        am=DAStudio.ActionManager;
        am.initializeClient(e);

        this.Listeners=...
        handle.listener(e,'MEPostClosed',{@postClosed,this});


        e.Position(3)=750;
        e.Position(4)=450;
    end
    e.show;



    function postClosed(eSrc,~,this)


        delete(eSrc);
        c=this.getChildren;
        for i=1:numel(c)
            delete(c(i));
        end
        delete(this);

