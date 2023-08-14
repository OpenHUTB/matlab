function varargout=new(node,p,varName)












    if numel(node)~=1
        pm_error('physmod:common:logging:sli:dataexplorer:NonScalarNode','sscexplore');
    end

    if node(1).numChildren==0
        pm_warning('physmod:common:logging:sli:dataexplorer:SimlogEmpty',varName);
    end

    try
        if nargin>1
            p=pm_charvector(p);
        end
    catch ME
        ME.throwAsCaller();
    end

    if nargin==2
        varName=inputname(1);
    end


    tree=lCreateTree(node);


    hFigure=figure('Name',getMessageFromCatalog('ExplorerTitle',node.id),...
    'NumberTitle','off','Units','Pixels',...
    'Position',[400,100,650,650],'HandleVisibility','callback',...
    'CloseRequestFcn',@lCloseCallback);




    lSetupVisibilityForToolbarAndMenuOptions(hFigure);






    set(hFigure,'DefaultLegendAutoUpdate','off');

    if(nargout==1)
        varargout{1}=hFigure;
    end


    buttonPanel=lCreateButtonPanel();


    stats=getNodeStatistics(node);
    statusPanel=lCreateStatusPanel(node,stats);


    mainPanel=javax.swing.JPanel;
    mainPanel.setLayout(java.awt.BorderLayout);


    mainPanel.add(buttonPanel,java.awt.BorderLayout.NORTH);
    mainPanel.add(tree.getScrollPane,java.awt.BorderLayout.CENTER);
    mainPanel.add(statusPanel,java.awt.BorderLayout.SOUTH);

    dim=java.awt.Dimension(330,500);
    mainPanel.setPreferredSize(dim);


    matlab.ui.internal.JavaMigrationTools.suppressedJavaComponent(mainPanel,java.awt.BorderLayout.WEST,hFigure);


    options=lDefaultOptions(node);


    guidata.node=node;
    guidata.tree=tree;
    guidata.options=options;
    guidata.navPanel=mainPanel;
    guidata.inputName=varName;
    guidata.rootStatistics=stats;

    selectedNodePathIndex.path=node.id;
    selectedNodePathIndex.index=-1;
    guidata.lastSelection={selectedNodePathIndex};
    guidata.isExtracted=false;
    set(hFigure,'UserData',guidata);


    tree.setSelectedNode(tree.getRoot);
    if nargin>1
        selectedPath='';
        if(~isempty(p)&&node.hasPath(p))
            z=get_path(tree.getRoot,node,p);
            selectedPath=z{end};
        end
        if~isempty(selectedPath)
            tree.setSelectedNode(selectedPath);
        end

    end

    tree.getTree.scrollPathToVisible(tree.getTree.getSelectionPath);
    movegui(hFigure);
    simscape.logging.internal.link(hFigure,true);
end



function options=lDefaultOptions(node)


    assert(numel(node)==1,'The node should be scalar');


    f=@(nv)(~strcmpi(nv{end}.series.unit,getMessageFromCatalog('Invalid')));
    nodesWithData=find(node,f);

    tStart=nan;
    tEnd=nan;
    if~isempty(nodesWithData)
        time=nodesWithData{1}.series.time;
        if(numel(time)>0)
            tStart=time(1);
            tEnd=time(end);
        end
    end


    options.time.limit=false;
    options.time.start=tStart;
    options.time.stop=tEnd;
    options.marker=1;
    options.multi=1;
    options.link.x=true;
    options.link.y=false;
    options.align=1;
    options.unit=1;
    options.legend=1;
    options.unitsPerNode=containers.Map();

end

function tree=lCreateTree(node)


    assert(numel(node)==1,'The node should be scalar');


    treeRoot=simscape.logging.internal.populateTree([],node);


    tree=javaObjectEDT('com.mathworks.hg.peer.UITreePeer');
    tree.setRoot(treeRoot);

    setName(tree.getTree,'loggingTree');


    treeHandle=handle(tree,'callbackproperties');
    set(treeHandle,'NodeSelectedCallBack',...
    {@lHgTreeSelectionCallback,tree,@lTreeSelectionCallback});


    tree.getTree.expandRow(0);


    tree.getTree.setDropTarget([]);


    tree.getTree.getSelectionModel.setSelectionMode(...
    javax.swing.tree.TreeSelectionModel.DISCONTIGUOUS_TREE_SELECTION);

end

function lSetupVisibilityForToolbarAndMenuOptions(hfig)


    uiObjects=findall(hfig);


    toolbar=findobj(uiObjects,'Tag','FigureToolBar');
    tags={'Standard.SaveFigure','Standard.FileOpen','Standard.NewFigure'};
    for idx=1:numel(tags)
        set(findall(toolbar,'Tag',tags{idx}),'Visible','off');
    end


    tags={'figMenuFileSaveAs','figMenuFileSave','figMenuNewFigure',...
    'figMenuOpen'};
    for idx=1:numel(tags)
        set(findobj(uiObjects,'Tag',tags{idx}),'Visible','off');
    end

end

function buttonPanel=lCreateButtonPanel



    iconDir=fullfile(matlabroot,'toolbox','physmod','common','logging','sli','m','resources','icons');
    if exist(iconDir,'dir')
        icons.plotOptions=fullfile(iconDir,'plot_options.png');
        icons.extractPlot=fullfile(iconDir,'extract_plot.png');
        icons.reloadData=fullfile(iconDir,'refresh.png');
    else
        iconDir=fullfile(matlabroot,'toolbox','matlab','icons');
        icons.plotOptions=fullfile(iconDir,'reficon.gif');
        icons.extractPlot=fullfile(iconDir,'figureicon.gif');
        icons.reloadData=fullfile(iconDir,'tool_rotate_3d.gif');
    end


    optionsButton=lCreateButton(...
    icons.plotOptions,...
    getMessageFromCatalog('PlotOptions'),...
    @lOptionsButtonCallback);
    setName(optionsButton,'optionsButton');


    plotButton=lCreateButton(...
    icons.extractPlot,...
    getMessageFromCatalog('ExtractPlot'),...
    @lPlotButtonCallback);
    setName(plotButton,'plotButton');


    reloadButton=lCreateButton(...
    icons.reloadData,...
    getMessageFromCatalog('ReloadLoggedData'),...
    @lReloadButtonCallback);
    setName(reloadButton,'reloadButton');

    linkButton=lCreateToggleButton(true,...
    icons.extractPlot,...
    'Unlink',@lLinkButtonCallback);
    setName(linkButton,'linkButton');


    buttonPanel=javax.swing.JPanel;
    buttonPanel.setLayout(java.awt.FlowLayout(java.awt.FlowLayout.LEFT));
    buttonPanel.setBorder(javax.swing.border.EtchedBorder());
    buttonPanel.add(optionsButton);
    buttonPanel.add(plotButton);
    buttonPanel.add(reloadButton);
    buttonPanel.add(linkButton);
end

function scrollPane=lCreateStatusPanel(node,rootStats)


    assert(numel(node)==1,'The node should be scalar');


    labelTitle=javax.swing.JLabel;
    labelTitle.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);


    labelDesc=javax.swing.JLabel;
    labelDesc.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
    setName(labelDesc,'descriptionLink');


    labelStats=javax.swing.JLabel;
    labelStats.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
    setName(labelStats,'statsLabel');


    labelSrc=javax.swing.JLabel;
    labelSrc.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
    setName(labelSrc,'sourceLink');


    statusPanel=javax.swing.JPanel;
    statusPanel.setLayout(javax.swing.BoxLayout(statusPanel,javax.swing.BoxLayout.Y_AXIS));
    statusPanel.setBorder(...
    javax.swing.border.CompoundBorder(...
    javax.swing.border.EtchedBorder(),...
    javax.swing.border.EmptyBorder(5,5,5,5)));

    statusPanel.add(labelTitle);
    statusPanel.add(labelDesc);
    statusPanel.add(labelStats);
    statusPanel.add(labelSrc);

    scrollPane=javax.swing.JScrollPane(statusPanel);
    dim=java.awt.Dimension(300,130);
    scrollPane.setPreferredSize(dim);
    scrollPane.setHorizontalScrollBarPolicy(...
    javax.swing.JScrollPane.HORIZONTAL_SCROLLBAR_AS_NEEDED);
    scrollPane.setVerticalScrollBarPolicy(...
    javax.swing.JScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED);


    lUpdateStatusPanel(scrollPane,node,{node},rootStats);

end


function lSetMouseClickCallback(label,labelTextStr,labelToolTip,labelCallback)



    tempStr=regexprep(labelTextStr,'<a.*">','');
    tempStr=strrep(tempStr,'</a>','');

    label.setText(tempStr);


    label.setText(labelTextStr);
    label.setToolTipText(labelToolTip);

    labelHandle=handle(label,'callbackproperties');
    if isempty(labelCallback)
        set(labelHandle,'MouseClickedCallback',[]);
    else
        set(labelHandle,'MouseClickedCallback',@(src,evt)labelCallback(src));
    end

end


