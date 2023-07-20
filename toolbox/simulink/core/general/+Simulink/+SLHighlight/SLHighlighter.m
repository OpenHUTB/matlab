





classdef SLHighlighter<handle

    properties


        params=struct('Highlight',[]);


        bdToStyleCount=containers.Map('KeyType','double',...
        'ValueType','int32');

        bd_hilight_tag='fadebd';
    end

    methods


        function hstyle=highlightElements(obj,blks,segments,bdHandle,varargin)





            hstyle=[];

            if ishandle(bdHandle)

                blks=reshape(blks,numel(blks),1);
                segments=reshape(segments,numel(segments),1);
                hstyle.handles=[blks;segments];

                index=ishandle(hstyle.handles);

                hstyle.handles=hstyle.handles(index);

                hstyle.bdHandle=bdHandle;


                styler=getStyler;


                if~obj.bdToStyleCount.isKey(bdHandle)
                    obj.bdToStyleCount(bdHandle)=0;
                end

                styler.applyClass(bdHandle,obj.bd_hilight_tag);


                [highlightStyle,tag,highlightSelectedBlocks]=createHighlightStyle(varargin{:});

                [hRule,hstyle.loopTags]=installStyle(tag,'simulink.Segment',...
                hstyle.handles,highlightStyle,highlightSelectedBlocks);

                hstyle.rules=hRule;
                hstyle.style=highlightStyle;
            end

            function[rule,loopTag]=installStyle(name,class,handles,style,highlightSelectedBlocks)

                if~isempty(handles)
                    obj.bdToStyleCount(bdHandle)=obj.bdToStyleCount(bdHandle)+1;
                    loopTag=strcat(name,int2str(obj.bdToStyleCount(bdHandle)));
                    bdName=get_param(bdHandle,'name');
                    loopTag=strcat(loopTag,'_');
                    loopTag=strcat(loopTag,bdName);

                    selector=diagram.style.ClassSelector(loopTag,class);
                    rule=styler.addRule(style,selector);

                    if highlightSelectedBlocks
                        applySelectedBlockHighlighting(styler,loopTag);
                    end

                    for i=1:length(handles)
                        styler.applyClass(handles(i),loopTag);
                    end
                else
                    rule=[];
                end
            end

        end

        function removeStyle(obj,hstyle)

            bdHandle=hstyle.bdHandle;

            if ishandle(bdHandle)
                obj.bdToStyleCount(bdHandle)=obj.bdToStyleCount(bdHandle)-1;

                styler=getStyler;


                if obj.bdToStyleCount(bdHandle)==0
                    styler.removeClass(bdHandle,obj.bd_hilight_tag);
                    obj.bdToStyleCount.remove(bdHandle);
                end


                if~isempty(hstyle.handles)
                    if ishandle(hstyle.rules)
                        remove(hstyle.rules);
                    end

                    for i=1:length(hstyle.handles)
                        if ishandle(hstyle.handles(i))
                            styler.removeClass(hstyle.handles(i),hstyle.loopTags);
                        end
                    end
                end
            end

        end

    end

    methods(Static)
        function o=Instance()
            persistent obj
            if isempty(obj)
                obj=Simulink.SLHighlight.SLHighlighter;
            end
            o=obj;

            mlock;
        end

    end
end



function styler=getStyler()

    stylerName='MathWorks.SLHighlight';

    styler=diagram.style.getStyler(stylerName);
    if isempty(styler)
        diagram.style.createStyler(stylerName);
        styler=diagram.style.getStyler(stylerName);

        fadeStyle=createFadeStyle();


        greyAllSimulinkSelector=diagram.style.DescendantSelector({'fadebd'},{},{},{'simulink'});
        styler.addRule(fadeStyle,greyAllSimulinkSelector);


        classSelectorBDGrey=diagram.style.ClassSelector('fadebd');
        styler.addRule(fadeStyle,classSelectorBDGrey);
    end


end

function style=createFadeStyle(varargin)
    style=diagram.style.Style;
    style.set('FillColor',[0.8,0.8,0.8,1.0]);
    style.set('FillStyle','Solid');
    style.set('TextColor',[0.5,0.5,0.5,1.0]);
    style.set('StrokeColor',[0.6,0.6,0.6,1.0]);
    style.set('Shadow',[]);
end

function applySelectedBlockHighlighting(styler,tag)


    selectionBlockHighlighter=diagram.style.Style;
    selectionBlockHighlighter.set('StrokeColor',[0.722,0.839,0.996,0.8]);
    selectionBlockHighlighter.set('StrokeWidth',3);

    selectionModifierSelector=diagram.style.MultiSelector({'MathWorks.GLUE2Styler:Selected',tag},{'Editor','Block'});
    styler.addRule(selectionBlockHighlighter,selectionModifierSelector);
end

function[style,tag,highlightSelectedBlocks]=createHighlightStyle(varargin)
    params.blockfillcolor=[1,1,1,1];
    params.blockedgecolor=[0,0,0,1];
    params.blocklinestyle='SolidLine';
    params.blocklinewidth=1.5;

    params.segmentcolor=[0,0,0,1];
    params.segmentlinestyle='SolidLine';
    params.segmentlinewidth=1.5;

    params.highlightcolor=[1,0,0,1];
    params.highlightwidth=1.5;
    params.highlightstyle='SolidLine';

    params.tag='Simulink';

    params.highlightselectedblocks=0;

    for i=1:2:nargin
        if ischar(varargin{i})...
            &&isfield(params,lower(varargin{i}))...
            &&(i+1<=nargin)...
            &&isequal(class(varargin{i+1}),class(params.(lower(varargin{i}))))...
            &&~isfield(params,lower(varargin{i+1}))
            params.(lower(varargin{i}))=varargin{i+1};
        else
            error('Wrong style parameters for highlights');
        end
    end

    style=diagram.style.Style;

    style.set('FillColor',params.blockfillcolor,'simulink.Block');
    style.set('FillColor',[1,1,1,1],'simulink.Segment');
    style.set('TextColor',[0,0,0,1]);

    style.set('StrokeColor',params.blockedgecolor,'simulink.Block');
    style.set('StrokeColor',params.segmentcolor,'simulink.Segment');

    stroke=MG2.Stroke;
    stroke.Color=params.highlightcolor;
    stroke.Width=params.highlightwidth;
    stroke.Style=params.highlightstyle;

    style.set('Trace',MG2.TraceEffect(stroke,'Outer'),'simulink.Block');

    style.set('Trace',MG2.TraceEffect(stroke,'Outer'),'simulink.Segment');

    style.set('StrokeStyle',params.blocklinestyle,'simulink.Block');

    style.set('StrokeStyle',params.segmentlinestyle,'simulink.Segment')
    style.set('StrokeWidth',params.blocklinewidth,'simulink.Block');
    style.set('StrokeWidth',params.segmentlinewidth,'simulink.Segment');

    tag=params.tag;
    highlightSelectedBlocks=params.highlightselectedblocks;

end
