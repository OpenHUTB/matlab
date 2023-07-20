classdef LabelledConnectionNodeStyler<handle

    properties(SetAccess=private,GetAccess=public,Hidden=true)
        stylerObj;
    end

    properties(Constant)
        LCNStylerClass='highlightSelected';
    end



    methods
        function this=LabelledConnectionNodeStyler
            this.createCustomStyler;
        end
    end



    methods(Access=public)


        function isHighlighted=isElementAlreadyHighlighted(this,element)
            isHighlighted=false;

            if isempty(this.stylerObj)
                this.stylerObj=diagram.style.getStyler(this.LCNStylerClass);
            end



            if this.stylerObj.hasClass(element,this.LCNStylerClass)
                isHighlighted=true;
            end
        end


        function applyHighlighting(this,elements)
            if isempty(this.stylerObj)
                this.stylerObj=diagram.style.getStyler(this.LCNStylerClass);
            end

            arrayfun(@(x)this.stylerObj.applyClass(x,this.LCNStylerClass),elements);
        end


        function removeHighlighting(this,elements)
            if isempty(this.stylerObj)
                this.stylerObj=diagram.style.getStyler(this.LCNStylerClass);
            end

            arrayfun(@(x)this.stylerObj.removeClass(x,this.LCNStylerClass),elements);
        end
    end




    methods(Access=private)
        function createCustomStyler(this)
            this.stylerObj=diagram.style.getStyler(this.LCNStylerClass);


            if isempty(this.stylerObj)
                diagram.style.createStyler(this.LCNStylerClass,3000);
                this.stylerObj=diagram.style.getStyler(this.LCNStylerClass);



                style=diagram.style.Style;%#ok<*MCNPR>
                stroke=MG2.Stroke;
                stroke.Color=[1,0.933,0,1];
                stroke.Width=6;
                stroke.CapStyle='FlatCap';
                stroke.JoinStyle='RoundJoin';
                stroke.ScaleFunction='SelectionNonLinear';
                style.set('Trace',MG2.TraceEffect(stroke,'Outer'));%#ok<MCNPN>
                shadow=MG2.ShadowEffect(1.0,5,[8,8],false);
                shadow.Color=[0.5,0.3,0];
                style.set('Shadow',shadow);%#ok<MCNPN>
                this.stylerObj.addRule(style,diagram.style.ClassSelector(this.LCNStylerClass));%#ok<MCNPN>
            end

        end
    end
end