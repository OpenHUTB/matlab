




function schema=SRBadgeMenu(fncname,cbinfo,eventData)
    fnc=str2func(fncname);

    if nargout(fnc)
        schema=fnc(cbinfo);
    else
        schema=[];
        if nargin==3
            fnc(cbinfo,eventData);
        else
            fnc(cbinfo);
        end
    end
end


function schema=OpenMasterGraph(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:OpenMasterGraph';
    schema.state='Enabled';
    schema.callback=@OpenMasterGraphCB;
    schema.autoDisableWhen='Never';

    target=SLStudio.Utils.getOneMenuTarget(cbinfo);
    graphHandle=target.handle;
    lockInfo=slInternal('getSRGraphLockInfo',graphHandle);


    label=DAStudio.message('Simulink:SubsystemReference:OpenMasterGraphMenuText');
    schema.label=[label,' (',lockInfo.GraphPathCausingLock,')'];


    schema.userdata=lockInfo.GraphPathCausingLock;
end

function OpenMasterGraphCB(cbinfo)
    open_system(cbinfo.userdata,'force');
end




function schema=ShowActiveInstancesMenu(cbinfo)
    schema=sl_container_schema;
    schema.tag='Simulink:ShowActiveInstances';
    schema.label=DAStudio.message(...
    'Simulink:SubsystemReference:GoToInstancesMenuText');
    schema.state='Enabled';

    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    target=SLStudio.Utils.getOneMenuTarget(cbinfo);
    blockHandle=target.handle;
    schema.childrenFcns={im.getAction('Simulink:HiddenSchema')};
    displayList=SLStudio.Utils.internal.createSSRefInstanceDisplayList(blockHandle);
    instanceCount=length(displayList);
    if(instanceCount==0)
        schema.state='Disabled';
    end
    childrenFcns=cell(instanceCount,1);

    for ii=1:instanceCount
        childrenFcns{ii}={@AddShowActiveInstancesMember,...
        {ii,displayList{ii}}};
    end

    if~isempty(childrenFcns)
        schema.childrenFcns=childrenFcns;
    end
end

function schema=AddShowActiveInstancesMember(cbinfo)
    memberIndex=cbinfo.userdata{1};
    memberName=cbinfo.userdata{2};

    schema=sl_action_schema;
    schema.label=memberName;
    schema.tag=['Simulink:ShowActiveInstancesMember_',...
    num2str(memberIndex)];
    schema.autoDisableWhen='Never';
    schema.userdata=memberName;
    schema.callback=@ShowActiveInstancesCB;
end

function ShowActiveInstancesCB(cbinfo)
    SLStudio.Utils.internal.ssRefOpenInstance(cbinfo.userdata);
end

