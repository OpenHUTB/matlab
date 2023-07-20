function navigate(sys,doc,id,reference,varargin)




    if nargin==1



        rmiOpenFile(sys);
        return;
    end

    callerOpt='';
    if nargin<4

        reference='';
    elseif strcmp(reference,'doors_to_slreq')


        slreq.editor();
        if~navToProxyItem('linktype_rmi_doors',doc,id)
            errordlg({...
            getString(message('Slvnv:slreq_import:NavDoorsToProxyMsg1',doc,id)),...
            getString(message('Slvnv:slreq_import:NavDoorsToProxyMsg2'))},...
            getString(message('Slvnv:slreq_import:NavDoorsToProxyTitle')));
        end
        return;
    elseif~isempty(reference)&&rmisl.isSidString(reference)

        callerOpt=strtok(reference,':');
    end


    ext='';
    if strcmp(sys,'other')
        if~isempty(doc)
            perIdx=find(doc=='.');
            if~isempty(perIdx)
                ext=doc((perIdx(end)):end);
            end
        end
        linkType=rmi.linktype_mgr('resolve',sys,ext);
    else
        linkType=rmi.linktype_mgr('resolveByRegName',sys);
    end




    if isempty(linkType)
        if strcmp(sys,'other')
            failedNavWarning(getString(message('Slvnv:rmi:navigate:TargetExtensionNotRegistered',ext)));
        else
            failedNavWarning(getString(message('Slvnv:rmi:navigate:TargetTypeNotRegistered',sys)));
        end
        return
    end


    if nargin>4&&strcmp(varargin{1},'original')
        useEditor=false;
    else
        useEditor=rmi.isInstalled();
    end

    if strcmp(linkType.Registration,'linktype_rmi_slreq')


        if useEditor
            if~isempty(callerOpt)
                navToReqEditor(doc,id,linkType,callerOpt);
            else
                navToReqEditor(doc,id,linkType,varargin{:});
            end
        else
            failedNavWarning(getString(message('Slvnv:slreq:SimulinkRequirementsNoLicenseForEditor')));
        end

    elseif linktypes.isVersionedResource(linkType.Registration)



        cmVer=slreq.cm.ResourceVersionManager.getVersion(linkType.Registration,doc,reference);
        docInfo=struct('doc',doc,'version',cmVer);
        performNavigation(linkType,docInfo,id);

    else

        if linkType.IsFile

            if useEditor&&any(strcmp(sys,{'linktype_rmi_word','linktype_rmi_excel'}))



                if slreq.app.MainManager.exists()
                    editor=slreq.app.MainManager.getInstance.requirementsEditor;
                    if~isempty(editor)&&navToProxyItem(sys,doc,id)
                        return;
                    end
                end
            end

            if any(strcmp(sys,{'linktype_rmi_word','other'}))&&rmisl.isDocBlockPath(doc)



                docPath=rmisl.docBlockTempPath(doc);
                if isempty(docPath)
                    failedNavWarning(getString(message('Slvnv:rmi:navigate:UnableToResolveDocBlock',doc)));
                    return;
                end

            elseif strncmp(doc,'http:',length('http:'))

                docPath=doc;

            else

                docPath=rmi.locateFile(doc,reference);
                if isempty(docPath)&&isempty(reference)&&isempty(fileparts(doc))





                    docPath=doc;
                end
            end

        elseif strcmp(sys,'linktype_rmi_matlab')

            docPath=rmiml.resolveDoc(doc,reference);

        elseif strcmp(sys,'linktype_rmi_data')



            docPath=rmide.resolveDict(doc,false);
            if isempty(docPath)


                docPath=rmi.locateFile(doc,reference);
            end

        elseif strcmp(sys,'linktype_rmi_testmgr')

            docPath=rmi.locateFile(doc,reference);
            if isempty(docPath)

                docPath=slreq.uri.getShortNameExt(doc);
            end

        else

            docPath=doc;
            if isempty(docPath)
                failedNavWarning(getString(message('Slvnv:rmi:navigate:UnspecifiedDocument')));
                return;
            end
        end

        if isempty(docPath)

            failedNavWarning(getString(message('Slvnv:rmi:navigate:UnableToLocateFile',doc)));
            return;
        else

            performNavigation(linkType,docPath,id);
        end

    end

    if nargin>4&&ispc&&strcmp(varargin{1},'_suppress_browser')

        reqmgt('winClose','(?:localhost|127\.0\.0\.1):\d+\/matlab\/feval/rmi.navigate');
    end
end

function performNavigation(linkType,docInfo,id)
    try
        feval(linkType.NavigateFcn,docInfo,id);
    catch Mexp
        errStr=Mexp.message;
        if contains(errStr,'==>')
            [~,errStr]=strtok(errStr,newline);
        end
        errordlg(...
        getString(message('Slvnv:rmi:navigate:NavigationErrorContent',linkType.Label,errStr)),...
        getString(message('Slvnv:rmi:navigate:NavigationError')));
    end
end

function result=navToProxyItem(sys,doc,id)
    result=false;
    req=slreq.data.ReqData.getInstance.findProxyItem(sys,doc,id);
    if~isempty(req)
        navToReqEditor(req,id);
        result=true;
    end
end

function navToReqEditor(doc,id,slreqLinkType,viewOpt)





    if nargin<3
        slreqLinkType=rmi.linktype_mgr('resolveByRegName','linktype_rmi_slreq');
        rmView='standalone';
    elseif nargin<4
        rmView='standalone';
    else
        if ischar(viewOpt)
            if any(strcmp(viewOpt,{'standalone','_suppress_browser'}))


                rmView='standalone';
            else

                rmView=get_param(bdroot(viewOpt),'Name');
            end
        elseif ishandle(viewOpt)

            rmView=get_param(bdroot(viewOpt),'Name');
        else
            error('navToReqEditor(): invalid type %s for viewOpt',class(viewOpt));
        end
    end
    feval(slreqLinkType.NavigateFcn,doc,id,rmView);
end

function failedNavWarning(msg)
    warndlg(msg,getString(message('Slvnv:rmi:navigate:FailedToNavigate')));
end

function rmiOpenFile(fPath)
    [~,~,ext]=fileparts(fPath);
    switch ext
    case '.mat'
        disp(['RMI called for MATLAB data file ',fPath]);
    case '.req'
        disp(['RMI called for MATLAB/Simulink traceability file ',fPath]);
    case{'.jpg','.jpeg','.png','.tif','.tiff','.bmp','.gif','.ico'}
        web(fPath);
    otherwise
        open(fPath);
    end
end

