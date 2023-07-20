function aliasTable=findSignalAlias()








    import cadence.utils.*


    adeInfo=evalin('base','adeInfo.loadResult');







    adeSessionName=adeInfo.adeSession;
    historyName=adeInfo.adeHistory;
    view=skill('t','axlGetSessionViewName','t',adeSessionName);
    cell=skill('t','axlGetSessionCellName','t',adeSessionName);
    library=skill('t','axlGetSessionLibName','t',adeSessionName);

    sessionName=skill('t','maeOpenSetup','t',library,'t',cell,...
    't',view,...
    's','?histName','t',historyName,'s','?mode','t','r');
    csvFileName=[tempname,'.csv'];

    skill('t','axlOutputsExportToFile','t',sessionName,'t',char(csvFileName));
    pause(0.05);


    signalTable=readtable(csvFileName,'format','%s%s%s%s%s%s%s%s','VariableNamingRule','preserve','Delimiter',',');


    netTable=signalTable((strcmp(signalTable.Type,'net')|(strcmp(signalTable.Type,'terminal'))),:);
    if~isempty(netTable)

        aliasTable=netTable(~strcmp(netTable.Name,''),:);

        aliasTable=aliasTable(~strcmp(aliasTable.Plot,'')|~strcmp(aliasTable.Save,''),:);
        aliasTable=aliasTable(:,["Test","Name","Output","Plot","Save"]);
    else
        aliasTable=netTable;
    end


end