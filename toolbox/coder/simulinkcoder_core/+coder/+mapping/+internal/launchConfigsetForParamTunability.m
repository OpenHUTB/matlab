function launchConfigsetForParamTunability(ssComponent,obj,propertyName)



    bd=ssComponent.getSource;
    mdlName=bd.getFullName;
    cs=getActiveConfigSet(mdlName);
    configset.showParameterGroup(cs,{'DefaultParameterBehavior'});

end