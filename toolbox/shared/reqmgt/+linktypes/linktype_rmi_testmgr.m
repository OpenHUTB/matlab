function linkType=linktype_rmi_testmgr

    linkType=ReqMgr.LinkType;
    linkType.Registration=mfilename;
    linkType.Label=getString(message('Slvnv:rmitm:LinkableDomainLabel'));

    linkType.IsFile=0;
    linkType.Extensions={'.mldatx'};

    linkType.LocDelimiters='@';
    linkType.Version='';

    linkType.NavigateFcn=@NavigateFcn;
    linkType.BrowseFcn=@BrowseObjects;
    linkType.ContentsFcn=@ContentsFcn;

    linkType.CreateURLFcn=@CreateURLFcn;

    linkType.ItemIdFcn=@ItemIdFcn;
    linkType.SelectionLinkFcn=@SelectionLinkFcn;
    linkType.SelectionLinkLabel=getString(message('Slvnv:rmitm:LinkToCurrent'));
end


function NavigateFcn(testFile,testID)
    if length(testID)>1&&testID(1)=='@'
        testID=testID(2:end);
    end
    rmitm.navigate(testFile,testID);
end


function req=SelectionLinkFcn(objH,make2way)
    req=[];
    [testFile,testID,~]=stm.internal.util.getCurrentTestCase();

    if isempty(testFile)||isempty(testID)
        errordlg(...
        getString(message('Slvnv:rmitm:TestCaseNotSelected')),...
        getString(message('Slvnv:rmitm:SelectionLinkingError')),...
        'modal');
        return;
    end

    stmTarget=[testFile,'|',testID];

    if make2way
        if~slreq.internal.isSlreqItem(objH)
            returnLink=rmi.makeReq(objH,stmTarget);
            if isempty(returnLink)

                req=[];
                return;
            else
                rmi.catReqs(stmTarget,returnLink);
                rmitm.UpdateNotifier.notifyReqUpdate(testFile,testID);
            end
        end
    end


    req=rmitm.makeReq(stmTarget,objH);
end

function testFile=BrowseObjects()



    extensions='*.mldatx;';
    [fileName,pathName]=uigetfile(...
    {extensions,getString(message('Slvnv:rmitm:SimulinkTestCaseExtensions',extensions));...
    '*.*',getString(message('Slvnv:reqmgt:linktype_rmi_simulink:AllFilesExtensions'))},...
    getString(message('Slvnv:rmitm:SelectTargetTestFile')));

    if isempty(fileName)||~ischar(fileName)
        testFile='';
        return;
    else
        testFile=fullfile(pathName,fileName);

        open(testFile);

        if ispc
            reqmgt('winFocus',['^',getString(message('Slvnv:reqmgt:rmidlg_mgr:LinkEditor',''))]);
        end
    end
end

function[labels,depths,locations]=ContentsFcn(testFile)

    [suites,items,index]=rmitm.getTestItems(testFile);
    dataSize=size(index');
    labels=cell(dataSize);
    depths=2*ones(dataSize);
    locations=cell(dataSize);
    testFileName='';
    for i=1:length(index)
        item=items(i);
        locations{i}=['@',item.uuid];
        if isempty(item.suite)

            depths(i)=0;
            testFileName=item.file;
            labels{i}=[testFileName,'.mldatx'];
        elseif isempty(item.case)

            depths(i)=1;

            labels{i}=getString(message('Slvnv:slreq_import:PartInDoc',item.suite,testFileName));
        else


            labels{i}=getString(message('Slvnv:slreq_import:PartInDoc',item.case,suites{index(i)}));
        end
    end
end


function url=CreateURLFcn(testFile,~,testCase)

    if~isempty(testCase)&&testCase(1)=='@'
        testCase=testCase(2:end);
    end
    url=sprintf('matlab:rmitm.navigate(''%s'', ''%s'')',testFile,testCase);
end


function out=ItemIdFcn(host,in,mode)

    if isempty(strtok(in))
        if mode
            out='';
        else
            [~,out]=fileparts(host);
        end
        return;
    end
    if isempty(host)
        if mode
            error(message('Slvnv:reqmgt:rmidlg_apply:NoValidSelectionIn','Simulink Test'));
        else
            out=in;
            return;
        end
    end
    if in(1)=='@'
        in(1)=[];
    end
    if mode

        out=strtok(in);
    else

        testCaseName=stm.internal.getTestCaseNameFromUUIDAndTestFile(in,host);
        if isempty(testCaseName)
            out=in;
        else
            out=[in,' (',testCaseName,')'];
        end
    end
end