function lUpdateStatusPanel(scrollPane,rootNode,selectedNodes,rootStats)


    assert(numel(rootNode)==1,'The root node should be scalar');

    locationStr='';
    locationTip='';
    locationCallback='';
    statusCallback='';
    statusDesc='';
    statusStats='';
    statusTooltip='';

    if isempty(selectedNodes)
        statusTitle=getMessageFromCatalog('NoNodeSelected');
    elseif numel(selectedNodes)==1
        node=selectedNodes{1};
        if numel(node)>1
            node=node(1);
        end
        if node==rootNode
            [statusTitle,statusDesc,statusStats,statusTooltip,statusCallback]=...
            lPrintStatus(selectedNodes,rootNode,rootStats);
        else
            printStatusFcn=lGetNodeDisplayOption(node,'PrintStatusFcn',@lPrintStatus);
            [statusTitle,statusDesc,statusStats,statusTooltip,statusCallback]=...
            printStatusFcn(selectedNodes);
        end
        printLocationFcn=lGetNodeDisplayOption(node,'PrintLocationFcn',@lPrintLocation);
        [locationStr,locationTip,locationCallback]=printLocationFcn(node);

    else
        [statusTitle,statusDesc,statusStats,statusTooltip,statusCallback]=...
        lPrintStatus(selectedNodes,rootNode,rootStats);
    end

    viewPort=scrollPane.getComponent(0);
    panel=viewPort.getComponent(0);

    titleLabel=panel.getComponent(0);
    titleLabel.setText(statusTitle);
    titleLabel.setToolTipText(statusTooltip);

    descLabel=panel.getComponent(1);
    lSetMouseClickCallback(descLabel,statusDesc,statusTooltip,statusCallback);

    statsLabel=panel.getComponent(2);
    statsLabel.setText(statusStats);
    statsLabel.setToolTipText(statusTooltip);

    locationLabel=panel.getComponent(3);
    lSetMouseClickCallback(locationLabel,locationStr,locationTip,locationCallback);


end

function[str,tooltipStr,cbck]=lPrintNodeId(node,rootStats)


    str='';
    cbck='';
    tooltipStr='';

    if(node(1).hasSource())
        source=node(1).getSource();
        isLink=false;
        if lIsSimulinkValid(source)



            isLink=true;
            cbck=@(src)(lNodeIdSourceCallback(node(1),src,rootStats));
        end

        [str,tooltipStr]=lGetNodeDescription(node,isLink);
    end

end

function[statusTitle,statusDesc,statusStats,statusTooltip,cbck]=...
    lPrintStatus(selectedNodes,rootNode,rootStats)


    assert((numel(selectedNodes)==1)||(nargin>1));
    cbck='';

    isMultiSelected=(numel(selectedNodes)>1);
    isRootNode=(nargin>1)&&(selectedNodes{1}==rootNode);

    if isMultiSelected||isRootNode
        assert(numel(rootNode)==1);
        node=rootNode;
        baseFreq=node.series.baseFrequency();
        statusTitle=getMessageFromCatalog('RootNodeStats');
        if nargin==3
            stats=rootStats;
        else
            stats=getNodeStatistics(node);
        end


        isLink=false;
        [statusDesc,tooltipStr]=lGetNodeDescription(node,isLink);
    else
        node=selectedNodes{1};
        baseFreq=node(1).series.baseFrequency();
        statusTitle=getMessageFromCatalog('SelectedNodeStats');
        stats=getNodeStatistics(node);
        [statusDesc,tooltipStr,cbck]=lPrintNodeId(node,stats);
    end




    if isMultiSelected
        if any(cellfun(@(z)z.isFrequency(),selectedNodes,'UniformOutput',true))
            baseFreq='--';
        else


            baseFreq=rootNode.series.baseFrequency();
        end
        for idx=1:numel(selectedNodes)
            series=selectedNodes{idx}(1).series;
            if stats.nPoints~=numel(series.time)
                stats.nPoints='--';
                break;
            end
        end
    end

    statusStats=lGetStatusStatsText(stats,baseFreq);
    statusTooltip=lGetStatusTooltipStr(tooltipStr,statusStats,statusTitle);

end

function isValid=lIsSimulinkValid(source)
    isValid=exist('is_simulink_loaded','file')&&is_simulink_loaded()&&...
    Simulink.ID.isValid(source);
end

function model=lGetModelFromSource(source)
    strs=strsplit(source,':');
    model=strs{1};
end

function[str,tip,cbck]=lPrintLocation(node)

    str='';tip='';cbck='';

    assert(numel(node)==1);

    if(node.hasSource())
        source=node.getSource();
        model=lGetModelFromSource(source);
        srcLabel=getMessageFromCatalog('Source');
        if exist('is_simulink_loaded','file')&&is_simulink_loaded()&&bdIsLoaded(model)
            if Simulink.ID.isValid(source)
                blockName=pmsl_sanitizename(...
                get_param(Simulink.ID.getHandle(source),'Name'));

                str=sprintf('<html>%s <a href="%s">%s</a></html>',srcLabel,...
                blockName,blockName);
                tip=getfullname(Simulink.ID.getHandle(source));
                cbck=@(src)(lBlockSourceCallback(source,src));
            else
                str=sprintf(getMessageFromCatalog('NoBlock'));
                tip=getMessageFromCatalog('NoBlockTooltip',node.id);
            end
        else
            noModelStatus=['(',getMessageFromCatalog('NoModel'),')'];
            str=sprintf('<html>%s <a href="%s">%s</a></html>',...
            srcLabel,noModelStatus,noModelStatus);
            tip=getMessageFromCatalog('NoSimulinkModel',model);
            cbck=@(src)(lBlockSourceCallback(source,src));
        end
    end

end

function lNodeIdSourceCallback(node,src,stats)


    assert(numel(node)==1);

    source=node.getSource();
    model=lGetModelFromSource(source);

    openSystem=true;
    updateLabel=false;

    if~bdIsLoaded(model)
        [openSystem,updateLabel]=lLoadModel(model);
    end

    if openSystem
        open_system(model);
        statusTitle=getMessageFromCatalog('SelectedNodeStats');
        isLink=false;
        if lIsSimulinkValid(source)
            if~strcmp(model,source)
                open_system(Simulink.ID.getHandle(source));
            end
            if updateLabel



                isLink=true;
                lUpdateStatusLabelText(src,node,stats,statusTitle,isLink);

            end
        else
            lUpdateStatusLabelText(src,node,stats,statusTitle,isLink);
        end
    end

end


function lBlockSourceCallback(source,src)


    model=lGetModelFromSource(source);

    highlight=true;
    updateLabel=false;


    if~bdIsLoaded(model)
        [highlight,updateLabel]=lLoadModel(model);
    end

    if highlight
        open_system(model);
        set_param(model,'HiliteAncestors','none')
        if lIsSimulinkValid(source)
            if~strcmp(model,source)
                pm.sli.highlightSystem(source);
            end
            if updateLabel
                blockName=pmsl_sanitizename(...
                get_param(Simulink.ID.getHandle(source),'Name'));
                srcLabel=getMessageFromCatalog('Source');
                str=sprintf('<html>%s <a href="%s">%s</a></html>',...
                srcLabel,blockName,blockName);
                tip=getfullname(Simulink.ID.getHandle(source));
                src.setText(str);
                src.setToolTipText(tip);
            end
        else
            src.setText(getMessageFromCatalog('NoBlock'));
            src.setToolTipText(getMessageFromCatalog('NoSimulinkBlock'));
        end
    end

end

function[modelAction,updateLabel]=lLoadModel(model)

    updateLabel=false;
    if(exist(model,'file')==4)
        choiceYes=getMessageFromCatalog('Yes');
        choiceNo=getMessageFromCatalog('No');
        result=questdlg(getMessageFromCatalog('ModelNotOpen',model),...
        getMessageFromCatalog('OpenModel'),choiceYes,choiceNo,choiceYes);
        modelAction=strcmp(result,choiceYes);
        updateLabel=modelAction;

    else
        str=getMessageFromCatalog('ModelNotOnPath',model);
        errorDialogTitle=getMessageFromCatalog('LoadError');
        errordlg(str,errorDialogTitle,'modal');
        modelAction=false;
    end

end

function statusStatsText=lGetStatusStatsText(stats,baseFrequency)

    baseFrequencyMsg='';







    if ischar(baseFrequency)||baseFrequency>0
        baseFrequencyMsg=[getMessageFromCatalog('BaseFrequency',...
        num2str(baseFrequency))...
        ,'<br/>'];
    end

    statusStatsText=sprintf(['<html>%s%s<br/>'...
    ,'%s<br/>'...
    ,'%s</html>'],...
    baseFrequencyMsg,...
    getMessageFromCatalog('NumTimeSteps',num2str(stats.nPoints)),...
    getMessageFromCatalog('NumLoggedVariables',num2str(stats.nVariables)),...
    getMessageFromCatalog('NumLoggedZeroCrossings',num2str(stats.nZCs)));

end


function lCloseCallback(hFigure,~)





    try
        ud=get(hFigure,'UserData');
        uitree=ud.tree;
        tree=uitree.getTree;

        javaMethodEDT('clearSelection',tree);




        drawnow;
    catch
    end

    delete(hFigure);

end

function lHgTreeSelectionCallback(src,evd,tree,selfcn)%#ok<INUSL>


    cbk=selfcn;
    hgfeval(cbk,tree,evd);

end

function lTreeSelectionCallback(tree,~)



    parent=tree.getScrollPane.getParent.getParent;
    if~isempty(parent)
        figureClient=parent.getParent;
        hFigure=getfigurefordesktopclient(figureClient);
        if~lIsFigureHandleValid(hFigure)
            return;
        end



        ud=get(hFigure,'UserData');
        if ud.node.numChildren==0
            return;
        end

        [isSelectionUpdated,selectedNodes]=...
        lValidateTreeSelection(ud.tree,ud.node,ud.lastSelection);


        if isSelectionUpdated

            ud.lastSelection=selectedNodes;
            set(hFigure,'UserData',ud);


            lPlot(hFigure);
        end

    end

