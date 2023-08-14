







function genCustomActionFromSystemObject(mdl)

    [~,mdlName,~]=fileparts(mdl);
    sysObj=eval(mdlName);
    actorInterface=sysObj.getInterface();
    actions=actorInterface.getActions('UserDefinedAction');


    for idx=1:length(actions)
        act=actions{idx};
        actName=act.Name;
        actBus=act.BusName;
        builder=ssm.sl_agent_metadata.internal.CustomActionBuilder(...
        actBus,'outputFileName',[actName,'.seaction']);
        builder.ActionName=actName;
        builder.StructuredData=act.DefaultValue;
        builder.writeToFile;
    end
end


