function varargout=selectionLinkHelper(varargin)







    persistent AllTypes;
    persistent initialized;
    persistent currentSource;
    persistent slIncluded;

    mlock;

    if nargin==1&&isempty(varargin{1})

        initialized=false;
        return;
    end

    if isempty(initialized)||~initialized

        initialized=true;
        slIncluded=true;
        currentSource='';




        AllTypes=cell(0,3);


        slReqRegName='linktype_rmi_slreq';
        slReqType=rmi.linktype_mgr('resolveByRegName',slReqRegName);
        AllTypes(end+1,:)={slReqRegName,slReqType.Label,slReqType.SelectionLinkLabel};
        cnt=1;

        enabledIdx=rmi.settings_mgr('get','selectIdx');
        if ispc
            BuiltinTypes={...
            'linktype_rmi_word';...
            'linktype_rmi_excel';...
            'linktype_rmi_doors'};

            enabledAndSetup=enabledIdx&[true,true,rmi.settings_mgr('get','isDoorsSetup')];
            EnabledTypes=BuiltinTypes(enabledAndSetup');
            for i=1:length(EnabledTypes)
                enabledReqsys=EnabledTypes{i};
                linktype=rmi.linktype_mgr('resolveByRegName',enabledReqsys);
                AllTypes(cnt+i,:)={enabledReqsys,linktype.Label,linktype.SelectionLinkLabel};
            end
        end


        if enabledIdx(3)
            oslcRegName='linktype_rmi_oslc';
            oslcLinkType=rmi.linktype_mgr('resolveByRegName',oslcRegName);
            if~isempty(oslcLinkType)
                AllTypes(end+1,:)={oslcRegName,oslcLinkType.Label,oslcLinkType.SelectionLinkLabel};
            end
        end


        regTargets=rmi.settings_mgr('get','regTargets');
        for i=1:length(regTargets)
            if regTargets{i}(1)=='%'
                continue;
            end
            customType=rmi.linktype_mgr('resolveByRegName',regTargets{i});
            if isempty(customType)
                warning(message('Slvnv:rmiml:FailedToResolveLinktype',regTargets{i}));
                continue;
            end

            if any(strcmp(fieldnames(customType),'SelectionLinkLabel'))&&~isempty(customType.SelectionLinkLabel)
                AllTypes(end+1,:)={regTargets{i},customType.Label,customType.SelectionLinkLabel};%#ok<AGROW>
            end
        end



        if dig.isProductInstalled('Simulink')&&is_simulink_loaded()
            AllTypes(end+1,:)=makeSimulinkRow();
            AllTypes(end+1,:)=makeExplorerRow();
        else
            slIncluded=false;
        end

    elseif~slIncluded&&(dig.isProductInstalled('Simulink')&&is_simulink_loaded())

        slIncluded=true;
        AllTypes(end+1,:)=makeSimulinkRow();
        AllTypes(end+1,:)=makeExplorerRow();
    end

    if nargin==0

        if~isempty(AllTypes)&&rmiLicenseAvailable()
            if rmiml.enable()
                varargout{1}=AllTypes;
            else
                varargout{1}=filterTypes(AllTypes);
            end
        else
            varargout{1}={};
        end

    elseif nargin==1

        if license_checkout_slvnv()
            type=varargin{1};
            if nargout>1
                varargout{1}=currentSource;
            end
            if~isempty(currentSource)

                [srcKey,remainder]=strtok(currentSource,'|');
                locationInfo=remainder(2:end);
            else

                [srcKey,locationInfo]=rmiml.getBookmark();



                if isempty(srcKey)
                    error(message('Slvnv:rmiml:NoFileIsOpen'));
                end
                if isempty(locationInfo)
                    locationInfo='1-1';
                end
            end
            makeLink(srcKey,locationInfo,type);
        end

    elseif nargin==2


        if~isempty(AllTypes)&&rmiLicenseAvailable()
            srcName=varargin{1};
            fId=varargin{2};
            currentSource=sprintf('%s|%s',srcName,fId);
            if rmiml.enable()
                varargout{1}=AllTypes;
            else
                varargout{1}=filterTypes(AllTypes);
            end
        else
            varargout{1}={};
        end

    elseif nargin==3


        currentSource='';
        if license_checkout_slvnv()
            type=varargin{1};
            srcKey=varargin{2};
            location=varargin{3};
            makeLink(srcKey,location,type);
        end

    else
        fprintf(1,'Incorrect number of arguments in call to rmiml.selectionLink()\n');
    end
end

function makeLink(srcName,location,type)

    if~rmiml.canLink(srcName,true)
        return;
    end

    make2way=rmi.settings_mgr('get','linkSettings','twoWayLink');


    if rmisl.isSidString(srcName)&&rmisl.isComponentHarness(srcName)
        srcName=rmiml.harnessToModelRemap(srcName);
    end

    if any(location=='-')
        range=sscanf(location,'%d-%d',2);
        location=getBookmarkId(srcName,range);
        reqs=[];
    elseif any(location==':')
        lineRange=sscanf(location,'%d:%d',2);
        rangeHelper=slreq.mleditor.ReqPluginHelper.getInstance();
        firstChar=rangeHelper.lineNumberToCharPosition(srcName,lineRange(1),0);
        lastChar=rangeHelper.lineNumberToCharPosition(srcName,lineRange(2),-1);
        range=[firstChar,lastChar];
        location=getBookmarkId(srcName,range);

        reqs=[];
    else

        reqs=rmiml.getReqs(srcName,location);
    end
    linkSource=sprintf('%s|%s',srcName,location);

    linktype=rmi.linktype_mgr('resolveByRegName',type);
    try
        req=feval(linktype.SelectionLinkFcn,linkSource,make2way);
        if~isempty(req)

            try
                reqs=catReqsPrim(reqs,req);
                rmiml.setReqs(reqs,srcName,location);
            catch Mex
                errordlg(Mex.message,...
                getString(message('Slvnv:reqmgt:linktype_rmi_word:RequirementsFailedToAddLink')));
            end
        end
    catch Mex
        errordlg(...
        getString(message('Slvnv:reqmgt:linktype_rmi_word:SelectionLinkingFailed',Mex.message)),...
        getString(message('Slvnv:reqmgt:linktype_rmi_word:FailedToAddLink')));
    end

    function result=catReqsPrim(reqs,creqs)
        if isempty(reqs)
            result=creqs(:);
        else
            result=[reqs(:);creqs(:)];
        end
    end
end

function id=getBookmarkId(srcName,range)
    range=range';
    [~,id]=rmiml.ensureBookmark(srcName,range);
end

function success=license_checkout_slvnv()
    invalid=builtin('_license_checkout','Simulink_Requirements','quiet');
    success=~invalid;
    if invalid
        rmi.licenseErrorDlg();
    end
end

function slRow=makeSimulinkRow()
    regName='linktype_rmi_simulink';
    linkType=rmi.linktype_mgr('resolveByRegName',regName);
    slRow={regName,linkType.Label,linkType.SelectionLinkLabel};
end

function slRow=makeExplorerRow()
    regName='linktype_rmi_data';
    linkType=rmi.linktype_mgr('resolveByRegName',regName);
    slRow={regName,linkType.Label,linkType.SelectionLinkLabel};
end

function activeTypes=filterTypes(allTypes)
    takeIdx=true(size(allTypes,1),1);
    slIsLoaded=dig.isProductInstalled('Simulink')&&is_simulink_loaded();
    hasSimulink=slIsLoaded&&~isempty(gcs);
    hasExplorer=slIsLoaded&&rmiut.isMeOpen();
    reqEditorOpen=slreq.app.MainManager.hasEditor();
    if hasSimulink&&hasExplorer
        activeTypes=allTypes;
    else
        for i=1:length(takeIdx)
            if~hasSimulink&&strcmp(allTypes{i,1},'linktype_rmi_simulink')
                takeIdx(i)=false;
            elseif~hasExplorer&&strcmp(allTypes{i,1},'linktype_rmi_data')
                takeIdx(i)=false;
            elseif~reqEditorOpen&&strcmp(allTypes{i,1},'linktype_rmi_slreq')
                takeIdx(i)=false;
            end
        end
        activeTypes=allTypes(takeIdx,:);
    end
end

function result=rmiLicenseAvailable()

    result=license('test','Simulink_Requirements');
end