end

function lOptionsButtonCallback(src,evt)%#ok<INUSD>



    parent=src.getParent.getParent.getParent;
    if~isempty(parent)
        figureClient=parent.getParent;
        hFigure=getfigurefordesktopclient(figureClient);


        lCreateOptionsDialog(hFigure)
    end

end

function lPlotButtonCallback(src,evt)%#ok<INUSD>



    parent=src.getParent.getParent.getParent;
    if~isempty(parent)
        figureClient=parent.getParent;
        hFigure=getfigurefordesktopclient(figureClient);


        newFigure=figure;


        tmpData=get(hFigure,'UserData');
        tmpData.isExtracted=true;
        set(newFigure,'UserData',tmpData);

        lPlot(hFigure,newFigure);





        set(newFigure,'UserData','');
    end

end

function lReloadButtonCallback(src,evt)%#ok<INUSD>



    parent=src.getParent.getParent.getParent;
    if~isempty(parent)
        figureClient=parent.getParent;
        hFigure=getfigurefordesktopclient(figureClient);
        ud=get(hFigure,'UserData');


        varName=inputdlg({getMessageFromCatalog('SpecifyName')},...
        getMessageFromCatalog('ReloadData',ud.node.id),1,{ud.inputName});
        errorDialogTitle=getMessageFromCatalog('LoadError');
        errorString=getMessageFromCatalog('NoReloadData');
        if~isempty(varName)
            varName=varName{1};
            if~isvarname(varName)
                errorCause=getMessageFromCatalog('InvalidName',varName);
                str=sprintf('%s\n %s',errorString,errorCause);
                errordlg(str,errorDialogTitle,'modal');
                return;
            end






            logVar='';
            if isvarname(ud.node(1).getSource())&&bdIsLoaded(ud.node.id)&&...
                strcmp(get_param(ud.node.id,'ReturnWorkspaceOutputs'),'on')
                out=get_param(ud.node.id,'ReturnWorkspaceOutputsName');
                if evalin('base','exist(''out'') == 1')
                    output=evalin('base',out);
                    logVar=output.get(varName);
                end
            else
                if~evalin('base',sprintf('exist(''%s'')',varName))
                    errorCause=getMessageFromCatalog('NoVariable',varName);
                    str=sprintf('%s\n %s',errorString,errorCause);
                    errordlg(str,errorDialogTitle,'modal');
                    return;
                end
                logVar=evalin('base',varName);
            end
            if isempty(logVar)
                logVar=evalin('base',varName);
            end
            if~isa(logVar,'simscape.logging.Node')
                errorCause=getMessageFromCatalog('NotSimscapeVariable',varName);
                str=sprintf('%s\n %s',errorString,errorCause);
                errordlg(str,errorDialogTitle,'modal');
                return;
            else


                [~,selectedPaths]=simscape.logging.internal.getSelectedNodes(...
                ud.tree,ud.node);
                simscape.logging.internal.refresh(hFigure,logVar,varName,selectedPaths);
            end
        end
    end


end

function lLinkButtonCallback(src,evt)%#ok<INUSD>



    parent=src.getParent.getParent.getParent;
    if~isempty(parent)
        figureClient=parent.getParent;
        explorerFigureHandle=getfigurefordesktopclient(figureClient);
        simscape.logging.internal.link(explorerFigureHandle,src.isSelected);
    end

end



function lPlot(explorerFigureHandle,plotFigureHandle)


    if~lIsFigureHandleValid(explorerFigureHandle)
        return;
    end


    ud=get(explorerFigureHandle,'UserData');
    tree=ud.tree;
    loggedNode=ud.node;
    options=ud.options;


    panels=ud.navPanel.getComponents;
    buttons=panels(1).getComponents;


    lEnableButtons(buttons,false);


    buttonCleanup=onCleanup(@()(lEnableButtons(buttons,true)));



    [nodes,paths,labels]=simscape.logging.internal.getSelectedNodes(...
    tree,loggedNode);



    if nargin==1
        plotFigureHandle=explorerFigureHandle;
    end


    scrollPane=ud.navPanel.getComponent(2);
    lUpdateStatusPanel(scrollPane,loggedNode,nodes,ud.rootStatistics);


    numNodesToPlot=lPlotOnFigure(plotFigureHandle,nodes,paths,labels,options);


    if(numNodesToPlot==0)
        buttonCleanup=onCleanup(@()(lEnableButton(buttons,'plotButton',false)));
    end

end

function[nodesToPlot,pathsToPlot,labelsToPlot,optionsToPlot]=...
    lProcessSelectedNodes(nodes,paths,labels,options)

    node=nodes{1};
    fcn=lGetNodeDisplayOption(node,'GetNodesToPlotFcn',@lFindNodesToPlot);

    [nodesToPlot,pathsToPlot,labelsToPlot,optionsToPlot]=fcn(nodes,paths,labels,options);
end

function fcn=lGetPlotFcn(node)

    fcn=lGetNodeDisplayOption(node,'PlotNodeFcn','');


    if isempty(fcn)&&(node(1).numChildren==0)
        fcn=@lPlotNodes;
    end
end

function[nodesToPlot,pathsToPlot,labelsToPlot,optionsToPlot]=...
    lFindNodesToPlot(nodes,paths,labels,options)


    nodesToPlot={};
    pathsToPlot={};
    labelsToPlot={};
    optionsToPlot=options;

    if isscalar(nodes{1})&&nodes{1}.numChildren>0
        node=nodes{1};
        childIds=simscape.logging.internal.sortChildIds(node);
        for idx=1:numel(childIds)
            childNode=child(nodes{1},childIds{idx});


            if~isscalar(childNode)
                continue
            end

            isPlotted=(childNode(1).numChildren==0);
            if lGetNodeDisplayOption(childNode,'IsPlottedByParent',isPlotted)
                assert(numel(childNode)==1);
                nodesToPlot{end+1}=childNode;%#ok<AGROW>
                pathsToPlot{end+1}=[paths{1},childIds(idx)];%#ok<AGROW>
                labelsToPlot{end+1}=childNode.id;%#ok<AGROW>
            end
        end
    elseif~isscalar(nodes{1})
        return
    else

        nodesToPlot=nodes;
        pathsToPlot=paths;
        labelsToPlot=labels;
    end
end

function[groupIdx,unitsToPlot,fcnsToPlot]=lGroupNodesForPlotting(...
    allNodes,allPaths,options)

    allPlotFcns=cellfun(@(n)func2str(lGetPlotFcn(n)),allNodes,'UniformOutput',false);


    allUnits=cellfun(@(n)(n.series.unit),allNodes,'UniformOutput',false);


    for idx=1:numel(allUnits)
        allUnits{idx}=lGetUnit(allUnits{idx},allPaths{idx},options);
    end




    allUnits=strrep(allUnits,getMessageFromCatalog('Invalid'),'1');


    uniqueFcns=unique(allPlotFcns,'stable');
    uniqueUnits=unique(allUnits,'stable');
    groupIdx=zeros(1,numel(allNodes));
    grp=1;
    for i=1:numel(uniqueFcns)
        for j=1:numel(uniqueUnits)
            idx=strcmp(allPlotFcns,uniqueFcns{i})&...
            strcmp(allUnits,uniqueUnits{j});
            if any(idx)
                groupIdx(idx)=grp;
                grp=grp+1;
            end
        end
    end
    unitsToPlot=allUnits;
    fcnsToPlot=allPlotFcns;
end

function numNodesToPlot=lPlotOnFigure(hFigure,nodes,paths,labels,options)


    numNodesToPlot=0;

    if~lIsFigureHandleValid(hFigure)
        return;
    end


    clf(hFigure);

    if numel(nodes)==0
        return;
    end



    if~lIsFigureHandleValid(hFigure)
        return;
    end



    hv=get(hFigure,'HandleVisibility');
    c=onCleanup(@()lSetFigureHandleVisibility(hFigure,hv));
    set(hFigure,'HandleVisibility','on');


    [nodesToPlot,pathsToPlot,labelsToPlot,optionsToPlot]=...
    lProcessSelectedNodes(nodes,paths,labels,options);

    numNodesToPlot=numel(nodesToPlot);
    [~,multiSelection]=lGetMultiSelectOptions(optionsToPlot.multi);
    [~,axisAlignmentSelection]=lGetAlignmentOptions(optionsToPlot.align);

    switch multiSelection
    case getMessageFromCatalog('PlotSeparate')


        ax=zeros(1,numNodesToPlot);


        for idx=1:numNodesToPlot
            switch axisAlignmentSelection
            case getMessageFromCatalog('PlotVertical')
                ax(idx)=subplot(numNodesToPlot,1,idx);
            case getMessageFromCatalog('PlotHorizontal')
                ax(idx)=subplot(1,numNodesToPlot,idx);
            otherwise
                try
                    pm_error('physmod:common:logging:sli:dataexplorer:InvalidAxisOption');
                catch ME
                    ME.throwAsCaller();
                end
            end

            assert(numel(nodesToPlot{idx})==1);

            unit=lGetUnit(nodesToPlot{idx}.series.unit,...
            pathsToPlot{idx},optionsToPlot);

            plotFcn=lGetPlotFcn(nodesToPlot{idx});
            plotFcn(nodesToPlot{idx},ax(idx),optionsToPlot,unit,pathsToPlot(idx),labelsToPlot(idx));
        end

        lLinkAxes(ax,optionsToPlot);

    case getMessageFromCatalog('PlotOverlay')


        [groupIdx,unitsToPlot,functionsToPlot]=...
        lGroupNodesForPlotting(nodesToPlot,pathsToPlot,optionsToPlot);

        numPlots=max(groupIdx);
        ax=zeros(1,numPlots);


        for idx=1:numPlots
            switch axisAlignmentSelection
            case getMessageFromCatalog('PlotVertical')
                ax(idx)=subplot(numPlots,1,idx);
            case getMessageFromCatalog('PlotHorizontal')
                ax(idx)=subplot(1,numPlots,idx);
            otherwise
                try
                    pm_error('physmod:common:logging:sli:dataexplorer:InvalidAxisOption');
                catch ME
                    ME.throwAsCaller();
                end
            end

            plotIdx=find(groupIdx==idx);
            nodes=nodesToPlot(plotIdx);
            unit=unitsToPlot{plotIdx(1)};
            plotFcn=str2func(functionsToPlot{plotIdx(1)});
            plotFcn(nodes,ax(idx),optionsToPlot,unit,pathsToPlot(plotIdx),...
            labelsToPlot(plotIdx));
        end


        lLinkAxes(ax,optionsToPlot);

    otherwise
        try
            pm_error('physmod:common:logging:sli:dataexplorer:InvalidOption');
        catch ME
            ME.throwAsCaller();
        end
    end

