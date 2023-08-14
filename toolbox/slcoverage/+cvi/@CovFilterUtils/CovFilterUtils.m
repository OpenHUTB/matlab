



classdef CovFilterUtils

    methods(Static,Hidden)

        function filterAppliedStruct=getFilterAppliedStruct()
            filterAppliedStruct=struct('isInternal',0,'fileNameId','','fileName','',...
            'filterName','','descr','','uuid','','err','');
        end


        function[filterId,foundFileName,err]=getFilterId(fileName,modelName)
            if nargin<2
                modelName='';
            end

            filterId='';
            foundFileName='';
            err='';
            if isempty(fileName)
                return
            end

            [foundFileName,fullFileName]=SlCov.FilterEditor.findFile(fileName,modelName);
            if isa(foundFileName,'message')
                warning(foundFileName);
                err=getString(foundFileName);
                return
            end

            d=dir(fullFileName);
            if isempty(d)

                err=getString(message('Slvnv:simcoverage:ioerrors:UnableToOpenForReading',fileName));
                return
            end

            filterId=sprintf('%s_%f',fullFileName,d.datenum);
        end


        function filterAppliedId=getFilterAppliedId(filterApplied)
            filterAppliedId='';
            if~isempty(filterApplied)
                filterAppliedId=[filterApplied.fileNameId];
            end
        end


        function filterAppliedStruct=setFilterApplied(filterAppliedStruct,foundFileName,fileName,fileNameId,err)
            ns=cvi.CovFilterUtils.getFilterAppliedStruct();
            if~isempty(err)
                ns.err=err;
                fIdx=[];
                for idx=1:numel(filterAppliedStruct)
                    if contains(filterAppliedStruct(idx).fileName,fileName)||...
                        contains(filterAppliedStruct(idx).err,fileName)
                        fIdx=idx;
                        break
                    end
                end
                if~isempty(fIdx)
                    filterAppliedStruct(idx)=ns;
                else
                    filterAppliedStruct=[filterAppliedStruct,ns];
                end
            else
                ns.fileName=foundFileName;
                ns.fileNameId=fileNameId;
                filterAppliedStruct=[filterAppliedStruct,ns];
            end
        end


        function oldFilterApplied=updateErroredFilterApplied(oldFilterApplied,filterApplied)

            if~isempty(filterApplied)
                nIdx=find({filterApplied.err}~="",1);
                if~isempty(nIdx)
                    if isempty(oldFilterApplied)
                        oldFilterApplied=filterApplied;
                    else

                        for idx=1:numel(filterApplied)
                            if isempty(find({oldFilterApplied.err}==string(filterApplied(idx).err),1))
                                oldFilterApplied=[oldFilterApplied,filterApplied(idx)];%#ok<AGROW>
                            end
                        end
                    end
                end
            end
        end


        function filterAppliedStruct=updateFilterApplied(filterAppliedStruct,fileName,filterObj)

            fIdx=find({filterAppliedStruct.fileName}==string(fileName));
            if~isempty(fIdx)
                filterAppliedStruct(fIdx).descr=filterObj.filterDescr;
                filterAppliedStruct(fIdx).uuid=filterObj.getUUID;
                filterAppliedStruct(fIdx).filterName=filterObj.filterName;
            end
        end


        function applyFilterOnCode(ccvd,filter,isSF)
            narginchk(2,3);



...
...
...
...
...
...
...
...
...
...
...
...
...

            if isempty(ccvd)
                return
            end

            if nargin<3
                isSF=false;
            end
            if isSF
                instIdx=-2;
            else
                instIdx=1;
            end

            if isa(ccvd,'SlCov.results.CodeCovData')
                try
                    codeInfoProp=filter.getAllCodeInfo();


                    for ii=1:numel(codeInfoProp)
                        [codeInfo,ssid]=SlCov.FilterEditor.decodeCodeFilterInfo(codeInfoProp{ii}.value);
                        isFilter=~logical(codeInfoProp{ii}.mode);
                        if~isempty(codeInfo)&&isempty(ssid)
                            if SlCov.FilterEditor.isCodeFilterFileInfo(codeInfo)
                                ccvd.annotateFile(isFilter,codeInfoProp{ii}.Rationale,codeInfo{:},instIdx);
                            elseif SlCov.FilterEditor.isCodeFilterFunInfo(codeInfo)
                                ccvd.annotateFunction(isFilter,codeInfoProp{ii}.Rationale,codeInfo{:},instIdx);
                            elseif SlCov.FilterEditor.isCodeFilterDecInfo(codeInfo)||...
                                SlCov.FilterEditor.isCodeFilterCondInfo(codeInfo)||...
                                SlCov.FilterEditor.isCodeFilterMCDCInfo(codeInfo)||...
                                SlCov.FilterEditor.isCodeFilterRelBoundInfo(codeInfo)
                                ccvd.annotateExpression(isFilter,codeInfoProp{ii}.Rationale,codeInfo{:},instIdx);
                            end
                        end
                    end

                    slModelElements=ccvd.CodeTr.getSLModelElements();

                    if~isempty(slModelElements)
                        SIDs={slModelElements.sid};
                        for ii=1:numel(SIDs)
                            ssid=ccvd.covdata.mapFromHarnessSID(SIDs{ii});
                            [isFiltered,prop,rationale]=filter.isFiltered(ssid);
                            if isFiltered
                                isFilter=~logical(prop.mode);
                                isInherited=~strcmp(prop.value,ssid);
                                if~isInherited
                                    ccvd.annotateModelElement(isFilter,rationale,ssid);
                                end
                            end
                        end
                    end
                catch Mex

                    if codeinstrumprivate('feature','disableErrorRecovery')
                        rethrow(Mex);
                    end
                end
            elseif isa(ccvd,'SlCov.results.CodeCovDataGroup')
                allCodeCov=ccvd.getAll();
                for ii=1:numel(allCodeCov)
                    cvi.CovFilterUtils.applyFilterOnCode(allCodeCov(ii),filter,isSF);
                end
            end
        end
    end
end


