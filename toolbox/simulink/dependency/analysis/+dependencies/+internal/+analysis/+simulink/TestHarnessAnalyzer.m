classdef TestHarnessAnalyzer<dependencies.internal.analysis.simulink.ModelAnalyzer




    properties(Constant)
        TestHarnessType=dependencies.internal.graph.Type("TestHarness");
        ExternalTestHarnessType=dependencies.internal.graph.Type("ExternalTestHarness");
        TestHarnessInfoType='TestHarnessInfo';
    end

    methods

        function this=TestHarnessAnalyzer()
            this@dependencies.internal.analysis.simulink.ModelAnalyzer(true)

            q1=Simulink.loadsave.Query('/HarnessInformation/Harness/Name');
            q2=Simulink.loadsave.Query('/HarnessInformation/Harness/OwnerPath');
            q3=Simulink.loadsave.Query('/ModelInformation/Model/OwnerBDName');
            this.addQueries([q1;q2;q3]);
        end

        function deps=analyze(this,handler,node,matches)
            import dependencies.internal.analysis.simulink.RequirementsAnalyzer;
            import dependencies.internal.util.resolveExternalRequirementLinks;

            deps=dependencies.internal.graph.Dependency.empty;



            if length(matches{1})~=length(matches{2})
                return;
            end

            [~,modelName]=fileparts(node.Location{1});

            for n=1:length(matches{1})
                harnessName=matches{1}(n).Value;
                path=matches{2}(n).Value;

                [modelPath,ownerPath,harnessPath]=i_buildPaths(modelName,path,harnessName);
                harnessNode=dependencies.internal.graph.Nodes.createTestHarnessNode(...
                node.Location{1},ownerPath,harnessName);

                [harnessReference,componentUnderTest]=i_buildComponents(handler,modelPath,harnessPath,node,harnessNode);

                deps(end+1)=dependencies.internal.graph.Dependency.createSource(...
                harnessReference,...
                componentUnderTest,...
                this.TestHarnessType);%#ok<AGROW>
            end

            xmlInfoNode=i_getXMLInfoNode(handler,node);
            if xmlInfoNode.Resolved
                deps=[deps,this.getHarnessDependencies(handler,node,xmlInfoNode)];
            end




            if~node.isFile()||isempty(matches{3})
                return;
            end

            for n=1:length(matches{3})
                modelName=matches{3}(n).Value;
                modelNode=handler.Analyzers.Simulink.resolve(node,modelName);
                harnessNode=node;

                if modelNode.Resolved
                    xmlInfoNode=i_getXMLInfoNode(handler,modelNode);
                    if xmlInfoNode.Resolved&&xmlInfoNode.isFile()
                        [~,harnessName]=fileparts(harnessNode.Location{1});
                        q1=Simulink.loadsave.Query(['/HarnessInformation/Harness[Name="',harnessName,'"]/OwnerPath']);
                        q2=Simulink.loadsave.Query(['/HarnessInformation/Harness[Name="',harnessName,'"]/HarnessUUID']);
                        [pathMatches,uuidMatches]=Simulink.loadsave.findAll(xmlInfoNode.Location{1},q1,q2);
                        if(~isempty(pathMatches{1}))
                            path=pathMatches{1}(1).Value;
                            deps(end+1)=this.getExternalHarnessDependency(handler,modelNode,harnessNode,path);%#ok<AGROW>
                            if~isempty(uuidMatches)
                                uuid=uuidMatches{1}(1).Value;
                                ownerPath=modelNode.Location{1};
                                type=RequirementsAnalyzer.RequirementType;
                                deps=[deps,resolveExternalRequirementLinks(...
                                handler,harnessNode,type,...
                                @(id,compNode)i_getComponentFromSID(handler,harnessName,type,id,compNode),...
                                ownerPath,uuid)];%#ok<AGROW>
                            end
                        end
                    end
                end
            end
        end

    end

    methods(Access=private)
        function deps=getHarnessDependencies(this,handler,modelNode,xmlInfoNode)
            deps=dependencies.internal.graph.Dependency.empty;

            q1=Simulink.loadsave.Query('/HarnessInformation/Harness/Name');
            q2=Simulink.loadsave.Query('/HarnessInformation/Harness/OwnerPath');
            [harnessNames,ownerPaths]=Simulink.loadsave.findAll(xmlInfoNode.Location{1},q1,q2);


            if length(harnessNames{1})~=length(ownerPaths{1})
                return;
            end

            for n=1:length(harnessNames{1})
                harness=harnessNames{1}(n).Value;
                path=ownerPaths{1}(n).Value;
                harnessNode=handler.Analyzers.Simulink.resolve(modelNode,harness);
                deps(end+1)=this.getExternalHarnessDependency(...
                handler,modelNode,harnessNode,path);%#ok<AGROW>
            end
            deps(end+1)=this.getXMLInfoFileDependency(modelNode,xmlInfoNode);
        end

        function deps=getExternalHarnessDependency(this,handler,modelNode,harnessNode,path)
            [~,modelName]=fileparts(modelNode.Location{1});
            [~,harnessName]=fileparts(harnessNode.Location{1});
            [modelPath,~,harnessPath]=i_buildPaths(modelName,path,harnessName);

            [harnessReference,componentUnderTest]=i_buildComponents(handler,modelPath,harnessPath,modelNode,harnessNode);
            deps=dependencies.internal.graph.Dependency.createSource(...
            harnessReference,...
            componentUnderTest,...
            this.ExternalTestHarnessType);
        end

        function deps=getXMLInfoFileDependency(this,modelNode,xmlInfoNode)
            deps=dependencies.internal.graph.Dependency(...
            modelNode,'',...
            xmlInfoNode,'',...
            this.TestHarnessInfoType);
        end

    end

