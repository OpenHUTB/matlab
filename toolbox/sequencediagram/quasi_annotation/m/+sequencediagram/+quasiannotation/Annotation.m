classdef Annotation<sequencediagram.quasiannotation.internal.BaseAnnotation

    properties(SetObservable)
        Text(1,1)string
        Position(1,2)double{mustBeReal,mustBeFinite,mustBeNonnegative}=[10,10];
        Size(1,2)double{mustBeReal,mustBeFinite,mustBeNonnegative}=[100,50];
    end

    methods
        function obj=Annotation(varargin)
            obj=obj@sequencediagram.quasiannotation.internal.BaseAnnotation(varargin{:});
        end
    end

    methods(Hidden)
        function html=generateHTML(obj)
            document=matlab.io.xml.dom.Document('div');
            annotationDiv=document.getDocumentElement();

            id=obj.getHtmlId();
            annotationDiv.setAttribute('id',id);

            styleString=...
            "position:absolute;"+...
            "width:"+obj.Size(1)+"px;"+...
            "height:"+obj.Size(2)+"px;"+...
            "left:"+obj.Position(1)+"px;"+...
            "top:"+obj.Position(2)+"px;";
            annotationDiv.setAttribute('style',styleString);

            annotationDiv.TextContent=obj.Text;

            writer=matlab.io.xml.dom.DOMWriter;
            writer.Configuration.XMLDeclaration=false;

            html=writer.writeToString(annotationDiv);
        end
    end
end

