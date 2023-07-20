function msg(json)


    data=jsondecode(json);
    cr=simulinkcoder.internal.Report.getInstance();
    cr.actionDispatcher(data);
