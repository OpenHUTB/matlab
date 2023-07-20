function varargout=editLinks(varargin)





    persistent dlgMap;
    if isempty(dlgMap)
        dlgMap=containers.Map('KeyType','char','ValueType','any');
        rmi('init');
    end

    idx=0;
    if nargin==0
        error('Current object calls not yet supported for STM');
    else
        [fPath,id]=rmitm.resolve(varargin{:});
        if isa(varargin{end},'double')
            idx=varargin{end};
        end
    end

    if isempty(id)
        error('Cannot bring dialog for entire testSuite, please supply testCase ID');
    else

        reqs=rmitm.getReqs(fPath,id);
    end

    dlgH=[];
    myKey=[fPath,'|',id];


    if isKey(dlgMap,myKey)
        dlgH=dlgMap(myKey);
        if ishandle(dlgH)


            dlgH.refresh();
            if ispc()
                reqmgt('winFocus',[dlgH.getSource.title,'.*']);
            end
        else

            dlgH=[];
        end
    end


    if isempty(dlgH)
        dlgH=ReqMgr.rmidlg_mgr('testmgr',myKey,reqs,idx);
        dlgMap(myKey)=dlgH;
    end


    if nargout>0
        varargout{1}=dlgH;
    end
end
