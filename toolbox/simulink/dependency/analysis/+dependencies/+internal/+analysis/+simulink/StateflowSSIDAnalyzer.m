classdef StateflowSSIDAnalyzer<dependencies.internal.analysis.simulink.ModelAnalyzer




    properties(Constant)
        ObjectTypes=["state","transition","event","data","enum"]
    end

    methods
        function this=StateflowSSIDAnalyzer()
            chartNames=Simulink.loadsave.Query('/Stateflow//chart/name');
            chartIDs=Simulink.loadsave.Query('/Stateflow//chart/name');
            chartIDs.Modifier=Simulink.loadsave.Modifier.ChartID;

            slxSSIDs=Simulink.loadsave.Query('/Stateflow//SSID');
            slxParents=Simulink.loadsave.Query('/Stateflow//SSID');
            slxParents.Modifier=Simulink.loadsave.Modifier.ParentSSID;
            slxCharts=Simulink.loadsave.Query('/Stateflow//SSID');
            slxCharts.Modifier=Simulink.loadsave.Modifier.ChartID;

            mdlTreeIDs=Simulink.loadsave.Query('/Stateflow/*[id=* and ssIdNumber=* and treeNode=*]/id');
            mdlTrees=Simulink.loadsave.Query('/Stateflow/*[id=* and ssIdNumber=* and treeNode=*]/treeNode');

            mdlLinkIDs=Simulink.loadsave.Query('/Stateflow/*[id=* and ssIdNumber=* and linkNode=*]/id');
            mdlLinks=Simulink.loadsave.Query('/Stateflow/*[id=* and ssIdNumber=* and linkNode=*]/linkNode');

            this.addQueries([chartNames;chartIDs]);
            this.addQueries([slxSSIDs;slxParents;slxCharts],repmat({'slx'},3,1));
            this.addQueries([mdlTreeIDs;mdlTrees;mdlLinkIDs;mdlLinks],repmat({'mdl'},4,1));
        end

        function deps=analyze(this,handler,~,matches)
            deps=dependencies.internal.graph.Dependency.empty;

            if isempty(matches{1})
                chartNameMap=containers.Map;
            else
                chartNames=handler.ModelInfo.BlockDiagramName+"/"+string({matches{1}.Value});
                chartIDs={matches{2}.Value};
                chartNameMap=containers.Map(chartIDs,chartNames);
            end

            parentMap=containers.Map;
            if handler.ModelInfo.IsSLX
                paths={matches{3}.Path};
                valid=endsWith(paths,"/"+this.ObjectTypes+"/SSID");

                ssids={matches{3}(valid).Value};
                parents={matches{4}(valid).Value};
                charts={matches{5}(valid).Value};

                for n=1:numel(ssids)
                    if strcmp(parents{n},charts{n})
                        parent=charts{n};
                    else
                        parent=charts{n}+":"+parents{n};
                    end
                    parentMap(charts{n}+":"+ssids{n})=parent;
                end

            else
                ids={matches{3}.Value,matches{5}.Value};
                links={matches{4}.Value,matches{6}.Value};

                for n=1:numel(ids)
                    nodes=str2num(links{n},Evaluation="restricted");%#ok<ST2NM>
                    parentMap(ids{n})=string(nodes(1));
                end
            end

            handler.setStateflowInfo(chartNameMap,parentMap);
        end
    end

end
