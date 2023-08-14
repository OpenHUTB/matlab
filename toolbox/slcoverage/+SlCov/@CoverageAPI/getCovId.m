function cvId=getCovId(blkH,sfId,varargin)




    [tsfId,tblkH,~]=SlCov.CoverageAPI.getBlockIds({blkH,sfId},[],[],[]);
    rootId=SlCov.CoverageAPI.getRootId(tblkH,tsfId);
    descr=getDescr(tblkH,tsfId);
    if isempty(rootId)||isempty(descr)
        cvId=checkScript(blkH);
        return;
    end
    correctForMatlabFunction=true;
    if numel(varargin)>0
        correctForMatlabFunction=varargin{1};
    end
    cvId=cvprivate('find_block_cv_id',rootId,descr);

    if ischar(cvId)
        cvId=[];
    elseif correctForMatlabFunction
        cvId=fixMatlabFunction(cvId);
    end

    function cvId=checkScript(name)
        cvId=[];
        if~ischar(name)||~endsWith(name,'.m')
            return;
        end
        name=name(1:end-2);


        mangledName=SlCov.CoverageAPI.mangleModelcovName(name);
        scriptModelcovIds=SlCov.CoverageAPI.findModelcovMangled(mangledName);
        rootIds=cv('get',scriptModelcovIds,'.rootTree.child');
        cvId=cv('get',cv('get',rootIds,'.topSlsf'),'.treeNode.child');


        function blockCvId=fixMatlabFunction(blockCvId)
            if~isempty(blockCvId)&&cv('get',blockCvId,'.refClass')==-99
                descs=cv('DecendentsOf',blockCvId);
                codes=cv('get',descs,'.code');
                code=codes(codes~=0);
                blockCvId=cv('get',code,'.slsfobj');
            end



            function descr=getDescr(blkH,sfId)
                descr=[];

                if~isempty(blkH)
                    descr=blkH;
                    if sfId~=0

                        descr={blkH,sfId};
                    end
                elseif~isempty(sfId)
                    descr=sfId;
                end


