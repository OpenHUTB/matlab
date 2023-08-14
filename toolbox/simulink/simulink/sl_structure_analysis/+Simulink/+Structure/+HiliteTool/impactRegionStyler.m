classdef impactRegionStyler<handle




    properties(SetAccess=private,GetAccess=public,Hidden=true)
        portsArray;
        stylerObj;
        TraceAllElements;
        isActive;
        portDisplayState;
        BD;
    end

    properties(Constant)
        ImpactRegionStylerName='MathWorks.HiliteTool.ImpactRegionStyler';
        ImpactRegionClass='MathWorks.HiliteTool.ImpactRegionStyling';
    end



    methods
        function this=impactRegionStyler
            this.createCustomStyler;
            this.TraceAllElements=Simulink.Structure.HiliteTool.styleElementsContainer;
            this.isActive=false;
            this.portDisplayState=false;
            this.BD=[];
        end
    end



    methods(Access=public)
        function hiliteInfo=styleSourceImpactRegion(this,segment,BD,varargin)
            this.clearStyling();
            this.BD=BD;
            hiliteInfo=Simulink.Structure.HiliteTool.internal.getHiliteInfo(...
            true,...
            segment,...
            true);
            this.styleHiliteInfo(hiliteInfo);
        end
    end



    methods(Access=public)
        function hiliteInfo=styleDestinationImpactRegion(this,segment,BD,varargin)
            this.clearStyling();
            this.BD=BD;
            hiliteInfo=Simulink.Structure.HiliteTool.internal.getHiliteInfo(...
            false,...
            segment,...
            true);
            this.styleHiliteInfo(hiliteInfo);
        end
    end



    methods(Access=private,Static)
        function ports=getPortListFromCellArray(portsFromStepTracing)
            assert(iscell(portsFromStepTracing));
            ports=[];
            for i=1:length(portsFromStepTracing)
                ports=[ports;portsFromStepTracing{i}];
            end
            ports=ports';
        end
    end



    methods(Access=private)
        function styleHiliteInfo(this,hiliteInfo)
            hiliteMap=hiliteInfo.graphHighlightMap;
            participatingGraphHandles=[hiliteMap{:,1}];
            elementList=[];
            for i=1:length(participatingGraphHandles)
                elementList=[elementList,hiliteMap{i,2}];
            end
            this.applyTraceAllStyling(elementList);
        end
    end



    methods
        function clearStyling(this)
            this.removeTraceAllStyling();
        end
    end



    methods
        function turnPortLabelsOn(this,portsFromStepTracing)
            this.setPortLabelState('on',portsFromStepTracing);
            this.portDisplayState=true;
        end

        function turnPortLabelsOff(this,portsFromStepTracing)
            this.setPortLabelState('off',portsFromStepTracing);
            this.portDisplayState=false;
        end
    end



    methods(Access=private)
        function setPortLabelState(this,state,portsFromStepTracing)
            elements=this.TraceAllElements.getElements(this.BD);



            elements=get_param(elements,'handle');
            if(iscell(elements))
                elements=cell2mat(elements);
            end



            segs=find_system(elements,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'type','line');
            ports=get_param(segs,'SrcPortHandle');

            if(iscell(ports))
                ports=cell2mat(ports);
            end

            ports=ports';

            ports=unique(ports);
            if(~isempty(portsFromStepTracing))
                portsFromStepTracing=this.getPortListFromCellArray(portsFromStepTracing);
                ports=ports(~ismember(ports,portsFromStepTracing));
            end



            for j=1:length(ports)
                port=ports(j);
                if~strcmp(get_param(port,'ShowValueLabel'),state)
                    set_param(port,'ShowValueLabel',state);
                end
            end
        end
    end



    methods
        function delete(this)
            this.removeTraceAllStyling();
            this.removePortLabels();
        end
    end




    methods(Access=private)
        function createCustomStyler(this)
            this.stylerObj=diagram.style.getStyler(this.ImpactRegionStylerName);

            if(isempty(this.stylerObj))
                diagram.style.createStyler(this.ImpactRegionStylerName,1);
                this.stylerObj=diagram.style.getStyler(this.ImpactRegionStylerName);
            end
            addRulesAndClassNames(this);
        end
    end



    methods(Access=private)
        function addRulesAndClassNames(styleObj)
            styleObj.installTraceAllStyling;
        end
    end



    methods(Access=private)
        function installTraceAllStyling(this)
            import Simulink.Structure.HiliteTool.*
            rules=this.getTraceAllRule;
            this.stylerObj.addRule(rules,diagram.style.MultiSelector({this.ImpactRegionClass},{'Editor'}));
            mSelect=diagram.style.MultiSelector({'MathWorks.GLUE2Styler:Selected',...
            this.ImpactRegionClass},{'Editor'});
            [~]=this.stylerObj.addRule(styleManager.getSelectionBlockHighlighterRule,mSelect);
        end
    end



    methods(Static,Access=public)
        function rules=getTraceAllRule

            rules=diagram.style.Style;
            rules.set('FillStyle','Solid');
            rules.set('FillColor',[1,1,1,1],'simulink.Block');
            rules.set('FillColor',[1,1,1,1],'simulink.Segment');
            rules.set('StrokeColor',[0.0,0.0,0.0,1.0],'simulink.Block');
            rules.set('StrokeColor',[0.0,0.0,0.0,1.0],'simulink.Segment');
            rules.set('StrokeStyle','SolidLine','simulink.Block');
            rules.set('StrokeStyle','SolidLine','simulink.Segment');

            stroke=MG2.Stroke;
            stroke.Color=[1,1,1,1];
            stroke.JoinStyle='RoundJoin';
            stroke.ScaleFunction='SelectionNonLinear';
            stroke.Width=2.0;
            rules.set('Trace',MG2.TraceEffect(stroke,'Outer'),'simulink.Segment');
            stroke.Width=4.0;
            rules.set('Trace',MG2.TraceEffect(stroke,'Outer'),'simulink.Block');
        end
    end



    methods(Access=public)
        function applyTraceAllStyling(this,elements)
            if(isempty(elements))
                return
            end

            this.TraceAllElements.removeStyling(this.stylerObj,...
            this.ImpactRegionClass,...
            this.BD);

            this.TraceAllElements.setElements(this.BD,elements);

            this.TraceAllElements.applyStyling(this.stylerObj,...
            this.ImpactRegionClass,...
            this.BD);
            this.isActive=true;
        end
    end



    methods(Access=public)
        function removeTraceAllStyling(this)
            this.TraceAllElements.removeStylingForAllBDs(this.stylerObj,...
            this.ImpactRegionClass);
            this.isActive=false;
        end
    end



    methods(Access=private)
        function removePortLabels(this)
            this.setPortLabelState('off',[]);
            this.portDisplayState=false;
        end
    end
end
