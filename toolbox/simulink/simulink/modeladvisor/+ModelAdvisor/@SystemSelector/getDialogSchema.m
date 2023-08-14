function dlgstruct=getDialogSchema(this,~)




    dlgInstruct.Name=this.DialogInstruction;
    dlgInstruct.Type='text';
    dlgInstruct.Alignment=5;
    dlgInstruct.Tag='text_ResultMsg';
    dlgInstruct.RowSpan=[1,1];
    dlgInstruct.ColSpan=[1,1];

    mytree.Type='tree';
    mytree.Name=DAStudio.message('Simulink:tools:MASystemHierarchy');
    mytree.Tag='mytree_tree';
    mytree.RowSpan=[2,2];
    mytree.ColSpan=[1,1];
    mytree.ObjectProperty='SelectedSystem';
    mytree.TreeItems=getTree(this.ModelObj,this.ShowLibraries);

    mytree.TreeExpandItems=get_expand_tree_items(this.SelectedSystem);
    dlgstruct.DialogTitle=this.DialogTitle;
    dlgstruct.Items={dlgInstruct,mytree};
    dlgstruct.LayoutGrid=[2,1];
    dlgstruct.RowStretch=[0,1];
    dlgstruct.ColStretch=1;
    dlgstruct.StandaloneButtonSet={'Ok','Cancel'};

    caller=dbstack;
    maCall=false;
    for i=1:length(caller)
        if~isempty(strfind(caller(i).file,'modeladvisor.'))&&strcmp(caller(i).name,'modeladvisor')
            maCall=true;
            break;
        end
    end
    if maCall
        dlgstruct.DisplayIcon=fullfile('toolbox','simulink','simulink','modeladvisor','resources','ma.png');
    end

    dlgstruct.CloseMethod='closeCB';
    dlgstruct.CloseMethodArgs={'%closeaction'};
    dlgstruct.CloseMethodArgsDT={'string'};
    dlgstruct.Sticky=this.Sticky;

    function treeItems=getTree(modelObj,showLibraries)
        if(modelObj==slroot)
            children=modelObj.getHierarchicalChildren;
            treeItems={'Simulink Root',{}};
            for u=1:length(children)
                if isa(children(u),'Simulink.BlockDiagram')&&...
                    (showLibraries||~strcmpi(children(u).BlockDiagramType,'library'))
                    substruct=convertSystemHierarchyToTreeFindSys(children(u).Name);
                    treeItems{2}{end+1}=substruct{1};

                    if(length(substruct)>1)
                        treeItems{2}{end+1}=substruct{2};
                    end
                end
            end
        else
            treeItems=convertSystemHierarchyToTreeFindSys(modelObj.Name);
        end

        function treeItems=convertSystemHierarchyToTreeFindSys(rootSystemName)
            treeItems={replaceCarriageReturnWithSpace(get_param(rootSystemName,'Name'))};
            childSubsystem=find_system(rootSystemName,'SearchDepth',1,...
            'MatchFilter',@Simulink.match.allVariants,...
            'LookUnderMasks','all','FollowLinks','on','BlockType','SubSystem');
            if~strcmp(bdroot(rootSystemName),rootSystemName)
                childSubsystem=childSubsystem(2:end);
            end
            if~isempty(childSubsystem)
                subtree={};
                for i=1:length(childSubsystem)
                    subtree=[subtree,convertSystemHierarchyToTreeFindSys(childSubsystem{i})];
                end
                treeItems={replaceCarriageReturnWithSpace(get_param(rootSystemName,'Name')),subtree};
            end


            function output=replaceCarriageReturnWithSpace(input)
                output=strrep(input,sprintf('\n'),' ');

                function expandItems=get_expand_tree_items(startPoint)
                    if ischar(startPoint)&&strcmp(startPoint,'Simulink Root')


                        parentSystem=[];
                    else
                        parentSystem=get_param(startPoint,'Parent');
                    end
                    expandItems={startPoint};
                    if~isempty(parentSystem)
                        expandItems{end+1}=parentSystem;
                        upperLevels=get_expand_tree_items(parentSystem);
                        expandItems=[expandItems,upperLevels];
                    end
