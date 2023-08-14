classdef(Sealed=true)styleManager<Simulink.Structure.HiliteTool.EmphasisStyleSheet

    properties(SetAccess=private,GetAccess=public,Hidden=true)

        SelectionElements;


        CurrentTraceElements;


        RootElement;


        SubSystemElements;
        SubSystemElementsState;


        ImpactRegionStyler;


        GeneralStyledElements;

        CustomStyler;


        PortBadge;
        ActivePortWithBadge;


        BlockBadge;
        ActiveBlockWithBadge;

    end

    properties(Constant)
        CustomStylerName='HiliteTool.CustomStyler';
        SelectionClass='MathWorks.HiliteTool.SelectionStyling';
        CurrentClass='MathWorks.HiliteTool.CurrentTraceStyling';
        RootClass='MathWorks.HiliteTool.RootSegmentStyling';
        SubSystemClass='MathWorks.HiliteTool.SubSystemStyling';
        ImagePath=fullfile(matlabroot,'/toolbox/simulink/simulink/sl_structure_analysis/+Simulink/+Structure/+HiliteTool/Images/');
    end



    methods(Access=public)
        function styleObj=styleManager

            styleObj.createCustomStyler;
            styleObj.SelectionElements=Simulink.Structure.HiliteTool.styleElementsContainer;
            styleObj.CurrentTraceElements=Simulink.Structure.HiliteTool.styleElementsContainer;
            styleObj.RootElement=Simulink.Structure.HiliteTool.styleElementsContainer;
            styleObj.ImpactRegionStyler=Simulink.Structure.HiliteTool.impactRegionStyler;
            styleObj.SubSystemElements=containers.Map('KeyType','double','ValueType','any');
            styleObj.SubSystemElementsState=containers.Map('KeyType','double','ValueType','any');
            styleObj.GeneralStyledElements=containers.Map('KeyType','double','ValueType','any');
            createPortBadge(styleObj);
            createBlockBadge(styleObj);
            styleObj.ActivePortWithBadge=[];
            styleObj.ActiveBlockWithBadge=[];
        end
    end



    methods(Access=private)
        function createCustomStyler(styleObj)
            styleObj.CustomStyler=diagram.style.getStyler(styleObj.CustomStylerName);

            if(isempty(styleObj.CustomStyler))
                diagram.style.createStyler(styleObj.CustomStylerName,3);
                styleObj.CustomStyler=diagram.style.getStyler(styleObj.CustomStylerName);
            end
            addRulesAndClassNames(styleObj);
        end
    end




    methods(Access=private)
        function addRulesAndClassNames(styleObj)
            styleObj.installRootSegmentStyling;
            styleObj.installCurrentTraceStyling;
            styleObj.installSelectionStyling;
            styleObj.installSubSystemStyling;
        end
    end



    methods(Access=private)
        function installRootSegmentStyling(styleObj)
            rules=styleObj.getRootSegmentRule;
            styleObj.CustomStyler.addRule(rules,diagram.style.MultiSelector({styleObj.RootClass},{'Editor'}));
            mSelect=diagram.style.MultiSelector({'MathWorks.GLUE2Styler:Selected'
            styleObj.RootClass},{'Editor'});
            [~]=styleObj.CustomStyler.addRule(styleObj.getSelectionBlockHighlighterRule,mSelect);
        end
    end



    methods(Static,Access=public)
        function rules=getRootSegmentRule

            rules=diagram.style.Style;
            rules.set('FillStyle','Solid');
            rules.set('FillColor',[1,1,1,1],'simulink.Block');
            rules.set('FillColor',[1,1,1,1],'simulink.Segment');
            rules.set('StrokeColor',[0.0,0.0,0.0,1.0],'simulink.Block');
            rules.set('StrokeColor',[0.0,0.0,0.0,1.0],'simulink.Segment');
            rules.set('StrokeStyle','SolidLine','simulink.Block');
            rules.set('StrokeStyle','SolidLine','simulink.Segment');

            stroke=MG2.Stroke;
            stroke.Color=[1,1,0.8,1.0];
            stroke.JoinStyle='RoundJoin';
            stroke.ScaleFunction='SelectionNonLinear';
            stroke.Width=3;
            rules.set('Trace',MG2.TraceEffect(stroke,'Outer'),'simulink.Segment');
        end
    end



    methods(Static,Access=public)
        function selectionBlockHighlighter=getSelectionBlockHighlighterRule
            selectionBlockHighlighter=diagram.style.Style;
            selectionBlockHighlighter.set('StrokeColor',[0.722,0.839,0.996,0.8],'simulink.Block');
            selectionBlockHighlighter.set('StrokeColor',[0.722,0.839,0.996,0.8],'simulink.Segment');
            selectionBlockHighlighter.set('StrokeWidth',3,'simulink.Segment');
            selectionBlockHighlighter.set('StrokeWidth',3,'simulink.Block');
        end
    end



    methods(Access=private)
        function installSelectionStyling(styleObj)
            rules=styleObj.getSelectionRule;
            styleObj.CustomStyler.addRule(rules,diagram.style.MultiSelector({styleObj.SelectionClass},{'Editor'}));
            mSelect=diagram.style.MultiSelector({'MathWorks.GLUE2Styler:Selected'
            styleObj.SelectionClass},{'Editor'});

            [~]=styleObj.CustomStyler.addRule(styleObj.getSelectionBlockHighlighterRule,mSelect);
        end
    end



    methods(Static,Access=public)
        function rules=getSelectionRule

            rules=diagram.style.Style;
            rules.set('FillStyle','Solid');
            rules.set('FillColor',[1,1,1,1],'simulink.Block');
            rules.set('FillColor',[1,1,1,1],'simulink.Segment');
            rules.set('StrokeColor',[0.0,0.0,0.0,1.0],'simulink.Block');
            rules.set('StrokeColor',[0.0,0.0,0.0,1.0],'simulink.Segment');
            rules.set('StrokeStyle','SolidLine','simulink.Block');
            rules.set('StrokeStyle','SolidLine','simulink.Segment');

            stroke=MG2.Stroke;
            stroke.Color=[0,0.6000,1.0000,1.0];
            stroke.Width=4;
            stroke.JoinStyle='RoundJoin';
            stroke.ScaleFunction='SelectionNonLinear';
            rules.set('Trace',MG2.TraceEffect(stroke,'Outer'),'simulink.Block');
            stroke.Width=2;
            stroke.Color=[0,0.6000,1.0000,1.0];
            rules.set('Trace',MG2.TraceEffect(stroke,'Outer'),'simulink.Segment');
        end
    end




    methods(Access=private)
        function installCurrentTraceStyling(styleObj)
            rules=styleObj.getCurrentTraceRule;
            styleObj.CustomStyler.addRule(rules,diagram.style.MultiSelector({styleObj.CurrentClass},{'Editor'}));
            mSelect=diagram.style.MultiSelector({'MathWorks.GLUE2Styler:Selected'
            styleObj.CurrentClass},{'Editor'});

            [~]=styleObj.CustomStyler.addRule(styleObj.getSelectionBlockHighlighterRule,mSelect);
        end
    end




    methods(Static,Access=public)
        function rules=getCurrentTraceRule

            rules=diagram.style.Style;
            rules.set('FillStyle','Solid');
            rules.set('FillColor',[1.0,1.0,1.0,1],'simulink.Block');
            rules.set('FillColor',[1,1,1,1],'simulink.Segment');
            rules.set('StrokeColor',[0.0,0.0,0.0,1.0],'simulink.Block');
            rules.set('StrokeColor',[0.0,0.0,0.0,1.0],'simulink.Segment');
            rules.set('StrokeStyle','SolidLine','simulink.Block');
            rules.set('StrokeStyle','SolidLine','simulink.Segment');
            rules.set('TextColor',[0,0,1],'simulink.SegmentLabel');
            rules.set('Glow',MG2.GlowEffect());
            rules.set('Opacity',1.0);

            stroke=MG2.Stroke;
            stroke.Color=[0.98,0.92,0.2,1.0];
            stroke.Width=4;
            stroke.JoinStyle='RoundJoin';
            stroke.ScaleFunction='SelectionNonLinear';
            rules.set('Trace',MG2.TraceEffect(stroke,'Outer'),'simulink.Block');
            stroke.Width=2.0;
            rules.set('Trace',MG2.TraceEffect(stroke,'Outer'),'simulink.Segment');
        end
    end



    methods(Access=private)
        function installSubSystemStyling(styleObj)
            rules=styleObj.getSubSystemRule;
            styleObj.CustomStyler.addRule(rules,diagram.style.MultiSelector({styleObj.SubSystemClass},{'Editor'}));
            mSelect=diagram.style.MultiSelector({'MathWorks.GLUE2Styler:Selected'
            styleObj.SubSystemClass},{'Editor'});
            [~]=styleObj.CustomStyler.addRule(styleObj.getSelectionBlockHighlighterRule,mSelect);
        end
    end



    methods(Static,Access=public)
        function rules=getSubSystemRule

            rules=diagram.style.Style;
            rules.set('FillStyle','Solid');
            rules.set('FillColor',[0.85,0.85,0.85,1],'simulink.Block');
            rules.set('FillColor',[1,1,1,1],'simulink.Segment');
            rules.set('StrokeColor',[0.0,0.0,0.0,1.0],'simulink.Block');
            rules.set('StrokeColor',[0.0,0.0,0.0,1.0],'simulink.Segment');
            rules.set('StrokeStyle','SolidLine','simulink.Block');
            rules.set('StrokeStyle','SolidLine','simulink.Segment');
            rules.set('Opacity',0.8);
            rules.set('Glow',MG2.GlowEffect());

            stroke=MG2.Stroke;
            stroke.Color=[0.98,0.92,0.2,1.0];
            stroke.Width=4;
            stroke.JoinStyle='RoundJoin';
            stroke.ScaleFunction='SelectionNonLinear';
            rules.set('Trace',MG2.TraceEffect(stroke,'Inner'),'simulink.Block');
        end
    end



    methods(Access=public)
        function delete(styleObj)



            removeSubSystemStyling(styleObj);
            removePortBadge(styleObj);
            removeBlockBadge(styleObj);
            styleObj.CustomStyler.clearAllClasses;
            removeGeneralStyling(styleObj);
        end
    end



    methods(Access=public)
        function clearStyling(styleObj)
            removeCurrentTraceStyling(styleObj);
            removeSelectionStyling(styleObj);
            removeGeneralStyling(styleObj);
            removeRootStyling(styleObj);
            removeTraceAllStyling(styleObj);
            removeSubSystemStyling(styleObj);
        end
    end



    methods(Access=public)
        function removeCurrentTraceStyling(styleObj)
            styleObj.CurrentTraceElements.removeStylingForAllBDs(styleObj.CustomStyler,...
            styleObj.CurrentClass);
        end
    end



    methods(Access=public)
        function removeSelectionStyling(styleObj)
            styleObj.SelectionElements.removeStylingForAllBDs(styleObj.CustomStyler,...
            styleObj.SelectionClass);
        end
    end



    methods(Access=public)
        function removeRootStyling(styleObj)
            styleObj.RootElement.removeStylingForAllBDs(styleObj.CustomStyler,...
            styleObj.RootClass);
        end
    end



    methods(Access=public)
        function removeTraceAllStyling(styleObj)
            styleObj.ImpactRegionStyler.clearStyling();
        end
    end



    methods(Access=public)
        function removeSubSystemStyling(styleObj)
            keys=styleObj.SubSystemElements.keys;
            for i=1:length(keys)
                BD=keys{i};
                modelState=get_param(BD,'Dirty');
                styleObj.toggleWarningsOff;
                elements=styleObj.SubSystemElements(BD);
                for j=1:length(elements)
                    element=elements(j);
                    try
                        elementState=styleObj.SubSystemElementsState(element);
                        set_param(element,'ContentPreviewEnabled',elementState);
                    catch
                    end
                end
                set_param(BD,'Dirty',modelState);
                styleObj.toggleWarningsOn;
            end
        end
    end



    methods(Access=public)
        function removeGeneralStyling(styleObj)
            keys=styleObj.GeneralStyledElements.keys;
            if(isempty(keys))
                return;
            end

            for i=1:length(keys)
                key=keys{i};


                try
                    bdname=getfullname(key);
                    if(bdIsLoaded(bdname))
                        removeGeneralStylingForBD(styleObj,key);
                    end
                catch

                end
            end
        end
    end



    methods(Access=private)
        function removeGeneralStylingForBD(styleObj,BD)
            GlobalElementList=styleObj.GeneralStyledElements(BD);
            if(~isempty(GlobalElementList))

                instanceData=styleObj.getInstanceData;
                instanceData.bd2HighlightedElements(BD)=num2cell(GlobalElementList);
                slprivate('remove_hilite',BD);
                SLM3I.SLDomain.removeBdFromHighlightMode(BD);
                Simulink.Structure.HiliteTool.styleManager.removeStyler(BD);
            else
                removeHighlightOnlyBD(styleObj,BD);
            end
        end
    end




    methods(Access=private)
        function removeHighlightOnlyBD(styleObj,bdHandle)
            styler=diagram.style.getStyler(Simulink.Structure.HiliteTool.EmphasisStyleSheet.HIGHLIGHT_STYLER_NAME);
            styler.removeClass(bdHandle,Simulink.Structure.HiliteTool.EmphasisStyleSheet.BD_HIGHLIGHT_STYLER_TAG);
            remove(styleObj.GeneralStyledElements);
        end
    end



    methods(Access=public)
        function keysToRemove=undoStyling(styleObj,discardedGlobalElementMap,newGlobalElementMap)

            keysToRemove=[];
            styleObj.GeneralStyledElements=newGlobalElementMap;
            keys=discardedGlobalElementMap.keys;

            removeCurrentTraceStyling(styleObj);
            removeSelectionStyling(styleObj);



            for i=1:length(keys)
                key=keys{i};
                elementsToRemove=discardedGlobalElementMap(key);
                elementsToKeep=[];
                if(isKey(styleObj.GeneralStyledElements,key))
                    elementsToKeep=styleObj.GeneralStyledElements(key);
                end

                ind=ismember(elementsToRemove,elementsToKeep);

                if(~isempty(elementsToKeep)&&~all(ind))
                    elementsToRemove=elementsToRemove(~ind);
                    removeGeneralStylingForSelectElements(styleObj,num2cell(elementsToRemove));
                elseif(length(elementsToRemove)>=length(elementsToKeep))

                    instanceData=styleObj.getInstanceData;
                    instanceData.bd2HighlightedElements(key)=num2cell(elementsToRemove);
                    slprivate('remove_hilite',key);
                    SLM3I.SLDomain.removeBdFromHighlightMode(key);
                    Simulink.Structure.HiliteTool.styleManager.removeStyler(key);
                    keysToRemove=[keysToRemove,key];
                end
                blocksToRemove=find_system(elementsToRemove,'SearchDepth',0,'type','block');
                removeSubSystemStylingForSelectBlocks(styleObj,blocksToRemove,key);
            end

        end
    end



    methods(Access=public)
        function removeGeneralStylingForSelectElements(styleObj,elements)
            styler=diagram.style.getStyler(styleObj.HIGHLIGHT_STYLER_NAME);
            styler.removeClass(elements,styleObj.HIGHLIGHT_STYLER_TAG);
        end
    end



    methods(Access=public)
        function highlightOnlyBD(styleObj,BD)
            styler=diagram.style.getStyler(styleObj.HIGHLIGHT_STYLER_NAME);
            styler.applyClass(BD,styleObj.BD_HIGHLIGHT_STYLER_TAG);
            if(~isKey(styleObj.GeneralStyledElements,BD))
                styleObj.GeneralStyledElements(BD)=[];
            end
        end
    end





    methods(Access=public)
        function applyGeneralStyling(styleObj,CurrentBD,elements)

            if(isempty(elements))
                return;
            end


            Simulink.Structure.HiliteTool.styleManager.applyStyler(CurrentBD,elements);

            if(~isKey(styleObj.GeneralStyledElements,CurrentBD))
                styleObj.GeneralStyledElements(CurrentBD)=elements;
            else
                styleObj.GeneralStyledElements(CurrentBD)=...
                [styleObj.GeneralStyledElements(CurrentBD),elements];
            end

        end
    end



    methods(Access=public)
        function applySelectionStyling(styleObj,elements,bdHandle)




            removeSelectionStyling(styleObj);

            if(isempty(elements))
                return
            end

            styleObj.SelectionElements.setElements(bdHandle,elements);

            styleObj.SelectionElements.applyStyling(styleObj.CustomStyler,...
            styleObj.SelectionClass,...
            bdHandle);
        end
    end



    methods(Access=public)
        function applyCurrentTraceStyling(styleObj,elements,bdHandle)

            if(isempty(elements))
                return
            end

            styleObj.CurrentTraceElements.removeStyling(styleObj.CustomStyler,...
            styleObj.CurrentClass,...
            bdHandle);

            styleObj.CurrentTraceElements.setElements(bdHandle,elements);

            styleObj.CurrentTraceElements.applyStyling(styleObj.CustomStyler,...
            styleObj.CurrentClass,...
            bdHandle);
        end
    end



    methods(Access=public)
        function applyRootElementStyling(styleObj,elements,bdHandle)
            if(isempty(elements))
                return
            end

            styleObj.RootElement.removeStyling(styleObj.CustomStyler,...
            styleObj.RootClass,...
            bdHandle);

            styleObj.RootElement.setElements(bdHandle,elements);

            styleObj.RootElement.applyStyling(styleObj.CustomStyler,...
            styleObj.RootClass,...
            bdHandle);
        end
    end



    methods(Access=public)
        function hiliteInfo=applyTraceAllStyling(styleObj,segment,BD,toSrc,varargin)
            if(toSrc)
                hiliteInfo=styleObj.ImpactRegionStyler.styleSourceImpactRegion(segment,...
                BD);
            else
                hiliteInfo=styleObj.ImpactRegionStyler.styleDestinationImpactRegion(segment,...
                BD);
            end
        end
    end



    methods(Access=public)
        function bool=isTraceAllActive(styleObj)
            bool=styleObj.ImpactRegionStyler.isActive;
        end
    end



    methods(Access=private)
        function createPortBadge(styleObj)
            try
                b=diagram.badges.create('HiliteToolBadge','Port');
            catch
                b=diagram.badges.get('HiliteToolBadge','Port');
            end
            styleObj.PortBadge=b;
        end
    end



    methods(Access=private)
        function createBlockBadge(styleObj)
            try
                b=diagram.badges.create('HiliteToolBadge','BlockNorthEast');
            catch
                b=diagram.badges.get('HiliteToolBadge','BlockNorthEast');
            end
            styleObj.BlockBadge=b;
        end
    end



    methods(Access=private)
        function removePortBadge(styleObj)
            if(~isempty(styleObj.ActivePortWithBadge)&&~isempty(styleObj.PortBadge))
                port=diagram.resolver.resolve(styleObj.ActivePortWithBadge);
                styleObj.PortBadge.setVisible(port,false);
                styleObj.ActivePortWithBadge=[];
            end
        end
    end



    methods(Access=private)
        function removeBlockBadge(styleObj)
            if(~isempty(styleObj.ActiveBlockWithBadge)&&~isempty(styleObj.BlockBadge))
                block=diagram.resolver.resolve(styleObj.ActiveBlockWithBadge);
                styleObj.BlockBadge.setVisible(block,false);
                styleObj.ActiveBlockWithBadge=[];
            end
        end
    end



    methods(Access=public)
        function addBadgeToPortForTraceToSrc(styleObj,port)
            styleObj.ActivePortWithBadge=port;
            port=diagram.resolver.resolve(port);

            styleObj.PortBadge.Image=fullfile(styleObj.ImagePath,...
            'SourceBadge.png');
            styleObj.PortBadge.Tooltip=styleObj.getBadgeToolTip;
            styleObj.PortBadge.setVisible(port,true);
        end
    end



    methods(Access=public)
        function addBadgeToPortForTraceToDst(styleObj,port)
            styleObj.ActivePortWithBadge=port;
            port=diagram.resolver.resolve(port);

            styleObj.PortBadge.Image=fullfile(styleObj.ImagePath,...
            'DestinationBadge.png');
            styleObj.PortBadge.Tooltip=styleObj.getBadgeToolTip;
            styleObj.PortBadge.setVisible(port,true);
        end
    end



    methods(Access=public)
        function addBadgeToBlockForTraceToSrc(styleObj,block)
            styleObj.ActiveBlockWithBadge=block;
            block=diagram.resolver.resolve(block);

            styleObj.BlockBadge.Image=fullfile(styleObj.ImagePath,...
            'SourceBadge.png');
            styleObj.BlockBadge.Tooltip=styleObj.getBadgeToolTip;
            styleObj.BlockBadge.setVisible(block,true);
        end
    end



    methods(Access=public)
        function addBadgeToBlockForTraceToDst(styleObj,block)
            styleObj.ActiveBlockWithBadge=block;
            block=diagram.resolver.resolve(block);

            styleObj.BlockBadge.Image=fullfile(styleObj.ImagePath,...
            'DestinationBadge.png');
            styleObj.BlockBadge.Tooltip=styleObj.getBadgeToolTip;
            styleObj.BlockBadge.setVisible(block,true);
        end
    end



    methods(Static,Access=private)

        function str=getBadgeToolTip
            if(get_param(gcs,'SimulinkSubDomain')=="Simulink")
                msg=message('Simulink:HiliteTool:BadgeToolTipWithPortValueToggle');
            else
                msg=message('Simulink:HiliteTool:BadgeToolTip');
            end
            str=msg.getString;
        end

    end


    methods(Access=public)
        function applySubSystemStyling(styleObj,BD,blocks)

            if(isempty(blocks))
                return
            end
            styleObj.toggleWarningsOff;
            modelState=get_param(BD,'Dirty');
            applySubSystemStylingForSelectBlocks(styleObj,blocks,BD);
            if~strcmpi(get_param(BD,'Lock'),'on')

                set_param(BD,'Dirty',modelState);
            end
            styleObj.toggleWarningsOn;
        end
    end



    methods(Access=private)
        function removeSubSystemStylingForSelectBlocks(styleObj,blocks,BD)
            styleObj.toggleWarningsOff;
            blocksCurrentlyTransparent=getCurrentSubSystemElements(styleObj,BD);
            if(~isempty(blocksCurrentlyTransparent))
                toRemove=ismember(blocksCurrentlyTransparent,blocks);
                blocksToRemove=blocksCurrentlyTransparent(toRemove);
                styleObj.SubSystemElements(BD)=blocksCurrentlyTransparent(~toRemove);
                modelState=get_param(BD,'Dirty');
                for i=1:length(blocksToRemove)
                    element=blocksToRemove(i);
                    try
                        elementState=styleObj.SubSystemElementsState(element);
                        set_param(element,'ContentPreviewEnabled',elementState);
                    catch
                    end
                end
                set_param(BD,'Dirty',modelState);
            end
            styleObj.toggleWarningsOn;
        end
    end



    methods(Access=private)
        function applySubSystemStylingForSelectBlocks(styleObj,blocks,BD)
            blocksCurrentlyTransparent=getCurrentSubSystemElements(styleObj,BD);
            blocksToStyle=blocks(~ismember(blocks,blocksCurrentlyTransparent));
            blocksSuccessfullyStyled=[];
            for i=1:length(blocksToStyle)
                block=blocksToStyle(i);

                isBlockQualified=(~isempty(getGraphForStepIn(block))&&...
                strcmpi(get_param(block,'Mask'),'off'));

                if(isBlockQualified)
                    try
                        styleObj.SubSystemElementsState(block)=...
                        get_param(block,'ContentPreviewEnabled');
                        set_param(block,'ContentPreviewEnabled','on');
                        blocksSuccessfullyStyled=[blocksSuccessfullyStyled;...
                        block];
                    catch
                    end
                end
            end
            addSubSystemElements(styleObj,BD,blocksSuccessfullyStyled);
        end
    end



    methods(Access=private)
        function blocksCurrentlyTransparent=getCurrentSubSystemElements(styleObj,BD)
            if(isKey(styleObj.SubSystemElements,BD))
                blocksCurrentlyTransparent=styleObj.SubSystemElements(BD);
            else
                blocksCurrentlyTransparent=[];
            end
        end
    end



    methods(Access=private)
        function addSubSystemElements(styleObj,BD,newElements)
            if(isempty(newElements))
                return;
            end
            if(isKey(styleObj.SubSystemElements,BD))
                styleObj.SubSystemElements(BD)=[styleObj.SubSystemElements(BD);newElements];
            else
                styleObj.SubSystemElements(BD)=newElements;
            end
        end
    end



    methods(Static,Access=public)
        function fadeBlock(blockHandle)
            editor=GLUE2.Util.findAllEditors(get_param(bdroot(blockHandle),'name'));
            if(~isempty(editor))
                studio=editor.getStudio();
                studio.App.hiliteAndFadeObject(diagram.resolver.resolve(blockHandle),200);
            end
        end
    end





    methods(Static,Access=private)
        function toggleWarningsOff
            warning('off','Simulink:Commands:SetParamLinkChangeWarn');
        end

        function toggleWarningsOn
            warning('on','Simulink:Commands:SetParamLinkChangeWarn');
        end
    end



    methods(Access=public)
        function turnOnPortLablesOnTraceAllPath(styleObj,portsFromStepTracing)
            styleObj.ImpactRegionStyler.turnPortLabelsOn(portsFromStepTracing);
        end

        function turnOffPortLablesOnTraceAllPath(styleObj,portsFromStepTracing)
            styleObj.ImpactRegionStyler.turnPortLabelsOff(portsFromStepTracing);
        end

        function bool=getTraceAllPortDisplayState(styleObj)
            bool=styleObj.ImpactRegionStyler.portDisplayState;
        end
    end
end

