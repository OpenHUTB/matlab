



function res=toStruct(this,idx)

    if nargin<2
        idx=[];
    end

    res=toStruct@codeinstrum.internal.codecov.CodeCovData(this,idx);


    res.modelinfo=[];
    res.test=[];

    if~isempty(this.covdata)
        try
            if isa(this.covdata,'cvdata')&&this.covdata.valid()
                if ismember(this.CodeTr.SourceKind,[internal.cxxfe.instrum.SourceKind.SFunction,...
                    internal.cxxfe.instrum.SourceKind.ECoder])
                    res.modelinfo=this.covdata.modelinfo;
                end
                if~isempty(this.covdata.test)
                    res.test=struct('setupCmd',this.covdata.test.setupCmd,...
                    'options',this.covdata.test.options);
                end
            end
        catch ME
            if~(strcmp(ME.identifier,'Slvnv:simcoverage:cvdata:InvalidCvDataNoObj')||...
                strcmp(ME.identifier,'Slvnv:simcoverage:cvdata:InvalidCvData'))
                rethrow(ME);
            end
        end
    end

    res.cvDbVersion=char(this.CvDbVersion);


    if~codeinstrumprivate('feature','honorCovLogicBlockShortCircuit')&&...
        isstruct(res.modelinfo)&&isfield(res.modelinfo,'logicBlkShortcircuit')
        res.modelinfo.logicBlkShortcircuit=1;
    end

    res.modelElements=struct();
    if~isempty(this.TraceInfo)
        res.modelElements.traceInfo=this.TraceInfo;
    end
