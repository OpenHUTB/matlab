function adapter=launchModelDDLinks(model,dataDictName)

    modelMap=containers.Map();
    buttonPanel=Simulink.ModelDDLinksButtonPanel;
    adapter=Simulink.dd.ModelDDLinksAdapter(buttonPanel,model,true,modelMap,dataDictName);
    me=DAStudio.Explorer(adapter,'',false);
    me.setListProperties({'-Name','Model','DataDictionary'});

    adapter.UserData.me=me;

    buttonPanel.rootAdapter=adapter;
    adapter.initialize();
    me.installInfoManager(buttonPanel);

    am=DAStudio.ActionManager;
    am.initializeClient(me);

















    tb=am.createToolBar(me);
    tbt=am.createToolBarText(tb);
    tbt.setText('View/edit data dictionaries used by model reference hierarchy');
    tb.addWidget(tbt);




















    me.title='Design Data for Referenced Models';

    me.scope='CurrentAndBelow';
    me.showTreeView(true);
    me.showDialogView(false);
    me.showStatusBar(false);
    me.showContentsOfHyperlink(false);
    me.GroupingEnabled=1;


    me.show();




    longestModelName='ALongModel';
    longestDDName='LongDataDictionary';
    me.setListViewStrColWidth('Model',longestModelName,2);

    me.setListViewStrColWidth('DataDictionary',longestDDName,2);
end
