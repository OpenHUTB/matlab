function isVisible=getVisibleFlag(hSrc,objProp,widgetGroup)
















    if nargin==3&&strcmpi(objProp,'group')
        isVisible=getGroupVisibility(widgetGroup);
        return;
    end




    if~isSupportedWidget(hSrc,objProp)
        isVisible=false;
        return;
    end





    autoGroup={'ideObjBuildTimeout','ideObjTimeout','exportIDEObj','ideObjName'};
    overrunGroup={'overrunNotificationMethod','overrunNotificationFcn'};
    linkerGroup={'linkerOptionsStr','getLinkerOptions','resetLinkerOptions'};
    profileGroup={'ProfileGenCode','profileBy','ProfileNumSamples'};
    systemGroup={'systemStackSize'};
    getfromIDEGroup={'getCompilerOptions','getLinkerOptions'};






    switch(hSrc.buildAction)
    case 'Archive_library'
        OptionsToBeInvisible=...
        [linkerGroup,...
        systemGroup,...
        overrunGroup,...
        profileGroup];
    otherwise
        OptionsToBeInvisible={};
    end




    switch(hSrc.buildFormat)
    case 'Makefile'
        OptionsToBeInvisible=[OptionsToBeInvisible,autoGroup,profileGroup,getfromIDEGroup];
    end

    if any(strcmp(objProp,OptionsToBeInvisible))
        isVisible=false;
    else
        isVisible=true;
    end






    if any(strcmp(objProp,profileGroup(2:end)))
        isVisible=isVisible&&strcmp(hSrc.ProfileGenCode,'on');
    end


    function isvisible=getGroupVisibility(widgetGroup)

        isvisible=any(cell2mat(cellfun(@(x)logical(x.Visible),widgetGroup.Items,'UniformOutput',false)));
