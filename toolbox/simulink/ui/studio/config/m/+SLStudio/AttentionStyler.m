

classdef AttentionStyler<handle


    properties(Constant,Access=private)
        GreyEverythingStylerName='Mathworks.AttentionStyler.GreyEverything';
        NoGreyStylerStylerName='Mathworks.AttentionStyler.NoGrey';
        HighlightStylerName='Mathworks.AttentionStyler.Highlight';

        GreyEverythingClass='greyEverything';
        NoGreyClass='noGrey';
        NoGreySegmentClass='noGreySegment';
        HighlightClass='highlightSelected';
    end

    properties(Dependent,Access=private)
GreyEverythingStyler
NoGreyStyler
HighlightStyler
AllStylers
    end

    methods
        function applyGreyEverything(obj,objToStyle,varargin)
            params=obj.parseOptionalParameters(varargin);
            do=diagram.resolver.resolve(objToStyle);
            if(~isempty(params.HierarchyID))
                do=diagram.resolver.resolve({params.HierarchyID,do});
            end
            assert(~do.isNull);
            obj.NoGreyStyler.clearChildrenClasses(obj.NoGreyClass,do);
            obj.NoGreyStyler.clearChildrenClasses(obj.NoGreySegmentClass,do);
            obj.GreyEverythingStyler.applyClass(do,obj.GreyEverythingClass);
        end

        function applyNoGrey(obj,objsToStyle,varargin)
            params=obj.parseOptionalParameters(varargin);
            for i=1:numel(objsToStyle)
                do=diagram.resolver.resolve(objsToStyle(i));
                assert(~do.isNull);
                if(strcmp(do.type,'Segment'))


                    segH=Simulink.resolver.asHandle(do);


                    segHandles=segH;
                    processed=[];
                    while(~isempty(segHandles))
                        currentSegment=segHandles(1);
                        children=get_param(currentSegment,'LineChildren');
                        processed(end+1)=currentSegment;%#ok<AGROW>
                        segHandles(1)=[];
                        for idx=1:numel(children)




                            if(ismember(children(idx),processed))
                                children(idx)=-1;
                            end
                        end
                        children=children(children~=-1);
                        segHandles=[segHandles,children'];%#ok<AGROW>

                        do=diagram.resolver.resolve(currentSegment);
                        if(~isempty(params.HierarchyID))
                            do=diagram.resolver.resolve({params.HierarchyID,do});
                        end
                        assert(~do.isNull);
                        obj.NoGreyStyler.applyClass(do,obj.NoGreySegmentClass);
                        obj.NoGreyStyler.applyClass(do,obj.NoGreyClass);
                    end
                else
                    if(~isempty(params.HierarchyID))
                        do=diagram.resolver.resolve({params.HierarchyID,do});
                    end
                    assert(~do.isNull);
                    obj.NoGreyStyler.applyClass(do,obj.NoGreyClass);
                end
            end
        end

        function applyHighlight(obj,objToStyle,varargin)
            params=obj.parseOptionalParameters(varargin);
            do=diagram.resolver.resolve(objToStyle);
            assert(~do.isNull);

            if(strcmp(do.type,'Segment'))
                do=do.getParent();
            end
            if(~isempty(params.HierarchyID))
                do=diagram.resolver.resolve({params.HierarchyID,do});
            end

            obj.HighlightStyler.applyClass(do,obj.HighlightClass);



            obj.applyNoGrey(objToStyle,'HierarchyID',params.HierarchyID);
        end

        function removeCurrentHighlight(obj,diagObj,varargin)
            params=obj.parseOptionalParameters(varargin);
            diagObj=diagram.resolver.resolve(diagObj);
            if(~isempty(params.HierarchyID))
                diagObj=diagram.resolver.resolve({params.HierarchyID,diagObj});
            end
            obj.HighlightStyler.clearChildrenClasses(obj.HighlightClass,diagObj);
        end

        function clearAllStylers(obj,mdlHandle,varargin)
            params=obj.parseOptionalParameters(varargin);
            do=diagram.resolver.resolve(mdlHandle);
            if(~isempty(params.HierarchyID))
                do=diagram.resolver.resolve({params.HierarchyID,do});
            end
            obj.GreyEverythingStyler.clearClasses(do);
            obj.GreyEverythingStyler.clearChildrenClasses(obj.GreyEverythingClass,do);
            obj.NoGreyStyler.clearChildrenClasses(obj.NoGreyClass,do);
            obj.NoGreyStyler.clearChildrenClasses(obj.NoGreySegmentClass,do);
            obj.HighlightStyler.clearChildrenClasses(obj.HighlightClass,do);
        end
    end

    methods(Access=private)
        function params=parseOptionalParameters(~,inputs)








            defaultHid=[];
            p=inputParser;
            p.addParameter('HierarchyID',defaultHid);
            p.parse(inputs{:});
            params=p.Results;
        end
    end

    methods
        function styler=get.GreyEverythingStyler(obj)
            styler=diagram.style.getStyler(obj.GreyEverythingStylerName);

            if(isempty(styler))





                diagram.style.createStyler(obj.GreyEverythingStylerName,2700);
                styler=diagram.style.getStyler(obj.GreyEverythingStylerName);

                greyOutOpacity=.7;
                greyOutBackgroundColor=[0.95,0.95,0.95];


                diagram.style.Style.registerProperty('GreyEverything','bool');
                diagram.style.Style.registerProperty('SFExternalFillColorId','Color');
                diagram.style.Style.registerProperty('Wash','Color');

                greyBDStyle=diagram.style.Style;

                greyBDStyle.set('Wash',greyOutBackgroundColor,'simulink.Graph');
                greyBDStyle.set('Wash',greyOutBackgroundColor,'stateflow.Chart')
                greyBDStyle.set('SFExternalFillColorId',greyOutBackgroundColor);
                greyBDStyle.set('GreyEverything',true);






                slGreyEverythingStyle=diagram.style.Style;









                slGreyEverythingStyle.set('Opacity',1,'simulink.SegmentLabel');


                slGreyEverythingStyle.set('Opacity',greyOutOpacity);











                diagram.style.Style.registerProperty('SFStateOpacity','double');
                sfGreyEverythingStyle=diagram.style.Style;
                sfGreyEverythingStyle.set('Opacity',greyOutOpacity,'stateflow.Junction');
                sfGreyEverythingStyle.set('Opacity',greyOutOpacity,'stateflow.Transition');
                sfGreyEverythingStyle.set('SFStateOpacity',greyOutOpacity,'stateflow.State');

                greyAllSimulinkSelector=diagram.style.DescendantSelector({obj.GreyEverythingClass},{},{},{'simulink'});
                styler.addRule(slGreyEverythingStyle,greyAllSimulinkSelector);

                greyAllStateflowSelector=diagram.style.DescendantSelector({obj.GreyEverythingClass},{},{},{'stateflow'});
                styler.addRule(sfGreyEverythingStyle,greyAllStateflowSelector);

                classSelectorBDGrey=diagram.style.ClassSelector(obj.GreyEverythingClass);
                descendantSelectorBDGrey=diagram.style.DescendantSelector({obj.GreyEverythingClass},{},{},{});
                styler.addRule(greyBDStyle,classSelectorBDGrey);
                styler.addRule(greyBDStyle,descendantSelectorBDGrey);
            end
        end

        function styler=get.NoGreyStyler(obj)
            styler=diagram.style.getStyler(obj.NoGreyStylerStylerName);

            if(isempty(styler))
                diagram.style.createStyler(obj.NoGreyStylerStylerName,2900);
                styler=diagram.style.getStyler(obj.NoGreyStylerStylerName);


                noGreyStyle=diagram.style.Style;
                noGreyStyle.set('Shadow',MG2.ShadowEffect(1,3,[4,4],false));
                noGreyStyle.set('Opacity',1);

                diagram.style.Style.registerProperty('SFStateOpacity','double');

                noGreyStyle.set('SFStateOpacity',1,'stateflow.State');

                opacityForSegments=diagram.style.Style;
                opacityForSegments.set('Opacity',1);

                styler.addRule(noGreyStyle,diagram.style.ClassSelector(obj.NoGreyClass));
                styler.addRule(opacityForSegments,diagram.style.ClassSelector(obj.NoGreySegmentClass));
            end

        end

        function styler=get.HighlightStyler(obj)
            styler=diagram.style.getStyler(obj.HighlightStylerName);

            if(isempty(styler))
                diagram.style.createStyler(obj.HighlightStylerName,3000);
                styler=diagram.style.getStyler(obj.HighlightStylerName);


                highlightColor=diagram.style.Style;
                stroke=MG2.Stroke;

                stroke.Color=[0.07,0.678,0.992,1];
                stroke.Width=6;
                stroke.CapStyle='FlatCap';
                stroke.JoinStyle='RoundJoin';
                stroke.ScaleFunction='SelectionNonLinear';
                highlightColor.set('Trace',MG2.TraceEffect(stroke,'Outer'));
                shadow=MG2.ShadowEffect(1.0,5,[8,8],false);
                shadow.Color=[0.5,0.3,0];
                highlightColor.set('Shadow',shadow);


                styler.addRule(highlightColor,diagram.style.ClassSelector(obj.HighlightClass));
            end
        end


        function stylers=get.AllStylers(obj)
            stylers=...
            [obj.GreyEverythingStyler;...
            obj.NoGreyStyler;...
            obj.HighlightStyler];
        end

    end

end
