function updateContents(dlgSrc,dialogH,force)




    userData=dlgSrc.dialogUD;%#ok<NASGU>
    fileName=dialogH.getWidgetValue('docEdit');

    docTypes=rmi.linktype_mgr('all');
    docLinkType=[];

    if dlgSrc.reqIdx>0&&~isempty(dlgSrc.typeItems)&&dlgSrc.typeItems(dlgSrc.reqIdx)>0
        docLinkType=docTypes(dlgSrc.typeItems(dlgSrc.reqIdx));
    end

    if isempty(docLinkType)
        return;
    end

    if ischar(dlgSrc.objectH)
        refSrc=strtok(dlgSrc.objectH,'|');
        isSl=false;
    else
        refSrc=dlgSrc.objectH(1);
        isSl=true;
    end

    if~isempty(docLinkType)&&~docLinkType.IsFile



        if isempty(docLinkType.ContentsFcn)
            return;
        end



        switch docLinkType.Registration
        case 'linktype_rmi_simulink'
            if rmisl.isHarnessIdString(fileName)

                fileName=Simulink.harness.internal.sidmap.getHarnessObjectFromUniqueID(fileName,true);
            end
        case 'linktype_rmi_matlab'

            if~rmisl.isSidString(fileName)
                fileName=rmi.ensureFilenameExtension(fileName,docLinkType.Registration);
                fileName=rmi.locateFile(fileName,refSrc);
            end
        case 'linktype_rmi_data'

            fileName=rmi.ensureFilenameExtension(fileName,docLinkType.Registration);
            fileName=rmi.locateFile(fileName,refSrc);
        otherwise
        end

        try


            ReqMgr.activeDlgUtil(dialogH);

            if strcmp(docLinkType.Registration,'linktype_rmi_oslc')

                [headings,levels,locstrs]=feval(docLinkType.ContentsFcn,fileName,struct('doRefresh',force));
            else
                [headings,levels,locstrs]=feval(docLinkType.ContentsFcn,fileName);
            end

        catch Mex
            disp(Mex.message);
            errordlg(...
            getString(message('Slvnv:reqmgt:LinkSet:updateContents:ErrorWhileCalling_content',docLinkType.Label)),...
            getString(message('Slvnv:reqmgt:LinkSet:updateContents:RequirementsUpdateContents')));
            ReqMgr.activeDlgUtil('clear');
            return;
        end

    else
        if isSl
            filePath=rmisl.locateFile(fileName,rmi('getmodelh',refSrc));
        else
            filePath=rmi.locateFile(fileName,refSrc);
        end
        if(isempty(filePath))
            errordlg(...
            getString(message('Slvnv:reqmgt:LinkSet:updateContents:IncorrectDocName')),...
            getString(message('Slvnv:reqmgt:LinkSet:updateContents:RequirementsUpdateContents')));
            return
        end

        if rmi.linktype_mgr('is_builtin',docLinkType)
            [headings,levels,locstrs]=getDocumentIndex(filePath,force);
        else
            try
                [headings,levels,locstrs]=feval(docLinkType.ContentsFcn,filePath);
            catch Mex
                disp(Mex.message);
                errordlg(...
                getString(message('Slvnv:reqmgt:LinkSet:updateContents:ErrorWhileCalling_content',docLinkType.Label)),...
                getString(message('Slvnv:reqmgt:LinkSet:updateContents:RequirementsUpdateContents')));
                return;
            end
        end
    end

    if isempty(headings)
        dlgSrc.docContents={{getString(message('Slvnv:reqmgt:LinkSet:updateContents:NoIndexFor',fileName))},' '};
        dialogH.refresh();
        dialogH.setEnabled('contentlb',false);
    else

        if~indexOK(docLinkType,headings,levels,locstrs)
            return;
        end

        if~isempty(levels)
            for idx=1:length(headings)
                indentStr='. . ';
                fullIndent=char(ones(levels(idx),1)*indentStr)';
                fullIndent=fullIndent(:)';
                headings{idx}=[fullIndent,headings{idx}];
            end
        end

        dlgSrc.docContents={headings,locstrs};
        dialogH.refresh();
        dialogH.setEnabled('contentlb',true);

        if dlgSrc.reqIdx>0&&dlgSrc.reqIdx<=length(dlgSrc.reqItems)
            matched=find(strcmp(dlgSrc.reqItems(dlgSrc.reqIdx).id,locstrs));
            if~isempty(matched)
                dialogH.setWidgetValue('contentlb',matched(1)-1);
            end
        end
    end


    dialogH=ReqMgr.activeDlgUtil();
    if~isempty(dialogH)
        titleStr=dialogH.getTitle;
        if ispc()
            reqmgt('winFocus',titleStr);
        end
        ReqMgr.activeDlgUtil('clear');
    end
