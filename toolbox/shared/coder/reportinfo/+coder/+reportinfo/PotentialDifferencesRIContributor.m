
classdef(Sealed)PotentialDifferencesRIContributor<coder.reportinfo.RIContributor

    properties(SetAccess=protected)
Data
    end

    properties(Access=private)
PotentialDifferences
    end

    methods
        function obj=PotentialDifferencesRIContributor(reportContributor,reportContext)
            if isprop(reportContext.Report.inference,'Functions')
                obj.PotentialDifferences=reportContributor.PotentialDifferences;
                obj.getInsights(reportContext.Report.inference.Functions);
            end
        end
    end

    methods(Access=private)
        function getInsights(obj,fcns)
            s=struct('MessageID','','MessageType','','Text','','ScriptID','',...
            'TextStart','','TextLength','','Category','','SubCategory','');
            category='PotentialDifferencesFromMATLAB';
            totalDiffs=numel(obj.PotentialDifferences);
            diffs=cell(1,totalDiffs);
            for i=1:totalDiffs
                msg=obj.PotentialDifferences(i);
                occurrences=msg.Occurrences;
                totalOccurrences=numel(occurrences);
                allMsgs=cell(1,totalOccurrences);
                for j=1:totalOccurrences
                    occ=occurrences(j);
                    scriptID=fcns(occ.FunctionID).ScriptID;
                    locations=occ.Locations;
                    totalLocations=numel(locations);
                    msgs=repmat(s,totalLocations,1);
                    for k=1:totalLocations
                        loc=locations(k);
                        msgs(k)=struct(...
                        'MessageID',msg.MsgID,'MessageType','Info',...
                        'Text',msg.MsgText,'ScriptID',scriptID,...
                        'TextStart',loc.TextStart,'TextLength',loc.TextLength,...
                        'Category',category,'SubCategory','');
                    end
                    allMsgs{j}=msgs;
                end
                diffs{i}=allMsgs;
            end
            data=[diffs{:}];
            if~isempty(data)
                obj.Data=vertcat(data{:});
            end
        end
    end
end