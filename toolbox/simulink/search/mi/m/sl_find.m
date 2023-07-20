function varargout=sl_find(varargin)








    utils.ScopedInstrumentation("sl_find::main");

    utils.ScopedWarningsSuppressor();

    Action=varargin{1};
    args=varargin(2:end);

    switch(Action)

    case 'RegisterObjects'
        varargout{1}=i_RegisterObjects;

    case 'RegisterProperties'
        varargout{1}=i_RegisterProperties;

    case 'FindObjects'
        i_FindObjects(args{:});

    case 'SelectObjects'
        varargout{1}=i_SelectObjects(args{:});

    case 'DeselectObjects'
        i_DeselectObjects(args{:});

    case 'OpenObjects'
        i_OpenObjects(args{:});

    case 'ContextMenu'
        i_ExecuteContextMenu(args{1},args{2});

    case 'UpdatePropertyInspector'
        i_UpdatePropInspector(args{:});

    case 'RemoveResultsMarkedStyle'
        i_removeAllMarkedStyle(args{:});

    end
end


function objList=i_RegisterObjects


    objList={'Simulink objects',...
    'Annotations',...
    'Blocks',...
    'Signals'};
end


function propList=i_RegisterProperties


    propList={'Name',...
    'Tag',...
    'BlockDialogParams',...
    'Description',...
    'BlockDescription',...
    'MaskDescription',...
    'BlockType',...
    'MaskType',...
    'LinkStatus',...
    'TestPoint'};
end



function searchFields=i_getDefaultSearchFields()
    searchFields={'Name','Description'};
end


function slStyledObject=i_SelectObjects(slHandles,otherParam)
    utils.ScopedInstrumentation("sl_find::i_SelectObjects");


    slStyledObject=struct('slDiagramObjs',[]);

    if all(isfield(otherParam,{'editor','highlightType','viewMode','studioTag'}))
        handles=slHandles;
        editor=otherParam.editor;
        highlightType=otherParam.highlightType;
        viewMode=otherParam.viewMode;
        studioTag=otherParam.studioTag;

        if strcmpi(highlightType,'markObject')
            slStyledObject=markObject(handles,editor,viewMode,studioTag);
        else

            i_UpdatePropInspector(editor,handles);

            highlightObject(handles,editor,viewMode,studioTag);
        end
    end
end


function i_DeselectObjects(varargin)
    utils.ScopedInstrumentation("sl_find::i_DeselectObjects");

    objH=varargin{1};
    systemList=varargin{2};
    highlightType=varargin{3};
    studioTag=varargin{5};

    if~strcmpi(highlightType,'markObject')
        removeHighlight(objH,systemList,studioTag);
    end
end




function highlightObject(objectHandle,editor,viewMode,studioTag)
    utils.ScopedInstrumentation("sl_find::highlightObject");

    stylerName='Mathworks.Finder.matchedObject';
    styler=diagram.style.getStyler(stylerName);

    if(isempty(styler))
        diagram.style.createStyler(stylerName,3000);
        styler=diagram.style.getStyler(stylerName);


        highlightColor=diagram.style.Style;
        stroke=MG2.Stroke;
        stroke.Color=[1,0.933,0,1];
        stroke.Width=6;
        stroke.CapStyle='FlatCap';
        stroke.JoinStyle='RoundJoin';
        stroke.ScaleFunction='SelectionNonLinear';
        highlightColor.set('Trace',MG2.TraceEffect(stroke,'Outer'));
        shadow=MG2.ShadowEffect(1.0,5,[8,8],false);
        shadow.Color=[0.5,0.3,0];
        highlightColor.set('Shadow',shadow);
        styler.addRule(highlightColor,diagram.style.ClassSelector('highlightSelected'));


        selectionBlockHighlighter=diagram.style.Style;
        selectionBlockHighlighter.set('StrokeColor',[0.722,0.839,0.996,0.8]);
        selectionBlockHighlighter.set('StrokeWidth',3);
        selectionModifierSelector=diagram.style.MultiSelector({'MathWorks.GLUE2Styler:Selected','highlightSelected'},{'Editor'});
        styler.addRule(selectionBlockHighlighter,selectionModifierSelector);
    end

    objH=objectHandle;
    type=get_param(objectHandle,'Type');
    if strcmpi(type,'port')
        objH=get_param(objectHandle,'line');
    end


    obj=diagram.resolver.resolve(objH);
    if(strcmp(obj.type,'Segment'))
        obj=obj.getParent();
    end


    styleName=MG2.TextSearchHighlightStyleName;
    textSearchHighlightStyler=diagram.style.getStyler(styleName);
    if~isempty(textSearchHighlightStyler)

        textSearchHighlightStyler.removeClass(obj,['SimulinkFind.currentSelected.',studioTag]);
        textSearchHighlightStyler.applyClass(obj,['SimulinkFind.currentSelected.',studioTag]);
    end


    if styler.hasClass(obj,'highlightSelected')
        return;
    end


    styler.applyClass(obj,'highlightSelected');



    if strcmpi(viewMode,'lightView')
        Simulink.scrollToVisible(objH,'ensureFit','off','panMode','minimal');
    end

    blockSFObjType={'Stateflow.Chart','Stateflow.TruthTableChart',...
    'Stateflow.StateTransitionTableChart','Stateflow.ReactiveTestingTableChart'};
    parentName=get_param(objH,'parent');
    parentChain=slprivate('systems2print',parentName,'CurrentSystemAndAbove',0,0);
    if~isempty(parentChain)
        for idx=2:length(parentChain)
            currentObj=parentChain(idx);


            if isSimulinkObj(currentObj)


                sfObj=Stateflow.SLUtils.getStateflowUddH(currentObj);
                if isempty(sfObj)
                    currentObjHandle=currentObj.handle;
                else
                    currentObjHandle=sfObj.Id;
                end
                styler.applyClass(currentObjHandle,'highlightSelected');
            else
                if any(strcmp(blockSFObjType,currentObj.getDisplayClass()))
                    currentObjHandle=get_param(currentObj.Path,'Handle');
                    styler.applyClass(currentObjHandle,'highlightSelected');
                else
                    currentObjHandle=currentObj.Id;
                    if isprop(currentObj,'IsSubchart')
                        if currentObj.IsSubchart
                            styler.applyClass(currentObjHandle,'highlightSelected');
                        end
                    end
                end

            end
        end
    end
end