end

function lPlotNodes(nodes,ax,options,units,nodePaths,labels)

    if~iscell(nodes)
        nodes={nodes};
    end

    legendEntries={};
    timeValuePairs={};



    for idx=1:numel(nodes)
        assert(numel(nodes{idx})==1,'The node must be scalar');
        series=nodes{idx}.series;
        time=series.time;
        values=series.values(units);
        dim=series.dimension;
        numElements=dim(1)*dim(2);

        for j=1:dim(2)
            for i=1:dim(1)
                if numElements>1
                    legendEntries{end+1}=sprintf('%s(%d,%d)',labels{idx},i,j);%#ok<AGROW>
                else
                    legendEntries{end+1}=sprintf('%s',labels{idx});%#ok<AGROW>
                end
            end
        end
        timeValuePairs{end+1}=time;%#ok<AGROW>
        timeValuePairs{end+1}=values;%#ok<AGROW>
    end


    lh=plot(ax,timeValuePairs{:},'Marker',lMarker(options.marker));
    for idx=1:numel(lh)
        lh(idx).DisplayName=strrep(legendEntries{idx},'_','\_');
    end




    [~,legendSelection]=lGetLegendOptions(options.legend);
    switch legendSelection
    case getMessageFromCatalog('PlotLegendAuto')
        if numel(legendEntries)>1
            legend('show');
        else
            if~isempty(regexp(legendEntries{1},'\.','once'))
                legend('show');
            end
        end
    case getMessageFromCatalog('PlotLegendAlways')
        if~isempty(legendEntries)
            legend('show');
        end
    case getMessageFromCatalog('PlotLegendNever')

    end


    title(ax,nodes{1}.id,'Interpreter','none');
    yLabelStr=sprintf('%s',units);
    xlabel(ax,getMessageFromCatalog('XAxisTime'),'Interpreter','none');
    ylabel(ax,yLabelStr,'Interpreter','none');
    grid(ax,'on');


    if options.time.limit
        set(ax,'XLim',[options.time.start,options.time.stop]);
    end


    hFigure=get(ax,'Parent');
    ud=get(hFigure,'UserData');
    if(ud.isExtracted==false)
        lCreateUnitButton(hFigure,ax,nodePaths);
    end

end

function lLinkAxes(ax,options)








    drawnow limitrate;

    try
        if isempty(ax)||~all(ishghandle(ax,'axes'))
            return;
        end
        if options.link.x&&options.link.y
            linkaxes(ax,'xy');
        elseif options.link.x
            linkaxes(ax,'x');
        elseif options.link.y
            linkaxes(ax,'y');
        else
            linkaxes(ax,'off');
        end
    catch
    end

end

function lEnableButtons(buttons,enable)


    for idx=1:numel(buttons)
        buttons(idx).setEnabled(enable);
    end

end

function lEnableButton(buttons,name,enable)


    for idx=1:numel(buttons)
        if strcmp(buttons(idx).getName,name)
            buttons(idx).setEnabled(enable);
        end
    end
end



function[selectionUpdated,currentSelection]=lValidateTreeSelection(...
    tree,loggedNode,lastSelection)

    import simscape.logging.internal.*


    selectionUpdated=true;
    currentSelection={};


    selectedTreeNodes=tree.getSelectedNodes;


    selectionPaths=tree.getTree.getSelectionPaths;

    assert(numel(selectedTreeNodes)==numel(selectionPaths),...
    getMessageFromCatalog('IncorrectSelectedNodes'));

    numSelected=numel(selectedTreeNodes);
    if numSelected==0
        return;
    end
    selectedNodes{1}=indexedNode(loggedNode,...
    indexedPath(selectedTreeNodes(1)));
    s=tree.getTree().getSelectionModel();

    pathsToRemove=selectionPaths;


    pathsToRemove(1)=[];
    currentSelection={indexedPath(selectedTreeNodes(1))};




    if(selectedNodes{1}(1).numChildren==0)
        for idx=2:numSelected
            nodePath=indexedPath(selectedTreeNodes(idx));
            n=indexedNode(loggedNode,nodePath);
            if n(1).numChildren==0
                pathsToRemove(idx)=[];
                currentSelection{end+1}=nodePath;%#ok<AGROW>
            end
        end
    end
    if numSelected>1
        javaMethodEDT('removeSelectionPaths',s,pathsToRemove);
    end


    selectionUpdated=~isequal(currentSelection,lastSelection);
end

function lUpdateUnitsPerNodeData(options,paths,specifiedUnit)


    for k=1:numel(paths)
        curPath=char(paths{k});
        options.unitsPerNode(curPath)=specifiedUnit;
    end

end

function lRemoveUnitsPerNodeData(options,paths)


    for k=1:numel(paths)
        curPath=char(paths{k});
        if(isKey(options.unitsPerNode,curPath))
            remove(options.unitsPerNode,curPath);
        end
    end

end



function res=lHasTagValue(node,name,value)

    if numel(node)>1
        node=node(1);
    end


    res=node.hasTag(name)&&all(strcmp(node.getTag(name),{name,value}));
end



function button=lCreateButton(iconFile,tooltip,cbFcn)

    icon=javax.swing.ImageIcon(iconFile);

    button=javaObjectEDT('com.mathworks.mwswing.MJButton');
    button.setIcon(icon);
    button.setToolTipText(tooltip);
    button.setPreferredSize(java.awt.Dimension(25,25));
    buttonHandle=handle(button,'callbackproperties');
    set(buttonHandle,'ActionPerformedCallback',cbFcn);
end

function button=lCreateToggleButton(toggleState,iconFile,tooltip,cbFcn)

    icon=javax.swing.ImageIcon(iconFile);
    button=javaObjectEDT('com.mathworks.mwswing.MJToggleButton');

    button.setIcon(icon);
    button.setToolTipText(tooltip);
    button.setSelected(toggleState);
    button.setPreferredSize(java.awt.Dimension(25,25));
    buttonHandle=handle(button,'callbackproperties');
    set(buttonHandle,'ActionPerformedCallback',cbFcn);
end

function lCreateUnitButton(hFigure,ax,paths)

    import simscape.logging.internal.*
    for idx=1:numel(paths)
        paths{idx}=indexedPathLabel(paths{idx});
    end

    [yButtonX,yButtonY,btnWidth,btnHeight]=lGetUnitButtonPosition(hFigure,ax);

    colorMatrix=repmat([1,1,1,1,1,1,1
    0,0,0,0,0,0,0
    1,0,0,0,0,0,1
    1,1,0,0,0,1,1
    1,1,1,0,1,1,1
    1,1,1,1,1,1,1
    1,1,1,1,1,1,1],...
    1,1,3);

    yMenu=lCreateUnitMenu(hFigure,get(ax,'YLabel'),paths);


    yButton=uicontrol('Parent',hFigure,...
    'Style','pushbutton',...
    'Tag',paths{1},...
    'Position',[yButtonX,yButtonY,btnWidth,btnHeight],...
    'CData',colorMatrix,...
    'Callback',{@(src,evt)lShowContextMenuOnButton(src,yMenu)});

    userData.yButton=yButton;
    userData.yMenu=yMenu;
    set(ax,'UserData',userData);


    addlistener(ax,'LocationChanged',@(varargin)lUpdateUnitButton(hFigure,ax));


    hz=zoom(hFigure);
    set(hz,'ActionPostCallback',@lZoomUpdateCallback);


    hr=rotate3d(ax);
    set(hr,'ActionPreCallback',@lHideButton);
    set(hr,'ActionPostCallback',@lRotateUpdateCallback);

    function lZoomUpdateCallback(hFigure,~)


        allAxesInFigure=findall(hFigure,'type','axes');
        for k=1:numel(allAxesInFigure)
            curAx=allAxesInFigure(k);
            curData=get(curAx,'UserData');

            if~isempty(curData)
                lUpdateUnitButton(hFigure,curAx);
            end
        end
    end

    function lHideButton(~,evtData)


        curAx=evtData.Axes;
        tmpUserData=get(curAx,'UserData');
        set(tmpUserData.yButton,'Visible','off');
    end

    function lRotateUpdateCallback(hFigure,evtData)


        curAx=evtData.Axes;
        tmpUserData=get(curAx,'UserData');
        set(tmpUserData.yButton,'Visible','on');
        lUpdateUnitButton(hFigure,curAx);
    end

