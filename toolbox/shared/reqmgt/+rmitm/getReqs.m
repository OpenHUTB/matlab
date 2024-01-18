function reqs=getReqs(varargin)
    [testSuite,id,ext]=rmitm.resolve(varargin{:});

    if~slreq.hasData(testSuite)
        slreq.utils.loadLinkSet(testSuite);
    end

    switch ext
    case '.mldatx'
        reqs=slreq.getReqs(testSuite,id,'linktype_rmi_testmgr');
    case '.m'
        bookmark=rmiml.RmiMUnitData.getBookmarkForTest(testSuite,id,rmiml.RmiMUnitData.NO_CREATE_BOOKMARK);
        if~isempty(bookmark)
            reqs=rmiml.getReqs(testSuite,bookmark);
        else
            reqs=[];
        end
    end

    if~isempty(reqs)
        isSlreq=strcmp({reqs.reqsys},'linktype_rmi_slreq');
        if any(isSlreq)
            adapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain('linktype_rmi_slreq');
            for i=find(isSlreq)
                reqs(i).description=adapter.getSummary(reqs(i).doc,reqs(i).id);
            end
        end

        if nargin>2
            reqs=rmi.filterReqs(reqs,varargin{end-1:end});
        end
    end
end


