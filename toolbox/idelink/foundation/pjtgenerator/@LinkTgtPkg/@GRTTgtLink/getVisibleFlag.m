function isVisible=getVisibleFlag(hSrc,objProp,widgetGroup)
















    if nargin==3&&strcmpi(objProp,'group')
        isVisible=getGroupVisibility(widgetGroup);
        return
    end





    overrunGroup={'overrunNotificationMethod','overrunNotificationFcn'};
    linkerGroup={'linkerOptionsStr','getLinkerOptions','resetLinkerOptions'};
    profileGroup={'ProfileGenCode','profileBy','ProfileNumSamples'};
    systemGroup={'systemStackSize'};






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


    if any(strcmp(objProp,OptionsToBeInvisible))
        isVisible=false;
    else
        isVisible=true;
    end






    if any(strcmp(objProp,{profileGroup{2:end}}))
        isVisible=isVisible&&strcmp(hSrc.ProfileGenCode,'on');
    end


    function isvisible=getGroupVisibility(widgetGroup)

        isvisible=any(cell2mat(cellfun(@(x)logical(x.Visible),widgetGroup.Items,'UniformOutput',false)));
