function varargout=editLinks(varargin)









    persistent dataMap;
    if isempty(dataMap)
        dataMap=containers.Map('KeyType','char','ValueType','any');


        rmi('init');
    end

    if~rmiml.canLink(varargin{1},true)
        return;
    end

    idx=0;
    switch length(varargin)
    case{2,3}
        fPath=varargin{1};
        if ischar(varargin{2})
            id=varargin{2};
        else

            lines=varargin{2};
            rangeHelper=slreq.mleditor.ReqPluginHelper.getInstance();
            range(1)=rangeHelper.lineNumberToCharPosition(fPath,lines(1),0);
            range(2)=rangeHelper.lineNumberToCharPosition(fPath,lines(2),-1);
            [fPath,id]=rmiml.getBookmark(fPath,range);
        end
        if nargin==3
            idx=varargin{3};
        end
    case 1

        [fPath,remainder]=strtok(varargin{1},'|');
        id=remainder(2:end);
    otherwise
        error(message('Slvnv:reqmgt:rmi:InvalidArgumentNumber'));
    end
    if isempty(id)
        error('Empty ID returned by rmiml.getBookmark()');
    end



    if rmisl.isSidString(fPath)&&rmisl.isComponentHarness(fPath)
        fPath=rmiml.harnessToModelRemap(fPath);
    end

    if any(id=='-')||any(id==':')


        reqs=[];
    else

        matchedRange=slreq.idToRange(fPath,id);
        if isempty(matchedRange)
            error(message('Slvnv:rmiml:UnmatchedID',id));
        elseif matchedRange(end)==0
            error(message('Slvnv:rmiml:BookmarkIsDeleted',id,srcUri));
        end
        rmiut.RangeUtils.setSelection(fPath,matchedRange);

        reqs=rmiml.getReqs(fPath,id);
    end

    if isKey(dataMap,fPath)
        srcData=dataMap(fPath);
        if ishandle(srcData.dlgH)
            if strcmp(srcData.id,id)&&(idx==0||srcData.dlgH.getSource.reqIdx==idx)


                srcData.dlgH.refresh();
                if ispc()
                    reqmgt('winFocus',[srcData.dlgH.getSource.title,'.*']);
                end
                return
            else

                if rmisl.isSidString(fPath)
                    srcName=fPath;
                else
                    [~,srcName]=fileparts(fPath);
                end
                question={...
                getString(message('Slvnv:reqmgt:rmidlg_mgr:DialogAlreadyOpenFor',srcName)),...
                getString(message('Slvnv:reqmgt:rmidlg_mgr:UnappliedLostIfContinue'))};
                reply=questdlg(question,getString(message('Slvnv:rmisl:menus_rmi_object:EditAddLinks')),...
                getString(message('Slvnv:reqmgt:rmidlg_mgr:Continue')),...
                getString(message('Slvnv:reqmgt:rmidlg_mgr:Cancel')),...
                getString(message('Slvnv:reqmgt:rmidlg_mgr:Cancel')));
                if~isempty(reply)&&strcmp(reply,getString(message('Slvnv:reqmgt:rmidlg_mgr:Continue')))
                    delete(srcData.dlgH);

                    srcData.dlgH=ReqMgr.rmidlg_mgr('matlab',sprintf('%s|%s',fPath,id),reqs,idx);
                    srcData.id=id;
                    dataMap(fPath)=srcData;
                else
                    return;
                end
            end
        else

            srcData.dlgH=ReqMgr.rmidlg_mgr('matlab',sprintf('%s|%s',fPath,id),reqs,idx);
            srcData.id=id;
            dataMap(fPath)=srcData;
        end
    else
        newEntry.fName=fPath;
        newEntry.id=id;
        newEntry.dlgH=ReqMgr.rmidlg_mgr('matlab',sprintf('%s|%s',fPath,id),reqs,idx);
        dataMap(fPath)=newEntry;
    end
    if nargout>0
        varargout{1}=dataMap(fPath).dlgH;
    end
end