function removeHighlight(varargin)
    utils.ScopedInstrumentation("sl_find::removeHighlight");

    stylerName='Mathworks.Finder.matchedObject';
    styler=diagram.style.getStyler(stylerName);

    objH=varargin{1};
    systemList=varargin{2};
    studioTag=varargin{3};

    try

        type=get_param(objH,'Type');
        if strcmpi(type,'port')
            objH=get_param(objH,'line');
        end


        obj=diagram.resolver.resolve(objH);
        if(strcmp(obj.type,'Segment'))
            obj=obj.getParent();
        end
        styler.removeClass(obj,'highlightSelected');


        styleName=MG2.TextSearchHighlightStyleName;
        textSearchHighlightStyler=diagram.style.getStyler(styleName);
        if~isempty(textSearchHighlightStyler)
            textSearchHighlightStyler.removeClass(obj,['SimulinkFind.currentSelected.',studioTag]);
        end


        blockSFObjType={'Stateflow.Chart','Stateflow.TruthTableChart',...
        'Stateflow.StateTransitionTableChart','Stateflow.ReactiveTestingTableChart'};
        parentName=get_param(objH,'parent');
        parentChain=slprivate('systems2print',parentName,'CurrentSystemAndAbove',0,0);
        if~isempty(parentChain)
            for idx=2:length(parentChain)
                currentObj=parentChain(idx);


                if isSimulinkObj(currentObj)
                    sfObj=Stateflow.SLUtils.getStateflowUddH(currentObj);
                    if isempty(sfObj)
                        currentObjHandle=currentObj.handle;
                    else
                        currentObjHandle=sfObj.Id;
                    end
                    styler.removeClass(currentObjHandle,'highlightSelected');
                else
                    if any(strcmp(blockSFObjType,currentObj.getDisplayClass()))
                        currentObjHandle=get_param(currentObj.Path,'Handle');
                        styler.removeClass(currentObjHandle,'highlightSelected');
                    else
                        currentObjHandle=currentObj.Id;
                        if isprop(currentObj,'IsSubchart')
                            if currentObj.IsSubchart
                                styler.removeClass(currentObjHandle,'highlightSelected');
                            end
                        end
                    end

                end
            end
        end
    catch


        for idx=1:length(systemList)
            rootSysH=get_param(systemList{idx},'Handle');
            obj=diagram.resolver.resolve(rootSysH);
            if~isempty(styler)
                styler.clearChildrenClasses('highlightSelected',obj);
            end


            styleName=MG2.TextSearchHighlightStyleName;
            textSearchHighlightStyler=diagram.style.getStyler(styleName);
            if~isempty(textSearchHighlightStyler)
                textSearchHighlightStyler.clearChildrenClasses(['SimulinkFind.currentSelected.',studioTag],obj);
            end
        end
    end
end



function isSimulink=isSimulinkObj(obj)
    className=obj.getDisplayClass();
    isSimulink=~contains(className,'Stateflow');
end




function slStyledObject=markObject(varargin)

    stylerName='Mathworks.Finder.markObject';
    styler=diagram.style.getStyler(stylerName);

    if(isempty(styler))
        diagram.style.createStyler(stylerName,2900);
        styler=diagram.style.getStyler(stylerName);


        highlightColor=diagram.style.Style;
        stroke=MG2.Stroke;
        stroke.Color=[1,0.933,0,0.35];
        stroke.Width=5;
        stroke.CapStyle='FlatCap';
        stroke.JoinStyle='RoundJoin';
        stroke.ScaleFunction='SelectionNonLinear';
        highlightColor.set('Trace',MG2.TraceEffect(stroke,'Outer'));
        styler.addRule(highlightColor,diagram.style.ClassSelector('finderMarkResult'));


        selectionBlockHighlighter=diagram.style.Style;
        selectionBlockHighlighter.set('StrokeColor',[0.722,0.839,0.996,0.8]);
        selectionBlockHighlighter.set('StrokeWidth',3);
        selectionModifierSelector=diagram.style.MultiSelector({'MathWorks.GLUE2Styler:Selected','finderMarkResult'},{'Editor'});
        styler.addRule(selectionBlockHighlighter,selectionModifierSelector);
    end




    objHandles=varargin{1};
    objNum=length(objHandles);
    if objNum>0
        slDiagramObjs=cell(1,objNum);
        for idx=1:objNum
            objH=objHandles(idx);

            type=get_param(objH,'Type');
            if strcmpi(type,'port')
                objH=get_param(objH,'line');
            end

            diagramObj=diagram.resolver.resolve(objH);
            if(strcmp(diagramObj.type,'Segment'))
                diagramObj=diagramObj.getParent();
            end
            slDiagramObjs{1,idx}=diagramObj;
        end


        styler.applyClass(slDiagramObjs,'finderMarkResult');


        if length(varargin)>3
            studioTag=varargin{4};
            styleName=MG2.TextSearchHighlightStyleName;
            textSearchHighlightStyler=diagram.style.getStyler(styleName);
            if~isempty(textSearchHighlightStyler)
                textSearchHighlightStyler.applyClass(slDiagramObjs,['SimulinkFind.otherResults.',studioTag]);
            end

        end

    else
        slDiagramObjs={};
    end

    slStyledObject.slDiagramObjs=slDiagramObjs;

end



function i_removeAllMarkedStyle(styledObjList,studioTag)


    slStylerName='Mathworks.Finder.markObject';
    slStyler=diagram.style.getStyler(slStylerName);

    if~isempty(slStyler)&&isfield(styledObjList,'slDiagramObjs')
        slObjList=[styledObjList.slDiagramObjs];
        if~isempty(slObjList)
            slStyler.removeClass(slObjList,'finderMarkResult');


            styleName=MG2.TextSearchHighlightStyleName;
            textSearchHighlightStyler=diagram.style.getStyler(styleName);
            if~isempty(textSearchHighlightStyler)
                textSearchHighlightStyler.removeClass(slObjList,['SimulinkFind.otherResults.',studioTag]);
            end

        end
    end
end


function i_OpenObjects(varargin)
    utils.ScopedInstrumentation("sl_find::i_OpenObjects");
    H=varargin{1};
    studioTag=varargin{2};
    modelsToBlocksMap=varargin{3};


    activeStudio=DAS.Studio.getStudio(studioTag);
    activeEditor=activeStudio.App.getActiveEditor();
    activeEditor.clearSelection();


    objType=get_param(H,'Type');
    handle=H;


    parent=get_param(H,'Parent');
    if strcmp(objType,'port')==1

        parent=get_param(parent,'Parent');
    end

    editorHandle=SLM3I.HierarchyServiceUtils.getHandle(activeEditor.getHierarchyId);
    parentHandle=get_param(parent,'Handle');
    if(editorHandle~=parentHandle)


        i_PrecheckAndOpenParent(parent,modelsToBlocksMap);
    end


    switch(objType)

    case 'block'


        activeEditor=activeStudio.App.getActiveEditor();
        if~activeEditor.isLocked()
            set_param(parent,'CurrentBlock',H);
        end

    case 'port'
        handle=get_param(H,'Line');
    end


    activeEditor=activeStudio.App.getActiveEditor();
    activeEditor.clearSelection();
    set_param(handle,'Selected','on');
    Simulink.scrollToVisible(handle,'ensureFit','off','panMode','minimal');

end



function i_PrecheckAndOpenParent(inModelPath,modelsToBlocksMap)




    try


        if strcmp(get_param(inModelPath,'Type'),'block_diagram')
            blockPaths={};
            rootModel=inModelPath;
        else
            blockPaths={inModelPath};
            rootModel=bdroot(inModelPath);
        end
        while(modelsToBlocksMap.isKey(rootModel))
            parentPath=modelsToBlocksMap(rootModel);

            blockPaths{end+1}=parentPath;
            rootModel=bdroot(parentPath);
        end
        blockPaths=flip(blockPaths);





        if isempty(blockPaths)
            bp=Simulink.BlockPath(inModelPath);
        else
            bp=Simulink.BlockPath(blockPaths);
        end



        blockFullPath=bp.getBlock(bp.getLength());
        needForceOpen=(hasmask(blockFullPath)==2)||(hasmask(blockFullPath)==1&&~hasmaskdlg(blockFullPath));

        bp.validate();
        bp.open('Force',needForceOpen);
    catch ME



        needForceOpen=(hasmask(inModelPath)==2)||(hasmask(inModelPath)==1&&~hasmaskdlg(inModelPath));
        if needForceOpen
            open_system(inModelPath,'force');
        else
            open_system(inModelPath);
        end
    end
end


