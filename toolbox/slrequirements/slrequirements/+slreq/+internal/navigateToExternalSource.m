function navigateToExternalSource(dataReq)




















    if dataReq.isReqIF()
        navigateToReqIfSource(dataReq);
    elseif dataReq.isOSLC()
        navigateToOslcResource(dataReq);
    else
        error(message('Slvnv:slreq:NotReqIFSourceItem',dataReq.id,dataReq.domain));
    end


end

function navigateToOslcResource(dataReq)
    dataReqSet=dataReq.getReqSet();
    queryBase=dataReqSet.getProperty('queryBase');

    projectName=dataReqSet.getProperty('projectName');
    contextUri=oslc.getSessionConfigUri(projectName);
    if isempty(contextUri)



        contextUri=dataReqSet.getProperty('configUri');
    end
    urlToReq=oslc.getNavURL(queryBase,dataReq.artifactId,contextUri);
    web(urlToReq,'-browser');
end

function navigateToReqIfSource(dataReq)


    domainLabel=dataReq.domain;
    domainLabel(1:slreq.data.Requirement.REQIF_DOMAIN_PREFIX_LENGTH)=[];
    callbackFcn=slreq.getNavigationFcn(domainLabel);

    if isempty(callbackFcn)



        domainLabel=stripApplicationVersionNumber(domainLabel);

        callbackFcn=slreq.getNavigationFcn(domainLabel);
    end

    if isempty(callbackFcn)


        promptForCallbackRegistration(domainLabel);

    elseif isempty(which(callbackFcn))


        msgStr=getString(message('Slvnv:rmiml:FileNotFound',[callbackFcn,'.m']));
        warndlg(msgStr,getString(message('Slvnv:rmi:navigate:FailedToNavigate')));

    else

        try
            feval(callbackFcn,slreq.Reference(dataReq));
        catch ex
            errordlg(...
            getString(message('Slvnv:rmi:navigate:NavigationErrorContent',domainLabel,ex.message)),...
            getString(message('Slvnv:rmi:navigate:NavigationError')));
        end
    end

end

function label=stripApplicationVersionNumber(label)




    noVersionNumber=regexprep(label,'\s[\d\.\-]+$','');
    if length(noVersionNumber)>5
        label=noVersionNumber;
    end
end

function promptForCallbackRegistration(domainLabel)

    dlgTitle=getString(message('Slvnv:rmi:navigate:NavigationError'));
    actionButton=getString(message('Slvnv:slreq:UndefinedNavCallbackTakeToEditor'));

    [~,currentPathAttribs]=fileattrib(pwd);
    if currentPathAttribs.UserWrite

        msgText={...
        getString(message('Slvnv:slreq:UndefinedNavCallbackReqIF',domainLabel)),...
        '',...
        getString(message('Slvnv:slreq:UndefinedNavCallbackInstruction','slreq.registerNavigationFcn')),...
        '',...
        getString(message('Slvnv:slreq:UndefinedNavCallbackKickstart'))};
        cancelButton=getString(message('Slvnv:slreq:Cancel'));
        result=questdlg(msgText,dlgTitle,actionButton,cancelButton,actionButton);
    else

        msgText={...
        getString(message('Slvnv:slreq:UndefinedNavCallbackReqIF',domainLabel)),...
        '',...
        getString(message('Slvnv:slreq:UndefinedNavCallbackInstruction','slreq.registerNavigationFcn'))};
        okButton=getString(message('Slvnv:slreq:OK'));
        result=questdlg(msgText,dlgTitle,okButton,okButton);
    end

    if~isempty(result)&&strcmp(result,actionButton)
        [autoFile,regName]=generateDefaultContent(domainLabel);
        slreq.registerNavigationFcn(domainLabel,regName);
        edit(autoFile);
    end

end

function[userFilePath,navFcnName]=generateDefaultContent(domainLabel)


    legalName=matlab.lang.makeValidName(domainLabel);
    navFcnName=['navTo',legalName];



    suffix=0;
    while exist(navFcnName)>0 %#ok<EXIST>
        suffix=suffix+1;
        if suffix>1
            navFcnName(end)=[];

        end
        navFcnName=sprintf('%s%d',navFcnName,suffix);
    end



    ourFilePath=fullfile(matlabroot,'toolbox','slrequirements','slrequirements','resources','stubNavFcn.m');
    fin=fopen(ourFilePath,'r');
    fileContents=fread(fin,'*char')';
    fclose(fin);

    fileContents=strrep(fileContents,'DOMAIN_LABEL',domainLabel);
    fileContents=strrep(fileContents,'FCN_NAME',navFcnName);

    userFilePath=fullfile(pwd,[navFcnName,'.m']);
    fout=fopen(userFilePath,'w');
    fprintf(fout,'%s\n',fileContents);
    fclose(fout);
end
