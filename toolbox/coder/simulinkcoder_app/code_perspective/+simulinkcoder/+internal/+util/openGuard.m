function[out,appName]=openGuard(studio,appName,blocking)





    if nargin<3
        blocking=true;
    end

    editor=studio.App.getActiveEditor;
    current=editor.blockDiagramHandle;
    top=studio.App.blockDiagramHandle;
    currentName=get_param(current,'Name');
    topName=get_param(top,'Name');



    if bdIsLibrary(top)
        out=true;
        return;
    end


    mdlMatch=(current==top);


    cp=simulinkcoder.internal.CodePerspective.getInstance;
    expectedApp=cp.getInfo(top);
    if isempty(expectedApp)

        out=false;
        return
    end



    stfChangeRequired=~strcmp(appName,expectedApp)&&~((strcmp(appName,'DDS')&&strcmp(expectedApp,'EmbeddedCoder'))...
    ||(strcmp(appName,'EmbeddedCoder')&&strcmp(expectedApp,'DDS')));


    appChanged=~strcmp(appName,expectedApp);


    topSTF=get_param(top,'SystemTargetFile');
    currentSTF=get_param(current,'SystemTargetFile');

    if(strcmp(appName,'EmbeddedCoder')&&strcmp(expectedApp,'DDS'))
        mapping=Simulink.CodeMapping.getCurrentMapping(bdroot);
        if~isempty(mapping)&&~isequal(mapping.DeploymentType,'Unset')
            mapping.DeploymentType='Unset';
        else

            out=false;
            return;
        end
    end



    if appChanged&&~stfChangeRequired
        loc_closeCP(studio);
        out=true;
        return
    end

    currentExpectedApp=cp.getInfo(current);


    topIsAutosarArch=Simulink.internal.isArchitectureModel(top,'AUTOSARArchitecture');

    if mdlMatch
        if topIsAutosarArch

            out=false;
            return;
        elseif mdlMatch&&~stfChangeRequired

            out=true;
            return;
        end
    end


    info=coder.internal.toolstrip.util.getAppInfo(appName);
    expectedInfo=coder.internal.toolstrip.util.getAppInfo(expectedApp);

    title=message('SimulinkCoderApp:codeperspective:Open',info.disp).getString;

    mdlMismatchText=message('SimulinkCoderApp:codeperspective:mdlMismatch',...
    topName,currentName).getString;

    stfMismatchText=message('SimulinkCoderApp:codeperspective:stfMismatch',...
    topSTF,info.stf,info.disp).getString;

    stfChangeText=message('SimulinkCoderApp:codeperspective:stfChange',...
    info.stf).getString;

    csrefText=message('SimulinkCoderApp:codeperspective:csref',...
    topSTF).getString;

    newAppText=message('SimulinkCoderApp:codeperspective:newApp',...
    expectedInfo.disp).getString;

    btnContinue=message('SimulinkCoderApp:codeperspective:Continue').getString;
    btnContinueOnTop=message('SimulinkCoderApp:codeperspective:ContinueOnTop').getString;
    btnCancel=message('SimulinkCoderApp:codeperspective:Cancel').getString;
    btnOpenActive=message('SimulinkCoderApp:codeperspective:OpenActiveAsTop').getString;
    btnOpenNewApp=message('SimulinkCoderApp:codeperspective:Open',expectedInfo.disp).getString;


    cs=getActiveConfigSet(top);
    isRef=isa(cs,'Simulink.ConfigSetRef');
    dp=DAStudio.DialogProvider;
    topIsOldAutosarComposition=Simulink.CodeMapping.isMappedToAutosarComposition(top);

    if~mdlMatch&&(topIsAutosarArch||topIsOldAutosarComposition)


        out=false;
        open_system(currentName);
        cp.turnOnPerspective(currentName);
    elseif~mdlMatch&&~stfChangeRequired
        if blocking
            text=mdlMismatchText;
            answer=dp.questdlg(text,title,{btnContinueOnTop,btnOpenActive,btnCancel},btnCancel);

            switch answer
            case btnContinueOnTop
                out=true;
            case btnOpenActive
                out=false;
                open_system(currentName);
                if~strcmp(currentExpectedApp,appName)
                    cp.cleanupFlags(currentName);
                    set_param(currentName,'SystemTargetFile',info.stf);
                    cp.turnOnPerspective(currentName,'nonblocking');
                else
                    cp.turnOnPerspective(currentName,'nonblocking');
                end
            otherwise
                out=false;
            end

        else
            out=true;
        end


    elseif mdlMatch&&stfChangeRequired
        if isRef
            if blocking
                text=sprintf('%s\n\n%s',csrefText,newAppText);
                answer=dp.questdlg(text,title,{btnOpenNewApp,btnCancel},btnCancel);

                if strcmp(answer,btnOpenNewApp)
                    out=false;
                    appName=expectedInfo.name;
                    cp.turnOnPerspective(studio,'nonblocking');
                else
                    out=false;
                end

            else
                out=false;
            end
        else
            if blocking
                text=stfMismatchText;
                if strcmp(appName,'Autosar')


                    out=true;
                else
                    answer=dp.questdlg(text,title,{btnContinue,btnCancel},btnCancel);
                    if strcmp(answer,btnContinue)
                        out=true;
                        loc_closeCP(studio);
                        set_param(top,'SystemTargetFile',info.stf);
                    else
                        out=false;
                    end
                end
            else
                out=false;
            end
        end

    elseif~mdlMatch&&stfChangeRequired
        if blocking

            if isRef
                text=sprintf('%s\n\n%s',csrefText,newAppText);
                answer=dp.questdlg(text,title,{btnOpenNewApp,btnCancel},btnCancel);
            else
                text=sprintf('%s\n\n%s',mdlMismatchText,stfChangeText);
                answer=dp.questdlg(text,title,{btnContinueOnTop,btnOpenActive,btnCancel},btnCancel);
            end

            switch answer
            case btnContinueOnTop
                out=true;
                loc_closeCP(studio);
                set_param(top,'SystemTargetFile',info.stf);
            case btnOpenActive
                out=false;
                open_system(currentName);
                if~strcmp(currentExpectedApp,appName)
                    cp.cleanupFlags(currentName);
                    set_param(currentName,'SystemTargetFile',info.stf);
                    cp.turnOnPerspective(currentName,'nonblocking');
                else
                    cp.turnOnPerspective(currentName,'nonblocking');
                end
            case btnOpenNewApp
                out=false;
                appName=expectedInfo.name;
                cp.turnOnPerspective(studio,'nonblocking');
            otherwise
                out=false;
            end
        else
            out=false;
        end

    end

    function loc_closeCP(studio)

        cp=simulinkcoder.internal.CodePerspective.getInstance;
        bool=cp.isInPerspective(studio);
        if bool


            cp.close(studio);
        end


