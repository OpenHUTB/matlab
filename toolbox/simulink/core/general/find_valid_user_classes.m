function validClassListOut=find_valid_user_classes(showWaitbar,inBaseWorkspace)









    if nargin==0
        showWaitbar=true;
        inBaseWorkspace=true;
    end

    try
        if showWaitbar
            hWaitbar=waitbar(0,DAStudio.message('Simulink:utility:SearchingForDataClasses'),...
            'Name',DAStudio.message('Simulink:dialog:DCDPleaseWait'));
        else
            hWaitbar=[];
        end


        validClassList={};


        if inBaseWorkspace
            validSimulinkClasses={
'Simulink.Parameter'
'Simulink.DualScaledParameter'
'Simulink.Signal'
'Simulink.AliasType'
'Simulink.NumericType'
'Simulink.Bus'
'Simulink.ConnectionBus'
'Simulink.LookupTable'
'Simulink.Breakpoint'
            };
        else
            validSimulinkClasses={
'Simulink.Parameter'
'Simulink.DualScaledParameter'
'Simulink.Signal'
'Simulink.NumericType'
'Simulink.LookupTable'
'Simulink.Breakpoint'
            };
        end




        builtinPackagesToInclude={
'canlib'
'SimulinkC166'
'SimulinkDemos'
'ECoderDemos'
'Simulink'
'mpt'
'TgtMemCtrl'
'tic2000demospkg'
'tic6000demospkg'
'slrealtime'
        };


        hSL=findpackage('Simulink');
        if~isempty(hSL)
            hSLData=findclass(hSL,'Data');
            if~isempty(hSLData)


                packageNames=[find_valid_packages('ExcludeBuiltin');...
                builtinPackagesToInclude];

                for pIdx=1:length(packageNames)

                    if showWaitbar&&ishghandle(hWaitbar)
                        waitbar(pIdx/length(packageNames),hWaitbar);
                    end

                    thisPackageName=packageNames{pIdx};


                    if strcmp(thisPackageName,'Simulink')
                        validClassList=[validClassList;validSimulinkClasses];%#ok
                    else


                        if strcmpi(thisPackageName,'slrealtime')







                            lxpc=license('inuse','xpc_target');
                            if dig.isProductInstalled('Simulink Real-Time')&&~isempty(lxpc)
                                hThisPackage=meta.package.fromName(thisPackageName);
                                if isempty(hThisPackage)
                                    continue;
                                end
                                validClassList=[validClassList;local_GetValidClasses(hThisPackage,inBaseWorkspace)];
                            elseif dig.isProductInstalled('Simulink Real-Time')&&isempty(lxpc)

                                validClassList=[validClassList;
                                'slrealtime.Parameter';
                                'slrealtime.Breakpoint';
                                'slrealtime.LookupTable'];
                            else
                                continue;
                            end
                        else
                            hThisPackage=meta.package.fromName(thisPackageName);

                            if isempty(hThisPackage)
                                continue;
                            end

                            validClassList=[validClassList;local_GetValidClasses(hThisPackage,inBaseWorkspace)];%#ok


                        end
                    end
                end
            end
        end
        if ishghandle(hWaitbar);close(hWaitbar);drawnow;end
    catch e
        validClassListOut=validClassList;
        if ishghandle(hWaitbar);close(hWaitbar);drawnow;end
        disp(e.message);
        return;
    end

    validClassListOut=validClassList;






    function validClasses=local_GetValidClasses(hThisPackage,inBaseWorkspace)


        validClasses={};


        warnStatus=warning('off','MATLAB:errorParsingClass');
        try
            hClasses=hThisPackage.ClassList;
        catch

            hClasses=[];
        end
        warning(warnStatus);


        for cIdx=1:length(hClasses)
            hThisClass=hClasses(cIdx);
            if Simulink.data.isDerivedFrom(hThisClass,'Simulink.Data')
                validClasses(end+1,1)={hThisClass.Name};%#ok
            end
            if Simulink.data.isDerivedFrom(hThisClass,'Simulink.LookupTable')
                validClasses(end+1,1)={hThisClass.Name};%#ok
            end
            if Simulink.data.isDerivedFrom(hThisClass,'Simulink.Breakpoint')
                validClasses(end+1,1)={hThisClass.Name};%#ok
            end
        end


        for cIdx=1:length(hClasses)
            hThisClass=hClasses(cIdx);
            if inBaseWorkspace
                if Simulink.data.isDerivedFrom(hThisClass,'Simulink.DataType')
                    validClasses(end+1,1)={hThisClass.Name};%#ok
                end
            else
                if Simulink.data.isDerivedFrom(hThisClass,'Simulink.NumericType')
                    validClasses(end+1,1)={hThisClass.Name};%#ok
                end
            end
        end


