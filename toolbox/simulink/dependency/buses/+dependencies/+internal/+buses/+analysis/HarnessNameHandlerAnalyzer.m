classdef HarnessNameHandlerAnalyzer<dependencies.internal.buses.analysis.ModelAnalyzer




    properties(GetAccess=public,SetAccess=immutable)
        HarnessMap containers.Map
    end

    properties(GetAccess=private,SetAccess=immutable)
        QueryTable(1,1)dependencies.internal.analysis.simulink.QueryTable
    end

    methods
        function this=HarnessNameHandlerAnalyzer()
            this.QueryTable=dependencies.internal.analysis.simulink.QueryTable;
            this.QueryTable.addQueries([
            Simulink.loadsave.Query('/HarnessInformation/Harness/Name')
            Simulink.loadsave.Query('/HarnessInformation/Harness/OwnerPath')
            Simulink.loadsave.Query('/HarnessInformation/Harness/Directory')
            ]);
            this.HarnessMap=containers.Map('KeyType','char','ValueType','any');
        end

        function table=getQueryTable(this,~)
            table=this.QueryTable;
        end

        function deps=analyze(this,~,~,fileNode,matches)
            deps=dependencies.internal.graph.Dependency.empty;
            names=matches{1};
            owners=matches{2};
            directories=matches{3};
            l=length(names);
            if l==0||l~=length(owners)||l~=length(directories)

                return;
            end
            filePath=fileNode.Location{1};
            [~,modelName]=fileparts(filePath);
            for i=1:l
                directoryName=directories(i).Value;

                tHNode=dependencies.internal.graph.Nodes.createTestHarnessNode(...
                filePath,i_buildOwnerPath(modelName,owners(i).Value),names(i).Value);

                this.HarnessMap(directoryName)=tHNode;
            end

        end
    end
end


function ownerPath=i_buildOwnerPath(modelName,path)
    if strcmp(path,'.')
        ownerPath=modelName;
    else
        ownerPath=[modelName,'/',path];
    end
end
