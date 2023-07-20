classdef Grid<sequencediagram.quasiannotation.internal.BaseAnnotation





































    properties(SetObservable)





        GridSpec(1,:)struct=struct(...
        'GridSize',{10,100,1000},...
        'LineThickness',{1,3,8},...
        'LineColor',{"#ccc","#ddd","#ddd"}...
        )



        Size(1,2)double{mustBeReal,mustBeFinite,mustBeNonnegative}=[800,1200];
    end

    methods
        function obj=Grid(varargin)
            obj=obj@sequencediagram.quasiannotation.internal.BaseAnnotation(varargin{:});
        end
    end

    methods(Hidden)
        function html=generateHTML(obj)
            document=matlab.io.xml.dom.Document('div');
            rootDiv=document.getDocumentElement();

            id=obj.getHtmlId();
            rootDiv.setAttribute('id',id);


















            sizeStyleString=...
            "width: "+obj.Size(1)+"px;"+...
            "height: "+obj.Size(2)+"px;";

            styleString=...
            "position: absolute;"+...
            "left: 0px;"+...
            "right: 0px;"+...
            "margin: 0px;"+...
            "z-index: -2147483648;"+...
            sizeStyleString;
            rootDiv.setAttribute('style',styleString);

            arrayfun(...
            @(spec)obj.addGridDiv(document,rootDiv,spec.GridSize,spec.LineColor,spec.LineThickness),...
            obj.GridSpec);

            writer=matlab.io.xml.dom.DOMWriter;
            writer.Configuration.XMLDeclaration=false;

            html=writer.writeToString(rootDiv);
        end
    end

    methods(Access=private)
        function addGridDiv(~,document,parent,gridSize,gridLineColor,lineThickness)
            gridDiv=document.createElement('div');








            gridBackgroundImageStyling=...
            "background-image: "+...
            "repeating-linear-gradient("+gridLineColor+" 0, "+gridLineColor+" "+lineThickness+"px, transparent "+lineThickness+"px, transparent 100%), "+...
            "repeating-linear-gradient( 90deg, "+gridLineColor+" 0, "+gridLineColor+" "+lineThickness+"px, transparent "+lineThickness+"px, transparent 100%);";

            gridSizeStyling=...
            "background-size: "+gridSize+"px "+gridSize+"px;";

            styleString=...
            "position: absolute;"+...
            "width: 100%;"+...
            "height: 100%;"+...
            "margin: 0px;"+...
            gridSizeStyling+...
            gridBackgroundImageStyling;

            gridDiv.setAttribute('style',styleString);

            parent.appendChild(gridDiv);
        end
    end
end


