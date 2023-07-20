



classdef cvdata<handle

    properties(Hidden=true)
        fileRef(1,1)struct=struct('name','','datenum','','uuid','')
        isLoaded(1,1)logical=true
    end

    properties(GetAccess=public,SetAccess=protected,Dependent=true,Hidden=true)
type
    end

    methods



        function value=get.type(this)
            checkId(this);
            if isDerived(this)
                value='DERIVED_DATA';
            else
                value='TEST_DATA';
            end
        end
    end

    methods(Abstract,Hidden)
        checkId(this)
        out=isCompatible(this,cvd)
        result=isDerived(this)
        load(this)
        out=valid(this)
        out=getAnalyzedModel(this)
        setUniqueId(this)
        clearUniqueId(this)
    end

    methods(Hidden)
        checkDataCompatibility(this,cvd)




        function res=isFromPreviousRelease(this)
            res=false;
            if~strcmpi(cv('Feature','Crossrelease'),'on')
                return
            end
            res=~strcmpi(SlCov.CoverageAPI.getDbVersion,this.dbVersion);
        end
    end

    methods(Static,Hidden)
        aggregateDescription(this,srcCvd1,srcCvd2)
        aggregateUniqueIds(this,srcCvd1,srcCvd2)
        nai=joinAggregatedTestInfo(lhsCvd,rhsCvd)
        ai=createAggregatedTestInfo(cvd)
        [ati,traceStruct]=removeDuplicateTestTraces(ati,traceStruct)




        function traceId=getInternalTraceId(uniqueId,aggregatedTestInfo)
            traceId=find(strcmp({aggregatedTestInfo.uniqueId},uniqueId),1);
        end




        function uniqueId=getUniqueIdFromTraceId(aggregatedTestInfo,traceId)
            uniqueId=aggregatedTestInfo(traceId).uniqueId;
        end




        function obj=setupFileRef(obj,fileName,uuid)
            [path,fileName,ext]=cvi.ReportUtils.getFilePartsWithReadChecks(fileName,'.cvt');
            fullFileName=fullfile(path,[fileName,ext]);
            dirInfo=dir(fullFileName);
            obj.fileRef.name=fullFileName;
            obj.fileRef.datenum=dirInfo.datenum;
            obj.fileRef.uuid=uuid;
            obj.isLoaded=false;
        end




        function checkFileRef(obj)
            [path,fileName,ext]=cvi.ReportUtils.getFilePartsWithReadChecks(obj.fileRef.name,'.cvt');
            fullFileName=fullfile(path,[fileName,ext]);
            dirInfo=dir(fullFileName);
            if~isequal(obj.fileRef.datenum,dirInfo.datenum)
                throwAsCaller(MException(message('Slvnv:simcoverage:cvdata:InvalidCvDataFileRef',fullFileName,datestr(obj.fileRef.datenum))));
            end
        end

    end
end


