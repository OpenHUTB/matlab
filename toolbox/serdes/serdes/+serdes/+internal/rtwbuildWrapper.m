function rtwbuildWrapper(buildTargets,app)

    oldBdroot=bdroot;
    simulinkCoderLicenseAvailable=license('test','real-time_workshop');
    embeddedCoderLicenseAvailable=license('test','rtw_embedded_coder');

    if simulinkCoderLicenseAvailable&&embeddedCoderLicenseAvailable
        coderModeText="";
    elseif simulinkCoderLicenseAvailable&&~embeddedCoderLicenseAvailable
        coderModeText=" - Simulink Coder Only";
    else
        coderModeText=" - Coderless";
    end
    pacifier=uiprogressdlg(app.ManagerFigure,"Indeterminate","on","Title","Generate DLL(s)"+coderModeText);

    originalSimulinkCoderState=get_param(oldBdroot,'UseSimulinkCoderFeatures');
    originalEmbeddedCoderState=get_param(oldBdroot,'UseEmbeddedCoderFeatures');

    restoreSimulinkCoderState=false;
    restoreEmbeddedCoderState=false;

    if~embeddedCoderLicenseAvailable&&...
        strcmp(originalEmbeddedCoderState,'on')
        set_param(oldBdroot,'UseEmbeddedCoderFeatures','off');
        restoreEmbeddedCoderState=true;
    end

    if~simulinkCoderLicenseAvailable&&...
        strcmp(originalSimulinkCoderState,'on')
        set_param(oldBdroot,'UseSimulinkCoderFeatures','off');
        restoreSimulinkCoderState=true;
    end

    if strcmpi(computer('arch'),'win64')

        buildConfigName=get_param(oldBdroot,'BuildConfiguration');
        if strcmpi(buildConfigName,'Compatibility')

            set_param(oldBdroot,'BuildConfiguration','Faster Builds');
        end
    end

    if ispc

        if regexp(pwd,'\s')

            baseDirName="tvxz dir";
            base8dot3Name="TVXZDI~";
            idx=1;
            testDirName=strcat(baseDirName,string(idx));
            dir8dot3Name=strcat(base8dot3Name,string(idx));

            while isfolder(testDirName)
                idx=idx+1;
                testDirName=strcat(baseDirName,string(idx));
                dir8dot3Name=strcat(base8dot3Name,string(idx));
            end
            mkdir(testDirName);

            if isfolder(dir8dot3Name)

                rmdir(testDirName);
            else

                figureTitle=message("serdes:ibis:FigureSpacesInPath").getString;
                buttonOneText=message('serdes:ibis:ButtonOneSpacesInPath').getString;
                buttonTwoText=message('serdes:ibis:ButtonTwoSpacesInPath').getString;
                response=uiconfirm(app.ManagerFigure,message('serdes:ibis:WarningSpacesInPath').getString,...
                figureTitle,'Options',{buttonOneText,buttonTwoText},...
                'Icon','warning');
                if strcmpi(response,buttonOneText)

                else
                    rmdir(testDirName);
                    return
                end
                rmdir(testDirName);
            end
        end
    end
    try
        for targetIdx=1:numel(buildTargets)
            buildTarget=buildTargets(targetIdx);
            pacifier.Message="Creating DLL for "+buildTarget+"...";
            rtwbuild(buildTarget,'ForceTopModelBuild',true)
        end
    catch ex
        restoreCoderState(oldBdroot,restoreSimulinkCoderState,restoreEmbeddedCoderState);
        close(pacifier)
        set_param(0,'CurrentSystem',oldBdroot)
        uialert(app.ManagerFigure,message('serdes:ibis:ErrorDuringExport').getString,"Error");
        rethrow(ex)
    end
    restoreCoderState(oldBdroot,restoreSimulinkCoderState,restoreEmbeddedCoderState);
    close(pacifier)
    set_param(0,'CurrentSystem',oldBdroot)
end


function restoreCoderState(model,restoreSimulinkCoderState,restoreEmbeddedCoderState)
    if restoreSimulinkCoderState
        set_param(model,'UseSimulinkCoderFeatures','on');
    end
    if restoreEmbeddedCoderState
        set_param(model,'UseEmbeddedCoderFeatures','on');
    end
end

