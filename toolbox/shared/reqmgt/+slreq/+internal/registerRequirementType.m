function registerRequirementType(typeName,description,parentName)













    fPathName=fullfile(pwd,'sl_customization.m');
    retryAfter=0.5;

    if isfile(fPathName)
        insertCustomization(fPathName,typeName,description,parentName,retryAfter);
    else
        createCustomization(fPathName,typeName,description,parentName);
    end

    waitForFile(fPathName,retryAfter);

    origCount=numel(slreq.app.RequirementTypeManager.getAllDisplayNames());

    slreq.refreshCustomizations();

    waitForTypeUpdate(origCount,retryAfter);
end

function createCustomization(filename,typeName,description,parentName)
    if rmiut.progressBarFcn('exists')
        rmiut.progressBarFcn('set',0.3,'Creating sl_customization.m ...');
    end
    outf=fopen(filename,'w');
    fprintf(outf,'function sl_customization(cm)\n');
    fprintf(outf,'    cObj = cm.SimulinkRequirementsCustomizer;\n');
    printNewTypeLine(outf,typeName,description,parentName);
    fprintf(outf,'end\n');
    fclose(outf);
end

function printNewTypeLine(outf,typeName,description,parentName)
    if any(strcmp(slreq.custom.RequirementType.getBuiltinTypeNames(),parentName))
        parentType=sprintf('slreq.custom.RequirementType.%s',parentName);
        fprintf(outf,'    cObj.addCustomRequirementType(''%s'', %s, ''%s'')\n',...
        typeName,parentType,description);
    else
        fprintf(outf,'    cObj.addCustomRequirementType(''%s'', ''%s'', ''%s'')\n',...
        typeName,parentName,description);
    end
end

function insertCustomization(filename,typeName,description,parentName,retryAfter)
    if rmiut.progressBarFcn('exists')
        rmiut.progressBarFcn('set',0.3,'Updating sl_customization.m ...');
    end
    backupName=[filename,'.',num2str(now)];
    movefile(filename,backupName);
    waitForFile(backupName,retryAfter);
    inpf=fopen(backupName);
    outf=fopen(filename,'w');
    while(true)
        line=fgets(inpf);
        if strcmp(strtrim(line),'end')
            printNewTypeLine(outf,typeName,description,parentName);
            fprintf(outf,line);
            break;
        else
            fprintf(outf,line);
        end
    end
    fclose(inpf);
    fclose(outf);
end

function waitForFile(filename,retryAfter)
    if rmiut.progressBarFcn('exists')
        rmiut.progressBarFcn('set',0.4,getString(message('Slvnv:slreq_objtypes:ProgressWaitingForFile')));
    end
    maxWait=20;
    countWait=0;
    while true
        if isfile(filename)
            break;
        elseif countWait>maxWait
            error(message('Slvnv:slreq_objtypes:WaitForFileTimeout',filename,num2str(retryAfter*20)));
        else
            pause(retryAfter);
            countWait=countWait+1;
            if rmiut.progressBarFcn('exists')
                rmiut.progressBarFcn('set',0.5,getString(message('Slvnv:slreq_objtypes:ProgressWaitingForFile')));
            end
        end
    end
end

function waitForTypeUpdate(origCount,retryAfter)
    if rmiut.progressBarFcn('exists')
        rmiut.progressBarFcn('set',0.6,getString(message('Slvnv:slreq_objtypes:ProgressWaitingForCustomization')));
    end
    while true
        if numel(slreq.app.RequirementTypeManager.getAllDisplayNames())>origCount
            break;
        else
            pause(retryAfter);
            if rmiut.progressBarFcn('exists')
                rmiut.progressBarFcn('set',0.7,getString(message('Slvnv:slreq_objtypes:ProgressWaitingForCustomization')));
            end
        end
    end
end
