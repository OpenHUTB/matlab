function[cvd,blockCvId,newBlockCvId,sfPortEquiv,codeInfo]=getCvdata(data,id,covMode)



    try
        if nargin<3
            covMode=[];
        end

        blockCvId=[];
        newBlockCvId=[];
        cvd=[];
        sfPortEquiv=-1;
        codeInfo=newCodeInfoStruct();


        if iscell(id)
            [id{:}]=convertStringsToChars(id{:});
        else
            id=convertStringsToChars(id);
        end

        if isa(data,'cv.cvdatagroup')

            if ischar(id)
                cvd=data.get(id,covMode);
            end

            if isempty(cvd)
                modelHandle=[];
                try
                    modelHandle=bdroot(get_param(id,'Handle'));
                catch Mex %#ok<NASGU>

                end
                if ishandle(modelHandle)
                    cvd=data.get(get_param(modelHandle,'Name'),covMode);
                end
            end

            if isempty(cvd)
                allData=data.getAll(covMode);
                for idx=1:numel(allData)
                    ccvd=allData{idx};



                    ccvd=ccvd(1);

                    [blockCvId,sfPortEquiv,fileName,fcnName,idMode]=getCVId(ccvd.rootId,id,ccvd,covMode);
                    if isBlockCvIdOK(blockCvId)
                        cvd=ccvd;
                        codeInfo=newCodeInfoStruct(blockCvId,fileName,fcnName,idMode);
                        break
                    end
                end
                if isempty(cvd)

                    for idx=1:numel(allData)
                        ccvd=allData{idx};
                        for jj=2:numel(ccvd)
                            ccvd=ccvd(jj);
                            [blockCvId,sfPortEquiv,fileName,fcnName,idMode]=getCVId(ccvd.rootId,id,ccvd,covMode);
                            if isBlockCvIdOK(blockCvId)
                                cvd=ccvd;
                                codeInfo=newCodeInfoStruct(blockCvId,fileName,fcnName,idMode);
                                break
                            end
                        end
                        if~isempty(cvd)
                            break
                        end
                    end
                end
            end

        else
            cvd=data;
            if~isempty(covMode)&&...
                SlCov.CovMode.fromString(covMode)~=SlCov.CovMode.fromString(data.simMode)


                cvd=[];
            end
        end

        if isempty(cvd)
            return
        else
            cvd=cvd(1);
        end
        rootId=cvd.rootId;


        if~isBlockCvIdOK(blockCvId)&&~isempty(cvd.modelinfo.ownerModel)

            needNewId=strcmpi(id,cvd.modelinfo.analyzedModel);

            [isBlockHarness,~,newRootId,errmsg]=cvi.ReportUtils.checkHarnessData(cvd);

            if isBlockHarness
                if~isempty(errmsg)
                    error(errmsg);
                    return;
                else
                    rootId=newRootId;
                end
            end
            if needNewId

                id=cvd.modelinfo.analyzedModel;
            end

        end

        [blockCvId,sfPortEquiv,fileName,fcnName,idMode]=getCVId(rootId,id,cvd,covMode);
        if isBlockCvIdOK(blockCvId)
            codeInfo=newCodeInfoStruct(blockCvId,fileName,fcnName,idMode);
        end

        newBlockCvId=blockCvId;

        if isBlockCvIdOK(blockCvId)&&cv('get',blockCvId,'.refClass')==-99
            descs=cv('DecendentsOf',blockCvId);
            codes=cv('get',descs,'.code');
            code=codes(codes~=0);
            newBlockCvId=cv('get',code,'.slsfobj');
        end
    catch MEx
        rethrow(MEx);
    end

    function[blockCvId,sfPortEquiv,fileName,fcnName,idMode]=getCVId(rootId,id,cvd,covMode)
        try
            modelcovId=cv('get',rootId,'.modelcov');

            cvi.ReportUtils.checkModelLoaded(modelcovId,[],false);



            cvi.ReportData.updateDataIdx(cvd);


            [lId,fileName,fcnName,idMode]=getIdForLookup(cvd,id,covMode);
            [blockCvId,sfPortEquiv]=cvprivate('find_block_cv_id',rootId,lId);
        catch MEx
            rethrow(MEx);
        end


        function codeInfo=newCodeInfoStruct(blockCvId,fileName,fcnName,mode)

            if nargin<4
                mode=SlCov.CovMode.Unknown;
            end
            if nargin<3
                fcnName='';
            end
            if nargin<2
                fileName='';
            end
            if nargin<1
                blockCvId=[];
            end
            codeInfo=struct(...
            'blockCvId',blockCvId,...
            'fileName',fileName,...
            'fcnName',fcnName,...
            'mode',mode...
            );


            function status=isBlockCvIdOK(blockCvId)

                status=~isempty(blockCvId)&&~ischar(blockCvId)&&blockCvId>0;


                function status=isSimCustomCodeOrSFunction(cvd,covMode)

                    if isempty(cvd.sfcnCovData)||~hasResults(cvd.sfcnCovData)
                        status=false;
                    else
                        if~isempty(covMode)&&covMode~=SlCov.CovMode.Normal
                            status=false;
                        else
                            status=true;
                        end
                    end


                    function[lId,fileName,fcnName,idMode]=getIdForLookup(cvd,id,covMode)


                        lId=id;
                        fileName='';
                        fcnName='';
                        idMode=SlCov.CovMode.Unknown;

                        if cvd.isSimulinkCustomCode()

                            if~SlCov.isSLCustomCodeCovFeatureOn()...
                                ||~isSimCustomCodeOrSFunction(cvd,covMode)
                                return
                            end




                            if ischar(id)
                                fileName=lId;
                                idMode=SlCov.CovMode.SLCustomCode;
                            elseif iscellstr(id)&&numel(id)==2&&~isempty(id{1})%#ok<ISCLSTR>
                                lId=id{1};
                                fileName=lId;
                                fcnName=id{2};
                                idMode=SlCov.CovMode.SLCustomCode;
                            end

                        elseif cvd.simMode==SlCov.CovMode.Normal

                            if~isSimCustomCodeOrSFunction(cvd,covMode)
                                return
                            end





                            blk=getPathFromId(id);
                            if isempty(blk)

                                return
                            end


                            try
                                sid=Simulink.ID.getSID(blk);
                            catch
                                return
                            end


                            allCovRes=cvd.sfcnCovData.getAll();
                            for ii=1:numel(allCovRes)
                                inst=allCovRes(ii).getInstanceSIDs();
                                if any(strcmp(sid,inst))

                                    lId=blk;
                                    if iscellstr(id(2:end))%#ok<ISCLSTR>
                                        fileName=id{2};
                                        if numel(id)==3
                                            fcnName=id{3};
                                        end
                                    end
                                    idMode=SlCov.CovMode.SFunction;
                                    return
                                end
                            end

                        elseif SlCov.CovMode.isGeneratedCode(cvd.simMode)

                            if(~isempty(covMode)&&~SlCov.CovMode.isGeneratedCode(covMode))||...
                                isempty(cvd.codeCovData)||~hasResults(cvd.codeCovData)
                                return
                            end








                            blk=getPathFromId(id);



                            if cvd.isAtomicSubsystemCode()
                                analyzedModel=cvd.getAnalyzedModelForATS();
                                id=analyzedModel;
                                blk=analyzedModel;
                            else
                                analyzedModel=cvd.modelinfo.analyzedModel;
                            end

                            if~isempty(blk)&&~strcmp(bdroot(blk),analyzedModel)

                                return
                            end

                            if isempty(blk)

                                if ischar(id)
                                    if~strcmp(id,analyzedModel)
                                        fileName=id;
                                    end
                                elseif iscellstr(id)%#ok<ISCLSTR>
                                    if(numel(id)<2)||(numel(id)>3)
                                        return
                                    end
                                    fileName=id{1};
                                    if cv('get',cv('get',cvd.rootId,'.modelcov'),'.isScript')||...
                                        ~strcmp(fileName,analyzedModel)
                                        fcnName=id{2};
                                    else
                                        fileName=id{2};
                                        if numel(id)>2
                                            fcnName=id{3};
                                        end
                                    end
                                else
                                    return
                                end
                                if~cvi.ReportData.hasSourceLocInCodeCovRes(cvd.codeCovData,fileName,fcnName)
                                    return
                                end
                                lId=analyzedModel;
                            else
                                if ischar(id)||(numel(id)==1&&ishandle(id))
                                    lId=id;
                                elseif iscellstr(id(2:end))%#ok<ISCLSTR>
                                    lId=id{1};
                                    if numel(id)==2
                                        fileName=id{2};
                                    elseif numel(id)==3
                                        fileName=id{2};
                                        fcnName=id{3};
                                    end
                                end
                            end
                            idMode=cvd.simMode;
                        end


                        function h=getPathFromId(id)

                            h=[];

                            if iscell(id)&&numel(id)>1&&~isempty(id{1})
                                h=getPathFromId(id{1});
                            elseif ischar(id)||(numel(id)==1&&ishandle(id))
                                try
                                    h=getfullname(id);
                                catch
                                end
                            end