end

function result=indexOK(docLinkType,headings,levels,locstrs)
    problem=is_headings_ok(headings,levels,locstrs);
    if isempty(problem)
        result=true;
    else
        errordlg(...
        getString(message('Slvnv:reqmgt:LinkSet:updateContents:ErrorInLinktype',docLinkType.Label,problem)),...
        getString(message('Slvnv:reqmgt:LinkSet:updateContents:RequirementsUpdateContents')));
        result=false;
    end
end

function problem=is_headings_ok(headings,levels,locstrs)
    problem=[];
    if~isempty(headings)
        headings_size=length(headings);
        locstrs_size=length(locstrs);
        if(headings_size~=locstrs_size)
            problem=getString(message('Slvnv:reqmgt:LinkSet:updateContents:ResultFailedLengthLocations'));
            return;
        end
        if(~iscell(headings)||~iscell(locstrs))
            problem=getString(message('Slvnv:reqmgt:LinkSet:updateContents:ResultFailedNotCell'));
            return
        end
        if(~isempty(levels))
            levels_size=length(levels);
            if(headings_size~=levels_size)
                problem=getString(message('Slvnv:reqmgt:LinkSet:updateContents:ResultFailedLengthLevels'));
            end
        end
    elseif~isempty(levels)||~isempty(locstrs)
        locationTypesChars=linktypes.rmiLocationTypes();
        if isempty(levels)&&~isempty(locstrs)

            for i=1:length(locationTypesChars)
                if strcmp(locstrs(1),locationTypesChars(i,1))
                    return;
                end
            end
        end
        problem=getString(message('Slvnv:reqmgt:LinkSet:updateContents:ResultFailedNumberIncorrect'));
    end
end

function[headings,levels,locstrs]=getDocumentIndex(filePath,force)



    persistent CachedHeadings;
    mlock;





    try
        fileInfo=dir(filePath);
    catch Mex
        error(message('Slvnv:reqmgt:file_headings:CannotFind',filePath));
    end


    if force||isempty(fileInfo)
        timeStamp=now;
    else
        timeStamp=fileInfo.datenum;
    end


    if ispc
        filePath=lower(filePath);
    end


    if isempty(CachedHeadings)
        cacheIdx=[];
    else

        cacheIdx=find(strcmp(filePath,CachedHeadings(:,1)));


        if~isempty(cacheIdx)
            cachedTime=CachedHeadings{cacheIdx,2};
            if timeStamp>cachedTime
                CachedHeadings(cacheIdx,:)=[];
                cacheIdx=[];
            end
        end
    end

    if~isempty(cacheIdx)
        headings=CachedHeadings{cacheIdx,3};
        levels=CachedHeadings{cacheIdx,4};
        locstrs=CachedHeadings{cacheIdx,5};
        return;
    end

    [labels,depths,locStr]=rmi.getDocIndex('other',filePath);

    if nargout<3
        headings=locStr;
        levels=depths;
        locstrs=[];
    else
        headings=labels;
        levels=depths;
        locstrs=locStr;
    end



    if isempty(CachedHeadings)
        CachedHeadings={filePath,timeStamp,headings,levels,locstrs};
    else
        CachedHeadings(end+1,:)={filePath,timeStamp,headings,levels,locstrs};
    end
end
