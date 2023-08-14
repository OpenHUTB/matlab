




classdef CovDataReader<sldv.code.internal.CovDataReader

    properties(SetAccess=protected,GetAccess=public,Hidden=true)
FilePerModuleName2CovRange
        EntryPointFunSigs=[]
    end

    methods



        function this=CovDataReader(covData,varargin)
            narginchk(1,2);

            this@sldv.code.internal.CovDataReader(varargin{:});

            this.IsUnknownIdCovered=~sldv.code.internal.feature('forceTestGen4UnknownCovId');
            this.FilePerModuleName2CovRange=containers.Map('KeyType','char','ValueType','any');


            codeAnalyzer=sldv.code.xil.internal.getCurrentCodeAnalyzer();
            if~builtin('isempty',codeAnalyzer)&&...
                isa(codeAnalyzer,'sldv.code.xil.CodeAnalyzer')&&...
                ~isempty(codeAnalyzer.AtsHarnessInfo)&&...
                isfield(codeAnalyzer.AtsHarnessInfo,'atsEntryPointFunSigs')&&...
                ~isempty(codeAnalyzer.AtsHarnessInfo.atsEntryPointFunSigs)
                this.EntryPointFunSigs=codeAnalyzer.AtsHarnessInfo.atsEntryPointFunSigs;
            end


            if isempty(covData)
                return
            end

            if isa(covData,'cvdata')
                covData=cv.cvdatagroup(covData);
            end
            modes={'SIL','ModelRefSIL'};
            for ii=1:numel(modes)
                mode=modes{ii};
                names=covData.allNames(mode);
                for jj=1:numel(names)
                    cvd=covData.get(names{jj},mode);
                    if isempty(cvd)
                        continue
                    end


                    key=SlCov.coder.EmbeddedCoder.buildModuleName(names{jj},mode);
                    codeCvd=cvd.codeCovData;


                    if~isempty(this.CovFilterObj)
                        try



                            clonedCvd=clone(codeCvd);

                            clonedCvd.applyCovFilter(this.CovFilterObj);



                            codeCvd=clonedCvd;
                        catch

                        end
                    end


                    data=sldv.code.internal.CovDataReader.getInstanceCovDataInfo(codeCvd,1);
                    this.Id2CovInfo(key)=data;




                    if cvd.isSharedUtility||cvd.isCustomCode
                        if this.FilePerModuleName2CovRange.isKey(codeCvd.OrigModuleName)
                            moduleInfo=this.FilePerModuleName2CovRange(codeCvd.OrigModuleName);
                        else
                            moduleInfo=struct('idRanges',[],'fileNames',[]);
                        end

                        covIdRange=codeCvd.CodeTr.getCovIdRange(codeCvd.CodeTr.Root);
                        moduleInfo.idRanges=[moduleInfo.idRanges;covIdRange];
                        moduleInfo.fileNames=[moduleInfo.fileNames;{key}];
                        this.FilePerModuleName2CovRange(codeCvd.OrigModuleName)=moduleInfo;
                    end
                end
            end

        end

    end

    methods(Access=protected)



        function codeCovData=getCodeCovData(this,~,~,moduleName,covOrDecId)
            if nargin<5
                covOrDecId=0;
            end
            codeCovData=[];


            key=moduleName;
            if~isempty(this.FilePerModuleName2CovRange)

                if this.FilePerModuleName2CovRange.isKey(key)
                    moduleInfo=this.FilePerModuleName2CovRange(key);
                    idx=find(moduleInfo.idRanges(:,1)<=covOrDecId&moduleInfo.idRanges(:,2)>=covOrDecId,1);
                    if~isempty(idx)
                        key=moduleInfo.fileNames{idx};
                    end
                end
            end


            if this.Id2CovInfo.isKey(key)
                codeCovData=this.Id2CovInfo(key);
            end
        end




        function codeFilterData=getCodeFilterData(this,~,moduleName,~)

            codeFilterData=[];


            if isempty(this.CovFilterObj)
                return
            end


            if this.Id2CovFilterInfo.isKey(moduleName)
                codeFilterData=this.Id2CovFilterInfo(moduleName);
                return
            end




            buildDirInfo=sldv.code.xil.CodeAnalyzer.getModuleBuilDirInfo(moduleName);
            dbFile=SlCov.coder.EmbeddedCoder.getCodeCovDataFiles(moduleName,buildDirInfo);
            if~isfile(dbFile)
                this.Id2CovFilterInfo(moduleName)=codeFilterData;
                return
            end


            try
                codeCovData=SlCov.results.CodeCovData(...
                'traceabilitydbfile',dbFile,...
                'forceNonEmptyResults',true,...
                'name',moduleName);
                codeCovData.applyCovFilter(this.CovFilterObj);


                data=sldv.code.internal.CovDataReader.getInstanceCovDataInfo(...
                codeCovData,1);
                this.Id2CovFilterInfo(moduleName)=data;
                codeFilterData=data;
            catch Mex %#ok<NASGU>
                this.Id2CovFilterInfo(moduleName)=codeFilterData;
                return
            end

        end




        function codeFilterData=getCodeFilterInternalExclusionData(this,~,moduleName,~)
            codeFilterData=[];


            if isempty(this.EntryPointFunSigs)
                return
            end


            if this.Id2CovInternalFilterInfo.isKey(moduleName)
                codeFilterData=this.Id2CovInternalFilterInfo(moduleName);
                return
            end




            [~,~,isSharedUtils]=SlCov.coder.EmbeddedCoder.parseModuleName(moduleName);
            buildDirInfo=sldv.code.xil.CodeAnalyzer.getModuleBuilDirInfo(moduleName);
            dbFile=SlCov.coder.EmbeddedCoder.getCodeCovDataFiles(moduleName,buildDirInfo);
            if~isfile(dbFile)
                this.Id2CovInternalFilterInfo(moduleName)=codeFilterData;
                return
            end


            try

                args={...
                'traceabilitydbfile',dbFile,...
                'forceNonEmptyResults',true,...
                'name',moduleName...
                };
                if~isSharedUtils
                    args=[args,{...
                    'entryPointFunSigs',this.EntryPointFunSigs,...
                    }];
                end
                codeCovData=SlCov.results.CodeCovData(args{:});


                codeCovData.resetFilters();
                if isSharedUtils
                    files=codeCovData.CodeTr.getFilesInResults();
                    for ii=1:numel(files)
                        funs=files(ii).functions.toArray();
                        if all(~ismember({funs.signature},this.EntryPointFunSigs))
                            codeCovData.annotateFile(true,'',files(ii).shortPath);
                        end
                    end
                end


                data=sldv.code.internal.CovDataReader.getInstanceCovDataInfo(...
                codeCovData,1);
                this.Id2CovInternalFilterInfo(moduleName)=data;
                codeFilterData=data;
            catch Mex %#ok<NASGU>
                this.Id2CovInternalFilterInfo(moduleName)=codeFilterData;
                return
            end
        end
    end
end