end

function lUpdateUnitButton(hFigure,ax)


    [yButtonX,yButtonY,btnWidth,btnHeight]=lGetUnitButtonPosition(hFigure,ax);

    userData=get(ax,'UserData');
    set(userData.yButton,'Position',[yButtonX,yButtonY,btnWidth,btnHeight]);

end

function lCreateOptionsDialog(hFigure)

    ud=get(hFigure,'UserData');
    options=ud.options;

    [~,marker]=lMarker(1);
    multiSelectionStrings=lGetMultiSelectOptions();
    alignmentStrings=lGetAlignmentOptions();
    legendStrings=lGetLegendOptions();
    unitStrings=lGetUnitOptions();



    jframe=javax.swing.JFrame();
    jframeColor=jframe.getBackground();
    backgroundColor=...
    [jframeColor.getRed(),jframeColor.getGreen(),jframeColor.getBlue()]/255;

    explorerPosition=get(hFigure,'Position');


    guiHandle=figure('Name',getMessageFromCatalog('Options',ud.node.id),...
    'NumberTitle','off',...
    'Resize','on',...
    'MenuBar','none',...
    'Position',explorerPosition,...
    'Toolbar','none','Color',backgroundColor,...
    'Visible','off','units','pixels',...
    'WindowStyle','modal');


    set(guiHandle,'units','characters');
    position=get(guiHandle,'position');
    set(guiHandle,'Position',[position(1),position(2)+10,43,26]);


    set(guiHandle,'UserData',hFigure);


    axisOptionsPanel=uipanel('parent',guiHandle,'visible','on',...
    'units','characters','Position',[1,26-9.25,41,9],...
    'Title',getMessageFromCatalog('OptionsAxes'),...
    'backgroundcolor',backgroundColor);

    timeCheck=uicontrol(axisOptionsPanel,'Style','checkbox',...
    'String',getMessageFromCatalog('OptionsLimitTime'),...
    'Tag','Limit time axis','Value',options.time.limit,...
    'units','characters',...
    'Position',[1,6.5,24,1.25],'BackgroundColor',backgroundColor);

    timeStartText=uicontrol('parent',axisOptionsPanel,'Style','text',...
    'String',getMessageFromCatalog('OptionsStartTime'),...
    'BackgroundColor',backgroundColor,...
    'HorizontalAlignment','Left',...
    'units','characters','Position',[5,5,14,1],...
    'Enable',lEnableString(options.time.limit));
    timeStartEdit=uicontrol('parent',axisOptionsPanel,'Style','edit',...
    'String',num2str(options.time.start),'Tag','Starttime',...
    'BackgroundColor','white',...
    'units','characters','Position',[20,4.75,19,1.5],...
    'HorizontalAlignment','right',...
    'Enable',lEnableString(options.time.limit));
    timeStopText=uicontrol('parent',axisOptionsPanel,'Style','text',...
    'String',getMessageFromCatalog('OptionsStopTime'),...
    'BackgroundColor',backgroundColor,...
    'HorizontalAlignment','Left',...
    'units','characters','Position',[5,3,14,1],...
    'Enable',lEnableString(options.time.limit));
    timeStopEdit=uicontrol('parent',axisOptionsPanel,'Style','edit',...
    'String',num2str(options.time.stop),'Tag','Stoptime',...
    'BackgroundColor','white',...
    'units','characters','Position',[20,2.75,19,1.5],...
    'HorizontalAlignment','right',...
    'Enable',lEnableString(options.time.limit));

    linkXAxes=uicontrol(axisOptionsPanel,'Style','checkbox',...
    'String',getMessageFromCatalog('OptionsLink'),...
    'Value',options.link.x,'units','characters',...
    'Position',[1,1.25,24,1.25],'BackgroundColor',backgroundColor);

    plotOptionsPanel=uipanel('parent',guiHandle,'visible','on',...
    'units','characters','Position',[1,26-22,41,12],...
    'Title',getMessageFromCatalog('PlotOptions'),...
    'backgroundcolor',backgroundColor);

    markerText=uicontrol(plotOptionsPanel,'Style','text',...
    'String',getMessageFromCatalog('PlotMarker'),...
    'BackgroundColor',backgroundColor,...
    'HorizontalAlignment','Left',...
    'units','characters','Position',[1,9,18,1]);%#ok<NASGU>

    markerPopup=uicontrol(plotOptionsPanel,'Style','popupmenu',...
    'String',marker,...
    'Value',options.marker,...
    'BackgroundColor','white',...
    'units','characters','Position',[20,8.75,19,1.5]);

    multiSelectText=uicontrol(plotOptionsPanel,'Style','text',...
    'String',getMessageFromCatalog('PlotSignals'),...
    'BackgroundColor',backgroundColor,...
    'HorizontalAlignment','Left',...
    'units','characters','Position',[1,7,18,1]);%#ok<NASGU>

    multiSelectPopup=uicontrol(plotOptionsPanel,'Style','popupmenu',...
    'String',multiSelectionStrings,...
    'Tag','multiSelectPopup','Value',options.multi,...
    'BackgroundColor','white',...
    'units','characters','Position',[20,6.75,19,1.5]);

    axisAlignmentText=uicontrol(plotOptionsPanel,'Style','text',...
    'String',getMessageFromCatalog('PlotArrangement'),...
    'BackgroundColor',backgroundColor,...
    'HorizontalAlignment','Left',...
    'units','characters','Position',[1,5,18,1]);%#ok<NASGU>

    axisAlignmentPopup=uicontrol(plotOptionsPanel,'Style','popupmenu',...
    'String',alignmentStrings,...
    'Tag','alignmentStrings','Value',options.align,...
    'BackgroundColor','white',...
    'units','characters','Position',[20,4.75,19,1.5]);

    legendText=uicontrol(plotOptionsPanel,'Style','text',...
    'String',getMessageFromCatalog('PlotLegend'),...
    'BackgroundColor',backgroundColor,...
    'HorizontalAlignment','Left',...
    'units','characters','Position',[1,3,18,1]);%#ok<NASGU>

    legendPopup=uicontrol(plotOptionsPanel,'Style','popupmenu',...
    'String',legendStrings,...
    'Tag','legendStrings','Value',options.legend,...
    'BackgroundColor','white',...
    'units','characters','Position',[20,2.75,19,1.5]);

    unitsText=uicontrol(plotOptionsPanel,'Style','text',...
    'String',getMessageFromCatalog('PlotUnits'),...
    'BackgroundColor',backgroundColor,...
    'HorizontalAlignment','Left',...
    'units','characters','Position',[1,1,18,1]);%#ok<NASGU>

    unitsPopup=uicontrol(plotOptionsPanel,'Style','popupmenu',...
    'Tag','unitsPopup','String',unitStrings,...
    'Value',options.unit,...
    'BackgroundColor','white',...
    'units','characters','Position',[20,0.75,19,1.5]);

    okButton=uicontrol(guiHandle,'Style','pushbutton',...
    'String',getMessageFromCatalog('Ok'),'Tag','OK',...
    'units','characters','Position',[11,1.25,10,1.5]);

    cancelButton=uicontrol(guiHandle,'Style','pushbutton',...
    'String',getMessageFromCatalog('Cancel'),'Tag','Cancel',...
    'units','characters','Position',[24,1.25,10,1.5]);


    set(okButton,'Callback',@lOkCallback);
    set(cancelButton,'Callback',@lCancelCallback);
    set(timeCheck,'Callback',@lTimeCheckCallback);


    set(guiHandle,'Visible','on');
    set(axisOptionsPanel,'visible','on');
    set(plotOptionsPanel,'visible','on');
    movegui(guiHandle);

    function lTimeCheckCallback(hObject,evtData)%#ok<INUSD>


        isEnabled=get(hObject,'Value')==get(hObject,'Max');
        set(timeStartText,'Enable',lEnableString(isEnabled));
        set(timeStartEdit,'Enable',lEnableString(isEnabled));
        set(timeStopText,'Enable',lEnableString(isEnabled));
        set(timeStopEdit,'Enable',lEnableString(isEnabled));
    end

    function lOkCallback(hObject,evtData)%#ok<INUSD>



        options.time.limit=get(timeCheck,'Value');
        startTime=str2double(get(timeStartEdit,'String'));
        stopTime=str2double(get(timeStopEdit,'String'));

        options.link.x=get(linkXAxes,'Value');

        options.marker=get(markerPopup,'Value');
        options.multi=get(multiSelectPopup,'Value');
        options.align=get(axisAlignmentPopup,'Value');
        options.legend=get(legendPopup,'Value');
        options.unit=get(unitsPopup,'Value');
        errorDlgTitle=getMessageFromCatalog('OptionsError');


        if options.time.limit
            if~isnumeric(startTime)||...
                isempty(startTime)||isnan(startTime)
                errordlg(getMessageFromCatalog('InvalidStartTime'),...
                errorDlgTitle);
                return;
            end

            if~isnumeric(stopTime)||...
                isempty(stopTime)||isnan(stopTime)
                errordlg(getMessageFromCatalog('InvalidStopTime'),...
                errorDlgTitle);
                return;
            end

            if stopTime<=startTime
                errordlg(getMessageFromCatalog('IncorrectStopTime'),...
                errorDlgTitle);
                return;
            end


            options.time.start=startTime;
            options.time.stop=stopTime;

        end


        unitSel=unitStrings{options.unit};
        if strcmpi(unitSel,getMessageFromCatalog('PlotUnitsCustom'))
            msg=lGetCustomUnits;
            if~isempty(msg)
                errordlg(msg,errorDlgTitle);
                return;
            end
        end


        hf=get(guiHandle,'UserData');
        ud=get(hf,'UserData');

        ud.options=options;
        set(hf,'UserData',ud);


        close(guiHandle);


        lPlot(hFigure);

    end

    function lCancelCallback(hObject,evtData)%#ok<INUSD>



        close(guiHandle);
    end

