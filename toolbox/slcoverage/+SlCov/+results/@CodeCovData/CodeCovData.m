




classdef CodeCovData<codeinstrum.internal.codecov.CodeCovData

    properties(SetAccess=private,GetAccess=public,Hidden=true)
covdata
        TraceInfo=[]
    end

    properties(Hidden=true)
        CvDbVersion(1,1)string
    end

    properties(Hidden=true,Dependent=true)
Mode
    end

    methods



        function this=CodeCovData(varargin)

            this@codeinstrum.internal.codecov.CodeCovData(varargin{:});
            this.Mode=SlCov.CovMode.Unknown;
            this.CvDbVersion=SlCov.CoverageAPI.getDbVersion();
        end




        function set.Mode(this,v)
            validateattributes(v,{'SlCov.CovMode'},{'scalar'},'SlCov.results.CodeCovData.set.Mode');
            v=uint32(SlCov.CovMode.fixTopMode(v));
            this.CodeCovDataImpl.Mode=internal.codecov.CovMode(v);
        end




        function res=get.Mode(this)
            res=SlCov.CovMode.fixTopMode(SlCov.CovMode(uint32(this.CodeCovDataImpl.Mode)));
        end




        function resObj=plus(this,rhsObj)
            resObj=SlCov.results.CodeCovData.performOp(this,rhsObj,'+');
        end




        function resObj=minus(this,rhsObj)
            resObj=SlCov.results.CodeCovData.performOp(this,rhsObj,'-');
        end




        function resObj=times(this,rhsObj)
            resObj=SlCov.results.CodeCovData.performOp(this,rhsObj,'*');
        end




        function resObj=mtimes(this,rhsObj)
            resObj=SlCov.results.CodeCovData.performOp(this,rhsObj,'*');
        end




        function resObj=extractInstance(this,instIdx)
            resObj=extractInstance@codeinstrum.internal.codecov.CodeCovData(this,instIdx);
            resObj.covdata=this.covdata;
        end




        function res=saveobj(this)
            res=saveobj@codeinstrum.internal.codecov.CodeCovData(this);
            res.covdata=[];
        end




        function applyCovFilter(this,covFilterObj,instIdx)
            narginchk(2,3);
            if nargin<3
                instIdx=1;
            end

            if~isempty(covFilterObj)&&isa(covFilterObj,'SlCov.FilterEditor')

                covFilterInfo=covFilterObj.getAllCodeInfo();



                for ii=1:numel(covFilterInfo)
                    filterInfo=covFilterInfo{ii};
                    [codeInfo,ssid]=SlCov.FilterEditor.decodeCodeFilterInfo(filterInfo.value);
                    isFilter=~logical(filterInfo.mode);
                    if~isempty(codeInfo)&&isempty(ssid)
                        if SlCov.FilterEditor.isCodeFilterFileInfo(codeInfo)
                            this.annotateFile(isFilter,filterInfo.Rationale,codeInfo{:},instIdx);
                        elseif SlCov.FilterEditor.isCodeFilterFunInfo(codeInfo)
                            this.annotateFunction(isFilter,filterInfo.Rationale,codeInfo{:},instIdx);
                        elseif SlCov.FilterEditor.isCodeFilterDecInfo(codeInfo)||...
                            SlCov.FilterEditor.isCodeFilterCondInfo(codeInfo)||...
                            SlCov.FilterEditor.isCodeFilterMCDCInfo(codeInfo)||...
                            SlCov.FilterEditor.isCodeFilterRelBoundInfo(codeInfo)
                            this.annotateExpression(isFilter,filterInfo.Rationale,codeInfo{:},instIdx);
                        end
                    end
                end
            end
        end



        function annotateModelElement(this,isFilter,rationale,ssid)
            if codeinstrumprivate('feature','honorModelFilters')
                isFilter=logical(isFilter);
                if isFilter
                    filterMode=internal.codecov.FilterMode.EXCLUDED;
                else
                    filterMode=internal.codecov.FilterMode.JUSTIFIED;
                end
                if isempty(rationale)
                    rationale='';
                end

                slModelElement=this.CodeTr.findSLModelElementBySID(ssid);
                this.CodeCovDataImpl.addFilter(1,...
                internal.codecov.FilterKind.SL_MODEL_ELEMENT,...
                internal.codecov.FilterSource.USER,...
                filterMode,rationale,slModelElement);
            end
        end




        function setCovData(this,covdata)
            this.covdata=covdata;
        end


        mapModelToCode(this,traceInfoMat,traceInfoBuilder,covdata);
        refreshModelCovIds(this,covdata);
        res=toStruct(this,idx);
    end

    methods(Access=protected)



        function resObj=copyElement(this)
            resObj=copyElement@codeinstrum.internal.codecov.CodeCovData(this);
            resObj.covdata=[];
        end
    end

    methods(Static=true)




        function obj=loadobj(this)
            if isstruct(this)

                obj1=SlCov.results.CodeCovData('traceabilityDbFile','');
                obj=codeinstrum.internal.codecov.CodeCovData.loadobj(this,obj1);
                if isfield(this,'Model2CodeTrRef')&&~isempty(this.Model2CodeTrRef)
                    slModel=obj.CodeTr.getSLModel();
                    if isempty(slModel)
                        obj.CodeTr.setSLModel(this.Model2CodeTrRef.value);
                        if isfield(this.Model2CodeTrRef.value,'traceInfo')
                            obj.TraceInfo=this.Model2CodeTrRef.value.traceInfo;
                        end
                    end
                end
                fieldNames={'Mode','TraceInfo','CvDbVersion'};
                for ii=1:numel(fieldNames)
                    fldName=fieldNames{ii};
                    if isfield(this,fldName)
                        obj.(fldName)=this.(fldName);
                    end
                end
            else
                obj=codeinstrum.internal.codecov.CodeCovData.loadobj(this);
            end
        end
    end

    methods(Static,Hidden)



        function res=performOp(lhs,rhs,opStr)

            narginchk(3,3);
            validatestring(opStr,{'+','-','*'},'SlCov.results.CodeCovData.performOp','opStr',3);

            res=codeinstrum.internal.codecov.CodeCovData.performOp(lhs,rhs,opStr,'SlCov.results.CodeCovData');


            if~isempty(res)

                if~isempty(lhs)
                    res.CvDbVersion=lhs.CvDbVersion;
                else

                    res.CvDbVersion=rhs.CvDbVersion;
                end
            end
        end




        function outStr=toBase64(obj)
            validateattributes(obj,{'SlCov.results.CodeCovData'},...
            {'scalar'},'SlCov.results.CodeCovData.toBase64','',1);
            outStr=char(matlab.internal.crypto.base64Encode(getByteStreamFromArray(obj)));
        end




        function obj=fromBase64(inStr)
            obj=getArrayFromByteStream(matlab.internal.crypto.base64Decode(string(inStr)));
        end

    end
end
