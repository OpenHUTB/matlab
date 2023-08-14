classdef ModelElement<handle




    properties(SetAccess=private)

        Id;


        Width;


        Height;


        SourceUrl;


        Document;
    end

    properties(Access=protected)

        Widget='webview/widgets/App';
    end

    methods
        function h=ModelElement(document,id,width,height,sourceUrl)
            validateattributes(document,...
            {'slreportgen.webview.DocumentBase'},{'scalar'},mfilename,'Document',1);
            validateattributes(id,...
            {'char'},{'nonempty'},mfilename,'Id',2);
            validateattributes(width,...
            {'char'},{'nonempty'},mfilename,'Width',3);
            validateattributes(height,...
            {'char'},{'nonempty'},mfilename,'Height',4);
            validateattributes(sourceUrl,...
            {'char'},{'nonempty'},mfilename,'SourceUrl',5);

            h.Id=id;
            h.Width=width;
            h.Height=height;
            h.SourceUrl=sourceUrl;


            h.Document=document;
        end

        function el=createDomElement(h)

            el=mlreportgen.dom.CustomElement('div');


            style=sprintf('style:''width: %s; height: %s;''',h.Width,h.Height);
            src=sprintf('src:''%s''',h.SourceUrl);
            props=sprintf('%s, %s',style,src);

            idAttr=mlreportgen.dom.CustomAttribute('id',h.Id);
            typeAttr=mlreportgen.dom.CustomAttribute('data-dojo-type',h.Widget);
            propsAttr=mlreportgen.dom.CustomAttribute('data-dojo-props',props);


            el.CustomAttributes=[idAttr,propsAttr,typeAttr];

            append(el,mlreportgen.dom.CustomText());
        end

    end
end