end

function xmlInfoNode=i_getXMLInfoNode(handler,node)
    [folder,name]=fileparts(node.Location{1});
    xmlInfoNode=handler.Resolver.findFile(node,fullfile(folder,name+"_harnessInfo.xml"),".xml");
end

function block=i_findRightmostBlock(path)
    [~,idx]=regexp(path,'(?<!/)(/)(?!/)','match');
    if(isempty(idx))
        block=path;
    else
        block=path(idx(end)+1:end);
    end
end

function[harnessReference,componentUnderTest]=i_buildComponents(handler,modelPath,harnessPath,modelNode,harnessNode)
    import dependencies.internal.graph.Component;
    harnessReference=Component.createBlock(harnessNode,harnessPath,"");
    if ""==modelPath
        componentUnderTest=Component.createRoot(modelNode);
    else
        componentUnderTest=Component.createBlock(modelNode,modelPath,handler.getSID(modelPath));
    end
end

function[modelPath,ownerPath,harnessPath]=i_buildPaths(modelName,path,harnessName)
    if strcmp(path,'.')
        modelPath='';
        ownerPath=modelName;
        harnessPath=[harnessName,'/',modelName];
    else
        harnessBlock=i_findRightmostBlock(path);
        modelPath=[modelName,'/',path];
        ownerPath=modelPath;
        harnessPath=[harnessName,'/',harnessBlock];
    end
end

function component=i_getComponentFromSID(handler,harnessName,type,sid,compNode)
    import dependencies.internal.graph.Component;
    if isempty(sid)
        component=Component(compNode,harnessName,type);
    else
        fullSid=strip(sid,':');
        fullSid=strtok(fullSid,'.');
        [mainSid,SSID]=strtok(fullSid,':');
        path=handler.getPath(mainSid);
        if isempty(SSID)
            component=Component.createBlock(compNode,path,fullSid);
        else
            component=Component(compNode,strcat(path,SSID),type,0,"",strcat(path,SSID),fullSid);
        end
    end
end