function i_ExecuteContextMenu(H,type)

    utils.ScopedInstrumentation("sl_find::i_ExecuteContextMenu");
    switch(get_param(H,'Type'))
    case 'block'

        if strncmpi(type,'Prop',4)
            open_system(H,'property');
        elseif strncmpi(type,'Param',5)&&...
            isempty(get_param(H,'OpenFcn'))&&...
            ~hasmaskdlg(H)
            open_system(H,'parameter');
        else
            open_system(H);
        end

    case 'port'
        dlgH=i_FindOpenDDGDialog(H);
        if isempty(dlgH)
            portObj=get_param(H,'Object');
            DAStudio.Dialog(portObj);
        else
            awtinvoke(dlgH,'show()');
            dlgH.showNormal;
        end

    end
end



function i_UpdatePropInspector(varargin)
    utils.ScopedInstrumentation("sl_find::i_UpdatePropInspector");
    editor=varargin{1};
    if length(varargin)>1
        objH=varargin{2};
    else

        selectList=editor.getSelection();
        size=selectList.size();
        if size>0
            primarySelection=selectList.at(size);
            objH=primarySelection.handle;
        else
            editorName=getSystemNameFromEditor(editor);
            objH=get_param(editorName,'Handle');
        end
    end


    studio=editor.getStudio();
    propInspector=studio.getComponent('GLUE2:PropertyInspector','Property Inspector');


    if~isempty(propInspector)
        objType=get_param(objH,'Type');
        if strcmpi(objType,'port')
            lineH=get_param(objH,'Line');
            objType=get_param(lineH,'Type');
            segObj=get_param(lineH,'Object');
            obj=segObj.getLine();
        else
            obj=get_param(objH,'Object');
        end
        propInspector.updateSource(objType,obj);
    end
end






function dlgH=i_FindOpenDDGDialog(PortHandle)
    utils.ScopedInstrumentation("sl_find::i_FindOpenDDGDialog");
    dlgH=[];

    if~ishandle(PortHandle)
        return;
    end




    dialogTag=strcat('Port Properties: ',num2str(PortHandle,16));

    try
        tr=DAStudio.ToolRoot;
        dlgList=tr.getOpenDialogs;
        for i=1:length(dlgList)
            dlg=dlgList(i);
            if strcmp(dlg.dialogTag,dialogTag)

                dlgH=dlg;
                break;
            end
        end
    catch
        dlgH=[];
    end
end



function simulinkSysH=getSimulinkSystem(systemName)
    utils.ScopedInstrumentation("sl_find::getSimulinkSystem");
    isStateflow=true;
    simulinkSys=systemName;
    while isStateflow
        if~isempty(systemName)
            try
                simulinkSysH=get_param(simulinkSys,'Handle');
                isStateflow=false;
            catch
                objNames=strsplit(simulinkSys,'/');
                systemName=objNames{end};
                simulinkSys=simulinkSys(1:(length(simulinkSys)-length(systemName)-1));
                isStateflow=true;
            end
        else
            simulinkSysH=0;
            isStateflow=false;
        end
    end
end





function sysName=getSystemNameFromEditor(activeEditor)
    utils.ScopedInstrumentation("sl_find::getSystemNameFromEditor");
    diag=activeEditor.getDiagram;
    if(isa(diag,'InterfaceEditor.Diagram'))
        model=diag.Model;
        slobj=get_param(model.SLGraphHandle,'Object');
        sysName=slobj.getFullName();
    else
        sysName=activeEditor.getName();
    end
end





function validBlockH=deleteChartBlock(blockH)
    utils.ScopedInstrumentation("sl_find::deleteChartBlock");
    validBlockH=blockH;
    for handle=blockH'
        if strcmp(get_param(handle,'BlockType'),'SubSystem')
            chartId=sfprivate('block2chart',handle);
            if chartId>0
                chartObj=sf('IdToHandle',chartId);
                if~isempty(chartObj)&&isa(chartObj,'Stateflow.Chart')
                    validBlockH(validBlockH==handle)=[];
                end
            end
        end
    end
end



function validBlockH=filterWebBlockFromMaskedSystem(blockH)
    utils.ScopedInstrumentation("sl_find::filterWebBlockFromMaskedSystem");
    validBlockH=blockH;

    for idx=1:length(blockH)
        handle=blockH(idx);
        if strcmp(get_param(handle,'BlockType'),'SubSystem')
            if strcmp(get_param(handle,'IsWebBlock'),'on')
                validBlockH(idx)=0;
            end
        end
    end
    validBlockH(validBlockH==0)=[];
end





function validBlockH=filterHiddenWebBlocks(blockH)
    utils.ScopedInstrumentation("sl_find::filterHiddenWebBlocks");
    validBlockH=blockH;

    for idx=1:length(blockH)
        handle=blockH(idx);
        tag=get_param(handle,'Tag');
        if(~isempty(tag))
            if strcmp(tag,'HiddenForWebPanel')
                validBlockH(idx)=0;
            end
        end
    end
    validBlockH(validBlockH==0)=[];
end


