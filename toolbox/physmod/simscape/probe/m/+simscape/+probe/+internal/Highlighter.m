classdef Highlighter<handle



    properties(Constant,Access=private)
        HighlightStylerName='simscape.probe.highlight';
        HighlightClass='highlighted';
    end

    properties(Access=private)
        Highlighted;
    end

    properties(Dependent,Access=private)
HighlightStyler
    end

    methods
        function obj=Highlighter
            obj.Highlighted=containers.Map('KeyType','double','ValueType','logical');
        end
        function delete(obj)
            stillHighlighted=obj.Highlighted.keys;
            for i=1:numel(stillHighlighted);
                obj.removeHighlightInner(stillHighlighted{i})
            end
        end
        function applyHighlight(this,block)
            this.HighlightStyler.applyClass(toBlock(block),this.HighlightClass);
            this.Highlighted(get_param(block,'Handle'))=true;
        end
        function removeHighlight(this,block)
            this.removeHighlightInner(block);
            this.Highlighted.remove(get_param(block,'Handle'));
        end
    end

    methods(Access=private)
        function removeHighlightInner(this,block)
            this.HighlightStyler.removeClass(toBlock(block),this.HighlightClass);
        end
    end

    methods
        function styler=get.HighlightStyler(this)
            styler=diagram.style.getStyler(this.HighlightStylerName);
            if isempty(styler)
                diagram.style.createStyler(this.HighlightStylerName,10000);
                styler=diagram.style.getStyler(this.HighlightStylerName);
                styler.addRule(makeStyle(),diagram.style.ClassSelector(this.HighlightClass));
            end
        end
    end
end

function block=toBlock(block)
    block=diagram.resolver.resolve(block);
    assert(~block.isNull);
    assert(strcmp(block.type,'Block'));
end

function highlightedStyle=makeStyle()
    highlightedStyle=diagram.style.Style;
    stroke=MG2.Stroke;
    stroke.Color=[0.07,0.678,0.992,1];
    stroke.Width=6;
    stroke.CapStyle='FlatCap';
    stroke.JoinStyle='RoundJoin';
    stroke.ScaleFunction='SelectionNonLinear';
    highlightedStyle.set('Trace',MG2.TraceEffect(stroke,'Outer'));
    shadow=MG2.ShadowEffect(1.0,5,[8,8],false);
    shadow.Color=[0.5,0.3,0];
    highlightedStyle.set('Shadow',shadow);



    highlightedStyle.set('Shadow',MG2.ShadowEffect(1,3,[4,4],false));
    highlightedStyle.set('Opacity',1);
end