classdef TestHarnessNodeAnalyzer<dependencies.internal.analysis.simulink.SimulinkModelAnalyzer




    properties(Constant)
        Extensions=string.empty;
    end

    properties(Constant,Access=private)
        NodeFilter=dependencies.internal.graph.NodeFilter.nodeType(dependencies.internal.analysis.simulink.TestHarnessAnalyzer.TestHarnessType);
    end

    methods

        function this=TestHarnessNodeAnalyzer(varargin)
            this@dependencies.internal.analysis.simulink.SimulinkModelAnalyzer(varargin{:});


            this.Queries.addQueries([
            Simulink.loadsave.Query('/HarnessInformation/Harness/Name')
            Simulink.loadsave.Query('/HarnessInformation/Harness/OwnerPath')
            Simulink.loadsave.Query('/HarnessInformation/Harness/Directory')
            ]);
        end

        function analyze=canAnalyze(this,~,node)
            analyze=apply(this.NodeFilter,node);
        end

    end

    methods(Access=protected)

        function[node,oldName,wasResaved]=prepareNode(this,node)
            oldName=node.Location{3};

            if this.isDirty(node.Path,oldName)||this.isOld(node.Path)
                tmpFile=dependencies.internal.analysis.simulink.saveModelToLatestVersion(node.Path);
                node=dependencies.internal.graph.Node.createFileNode(tmpFile);
                wasResaved=true;
            else
                node=dependencies.internal.graph.Node.createFileNode(node.Path);
                wasResaved=false;
            end
        end

        function deps=analyzeMatches(this,handler,node,queries,matches,owner)

            [~,parentName]=fileparts(node.Location{1});
            numHarnesses=length(matches{end-1});
            owners=cell(numHarnesses,1);
            for n=1:numHarnesses
                ownerPath=matches{end-1}(n).Value;
                if strcmp(ownerPath,'.')
                    owners{n}=parentName;
                else
                    owners{n}=[parentName,'/',ownerPath];
                end
            end


            name=strcmp(node.Location{3},{matches{end-2}.Value});
            path=strcmp(node.Location{2},owners');
            idx=find(name&path);


            if~isempty(idx)
                hint=['/simulink/',matches{end}(idx(1)).Value,'/'];
                harnessMatches=i_filterAndRewriteMatches(matches,hint);


                deps=this.analyzeMatches@dependencies.internal.analysis.simulink.SimulinkModelAnalyzer(...
                handler,node,queries,harnessMatches,owner);
            else
                deps=dependencies.internal.graph.Dependency.empty;
            end

        end
    end

end


function matches=i_filterAndRewriteMatches(matches,hint)


    for n=1:length(matches)
        if~isempty(matches{n})
            matches{n}=matches{n}(strncmp(hint,{matches{n}.Hint},length(hint)));
        end
    end
end
