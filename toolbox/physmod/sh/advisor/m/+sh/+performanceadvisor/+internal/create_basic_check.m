function obj=create_basic_check(objType,id,checkFcn,actionFcn)





    narginchk(3,4);
    if nargin<4
        actionFcn=[];
    end

    checkId=['com.mathworks.simscape.performanceadvisor.',id];

    messageCatalog=['physmod:sh:performanceadvisor:',id];
    getMessage=@(msgId)DAStudio.message([messageCatalog,':',msgId]);

    switch objType

    case 'check'


        obj=ModelAdvisor.Check(checkId);

        obj.CallbackContext='None';
        obj.Visible=true;
        obj.Enable=true;
        obj.Value=true;

        obj.CSHParameters.MapKey='ma.simscape';
        obj.CSHParameters.TopicID=checkId;

        obj.setLicense({'SimHydraulics'});


        obj.Title=getMessage('Title');
        obj.TitleTips=getMessage('TitleTips');


        obj.setCallbackFcn(checkFcn,'None','StyleOne');


        if~isempty(actionFcn)
            updateAction=ModelAdvisor.Action;
            updateAction.setCallbackFcn(actionFcn);
            updateAction.Name=getMessage('ActionName');
            updateAction.Description=getMessage('ActionDescription');
            updateAction.Enable=true;
            obj.setAction(updateAction);
        end

    case 'task'

        obj=ModelAdvisor.Task(checkId);
        obj.setCheck(checkId);

    otherwise
        obj=[];
        pm_assert(false,['Unsupported object request: ',objType]);
    end

end
