classdef Root<handle




    properties(SetObservable=true)
        name=''
        interface=[]
        activeTree=[]
        passiveTree=[]
        settings=[]
        resultsExplorer=[]
    end
    methods(Static=true)
        function root=create(resultsExplorer)
            root=cvi.ResultsExplorer.Root(resultsExplorer);
            root.interface=SlCovResultsExplorer.Root(resultsExplorer,root);
            root.interface.addToHierarchy(root.settings.interface);
            resultsExplorer.filterExplorer=cvi.FilterExplorer.FilterExplorer(resultsExplorer.uuid,resultsExplorer);
            root.interface.addToHierarchy(resultsExplorer.filterExplorer.filterTree.interface);
            root.interface.addToHierarchy(root.activeTree.interface);
            root.interface.addToHierarchy(root.passiveTree.interface);
        end
    end

    methods


        function root=Root(resultsExplorer)
            root.name=resultsExplorer.topModelName;
            root.resultsExplorer=resultsExplorer;
            activeTreeName=getString(message('Slvnv:simcoverage:cvresultsexplorer:ActiveTreeName'));
            passiveTreeName=getString(message('Slvnv:simcoverage:cvresultsexplorer:PassiveTreeName'));
            root.activeTree=cvi.ResultsExplorer.Tree.create(activeTreeName,resultsExplorer);
            root.activeTree.isActive=true;
            root.passiveTree=cvi.ResultsExplorer.Tree.create(passiveTreeName,resultsExplorer);
            root.settings=cvi.ResultsExplorer.Settings.create(resultsExplorer);
        end


        function label=getDisplayLabel(node)
            label=node.name;
        end

        function retVal=getPropertyStyle(~,~)
            retVal=DAStudio.PropertyStyle;

        end


        function icon=getDisplayIcon(~)
            icon=fullfile(matlabroot,'toolbox','slcoverage','+cvi','+ResultsExplorer','@ResultsExplorer','icons','SimulinkModelIcon.png');

        end

        function cm=getContextMenu(~)
            try
                cm=[];
            catch MEx
                display(MEx.stack(1));
            end
        end
    end
end