function funcList=i_getFunctionList(value,caseInsensitive)

    funcList={};
    if~isempty(value)
        value=regexprep(value,'''','''''');
        if caseInsensitive
            functionStr=['@(property) (~isempty(regexp(property, ''',value,''',''ignorecase'')))'];
        else
            functionStr=['@(property) (~isempty(regexp(property, ''',value,''',''once'')))'];
        end
        funcList{1}=str2func(functionStr);
    end
end




function mFuncBlock=getMatlabFunctionBlock(varargin)
    utils.ScopedInstrumentation("sl_find::getMatlabFunctionBlock");
    propValues={};


    if find(strcmp('SearchDepth',varargin))
        simpleLoc=12;
        propValues=[propValues,'-depth',1];
    else
        simpleLoc=10;
    end


    caseSensitiveLoc=find(strcmp('CaseSensitive',varargin));
    caseInsensitive=strcmp(varargin{caseSensitiveLoc+1},'off');


    if length(varargin)==simpleLoc
        searchString='';
    elseif strncmp(varargin{simpleLoc},'Simple',6)
        searchStrInfo=varargin{simpleLoc+1};
        searchString=searchStrInfo.searchString;

        if~isempty(searchString)
            hasModifier=searchStrInfo.hasModifier;
            if hasModifier
                propertyList={searchStrInfo.modifier};
            else
                propertyList={'Name','Script'};
            end

            functionList=i_getFunctionList(searchString,caseInsensitive);
            matchAllList=cell(1,4*length(propertyList)-1);
            for propIndex=1:length(propertyList)
                if propIndex==1
                    matchAllList(1:3)=['-function',propertyList{propIndex},functionList(1)];
                else
                    matchAllList(1,(propIndex-1)*4:propIndex*4-1)=['-or','-function',propertyList{propIndex},functionList(1)];
                end
            end
            propValues{end+1}=matchAllList;
        end

        numPairs=(length(varargin)-simpleLoc-1)/2;
        if numPairs>0
            for i=1:numPairs
                prop=varargin{simpleLoc+i*2};
                value=varargin{simpleLoc+i*2+1};
                if~isempty(value)
                    functionList=i_getFunctionList(value,caseInsensitive);
                    propValues=[propValues,'-and','-function',prop,functionList(1)];
                end
            end
        end
    end


    sysH=getSimulinkSystem(varargin{1});
    sysUddH=get_param(sysH,'Object');


    mFuncObj=sysUddH.find('-isa','Stateflow.EMChart','-and',propValues{:});


    sfrt=sfroot;
    linkedCharts=sysUddH.find('-isa','Stateflow.LinkChart');
    for idx=1:length(linkedCharts)
        linkedObjPath=get_param(linkedCharts(idx).Path,'ReferenceBlock');
        mLinkFunc=sfrt.find('-isa','Stateflow.EMChart','Path',linkedObjPath,'-and',propValues{:});
        mFuncObj=[mFuncObj;mLinkFunc];
    end

    mFuncObjNum=length(mFuncObj);
    mFuncBlock=struct([]);

    if~isempty(mFuncObj)
        for i=1:mFuncObjNum
            mFuncBlock(i).script=mFuncObj(i).Script;
            chartId=mFuncObj(i).Id;
            mFuncBlock(i).handle=sfprivate('chart2block',chartId);
        end
    end

end



function searchFieldsInfo=getSearchFields(findArgs,searchTypeIndex)
    utils.ScopedInstrumentation("sl_find::getSearchFields");
    searchFieldsInfo=struct();
    searchType=findArgs{searchTypeIndex};
    searchStrInfo=findArgs{searchTypeIndex+1};
    searchFieldsInfo.isModifierBlockDialogParams=false;


    searchFieldsInfo.simpleSearch=strncmp(searchType,'Simple',6);
    searchFieldsInfo.searchBlockParameters=strcmp(searchType,'SimpleAndParams');


    hasModifier=searchStrInfo.hasModifier;
    searchFieldsInfo.hasModifier=hasModifier;

    searchFieldList=struct([]);

    if~hasModifier

        searchFields=i_getDefaultSearchFields();
        searchFieldNum=length(searchFields);

        for i=1:searchFieldNum
            fieldName=searchFields{i};
            if strcmpi(fieldName,'Name')
                searchFieldList(i).annoSearchField='PlainText';
                searchFieldList(i).blockSearchField='Name';
                searchFieldList(i).signalSearchField='Name';
            else
                searchFieldList(i).annoSearchField=fieldName;
                searchFieldList(i).blockSearchField=fieldName;
                searchFieldList(i).signalSearchField=fieldName;
            end
        end
        displayFieldList={'Type','Name','Description','Parent','Source','Destination'};
    else


        modifier=searchStrInfo.modifier;


        if strcmpi(modifier,'BlockDialogParams')
            searchFieldsInfo.isModifierBlockDialogParams=true;
        end

        if strcmpi(modifier,'Name')
            searchFieldList(1).annoSearchField='PlainText';
        else
            searchFieldList(1).annoSearchField=modifier;
        end
        searchFieldList(1).blockSearchField=modifier;
        searchFieldList(1).signalSearchField=modifier;

        basicFields={'type','name','parent','source','destination'};
        if~any(ismember(lower(modifier),basicFields))&&~searchFieldsInfo.isModifierBlockDialogParams
            displayFieldList={'Type','Name',modifier,'Parent','Source','Destination'};
        else
            displayFieldList={'Type','Name','Parent','Source','Destination'};
        end

    end

    if slfeature('SimulinkSearchReplace')
        displayFieldList{end+1}='SubType';
    end

    searchFieldsInfo.searchFieldList=searchFieldList;
    searchFieldsInfo.displayFieldList=displayFieldList;
end



function prarameterValue=getMatchedParameterValues(handle,searchStrList,caseSensitive)
    utils.ScopedInstrumentation("sl_find::getMatchedParameterValues");

    prarameterValue=struct();
    dialogParamList={};
    dialogParamList{1}=get_param(handle,'DialogParameters');
    if strcmp(get_param(handle,'Mask'),'on')
        dialogParamList{2}=get_param(handle,'IntrinsicDialogParameters');
    end

    isReplaceFeatureOn=slfeature('SimulinkSearchReplace')>0;

    for dialogIndex=1:length(dialogParamList)
        dialogParam=dialogParamList{dialogIndex};
        if~isempty(dialogParam)&&isstruct(dialogParam)
            paramList=fieldnames(dialogParam);

            for i=1:length(paramList)
                paramName=paramList{i};
                paramValue=get_param(handle,paramName);


                if ischar(paramValue)
                    paramValue=handleNewLine_s(paramValue,isReplaceFeatureOn);
                end


                startIndex=[];
                if~isempty(paramValue)&&(ischar(paramValue)||isnumeric(paramValue))
                    for idx=1:length(searchStrList)
                        searchStr=searchStrList{idx};
                        if~isempty(searchStr)
                            if ischar(searchStr)&&ischar(paramValue)
                                if strcmpi(caseSensitive,'on')
                                    startIndex=regexp(paramValue,searchStr);
                                else
                                    startIndex=regexpi(paramValue,searchStr);
                                end
                            elseif isnumeric(searchStr)
                                isSameNumber=all(paramValue==searchStr);
                                if isSameNumber
                                    startIndex=1;
                                end
                            end
                        end
                    end
                end

                if~isempty(startIndex)
                    paramDisplayName=dialogParam.(paramName).Prompt;


                    if isempty(paramDisplayName)
                        paramDisplayName=paramName;
                    end

                    if isReplaceFeatureOn
                        prarameterValue.(paramName)=struct(...
                        'name',paramDisplayName,'realname',paramName,'value',paramValue...
                        );
                    else
                        prarameterValue.(paramName)=struct('name',paramDisplayName,'value',paramValue);
                    end
                end
            end

        end

    end
end




function isSignalType=isSearchSignalTypeWithModifier(searchStrInfo)
    isSignalType=false;
    if searchStrInfo.hasModifier&&strcmpi(searchStrInfo.modifier,'type')
        searchStr=searchStrInfo.searchString;
        if~isempty(regexpi('signal',searchStr,'once'))
            isSignalType=true;
        end
    end
end




function nonScopeBlocks=filterOutScopes(blocks)
    nonScopeBlocks=blocks;


    blks_scope=find_system(blocks,'SearchDepth',0,'BlockType','Scope');
    if~isempty(blks_scope)
        nonScopeBlocks=blocks(~ismember(blocks,blks_scope));
    end
end



function i_FindObjects(functionIdx,findAsyncM,searchTypes,sysName,otherArgs)
    utils.ScopedInstrumentation("sl_find::i_FindObjects");

    slSelections=searchTypes{1,1};
    sfSelections=searchTypes{1,2};
    f_SL=slSelections(1);
    f_ANNO=slSelections(2);
    f_BLKS=slSelections(3);
    f_SIG=slSelections(4);


    f_CHARTS=sfSelections(1)||sfSelections(3);


    findArgs=[{sysName},otherArgs];
    currentSystemName=sysName;
    findArgs{1}=getSimulinkSystem(findArgs{1});


    if find(strcmp('SearchDepth',findArgs))
        simpleLoc=12;
    else
        simpleLoc=10;
    end




    searchFieldsInfo=getSearchFields(findArgs,simpleLoc);



    searchString=findArgs{simpleLoc+1}.searchString;



    searchStringList=[{searchString};findArgs{simpleLoc+1}.searchNumber];


    if isSearchSignalTypeWithModifier(findArgs{simpleLoc+1})
        searchStringList=[searchStringList;'port'];
    end



    findParamInfo=struct();
    findParamInfo.functionIdx=functionIdx;
    findParamInfo.currentSysName=currentSystemName;
    findParamInfo.searchStringList=searchStringList;
    findParamInfo.displayFieldList=searchFieldsInfo.displayFieldList;
    findParamInfo.isModifierBlockDialogParam=searchFieldsInfo.isModifierBlockDialogParams;

    caseSensitiveLoc=find(strcmp('CaseSensitive',findArgs));
    caseSensitiveValue=findArgs(caseSensitiveLoc+1);
    findParamInfo.caseSensitive=caseSensitiveValue;

    searchedMaskProp=~isempty(find(strcmp('MaskDescription',findArgs),1))...
    ||~isempty(find(strcmp('MaskType',findArgs),1));
    findParamInfo.searhcedMaskProp=searchedMaskProp;


    findAsyncParam=struct();
    findAsyncParam.findArgs=findArgs;
    findAsyncParam.simpleLoc=simpleLoc;
    findAsyncParam.searchStringList=searchStringList;
    findAsyncParam.searchFieldsInfo=searchFieldsInfo;
    findParamInfo.discardCharts=~f_CHARTS;
    findAsyncParam.findParamInfo=findParamInfo;


    if(f_SL||f_ANNO)
        findSysH=findArgs{1};
        searchType=FindAsyncManager.annoType;


        i_AddFindTasks(findSysH,findAsyncM,searchType,findAsyncParam);
    end


    if(f_SL||f_BLKS)

        blks_allResult=find_system(findArgs{1},...
        'Async',true,...
        'Variants','AllVariants',...
        'IncludeCommented','on',...
        findArgs{2:simpleLoc-1},...
        'Type','block');


        searchType=FindAsyncManager.allSlBlks;
        taskInfo=struct();
        taskInfo.isAsync=true;
        taskInfo.result=blks_allResult;
        taskInfo.searchType=searchType;
        taskInfo.progressListener=@(resultsH)i_AddFindTasks(resultsH,findAsyncM,searchType,findAsyncParam);

        findAsyncM.addTask(taskInfo);


        blk_matlabFunction=getMatlabFunctionBlock(sysName,otherArgs{:});

        if~isempty(blk_matlabFunction)

            searchType=FindAsyncManager.matlabFunctionType;

            taskInfo=struct();
            taskInfo.isAsync=false;
            taskInfo.result=blk_matlabFunction;
            taskInfo.searchType=searchType;
            taskInfo.progressListener=@(resultsH)i_FindObjectsProgressListener(findParamInfo,searchType,resultsH);

            findAsyncM.addTask(taskInfo);
        end

    end


    if(f_SL||f_SIG)
        findSysH=findArgs{1};
        searchType=FindAsyncManager.signalType;


        i_AddFindTasks(findSysH,findAsyncM,searchType,findAsyncParam);
    end
end



function i_AddFindTasks(findSys,findAsyncM,objType,findAsyncParam)
    utils.ScopedInstrumentation("sl_find::i_AddFindTasks");
    findArgs=findAsyncParam.findArgs;
    simpleLoc=findAsyncParam.simpleLoc;
    searchStringList=findAsyncParam.searchStringList;
    findParamInfo=findAsyncParam.findParamInfo;
    searchFieldsInfo=findAsyncParam.searchFieldsInfo;

    simpleSearch=searchFieldsInfo.simpleSearch;
    searchBlockParameters=searchFieldsInfo.searchBlockParameters;

    searchFieldList=searchFieldsInfo.searchFieldList;



    if(objType==findAsyncM.allSlBlks)
        BlockParamIndex=find(strcmpi('BlockDialogParams',findArgs));
        if~isempty(BlockParamIndex)&&find(mod(BlockParamIndex,2)==0)
            findSys=filterOutScopes(findSys);
        end
    end

    returnPropertyMatches={'ReturnPropertyMatches','off'};
    if(slfeature('FindSystemSupportForReturningPropMatches')>0)
        returnPropertyMatches={'ReturnPropertyMatches','on'};
    end


    for searchStrIndex=1:length(searchStringList)


        searchStr=searchStringList{searchStrIndex};
        findArgs{simpleLoc+1}=searchStr;

        if simpleSearch
            findArgs{simpleLoc}='Name';

            if isempty(findArgs{simpleLoc+1})
                if(slfeature('FindSystemSupportForReturningPropMatches')>0)
                    returnPropertyMatches={'ReturnPropertyMatches','off'};
                end

                findArgs(simpleLoc:simpleLoc+1)=[];
                simpleSearch=0;
                searchBlockParameters=0;
            end
        end

        if searchFieldsInfo.hasModifier
            returnPropertyMatches={'ReturnPropertyMatches','off'};
        end

        suppressWarnings={'SuppressWarnings',returnPropertyMatches{2}};

        for idx=1:length(searchFieldList)
            searchField=searchFieldList(idx);

            if(objType==findAsyncM.annoType)
                if simpleSearch
                    findArgs{simpleLoc}=searchField.annoSearchField;
                end
                newAnnoResult=find_system(findSys,...
                'Async',true,...
                'Findall','on',...
                'Variants','AllVariants',...
                'IncludeCommented','on',...
                returnPropertyMatches{1:end},...
                suppressWarnings{1:end},...
                findArgs{2:end},...
                'Type','annotation');



                searchType=FindAsyncManager.annoType;
                taskInfo=struct();
                taskInfo.isAsync=true;
                taskInfo.result=newAnnoResult;
                taskInfo.searchType=searchType;
                taskInfo.progressListener=@(resultsH)i_FindObjectsProgressListener(findParamInfo,searchType,resultsH);

                findAsyncM.addTask(taskInfo);


            elseif(objType==findAsyncM.allSlBlks)
                if simpleSearch
                    findArgs{simpleLoc}=searchField.blockSearchField;
                end



                blockArgs=findArgs;
                searchDepthIndex=find(strcmp('SearchDepth',blockArgs),1,'first');
                if~isempty(searchDepthIndex)&&length(blockArgs)>searchDepthIndex&&blockArgs{searchDepthIndex+1}==1
                    blockArgs(searchDepthIndex:searchDepthIndex+1)=[];
                end

                newBlkResult=find_system(findSys,...
                'Async',true,...
                'Variants','AllVariants',...
                'IncludeCommented','on',...
                'SearchDepth',0,...
                returnPropertyMatches{1:end},...
                suppressWarnings{1:end},...
                blockArgs{2:end},...
                'Type','block');



                searchType=FindAsyncManager.blockType;
                taskInfo=struct();
                taskInfo.isAsync=true;
                taskInfo.result=newBlkResult;
                taskInfo.searchType=searchType;
                taskInfo.progressListener=@(resultsH)i_FindObjectsProgressListener(findParamInfo,searchType,resultsH);

                findAsyncM.addTask(taskInfo);



            elseif(objType==findAsyncM.signalType)
                if simpleSearch
                    findArgs{simpleLoc}=searchField.signalSearchField;
                end
                newPortResult=find_system(findSys,...
                'Async',true,...
                'findall','on',...
                'Variants','AllVariants',...
                'IncludeCommented','on',...
                returnPropertyMatches{1:end},...
                suppressWarnings{1:end},...
                findArgs{2:end},...
                'Type','port','PortType','outport');


                searchType=FindAsyncManager.signalType;

                taskInfo=struct();
                taskInfo.isAsync=true;
                taskInfo.result=newPortResult;
                taskInfo.searchType=searchType;
                taskInfo.progressListener=@(resultsH)i_FindObjectsProgressListener(findParamInfo,searchType,resultsH);

                findAsyncM.addTask(taskInfo);
            end
        end



        if(objType==findAsyncM.allSlBlks)

            if searchBlockParameters&&~searchFieldsInfo.hasModifier
                findArgs{simpleLoc}='BlockDialogParams';


                blks_nonScope=filterOutScopes(findSys);



                blockArgs=findArgs;
                searchDepthIndex=find(strcmp('SearchDepth',blockArgs),1,'first');
                if~isempty(searchDepthIndex)&&length(blockArgs)>searchDepthIndex&&blockArgs{searchDepthIndex+1}==1
                    blockArgs(searchDepthIndex:searchDepthIndex+1)=[];
                end

                blkResult_more=find_system(blks_nonScope,...
                'Async',true,...
                'Variants','AllVariants',...
                'IncludeCommented','on',...
                'SearchDepth',0,...
                returnPropertyMatches{1:end},...
                suppressWarnings{1:end},...
                blockArgs{2:end},...
                'Type','block');


                searchType=FindAsyncManager.blockDlgParamType;
                taskInfo=struct();
                taskInfo.isAsync=true;
                taskInfo.result=blkResult_more;
                taskInfo.searchType=searchType;
                taskInfo.progressListener=@(resultsH)i_FindObjectsProgressListener(findParamInfo,searchType,resultsH);

                findAsyncM.addTask(taskInfo);

            end
        end

    end
end



function validHandles=getValidHandle(searchType,newResultsH)
    utils.ScopedInstrumentation("sl_find::getValidHandle");

    if searchType==FindAsyncManager.matlabFunctionType
        objH=[newResultsH.handle]';
    else
        objH=newResultsH;
    end

    resultNum=length(objH);
    invalidIndex=false(1,resultNum);
    for i=1:resultNum
        currentH=objH(i);
        try
            get_param(currentH,'Name');
        catch

            invalidIndex(i)=true;
        end
    end

    validHandles=newResultsH;
    validHandles(invalidIndex)=[];
end



function results=i_FindObjectsProgressListener(findParam,search_type,newResultsH)
    utils.ScopedInstrumentation("sl_find::i_FindObjectsProgressListener");

    utils.ScopedWarningsSuppressor();

    results=[];

    if~isempty(newResultsH)
        try
            if slfeature('FindSystemSupportForReturningPropMatches')>0&&...
                slfeature('SimulinkSearchReplace')>0&&...
                (isstruct(newResultsH)||search_type==FindAsyncManager.matlabFunctionType)
                results=[];
                if search_type==FindAsyncManager.annoType||search_type==FindAsyncManager.matlabFunctionType
                    results=newResultsH;
                elseif(search_type==FindAsyncManager.blockType...
                    ||search_type==FindAsyncManager.blockDlgParamType)
                    results=i_ProcessBlks2(newResultsH,findParam);
                elseif(search_type==FindAsyncManager.signalType)
                    results=i_ProcessPorts2(newResultsH,findParam.currentSysName);
                end


                if(search_type~=FindAsyncManager.matlabFunctionType)
                    currentSystemName=findParam.currentSysName;
                    results=filterObjOutsideCurrentSys2(results,currentSystemName,search_type);
                end

                results=i_CreateResults2(results,search_type,findParam);

            else



                newResultsH=getValidHandle(search_type,newResultsH);
                objH=[];

                if(search_type==FindAsyncManager.annoType)
                    objH=newResultsH;
                elseif(search_type==FindAsyncManager.blockType)
                    objH=i_ProcessBlks(newResultsH,findParam);
                elseif(search_type==FindAsyncManager.blockDlgParamType)
                    objH=i_ProcessBlks(newResultsH,findParam);
                elseif(search_type==FindAsyncManager.matlabFunctionType)
                    objH=newResultsH;
                elseif(search_type==FindAsyncManager.signalType)
                    currentSystemName=findParam.currentSysName;
                    objH=i_ProcessPorts(newResultsH,currentSystemName);
                end


                if(search_type~=FindAsyncManager.matlabFunctionType)
                    currentSystemName=findParam.currentSysName;
                    objH=filterObjOutsideCurrentSys(objH,currentSystemName,search_type);
                end

                results=i_CreateResults(objH,search_type,findParam);

            end

        catch ME
            disp(ME.message);
        end
    end
end




function blockH=i_ProcessBlks(rawBlockH,findParam)
    utils.ScopedInstrumentation("sl_find::i_ProcessBlks");
    blockH=rawBlockH;


    blockH=deleteChartBlock(blockH);


    if findParam.searhcedMaskProp
        blockH=filterWebBlockFromMaskedSystem(blockH);
    end



    blockH=filterHiddenWebBlocks(blockH);



    blkType=get_param(blockH,'Type');
    blkdiag_idx=find(strcmpi(blkType,'block_diagram'));
    if~isempty(blkdiag_idx)
        blockH(blkdiag_idx)=[];
    end
end



function validResults=i_ProcessBlks2(newResults,findParam)
    utils.ScopedInstrumentation("sl_find::i_ProcessBlks");

    validResults=newResults;
    if slfeature('FindSystemSupportForReturningPropMatches')==0||slfeature('SimulinkSearchReplace')==0
        return
    end

    newOfNewResults=length(newResults);
    resultIdx=1;

    for i=1:newOfNewResults
        blkH=newResults(i).handle;
        if strcmp(get_param(blkH,'BlockType'),'SubSystem')

            if findParam.searhcedMaskProp&&strcmp(get_param(blkH,'IsWebBlock'),'on')
                validResults(resultIdx)=[];
            else

                chartId=sfprivate('block2chart',blkH);
                isCurrentResultInvalid=false;
                if chartId>0
                    chartObj=sf('IdToHandle',chartId);
                    if~isempty(chartObj)&&isa(chartObj,'Stateflow.Chart')
                        if findParam.discardCharts||(~strcmp(get_param(blkH,'LinkStatus'),'resolved')&&strcmp(get_param(blkH,'mask'),'off'))
                            validResults(resultIdx)=[];
                            isCurrentResultInvalid=true;
                        end
                    end
                end

                if~isCurrentResultInvalid
                    resultIdx=resultIdx+1;
                end
            end
        elseif(~isempty(get_param(blkH,'Tag'))&&strcmp(get_param(blkH,'Tag'),'HiddenForWebPanel'))


            validResults(resultIdx)=[];
        elseif strcmpi(get_param(blkH,'Type'),'block_diagram')


            validResults(resultIdx)=[];
        else
            resultIdx=resultIdx+1;
        end
    end
end




function portH=i_ProcessPorts(rawPortH,currentSystemName)
    utils.ScopedInstrumentation("sl_find::i_ProcessPorts");

    portParents=get_param(rawPortH,'Parent');
    portParents=handleNewLine_s(portParents,slfeature('SimulinkSearchReplace'));
    invalidPort=strcmp(portParents,currentSystemName);



    lineH=get_param(rawPortH,'Line');
    if iscell(lineH)
        lineH=[lineH{:}]';
    end
    for i=1:length(lineH)
        if ishandle(lineH(i))
            lineObj=get_param(lineH(i),'Object');
            parent=lineObj.Parent;
            try
                isChart=false;
                if strcmp(get_param(parent,'BlockType'),'SubSystem')
                    chartId=sfprivate('block2chart',parent);
                    if chartId>0
                        isChart=true;
                    end
                end
            catch
                isChart=false;
            end
            if isChart
                invalidPort(i)=1;
            end
        end
    end


    portH=rawPortH(ishandle(lineH(:))&~invalidPort);
end



function newResult=i_ProcessPorts2(newResult,currentSystemName)
    utils.ScopedInstrumentation("sl_find::i_ProcessPorts");

    if slfeature('FindSystemSupportForReturningPropMatches')==0||slfeature('SimulinkSearchReplace')==0
        return
    end


    portParents=get_param([newResult.handle],'Parent');
    portParents=handleNewLine_s(portParents,slfeature('SimulinkSearchReplace'));
    invalidPort=strcmp(portParents,currentSystemName);



    lineH=get_param([newResult.handle],'Line');
    if iscell(lineH)
        lineH=[lineH{:}]';
    end

    numOfLineH=length(lineH);
    for i=1:numOfLineH
        if ishandle(lineH(i))
            lineObj=get_param(lineH(i),'Object');
            parent=lineObj.Parent;
            try
                isChart=false;
                if strcmp(get_param(parent,'BlockType'),'SubSystem')
                    chartId=sfprivate('block2chart',parent);
                    if chartId>0
                        isChart=true;
                    end
                end
            catch
                isChart=false;
            end
            if isChart
                invalidPort(i)=1;
            end
        end
    end



    newResult=newResult(ishandle(lineH(:))&~invalidPort);

end




function objectH=filterObjOutsideCurrentSys(objHdls,currentSystemName,search_type)
    utils.ScopedInstrumentation("sl_find::filterObjOutsideCurrentSys");

    if(search_type==FindAsyncManager.signalType)
        objH=get_param(objHdls,'Line');
        if iscell(objH)
            objH=[objH{:}]';
        end
    elseif(search_type==FindAsyncManager.matlabFunctionType)
        objH=[objHdls.handle]';
    else
        objH=objHdls;
    end

    parents=get_param(objH,'Parent');
    if~iscell(parents)
        parents={parents};
    end

    parents=strrep(parents,newline,' ');


    nonSFparent=strcmp(parents,strtok(currentSystemName,'/'));


    currentSysAndBelow=strncmp(parents,currentSystemName,length(currentSystemName));


    candidateIdx=find(nonSFparent==0);

    if~isempty(candidateIdx)

        candidateIdx(slprivate('is_stateflow_based_block',parents(candidateIdx)))=[];


        nonSFparent(candidateIdx)=1;
        validStates=nonSFparent&currentSysAndBelow;
    else
        validStates=currentSysAndBelow;
    end

    objectH=objHdls(validStates);

end




function newResults=filterObjOutsideCurrentSys2(newResults,currentSystemName,search_type)
    utils.ScopedInstrumentation("sl_find::filterObjOutsideCurrentSys");

    if slfeature('FindSystemSupportForReturningPropMatches')==0||slfeature('SimulinkSearchReplace')==0
        return
    end


    if(search_type==FindAsyncManager.signalType)
        objH=get_param([newResults.handle],'Line');
        if iscell(objH)
            objH=[objH{:}]';
        end
    else
        objH=[newResults.handle];
    end

    parents=get_param(objH,'Parent');
    if~iscell(parents)
        parents={parents};
    end

    parents=strrep(parents,newline,' ');


    nonSFparent=strcmp(parents,strtok(currentSystemName,'/'));


    currentSysAndBelow=strncmp(parents,currentSystemName,length(currentSystemName));


    candidateIdx=find(nonSFparent==0);

    if~isempty(candidateIdx)

        candidateIdx(slprivate('is_stateflow_based_block',parents(candidateIdx)))=[];


        nonSFparent(candidateIdx)=1;
        validStates=nonSFparent&currentSysAndBelow;
    else
        validStates=currentSysAndBelow;
    end

    newResults=newResults(validStates);

end




function results=i_CreateResults(objectH,objType,findParam)
    utils.ScopedInstrumentation("sl_find::i_CreateResults");

    utils.ScopedWarningsSuppressor();

    resultNum=length(objectH);
    if resultNum>0

        if objType==FindAsyncManager.matlabFunctionType
            objH=[objectH.handle]';
        else
            objH=objectH;
        end

        fieldValues=struct();
        displayFieldList=findParam.displayFieldList;
        isReplaceFeatureOn=slfeature('SimulinkSearchReplace')>0;
        for idx=1:length(displayFieldList)
            fieldName=displayFieldList{idx};
            switch(fieldName)
            case 'Type'

                types=get_param(objH,'Type');
                if ischar(types)
                    types={types};
                end
                types=strrep(types,'annotation','Annotation');
                types=strrep(types,'block','Block');
                types=strrep(types,'port','Signal');

                if isReplaceFeatureOn
                    if objType==FindAsyncManager.blockType...
                        ||objType==FindAsyncManager.blockDlgParamType...
                        ||objType==FindAsyncManager.matlabFunctionType
                        fieldValues.SubType=arrayfun(...
                        @(objHandle)getBlockSubType(objHandle),...
                        objH,...
                        'UniformOutput',false...
                        );
                    else
                        fieldValues.SubType=types;
                    end
                end

                fieldValues.(fieldName)=types;

            case 'Name'

                if objType==FindAsyncManager.annoType

                    names=get_param(objH,'PlainText');
                else
                    names=get_param(objH,'Name');
                end

                if ischar(names)
                    names={names};
                end


                names=handleNewLine_s(names,isReplaceFeatureOn);

                fieldValues.(fieldName)=names;

            case 'Source'


                if objType==FindAsyncManager.signalType
                    sources=get_param(get_param(objH,'Parent'),'Name');
                    if ischar(sources)
                        sources={sources};
                    end
                else
                    sources=cell(resultNum,1);
                    sources(:)={''};
                end


                sources=handleNewLine_s(sources,isReplaceFeatureOn);

                fieldValues.(fieldName)=sources;

            case 'Destination'


                if objType==FindAsyncManager.signalType
                    dest=arrayfun(...
                    @getSignalDestination,...
                    objH,...
                    'UniformOutput',false...
                    );
                else
                    dest=cell(resultNum,1);
                    dest(:)={''};
                end


                dest=handleNewLine_s(dest,isReplaceFeatureOn);

                fieldValues.(fieldName)=dest;
            case 'SubType'

            case 'Parent'

                if isReplaceFeatureOn&&...
                    objType==FindAsyncManager.signalType
                    parents=get_param(get_param(objH,'Parent'),'Parent');
                else
                    parents=get_param(objH,'Parent');
                end

                if ischar(parents)
                    parents={parents};
                end


                parents=handleNewLine_s(parents,isReplaceFeatureOn);

                fieldValues.Parent=parents;
            otherwise

                try
                    values=get_param(objH,fieldName);

                    if ischar(values)||isnumeric(values)
                        values={values};
                    end

                    if all(cellfun(@isnumeric,values))
                        values=cellfun(@num2str,values,'UniformOutput',0);
                    end


                    values=handleNewLine_s(values,isReplaceFeatureOn);

                    fieldValues.(fieldName)=values;
                catch


                    results=[];
                    return;
                end
            end
        end


        searchStrList=findParam.searchStringList;
        caseSensitiveValue=findParam.caseSensitive;
        functionIdx=findParam.functionIdx;

        results(resultNum)=struct();
        resultIdx=1;


        for i=1:resultNum
            results(resultIdx).FunctionIdx=functionIdx;
            results(resultIdx).Handle=objH(i);

            for idx=1:length(displayFieldList)
                fieldName=displayFieldList{idx};
                results(resultIdx).(fieldName)=fieldValues.(fieldName){i};
            end


            if objType==FindAsyncManager.matlabFunctionType
                results(resultIdx).Script=objectH(i).script;
            end

            indexIncreased=false;


            if objType==FindAsyncManager.blockDlgParamType||findParam.isModifierBlockDialogParam


                results(resultIdx).PropertyName='';
                results(resultIdx).PropertyValue='';


                matchedParamValue=getMatchedParameterValues(objH(i),searchStrList,caseSensitiveValue);
                paramList=fieldnames(matchedParamValue);

                if~isempty(paramList)


                    for j=1:length(paramList)
                        if j>1
                            results(resultIdx)=results(resultIdx-1);
                        end
                        matchedParam=paramList{j};
                        paramValueStruct=matchedParamValue.(matchedParam);
                        results(resultIdx).PropertyName=paramValueStruct.name;
                        if isReplaceFeatureOn
                            results(resultIdx).RealPropertyName=paramValueStruct.realname;
                        end
                        results(resultIdx).PropertyValue=paramValueStruct.value;


                        resultIdx=resultIdx+1;
                        indexIncreased=true;
                    end
                end


            end


            if~indexIncreased
                resultIdx=resultIdx+1;
            end
        end
    else
        results=[];
    end
end


function results=i_CreateResults2(newResults,objType,findParam)
    utils.ScopedInstrumentation("sl_find::i_CreateResults");

    utils.ScopedWarningsSuppressor();

    if slfeature('FindSystemSupportForReturningPropMatches')==0||slfeature('SimulinkSearchReplace')==0
        return
    end

    numOfResult=length(newResults);
    if(numOfResult<=0)
        results=[];
        return;
    end

    results(numOfResult)=struct();
    resultIdx=1;

    displayFieldList=findParam.displayFieldList;

    for i=1:numOfResult

        if~isfield(newResults(i),'propertyHitResults')&&objType~=FindAsyncManager.matlabFunctionType

            results=[];
            return;
        end

        objH=newResults(i).handle;

        results(resultIdx).FunctionIdx=findParam.functionIdx;
        results(resultIdx).Handle=objH;

        for idx=1:length(displayFieldList)
            fieldName=displayFieldList{idx};
            switch(fieldName)
            case 'Type'
                types=get_param(objH,'Type');

                types=strrep(types,'annotation','Annotation');
                types=strrep(types,'block','Block');
                types=strrep(types,'port','Signal');

                if objType==FindAsyncManager.blockType...
                    ||objType==FindAsyncManager.blockDlgParamType...
                    ||objType==FindAsyncManager.matlabFunctionType
                    results(resultIdx).SubType=getBlockSubType(objH);
                else
                    results(resultIdx).SubType=types;
                end

                results(resultIdx).(fieldName)=types;

            case 'Name'
                if objType==FindAsyncManager.annoType

                    names=get_param(objH,'PlainText');
                else
                    names=get_param(objH,'Name');
                end


                names=handleNewLine_s(names,1);

                results(resultIdx).(fieldName)=names;

            case 'Source'

                if objType==FindAsyncManager.signalType
                    sources=get_param(get_param(objH,'Parent'),'Name');
                else
                    sources='';
                end


                sources=handleNewLine_s(sources,1);

                results(resultIdx).(fieldName)=sources;

            case 'Destination'


                if objType==FindAsyncManager.signalType
                    dest=getSignalDestination(objH);
                else
                    dest='';
                end


                dest=handleNewLine_s(dest,1);

                results(resultIdx).(fieldName)=dest;
            case 'SubType'

            case 'Parent'

                if objType==FindAsyncManager.signalType
                    parents=get_param(get_param(objH,'Parent'),'Parent');
                else
                    parents=get_param(objH,'Parent');
                end


                parents=handleNewLine_s(parents,1);

                results(resultIdx).Parent=parents;
            otherwise

                try
                    values=get_param(objH,fieldName);

                    if ischar(values)||isnumeric(values)
                        values={values};
                    end

                    if all(cellfun(@isnumeric,values))
                        values=cellfun(@num2str,values,'UniformOutput',0);
                    end


                    values=handleNewLine_s(values,1);

                    results(resultIdx).(fieldName)=values;
                catch


                    results=[];
                    return;
                end
            end
        end


        if objType==FindAsyncManager.matlabFunctionType
            results(resultIdx).Script=newResults(i).script;



            resultIdx=resultIdx+1;
            continue;
        end
        indexIncreased=false;

        propMatches=newResults(i).propertyHitResults;
        noOfMatchedProp=length(propMatches);
        isBlkDlgParam=false;
        atleastOneBlkDlgParamFound=true;

        if objType==FindAsyncManager.blockDlgParamType||findParam.isModifierBlockDialogParam
            isBlkDlgParam=true;
            atleastOneBlkDlgParamFound=false;
        end

        if~isBlkDlgParam
            results(resultIdx).propertycollection(noOfMatchedProp)=struct();
        end

        idx=1;
        for j=1:noOfMatchedProp

            if isBlkDlgParam

                dialogParamList=get_param(objH,'DialogParameters');
                isblkdlgParamFound=true;
                if~isfield(dialogParamList,propMatches(j).paramName)
                    if strcmp(get_param(objH,'Mask'),'on')
                        dialogParamList=get_param(objH,'IntrinsicDialogParameters');
                        if~isfield(dialogParamList,propMatches(j).paramName)
                            isblkdlgParamFound=false;
                        end
                    else
                        isblkdlgParamFound=false;
                    end
                end

                if~isblkdlgParamFound




                    continue;

                end
                atleastOneBlkDlgParamFound=true;
                results(resultIdx).propertycollection(1)=struct();



                if resultIdx>1

                    results(resultIdx)=results(resultIdx-1);
                end
                results(resultIdx).RealPropertyName=propMatches(j).paramName;
                results(resultIdx).PropertyValue=get_param(objH,propMatches(j).paramName);

                prompt=dialogParamList.(propMatches(j).paramName).Prompt;
                if isempty(prompt)
                    prompt=results(resultIdx).RealPropertyName;
                end
                results(resultIdx).PropertyName=prompt;
                results(resultIdx).propertycollection(1).propertyname=prompt;
            else
                if objType==FindAsyncManager.annoType&&...
                    strcmp(propMatches(j).paramName,'PlainText')
                    results(resultIdx).propertycollection(idx).propertyname='Name';
                else
                    results(resultIdx).propertycollection(idx).propertyname=propMatches(j).paramName;
                end
            end


            results(resultIdx).propertycollection(idx).originalvalue=get_param(objH,propMatches(j).paramName);
            results(resultIdx).propertycollection(idx).splitNonMatch=propMatches(j).unmatchRegions;
            results(resultIdx).propertycollection(idx).hitsubstrings=propMatches(j).matchRegions;

            if isBlkDlgParam

                resultIdx=resultIdx+1;
                indexIncreased=true;
            else
                idx=idx+1;
            end
        end

        if isBlkDlgParam&&~atleastOneBlkDlgParamFound
            results(resultIdx)=[];
            indexIncreased=true;
        end


        if~indexIncreased
            resultIdx=resultIdx+1;
        end
    end
end

function valStr=handleNewLine_s(valStr,isReplaceFeatureOn)
    if isReplaceFeatureOn
        return;
    end
    valStr=strrep(valStr,newline,' ');

end
function destName=getSignalDestination(objHandle)
    destName='';
    lineH=get_param(objHandle,'Line');

    if ishandle(lineH)
        dstBlocks=get_param(lineH,'DstBlockHandle');

        dstH=dstBlocks(1);
        if ishandle(dstH)
            destName=get_param(dstH,'Name');
        end
    end

end






function blockSubType=getBlockSubType(blockH)
    blockType=get_param(blockH,'BlockType');
    if strcmp(blockType,'SubSystem')
        blockSubType=get_param(blockH,'SFBlockType');
        if strcmp(blockSubType,'NONE')
            blockSubType=blockType;
        end
    else
        blockSubType=blockType;
    end
end