end

function yMenu=lCreateUnitMenu(hFigure,label,paths)


    yMenu=uicontextmenu;
    unit=get(label,'String');
    optionUnits=pm_suggestunits(unit);
    ud=get(hFigure,'UserData');
    for i=1:numel(optionUnits)
        elem=optionUnits{i};
        uimenu(yMenu,'Label',elem,'Callback',@(varargin)lRegularCallback(hFigure,elem));
    end
    uimenu(yMenu,'Label',getMessageFromCatalog('PlotUnitsDefault'),'Callback',...
    @(varargin)lDefaultCallback(hFigure));
    uimenu(yMenu,'Label',getMessageFromCatalog('PlotUnitsSpecify'),'Callback',...
    @(varargin)lSpecifyCallback(hFigure,unit));

    function lRegularCallback(hFigure,newUnit)


        lUpdateUnitsPerNodeData(ud.options,paths,newUnit);
        lPlot(hFigure);
    end

    function lDefaultCallback(hFigure)


        lRemoveUnitsPerNodeData(ud.options,paths);
        lPlot(hFigure);
    end

    function lSpecifyCallback(hFigure,curUnit)



        dlgInput=inputdlg(getMessageFromCatalog('UnitsSpecify'));



        if(~isempty(dlgInput))
            specifiedUnit=char(dlgInput);

            if(pm_isunit(specifiedUnit))
                if(pm_commensurate(unit,specifiedUnit))
                    lUpdateUnitsPerNodeData(ud.options,paths,specifiedUnit);
                    lPlot(hFigure);
                else
                    errordlg(getMessageFromCatalog('NonCommensurateUnit',specifiedUnit,curUnit),...
                    getMessageFromCatalog('CommensurateUnitErrorTitle'));
                end
            else
                errordlg(getMessageFromCatalog('InvalidSpecifiedUnit',specifiedUnit),...
                getMessageFromCatalog('InvalidUnitErrorTitle'));
            end
        end
    end

end

function[m,markers]=lMarker(idx)


    markers={getMessageFromCatalog('PlotMarkerNone'),'.','*','o','+','^'};
    m=markers{idx};
end

function[multiSelectOptions,selection]=lGetMultiSelectOptions(idx)


    multiSelectOptions={getMessageFromCatalog('PlotOverlay'),...
    getMessageFromCatalog('PlotSeparate')};
    if nargin==0
        idx=1;
    end
    selection=multiSelectOptions{idx};
end

function[alignmentOptions,selection]=lGetAlignmentOptions(idx)


    alignmentOptions={getMessageFromCatalog('PlotVertical'),...
    getMessageFromCatalog('PlotHorizontal')};
    if nargin==0
        idx=1;
    end
    selection=alignmentOptions{idx};
end

function[legendOptions,selection]=lGetLegendOptions(idx)


    legendOptions={getMessageFromCatalog('PlotLegendAuto'),...
    getMessageFromCatalog('PlotLegendAlways'),...
    getMessageFromCatalog('PlotLegendNever')};
    if nargin==0
        idx=1;
    end
    selection=legendOptions{idx};
end

function[unitOptions,selection]=lGetUnitOptions(idx)


    unitOptions={getMessageFromCatalog('PlotUnitsDefault'),...
    getMessageFromCatalog('PlotUnitsSI'),...
    getMessageFromCatalog('PlotUnitsUSCustomary'),...
    getMessageFromCatalog('PlotUnitsCustom')};
    if nargin==0
        idx=1;
    end
    selection=unitOptions{idx};
end

function s=lEnableString(v)


    if v||strcmpi(v,'on')
        s='on';
    else
        s='off';
    end
end

function u=lGetOptionUnit(unit,option)



    u=unit;
    [~,unitSelection]=lGetUnitOptions(option);

    if~strcmpi(unitSelection,getMessageFromCatalog('PlotUnitsDefault'))
        [siUnits,usUnits]=lUnitDefinitions;
        switch unitSelection
        case getMessageFromCatalog('PlotUnitsSI')
            units=siUnits;
        case getMessageFromCatalog('PlotUnitsUSCustomary')
            units=usUnits;
        case getMessageFromCatalog('PlotUnitsCustom')
            [msg,units]=lGetCustomUnits;
            if~isempty(msg)
                w=warning('query','backtrace');
                warning('off','backtrace');
                c=onCleanup(@()(warning(w)));
                warning('physmod:common:logging:sli:dataexplorer:InvalidCustomUnits',...
                msg);
            end
        otherwise
        end
        units=lGetValidUnits(units,unitSelection);
        unitIdx=pm_directlyconvertible(unit,units);
        if any(unitIdx)
            u=units{unitIdx};
        end
    end

end

function u=lGetUnit(unit,path,options)

    path=simscape.logging.internal.indexedPathLabel(path);
    u=unit;
    if isKey(options.unitsPerNode,path)
        u=options.unitsPerNode(path);
    else
        if~strcmp(u,getMessageFromCatalog('Invalid'))
            u=lGetOptionUnit(u,options.unit);
        end
    end

end

function validUnits=lGetValidUnits(u,name)


    valid=pm_isunit(u);
    invalidUnits=u(~valid);
    validUnits=u(valid);
    if~isempty(invalidUnits)
        str=sprintf('''%s''',invalidUnits{1});
        for idx=2:numel(invalidUnits)
            str=sprintf('%s, ''%s''',str,invalidUnits{idx});
        end
        w=warning('query','backtrace');
        warning('off','backtrace');
        c=onCleanup(@()(warning(w)));
        warning('physmod:common:logging:sli:dataexplorer:InvalidUnitExpression',...
        [getMessageFromCatalog('InvalidUnitExpression',name),' \n%s\n'],str);
    end
end

function[yButtonX,yButtonY,btnWidth,btnHeight]=lGetUnitButtonPosition(hFigure,ax)


    yLabel=get(ax,'YLabel');
    btnHeight=13;
    btnWidth=13;
    btnMargin=1;

    figurePosition=lGetPropertyByUnits(hFigure,'Position','pixels');
    axPosition=lGetPropertyByUnits(ax,'Position','normalized');

    [yButtonX,yButtonY]=lCalculateUnitButtonPosition(hFigure,figurePosition,...
    axPosition,yLabel,btnWidth,btnHeight,btnMargin);

end

function[buttonX,buttonY]=lCalculateUnitButtonPosition(hFigure,figurePosition,...
    axPosition,label,btnWidth,btnHeight,btnMargin)



    labelExtent=lGetPropertyByUnits(label,'Extent','normalized');

    figureWidth=figurePosition(3);
    figureHeight=figurePosition(4);

    axXMargin=axPosition(1);
    axYMargin=axPosition(2);
    axWidth=axPosition(3);
    axHeight=axPosition(4);

    labelXMargin=labelExtent(1);
    labelYMargin=labelExtent(2);
    labelWidth=labelExtent(3);
    labelHeight=labelExtent(4);





    isDocked=strcmp('docked',get(hFigure,'WindowStyle'));

    if isDocked
        userData=get(hFigure,'UserData');
        leftMargin=userData.navPanel.getWidth;
        figureWidth=figureWidth-leftMargin;
    end

    if(get(label,'Rotation')==90)
        buttonX=axXMargin*figureWidth+(labelXMargin+labelWidth)*axWidth*figureWidth-btnWidth;
        buttonY=axYMargin*figureHeight+labelYMargin*axHeight*figureHeight-btnMargin-btnHeight;
    else
        buttonX=axXMargin*figureWidth+labelXMargin*axWidth*figureWidth-btnMargin-btnWidth;
        buttonY=axYMargin*figureHeight+(labelYMargin+labelHeight/2)*axHeight*figureHeight-btnHeight/2;
    end

end

function lShowContextMenuOnButton(hObject,uiContextMenu)




    if~exist('uiContextMenu','var')
        uiContextMenu=get(hObject,'uiContextMenu');
    end

    assert(~isempty(uiContextMenu),getMessageFromCatalog('ContextMenuNotFound'));

    hObjectPos=lGetPropertyByUnits(hObject,'Position','pixels');
    pos=hObjectPos(1:2);
    set(uiContextMenu,'Position',pos);
    set(uiContextMenu,'Visible','on');

end

function position=lGetPropertyByUnits(hObject,property,units)


    oldUnits=get(hObject,'Units');
    set(hObject,'Units',units);
    position=get(hObject,property);
    set(hObject,'Units',oldUnits);

end



function label=lSimulationStatisticsTreeLabel(~)

    label='SimulationStatistics (ZeroCrossings)';
end

