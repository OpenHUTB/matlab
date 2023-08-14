function schema=getSlMenuCustomization(callbackInfo)









    persistent menuItems;
    persistent haveItems;
    persistent menuLabel;

    if isempty(haveItems)


        haveItems=false;
        methodName=mfilename;

        clientNames=SSC.SimscapeCC.getClientClasses;
        for j=1:length(clientNames)

            eval([' thisClient = ',clientNames{j},';']);
            if any(strcmp(methods(thisClient),methodName))


                menuItems{end+1}=eval(['@',clientNames{j},'.',methodName]);
                haveItems=true;

            end

        end

        configData=SimscapeCC_config;

        menuLabel=pm_message(configData.SlMenu.Name_msgid);

    end


    if haveItems

        schema=sl_container_schema;
        schema.childrenFcns=menuItems;

    else


        schema=sl_action_schema;
        schema.callback=@noOpCallback;

    end

    schema.label=menuLabel;
    schema.tag='SSC';





    function noOpCallback(callbackInfo)


