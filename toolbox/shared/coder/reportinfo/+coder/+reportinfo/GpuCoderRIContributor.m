
classdef(Sealed)GpuCoderRIContributor<coder.reportinfo.RIContributor

    properties(SetAccess=protected)
Data
    end

    properties(Access=private)
DiagnosticsData
    end

    methods
        function obj=GpuCoderRIContributor(reportContributor)
            obj.DiagnosticsData=reportContributor.DiagnosticsData;
            obj.getInsights();
        end
    end

    methods(Access=private)
        function getInsights(obj)
            s=struct('MessageID','','MessageType','','Text','','ScriptID','',...
            'TextStart','','TextLength','','Category','','SubCategory','');
            category='GpuDiagnostics';
            totalDiagnostics=numel(obj.DiagnosticsData);
            diagnostics=cell(1,totalDiagnostics);
            for i=1:totalDiagnostics
                entry=obj.DiagnosticsData(i);
                subCategory=entry.id;
                checks=entry.checks;
                totalChecks=numel(checks);
                allMsgs=cell(1,totalChecks);
                for j=1:totalChecks
                    msg=checks(j);
                    occurrences=msg.occurrences;
                    totalOccurrences=numel(occurrences);
                    msgs=repmat(s,totalOccurrences,1);
                    for k=1:numel(occurrences)
                        occ=occurrences(k);
                        msgs(k)=struct(...
                        'MessageID',msg.msgId,'MessageType','Info',...
                        'Text',msg.msgText,'ScriptID',occ.ScriptID,...
                        'TextStart',occ.TextStart,'TextLength',occ.TextLength,...
                        'Category',category,'SubCategory',subCategory);
                    end
                    allMsgs{j}=msgs;
                end
                diagnostics{i}=allMsgs;
            end
            data=[diagnostics{:}];
            if~isempty(data)
                obj.Data=vertcat(data{:});
            end
        end
    end
end