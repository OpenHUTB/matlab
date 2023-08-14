



function varargout=getMLCoderCoverageInfoInternal(data,metric,ids,covMode)

    nargoutchk(0,2);
    if nargout<1
        return
    end

    if nargin<4
        covMode=SlCov.CovMode.SIL;
    end
    covMode=SlCov.CovMode(covMode);

    if iscell(ids)
        [ids{:}]=convertStringsToChars(ids{:});
    else
        ids=convertStringsToChars(ids);
    end
    ids=cellstr(ids);

    metric=convertStringsToChars(metric);

    if isa(data,'cv.coder.cvdatagroup')
        allData=data.getAll(covMode);
        covData=SlCov.results.CodeCovDataGroup();
        for ii=1:numel(allData)
            covData.add(allData{ii}(1).codeCovData);
        end



        if nargout>=1&&all(cellfun(@isempty,ids))
            covDataList=covData.getAll(false);
            cov=[];
            desc=[];
            if~isempty(covDataList)
                fieldNames={};
                switch metric
                case{'decision','condition','mcdc'}
                    fieldNames={metric};
                case 'execution'
                    fieldNames={'testobjects','function','functionCall','executableStatement'};
                case 'relationalop'
                    fieldNames={'testobjects'};
                case 'complexity'
                    cov=0;
                    for ii=1:numel(covDataList)
                        cov=cov+SlCov.results.CodeCovData.getCoverageInfo(covDataList(1),metric);
                    end
                    varargout{1}=cov;
                    return
                otherwise
                end

                if~isempty(fieldNames)
                    [res{1:nargout}]=SlCov.results.CodeCovData.getCoverageInfo(covDataList(1),metric);
                    cov=res{1};
                    if nargout==2
                        desc=res{2};
                    end
                    for ii=2:numel(covDataList)
                        [currRes{1:nargout}]=SlCov.results.CodeCovData.getCoverageInfo(covDataList(ii),metric);
                        currCov=currRes{1};
                        if nargout==2
                            currDesc=currRes{2};
                        end
                        if isempty(currCov)

                            continue
                        end
                        if~isempty(cov)
                            cov=sum([cov;currCov]);
                        else
                            cov=currCov;
                        end
                        if nargout<2
                            continue
                        end
                        if~isempty(desc)
                            for jj=1:numel(fieldNames)
                                fieldName=fieldNames{jj};
                                if isfield(currDesc,fieldName)
                                    desc.(fieldName)=[desc.(fieldName)(:)',currDesc.(fieldName)(:)'];
                                end
                            end
                            desc.isFiltered=double(any([desc.isFiltered,currDesc.isFiltered]));
                            desc.justifiedCoverage=double(any([desc.justifiedCoverage,currDesc.justifiedCoverage]));
                            desc.isJustified=double(any([desc.isJustified,currDesc.isJustified]));
                            if~isempty(currDesc.filterRationale)
                                rat=currDesc.filterRationale;
                                if~isempty(desc.filterRationale)
                                    rat=[desc.filterRationale,newline,rat];%#ok<AGROW>
                                end
                                desc.filterRationale=rat;
                            end
                        else
                            desc=currDesc;
                        end
                    end
                end
            end
            varargout{1}=cov;
            if nargout==2
                varargout{2}=desc;
            end
            return
        end
    else
        covData=data.codeCovData;
    end

    [varargout{1:nargout}]=SlCov.results.CodeCovData.getCoverageInfo(covData,metric,ids{:});