function label=lZeroCrossingTreeLabel(node)

    assert(numel(node)==1);
    numCrossings=sum(node.crossings.series.values);
    switch numCrossings
    case 0
        label=sprintf('%s - no crossings',node.id);
    case 1
        label=sprintf('%s - 1 crossing',node.id);
    otherwise
        label=sprintf('%s - %d crossings',node.id,numCrossings);
    end
end


function[statusTitle,statusDesc,statusStats,statusTooltip,cbck]=...
    lSimulationStatisticsPrintStatus(simulationStatisticsNode)

    assert(numel(simulationStatisticsNode)==1,...
    'The simulation statistics node should be scalar');

    node=simulationStatisticsNode{1};
    statusTitle=getMessageFromCatalog('SelectedNodeStats');


    hasZCTag=@(n)lHasTagValue(n,'SimulationStatistics','ZeroCrossing');
    isZC=@(x)(hasZCTag(x{end}));

    loggedZeroCrossings=node.find(isZC);

    if~isempty(loggedZeroCrossings)
        numPoints=loggedZeroCrossings{1}.values.series.points;

        countCrossings=@(n)sum(n.crossings.series.values());
        numCrossings=sum(cellfun(countCrossings,loggedZeroCrossings));

    else
        numPoints=NaN;
        numCrossings=NaN;
    end

    [statusDesc,tooltipStr,cbck]=lPrintNodeId(node,'');
    statusStats=sprintf(['<html>%s<br/>'...
    ,'%s<br/>'...
    ,'%s</html>'],...
    getMessageFromCatalog('NumTimeSteps',num2str(numPoints)),...
    getMessageFromCatalog('NumLoggedZeroCrossings',num2str(numel(loggedZeroCrossings))),...
    getMessageFromCatalog('NumZeroCrossings',num2str(numCrossings)));

    statusTooltip=lGetStatusTooltipStr(tooltipStr,statusStats,statusTitle);

end

function[statusTitle,statusDesc,statusStats,statusTooltip,cbck]=...
    lZeroCrossingPrintStatus(zcNode)


    [statusTitle,statusDesc,statusStats,statusTooltip,cbck]=...
    lSimulationStatisticsPrintStatus(zcNode);
end

function[statusTitle,statusDesc,statusStats,statusTooltip,cbck]=...
    lZeroCrossingCrossingsPrintStatus(zcCrossingsNode)

    assert(numel(zcCrossingsNode)==1);

    node=zcCrossingsNode{1};
    statusTitle=getMessageFromCatalog('SelectedNodeStats');
    numPoints=node.series.points;
    numCrossings=sum(node.series.values());

    [statusDesc,tooltipStr,cbck]=lPrintNodeId(node,'');
    statusStats=sprintf(['<html>%s<br/>'...
    ,'%s</html>'],...
    getMessageFromCatalog('NumTimeSteps',num2str(numPoints)),...
    getMessageFromCatalog('NumZeroCrossings',num2str(numCrossings)));

    statusTooltip=lGetStatusTooltipStr(tooltipStr,statusStats,statusTitle);

end

function[statusTitle,statusDesc,statusStats,statusTooltip,cbck]=...
    lZeroCrossingValuesPrintStatus(zcValuesNode)


    assert(numel(zcValuesNode)==1);

    node=zcValuesNode{1};
    statusTitle=getMessageFromCatalog('SelectedNodeStats');
    numPoints=node.series.points;

    [statusDesc,tooltipStr,cbck]=lPrintNodeId(node,'');
    statusStats=sprintf('<html>%s</html>',...
    getMessageFromCatalog('NumTimeSteps',num2str(numPoints)));

    statusTooltip=lGetStatusTooltipStr(tooltipStr,statusStats,statusTitle);

end

function[str,tip,cbck]=lZeroCrossingPrintLocation(node)


    assert(numel(node)==1);

    str='';
    tip='';
    cbck='';

    key='ZeroCrossingLocation';
    if node.hasTag(key)
        tag=node.getTag(key);
        fileLocation=tag{2};
        if~isempty(fileLocation)
            tokens=textscan(fileLocation,'%s%d%d','Delimiter',',');
            fileName=tokens{1}{1};
            fileRow=tokens{2};
            fileCol=tokens{3};

            if exist(which(fileName),'file')
                str=sprintf('<html>%s<a href="%s">%s</a></html>',...
                getMessageFromCatalog('ZeroCrossingLocation',''),fileName,fileName);
                cbck=@(src)opentoline(which(fileName),fileRow,fileCol);
            else
                str=sprintf('<html>%s</html>',...
                getMessageFromCatalog('ZeroCrossingLocation',fileName));
                cbck='';
            end

        else
            str=sprintf('<html>%s</html>',...
            getMessageFromCatalog('ZeroCrossingLocation',getMessageFromCatalog('ZeroCrossingLocationUnAvailable')));
            cbck='';
        end

        key='ZeroCrossingLocationMessage';
        if node.hasTag(key)
            tag=node.getTag(key);
            fullLocation=strrep(tag{2},'|','<br/>');
            tip=sprintf('<html>%s</html>',fullLocation);
        end
    end
end

function[nodesToPlot,pathsToPlot,labelsToPlot,optionsToPlot]=...
    lSimulationStatisticsNodesToPlot(nodes,paths,labels,options)

    assert(numel(nodes)==1);

    nodesToPlot=nodes;
    pathsToPlot=paths;
    labelsToPlot=labels;

    optionsToPlot=options;

    optionsToPlot.multi=1;
    optionsToPlot.legend=3;

end

function[nodesToPlot,pathsToPlot,labelsToPlot,optionsToPlot]=...
    lZeroCrossingNodesToPlot(nodes,paths,~,options)

    assert(numel(nodes)==1);
    node=nodes{1};
    assert(numel(node)==1);
    assert(numel(paths)==1);
    path=paths{1};
    nodesToPlot={node.crossings,node.values};
    pathsToPlot={[path,{'crossings'}],[path,{'values'}]};
    labelsToPlot={'crossings','values'};

    optionsToPlot=options;

    optionsToPlot.multi=1;
    optionsToPlot.legend=3;

end

function[tt,vv]=lPrepareCrossingDataForCumulativePlot(t,v)

    idx=find(v>0);
    tstep=[t(1);(1-eps)*t(idx);t(idx)];
    vstep=[v(1);zeros(size(idx));v(idx)];
    [tt,idx]=sort(tstep);
    vv=cumsum(vstep(idx));
    vv=[vv(:);vv(end)]';
    tt=[tt(:);t(end)]';
end

function lPlotSimulationStatistics(nodes,ax,options,~,~,~)

    if~iscell(nodes)
        nodes={nodes};
    end
    assert(numel(nodes)==1);
    statisticsNode=nodes{1};

    zcNodeIds=simscape.logging.internal.sortChildIds(statisticsNode);

    time=[];values=[];
    for i=1:numel(zcNodeIds)
        zcNodes=statisticsNode.child(zcNodeIds{i});
        crossingNode=zcNodes(1).crossings;
        if isempty(time)
            time=crossingNode.series.time;
        end
        if isempty(values)
            values=crossingNode.series.values;
        else


            values=[values,crossingNode.series.values];%#ok<AGROW>
        end
    end

    values=sum(values,2);


    [t,v]=lPrepareCrossingDataForCumulativePlot(time,values);


    plot(ax,t,v,'Marker','x');


    title(ax,'SimulationStatistics (ZeroCrossings)','Interpreter','none');
    xlabel(ax,getMessageFromCatalog('XAxisTime'),'Interpreter','none');
    ylabel(ax,getMessageFromCatalog('YAxisAllCrossings'),'Interpreter','none');
    grid(ax,'on');


    if options.time.limit
        set(ax,'XLim',[options.time.start,options.time.stop]);
    end

end

function lPlotZCSignal(ax,nodes,paths,labels,options,marker,ylab,dataFcn)

    if~iscell(nodes)
        nodes={nodes};
    end

    colors=get(gca,'ColorOrder');
    numColors=size(colors,1);
    for i=1:numel(nodes)
        node=nodes{i};
        assert(numel(node)==1);

        [t,v]=dataFcn(node.series.time,node.series.values);
        colorIdx=1+mod(i-1,numColors);
        plot(ax,t,v,'Marker',marker,'Color',colors(colorIdx,:));
        hold(ax,'on');
    end
    hold(ax,'off');


    [~,legendSelection]=lGetLegendOptions(options.legend);
    legendEntries=cell(size(paths));
    for idx=1:numel(paths)
        legendEntries{idx}=simscape.logging.internal.indexedPathLabel(paths{idx});
    end

    legendEntries=strrep(strrep(strrep(legendEntries,...
    '.SimulationStatistics',''),...
    '.values',''),...
    '.crossings','');

    switch legendSelection
    case{getMessageFromCatalog('PlotLegendAuto'),getMessageFromCatalog('PlotLegendAlways')}
        if~isempty(legendEntries)&&~isempty(get(ax,'Children'))
            legend(legendEntries,'Interpreter','none');
        end
    case getMessageFromCatalog('PlotLegendNever')

    end


    title(ax,'SimulationStatistics (ZeroCrossings)','Interpreter','none');
    xlabel(ax,getMessageFromCatalog('XAxisTime'),'Interpreter','none');
    ylabel(ax,ylab,'Interpreter','none');
    grid(ax,'on');


    if options.time.limit
        set(ax,'XLim',[options.time.start,options.time.stop]);
    end

end

