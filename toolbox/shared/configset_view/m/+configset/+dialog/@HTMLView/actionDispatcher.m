function actionDispatcher(obj,~,eventData)




    msg=eventData.data;
    if~strcmp(obj.ID,msg.id)
        return;
    end

    action=msg.action;
    data=msg.data;
    switch action
    case 'init'
        obj.createPage();
    case 'done'
        obj.pageReady();
    case 'callback'
        obj.callback(data);
    case 'locateInDialog'
        obj.locateInDialog(data);
    case 'helpview'
        obj.launchHelpPage(data);
    case 'params'
        obj.sendParams(data);
    case 'selectTreeNode'
        obj.selectTreeNode(data);
    case 'layout'
        obj.layout(data);
    case 'coderTarget'
        obj.coderTarget(data);
    case 'removeError'
        obj.removeError('',data);
    case 'msg'
        obj.msg(data);
    case 'jobDone'
        obj.jobDone(data);
    case 'action'

        obj.action(data);
    case 'evalM'

        obj.evalM(data);
    case 'addConfigSet'
        obj.addConfigSet(data);
    case 'selectConfigSet'
        obj.selectConfigSet(data);
    case 'dialog-action'
        obj.dialogAction(data);
    otherwise
    end
