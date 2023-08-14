classdef CodeSliceObject<slci.results.SliceObject




    properties(SetAccess=protected,GetAccess=protected)

        fVerSubstatus='';
    end
    methods(Access=public,Hidden=true)

        function obj=CodeSliceObject(aKey,aName,aFunctionScope)
            if nargin==0
                DAStudio.error('Slci:results:DefaultConstructorError',...
                'CODESLICE')
            end
            slci.results.CodeSliceObject.validateKey(aKey);
            obj=obj@slci.results.SliceObject(aKey,aName,aFunctionScope);
        end
    end
    methods(Access=public,Hidden=true)

        function aDispName=getDispName(obj,datamgr)%#ok
            if strcmp(obj.getName(),'NOT_AN_OUTPUT')
                aDispName='-';
            else
                aDispName=obj.getName();
            end
            aDispName=slci.internal.encodeString(aDispName,'all','encode');
        end
    end
    methods(Access=public,Hidden=true)

        function addSourceObject(obj,aSourceObjects)
            for k=1:numel(aSourceObjects)
                srcObject=aSourceObjects{k};
                if isa(srcObject,'slci.results.CodeObject')
                    aKey=srcObject.getKey();
                    obj.addSourceKey(aKey);
                else
                    DAStudio.error('Slci:results:ErrorCodeSliceSource');
                end
            end
        end
        function checkContributingObject(obj,aSourceObj)%#ok
            if~isa(aSourceObj,'slci.results.CodeObject')
                DAStudio.error('Slci:results:ErrorContributingCodeObject');
            end
        end



        function computeStatus(obj,dataMgr,varargin)
            contribKeys='';
            if strcmp(obj.getName(),'NOT_AN_OUTPUT')
                aStatus=slci.internal.ReportConfig.getVerificationFailStatus();
            else
                codeReader=dataMgr.getReader('CODE');
                sliceKey=obj.getKey();
                contribKeys=obj.getContributingSources();
                if~isempty(contribKeys)
                    contribObjects=codeReader.getObjects(contribKeys);
                    statuses=cellfun(@(x)x.getStatusForSlice(sliceKey),...
                    contribObjects,...
                    'UniformOutput',...
                    false);
                    aStatus=obj.fReportConfig.getHeaviest(statuses);
                else
                    aStatus=obj.fReportConfig.defaultStatus;
                end
            end
            obj.setStatus(aStatus);


            if slcifeature('SLCIJustification')==1
                assert(nargin==3,'SLCI Configuration is not passed.');
                if nargin==3
                    conf=varargin{1};
                end
                fname=fullfile(conf.getReportFolder(),...
                [conf.getModelName(),'_justification.json']);

                if isfile(fname)&&~isempty(contribKeys)
                    codelinesKey=obj.getCodeLines(contribKeys);
                    modelManager=slci.view.ModelManager(fname);
                    if modelManager.isFiltered(codelinesKey)

                        aggSubstatus='JUSTIFIED';
                        obj.setSubstatus(aggSubstatus);
                        status=obj.fReportConfig.getStatus(aggSubstatus);
                        obj.setStatus(status);
                    end
                end
            end
        end
    end
    methods(Static=true,Access=protected,Hidden=true)
        function validateKey(aKey)
            if(isempty(aKey)||~ischar(aKey))
                DAStudio.error('Slci:results:InvalidKey','CODESLICE');
            end
        end
    end
    methods(Access=protected)
        function checkTraceObj(obj,aTraceObj)%#ok
            if~isa(aTraceObj,'slci.results.BlockSliceObject')
                DAStudio.error('Slci:results:ErrorTraceObjects',...
                'CODESLICE',class(aTraceObj));
            end
        end
        function setSubstatus(obj,aSubstatus)

            if isKey(obj.fReportConfig.VStatusTable,aSubstatus)||...
                isempty(aSubstatus)
                obj.fVerSubstatus=aSubstatus;
            else
                DAStudio.error('Slci:results:InvalidSubstatus',aSubstatus);
            end
        end



        function codelines=getCodeLines(~,contributeSrc)
            codeTrace=slci.view.data.CodeTrace();
            for j=1:numel(contributeSrc)
                cj=contributeSrc{j};
                lineTrace=strsplit(cj,filesep);
                lineTrace=strsplit(lineTrace{end},':');
                codeTrace.addTrace(lineTrace{1},lineTrace{2});
            end
            codelines=codeTrace.toString;
        end
    end
end
