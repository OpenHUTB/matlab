
function dlgStruct=getActiveDialogSchema(obj,~)




    dlgTag='Tree_';

    rootNode=obj.resultsExplorer.root.activeTree.root;
    dlgStruct=[];
    if numel(rootNode.children)>=1
        aggregatedResultExists=true;
        if obj.needAggregate
            [agcvd,errmsg]=rootNode.aggregate();
            aggregatedResultExists=~isempty(agcvd);
            if isempty(errmsg)
                obj.needAggregate=false;
            else
                warndlg(getString(message('Slvnv:simcoverage:cvresultsexplorer:AggregationError',errmsg)),...
                getString(message('Slvnv:simcoverage:cvresultsexplorer:ActiveTreeName')),'modal');
            end
        end
        if aggregatedResultExists
            dlgStruct=rootNode.getNodeDialogSchema(true);
        end
    end

    if isempty(dlgStruct)
        dlgStruct=rootNode.getNodeDialogSchema(false);
    end

    dlgStruct.DialogTag=[dlgTag,'active'];
    dlgStruct.HelpArgs={dlgStruct.DialogTag};
    dlgStruct.HelpMethod='cvi.ResultsExplorer.ResultsExplorer.helpFcn';


end
