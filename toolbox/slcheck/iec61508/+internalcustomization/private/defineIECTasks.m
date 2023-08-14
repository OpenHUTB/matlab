function defineIECTasks

    loc_defineByTag('IEC61508');
    loc_defineByTag('IEC62304');
    loc_defineByTag('ISO26262');
    loc_defineByTag('ISO25119');
    loc_defineByTag('EN50128');

end

function loc_defineByTag(tagName)
    mdladvRoot=ModelAdvisor.Root;

    rec=ModelAdvisor.FactoryGroup(tagName);
    rec.DisplayName=DAStudio.message(['ModelAdvisor:iec61508:',tagName,'TaskGroupTitle']);
    rec.Description=DAStudio.message(['ModelAdvisor:iec61508:',tagName,'TaskGroupDescription']);

    rec.addCheck('mathworks.iec61508.MdlVersionInfo');
    rec.addCheck('mathworks.iec61508.MdlMetricsInfo');
    rec.addCheck('mathworks.iec61508.UnconnectedObjects');

    rec2=ModelAdvisor.Common.defineHISLTasks(tagName,false);
    rec.addFactoryGroup(rec2);

    rec3=ModelAdvisor.Common.defineCertKitsTasks(tagName);
    rec.addFactoryGroup(rec3);

    mdladvRoot.publish(rec2);
    mdladvRoot.publish(rec3);
    mdladvRoot.publish(rec);
end