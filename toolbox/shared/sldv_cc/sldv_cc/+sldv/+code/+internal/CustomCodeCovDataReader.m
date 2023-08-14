



classdef CustomCodeCovDataReader<sldv.code.internal.CovDataReader



    methods



        function obj=CustomCodeCovDataReader(covData,covFilter)
            if nargin<2
                covFilter=[];
            end

            obj@sldv.code.internal.CovDataReader(covFilter);

            if~isempty(covData)
                if isa(covData,'cv.cvdatagroup')
                    allCovDatas=covData.getAll();
                else
                    allCovDatas={covData};
                end

                for ii=1:numel(allCovDatas)
                    currentCovData=allCovDatas{ii};
                    if~isempty(currentCovData.sfcnCovData)
                        allSFcnData=currentCovData.sfcnCovData.getAll();
                        for jj=1:numel(allSFcnData)
                            obj.handleSFcnCovData(allSFcnData(jj));
                        end
                    end
                end
            end
        end
    end

    methods(Access=private)
        function handleSFcnCovData(obj,sfcnData)

            switch sfcnData.CodeTr.SourceKind
            case internal.cxxfe.instrum.SourceKind.SFunction
                for ii=1:sfcnData.getNumInstances()
                    res=sfcnData.getInstanceResults(ii);
                    obj.Id2CovInfo(res.instance.sid)=...
                    sldv.code.internal.CovDataReader.getInstanceCovDataInfo(sfcnData,ii);
                end
            case internal.cxxfe.instrum.SourceKind.SLCustomCode
                numInst=sfcnData.getNumInstances();
                if numInst>1

                    idx=numInst+1;
                else
                    idx=1;
                end
                try
                    tmp=sldv.code.internal.CovDataReader.getInstanceCovDataInfo(sfcnData,idx);



                    res=sfcnData.getInstanceResults(1);
                    sid=res.instance.name;

                    if obj.Id2CovInfo.isKey(sid)


                        current=obj.Id2CovInfo(sid);
                        current.CoveredIds=[current.CoveredIds(:);tmp.CoveredIds(:)];


                        tmpMcdcs=tmp.CoveredMCDC.keys;
                        for ii=1:numel(tmpMcdcs)
                            k=tmpMcdcs{ii};
                            current.CoveredMCDC(k)=tmp.CoveredMCDC(k);
                        end


                        tmpFilt=tmp.FilterInfoIds.keys;
                        for ii=1:numel(tmpFilt)
                            k=tmpFilt{ii};
                            current.FilterInfoIds(k)=tmp.FilterInfoIds(k);
                        end


                        tmpFilt=tmp.FilterInfoMCDC.keys;
                        for ii=1:numel(tmpFilt)
                            k=tmpFilt{ii};
                            current.FilterInfoMCDC(k)=tmp.FilterInfoMCDC(k);
                        end

                        obj.Id2CovInfo(sid)=current;
                    else
                        obj.Id2CovInfo(sid)=tmp;
                    end
                catch ME
                    if sldv.code.internal.feature('disableErrorRecovery')
                        rethrow(ME);
                    end
                end
            end
        end
    end

    methods(Access=protected)



        function codeCovData=getCodeCovData(obj,blkH,covData,moduleName,covOrDecId)%#ok<INUSD>
            key=Simulink.ID.getSID(blkH);
            codeCovData=obj.Id2CovInfo(key);
        end




        function codeFilterData=getCodeFilterInternalExclusionData(this,blkH,moduleName,covOrDecId)%#ok<INUSD>
            codeFilterData=[];
        end




        function codeFilterData=getCodeFilterData(this,blkH,moduleName,covOrDecId)%#ok<INUSD>
            codeFilterData=[];

            if~isempty(this.CovFilterObj)
                key=Simulink.ID.getSID(blkH);

                if this.Id2CovFilterInfo.isKey(key)
                    codeFilterData=this.Id2CovFilterInfo(key);
                    return
                end



                try
                    [isFiltered,prop,rationale]=this.CovFilterObj.isFiltered(key);
                    if isFiltered
                        codeFilterData=sldv.code.internal.CovDataReader.newInstanceCovDataInfo();
                        codeFilterData.FilterInfoByHandle(blkH)=sldv.code.internal.CovDataReader.newFilterInfo(true,prop.mode,rationale);
                        this.Id2CovFilterInfo(key)=codeFilterData;
                        return
                    end
                catch ME
                    if sldv.code.internal.feature('disableErrorRecovery')
                        rethrow(ME);
                    end
                    codeFilterData=[];
                end

                handleType=get_param(blkH,'Type');
                if "block_diagram"==handleType
                    try

                        model=get_param(blkH,'Name');
                        ccLib=CGXE.CustomCode.getCustomLibNameFromModel(model,'dynamic',moduleName);

                        if isfile(ccLib)
                            traceabilityDb=internal.slcc.cov.LibUtils.getTraceabilityDb(ccLib);

                            tmpDir=tempname;
                            polyspace.internal.makeParentDir(fullfile(tmpDir,'.'));
                            cleanupDir=onCleanup(@()sldv.code.internal.removeDir(tmpDir));
                            dbFile=sldv.code.internal.extractDb(tmpDir,traceabilityDb);

                            codeCovData=SlCov.results.CodeCovData(...
                            'traceabilitydbfile',dbFile,...
                            'forceNonEmptyResults',true,...
                            'name',moduleName);
                            codeCovData.applyCovFilter(this.CovFilterObj);

                            codeFilterData=sldv.code.internal.CovDataReader.getInstanceCovDataInfo(...
                            codeCovData,1);
                        end
                    catch ME
                        if sldv.code.internal.feature('disableErrorRecovery')
                            rethrow(ME);
                        end
                        codeFilterData=[];
                    end
                elseif "block"==handleType
                    try
                        blockType=get_param(blkH,'BlockType');
                        if "S-Function"==blockType
                            functionName=get_param(blkH,'FunctionName');

                            tmpDir=tempname;
                            polyspace.internal.makeParentDir(fullfile(tmpDir,'.'));
                            cleanupDir=onCleanup(@()sldv.code.internal.removeDir(tmpDir));
                            dbFile=sldv.code.sfcn.internal.extractSFcnDb(functionName,tmpDir);
                            codeCovData=SlCov.results.CodeCovData(...
                            'traceabilitydbfile',dbFile,...
                            'forceNonEmptyResults',true,...
                            'name',key,...
                            'instances',struct('SID',key));

                            instIdx=1;
                            covFilterInfo=this.CovFilterObj.getAllCodeInfo();
                            for ii=1:numel(covFilterInfo)
                                filterInfo=covFilterInfo{ii};
                                [codeInfo,ssid]=Sldv.Filter.decodeCodeFilterInfo(filterInfo.value);
                                isFilter=~logical(filterInfo.mode);
                                if~isempty(codeInfo)&&strcmp(ssid,key)
                                    if Sldv.Filter.isCodeFilterFileInfo(codeInfo)
                                        codeCovData.annotateFile(isFilter,filterInfo.Rationale,codeInfo{:},instIdx);
                                    elseif Sldv.Filter.isCodeFilterFunInfo(codeInfo)
                                        codeCovData.annotateFunction(isFilter,filterInfo.Rationale,codeInfo{:},instIdx);
                                    elseif Sldv.Filter.isCodeFilterDecInfo(codeInfo)||Sldv.Filter.isCodeFilterCondInfo(codeInfo)||...
                                        Sldv.Filter.isCodeFilterMCDCInfo(codeInfo)||Sldv.Filter.isCodeFilterRelBoundInfo(codeInfo)
                                        codeCovData.annotateExpression(isFilter,filterInfo.Rationale,codeInfo{:},instIdx);
                                    end
                                end
                            end

                            codeFilterData=sldv.code.internal.CovDataReader.getInstanceCovDataInfo(...
                            codeCovData,1);
                        end
                    catch ME
                        if sldv.code.internal.feature('disableErrorRecovery')
                            rethrow(ME);
                        end
                        codeFilterData=[];
                    end
                end

                this.Id2CovFilterInfo(key)=codeFilterData;
            end
        end
    end
end