function lPlotSignalCrossings(nodes,ax,options,~,paths,labels)

    marker=lMarker(options.marker);
    if strcmpi(marker,getMessageFromCatalog('PlotMarkerNone'))
        marker='x';
    end
    lPlotZCSignal(ax,nodes,paths,labels,options,marker,...
    getMessageFromCatalog('YAxisCrossings'),...
    @lPrepareCrossingDataForCumulativePlot);
end

function lPlotSignalValues(nodes,ax,options,~,paths,labels)

    marker=lMarker(options.marker);
    lPlotZCSignal(ax,nodes,paths,labels,options,marker,...
    getMessageFromCatalog('YAxisValues'),@deal);
end

function res=lGetNodeDisplayOption(node,name,default)

    persistent DATA_MAP
    if isempty(DATA_MAP)

        iconDir=[matlabroot,'/toolbox/physmod/common/logging/sli/m/resources/icons/'];
        if exist(iconDir,'dir')
            icons.statistics=[iconDir,'statistics.png'];
            icons.zeroCrossing=[iconDir,'zero_crossing.png'];
            icons.signalCrossings=[iconDir,'zc_crossings.png'];
            icons.signalValues=[iconDir,'zc_values.png'];
        else
            iconDir=[matlabroot,'/toolbox/matlab/icons/'];
            icons.statistics=[iconDir,'profiler.gif'];
            icons.zeroCrossing=[iconDir,'pageicon.gif'];
            icons.signalCrossings=[iconDir,'greenarrowicon.gif'];
            icons.signalValues=[iconDir,'greenarrowicon.gif'];
        end


        DATA_MAP={...
        {'SimulationStatistics','Statistics',...
        struct('TreeNodeIcon',icons.statistics,...
        'TreeNodeLabelFcn',@lSimulationStatisticsTreeLabel,...
        'PrintStatusFcn',@lSimulationStatisticsPrintStatus,...
        'PrintLocationFcn','',...
        'IsPlottedByParent',true,...
        'GetNodesToPlotFcn',@lSimulationStatisticsNodesToPlot,...
        'PlotNodeFcn',@lPlotSimulationStatistics)
        },...
        {'SimulationStatistics','ZeroCrossing',...
        struct('TreeNodeIcon',icons.zeroCrossing,...
        'TreeNodeLabelFcn',@lZeroCrossingTreeLabel,...
        'PrintStatusFcn',@lZeroCrossingPrintStatus,...
        'PrintLocationFcn',@lZeroCrossingPrintLocation,...
        'IsPlottedByParent',false,...
        'GetNodesToPlotFcn',@lZeroCrossingNodesToPlot,...
        'PlotNodeFcn','')
        },...
        {'ZeroCrossing','SignalCrossings',...
        struct('TreeNodeIcon',icons.signalCrossings,...
        'TreeNodeLabelFcn','',...
        'PrintStatusFcn',@lZeroCrossingCrossingsPrintStatus,...
        'PrintLocationFcn','',...
        'IsPlottedByParent',true,...
        'GetNodesToPlotFcn','',...
        'PlotNodeFcn',@lPlotSignalCrossings)
        },...
        {'ZeroCrossing','SignalValues',...
        struct('TreeNodeIcon',icons.signalValues,...
        'TreeNodeLabelFcn','',...
        'PrintStatusFcn',@lZeroCrossingValuesPrintStatus,...
        'PrintLocationFcn','',...
        'IsPlottedByParent',true,...
        'GetNodesToPlotFcn','',...
        'PlotNodeFcn',@lPlotSignalValues)
        }
        };
    end

    res=default;
    for i=1:numel(DATA_MAP)
        mapEntry=DATA_MAP{i};
        if lHasTagValue(node,mapEntry{1},mapEntry{2})
            res=mapEntry{3}.(name);
            if isempty(res)
                res=default;
            end
            break;
        end
    end

end

function[errorMsg,customUnits]=lGetCustomUnits()



    customUnits={};
    errorMsg='';
    fileName='ssc_customlogunits';


    if exist(fileName,'file')
        try
            u=ssc_customlogunits;


            if iscell(u)&&all(pm_isunit(u))
                customUnits=u;
            else
                errorMsg=pm_message('physmod:common:logging:sli:dataexplorer:InvalidCustomUnits',...
                fileName,fileName);
            end
        catch
            errorMsg=pm_message('physmod:common:logging:sli:dataexplorer:InvalidCustomUnits',...
            fileName,fileName);
        end
    end

end


function[siUnits,usUnits]=lUnitDefinitions()


    siUnits={'m/s','N','m','rad/s','rad','N*m','Pa','m^3/s','kg/s',...
    'm^3','m^2/s','K','J','W','J/kg','J/(kg*K)','W/(m*K)',...
    'W/(m^2*K)','kg/m^3','1/K','rad/s^2','m^2','m/s^2'};


    usUnits={'ft/s','lbf','ft','rpm','rev','lbf*ft','psi','gpm','lbm/s',...
    'gal','cSt','Fh','Btu','Btu/hr','Btu/lbm','Btu/(lbm*R)','Btu/(hr*ft*R)',...
    'Btu/(hr*ft^2*R)','lbm/ft^3','1/R','rev/s^2','in^2','ft/s^2'};

end

function a=get_path(uitree,node,p)

    p=textscan(p,'%s','delimiter','.');
    p=p{:};

    a=cell(1,numel(p));
    tree=uitree;
    n=node;
    for idx=1:numel(p)
        z=getChild(tree,n,p{idx});
        a(idx)=z;
        n=n.node(p{idx});
        tree=z;
    end
end

function c=getChild(tree,node,id)
    s=simscape.logging.internal.sortChildIds(node);
    jdx=find(strcmp(s,id));
    c=tree.getChildAt(jdx-1);
end

function valid=lIsFigureHandleValid(hFigure)


    if isempty(hFigure)||~(hFigure.isvalid)
        valid=false;
    else
        valid=true;
    end
end

function lSetFigureHandleVisibility(hFigure,hv)
    if lIsFigureHandleValid(hFigure)
        set(hFigure,'HandleVisibility',hv);
    end
end

function[nodeDesc,statusToolTip]=lGetNodeDescription(node,isLink)

    dimension=mat2str(size(node));

    if numel(node)>1
        nodeDescription=node.id;
        node=node(1);
    else
        nodeDescription=node.getDescription;
    end

    if isempty(nodeDescription)
        nodeDescription=node.getName;
        nodeTruncatedDesc=node.getName;
    else




        maxSize=35;
        if numel(nodeDescription)>maxSize
            nodeTruncatedDesc=[nodeDescription(1:maxSize),' '...
            ,getMessageFromCatalog('VariableDescriptionEllipsis')];
        else
            nodeTruncatedDesc=nodeDescription;
        end
    end

    conversion=node.series.conversion;

    descriptionMsg=getMessageFromCatalog('VariableDescription');
    conversionMsg=getMessageFromCatalog('UnitConversion',conversion);

    if~isempty(node.getDescription)
        if isLink
            nodeDesc=sprintf(['<html>%s <a href="%s">%s</a><br/>'...
            ,'%s<br/></html>'],...
            descriptionMsg,nodeTruncatedDesc,nodeTruncatedDesc,...
            conversionMsg);
            statusToolTip=sprintf(['<html>%s <a href="%s">%s</a><br/>'...
            ,'%s<br/></html>'],...
            descriptionMsg,nodeDescription,nodeDescription,...
            conversionMsg);
        else
            nodeDesc=sprintf(['<html>%s %s<br/>'...
            ,'%s<br/></html>'],...
            descriptionMsg,nodeTruncatedDesc,...
            conversionMsg);
            statusToolTip=sprintf(['<html>%s "%s"<br/>'...
            ,'%s<br/></html>'],...
            descriptionMsg,nodeDescription,...
            conversionMsg);
        end
    else

        dimensionMsg=getMessageFromCatalog('NodeDimension');
        dimensionMsg=[dimensionMsg,dimension];
        if isLink
            nodeDesc=sprintf('<html>%s <a href="%s">%s</a><br/>%s<br/></html>',...
            descriptionMsg,nodeTruncatedDesc,nodeTruncatedDesc,dimensionMsg);
            statusToolTip=sprintf('<html>%s <a href="%s">%s</a><br/>%s<br/></html>',...
            descriptionMsg,nodeDescription,nodeDescription,dimensionMsg);
        else
            nodeDesc=sprintf('<html>%s %s<br/>%s<br/></html>',...
            descriptionMsg,nodeTruncatedDesc,dimensionMsg);
            statusToolTip=sprintf('<html>%s "%s"<br/>%s<br/></html>',...
            descriptionMsg,nodeDescription,dimensionMsg);
        end
    end

end

function statusStr=lGetStatusTooltipStr(nodeDisplayStr,statusTxt,title)


    statusStr=sprintf(['<html>%s<br/>',nodeDisplayStr,statusTxt],title);

end


function lUpdateStatusLabelText(src,node,stats,title,isLink)



    assert(numel(node)==1);

    [~,tooltipStr]=lGetNodeDescription(node,isLink);
    baseFreq=node.series.baseFrequency();
    if~isempty(stats)
        statusStats=lGetStatusStatsText(stats,baseFreq);
        tooltipStr=lGetStatusTooltipStr(tooltipStr,lGetStatusStatsText(stats,baseFreq),title);
    else
        printStatusFcn=lGetNodeDisplayOption(node,'PrintStatusFcn',@lPrintStatus);
        statusStats=printStatusFcn({node});
        tooltipStr=statusStats;
    end

    src.setText(statusStats);
    src.setToolTipText(tooltipStr);

end
