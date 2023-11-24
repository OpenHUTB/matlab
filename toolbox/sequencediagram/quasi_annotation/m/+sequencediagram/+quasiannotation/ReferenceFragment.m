classdef ReferenceFragment<sequencediagram.quasiannotation.internal.BaseAnnotation

    properties(SetObservable)

        ParentModelName(1,1)string

        SequenceDiagramName(1,1)string

        Comment(1,1)string

        Position(1,2)double{mustBeReal,mustBeFinite,mustBeNonnegative}=[25,10];
        Size(1,2)double{mustBeReal,mustBeFinite,mustBeNonnegative}=[100,50];
    end

    methods
        function obj=ReferenceFragment(varargin)
            obj=obj@sequencediagram.quasiannotation.internal.BaseAnnotation(varargin{:});
        end
    end

    methods(Hidden)
        function html=generateHTML(obj)

            document=matlab.io.xml.dom.Document('div');
            fragmentRootDiv=obj.createRootDiv(document);
            obj.addFragmentTypeDiv(document,fragmentRootDiv);
            obj.addFakeOperandWithLinkAndComment(document,fragmentRootDiv)

            writer=matlab.io.xml.dom.DOMWriter;
            writer.Configuration.XMLDeclaration=false;

            html=writer.writeToString(fragmentRootDiv);
        end
    end

    methods(Access=private)
        function fragmentRootDiv=createRootDiv(obj,document)
            fragmentRootDiv=document.getDocumentElement();

            id=obj.getHtmlId();
            fragmentRootDiv.setAttribute('id',id);

            styleString=...
            "position:absolute;"+...
            "width:"+obj.Size(1)+"px;"+...
            "height:"+obj.Size(2)+"px;"+...
            "left:"+obj.Position(1)+"px;"+...
            "top:"+obj.Position(2)+"px;";
            fragmentRootDiv.setAttribute('style',styleString);

            cssClassString="glyph diagram-entity sequencediagram-compositefragment";
            fragmentRootDiv.setAttribute('class',cssClassString);
        end

        function addFragmentTypeDiv(~,document,fragmentRootDiv)
            fragmentTypeDiv=document.createElement('div');
            fragmentTypeDiv.setAttribute('class','title obscuresLifeline');

            fragmentTypeStringDiv=document.createElement('div');
            fragmentTypeStringDiv.setAttribute('class','compositeFragmentType_shortName obscuresLifeline');
            fragmentTypeStringDiv.TextContent="Ref";

            fragmentTypeDiv.appendChild(fragmentTypeStringDiv);
            fragmentRootDiv.appendChild(fragmentTypeDiv);
        end

        function addFakeOperandWithLinkAndComment(obj,document,fragmentRootDiv)
            operandDiv=obj.addFakeOperand(document,fragmentRootDiv);
            obj.addSequenceDiagramLink(document,operandDiv);
            obj.addComment(document,operandDiv);
        end

        function operandDiv=addFakeOperand(~,document,fragmentRootDiv)
            operandDiv=document.createElement('div');

            operandDiv.setAttribute('class','glyph diagram-entity sequencediagram-operand');

            styleString=...
            "top: 25px;"+...
            "left: 1px;"+...
            "width: 100%;"+...
            "height: calc(100% - 25px);";
            operandDiv.setAttribute('style',styleString);

            fragmentRootDiv.appendChild(operandDiv);
        end

        function addSequenceDiagramLink(obj,document,operandDiv)
            if strlength(obj.SequenceDiagramName)==0
                return;
            end

            linkText="";
            if strlength(obj.ParentModelName)~=0
                linkText=linkText+obj.ParentModelName+" : ";
            end
            linkText=linkText+obj.SequenceDiagramName;

            sequenceDiagramLink=document.createElement('a');
            sequenceDiagramLink.TextContent=linkText;

            clickFcn=sequencediagram.quasiannotation.internal.EditorInterface.getRunMatlabFunctionFromJavascriptString(...
            'sequencediagram.quasiannotation.ReferenceFragment.openSequenceDiagram',...
            {obj.UUID});

            sequenceDiagramLink.setAttribute('href',"#");
            sequenceDiagramLink.setAttribute('onclick',clickFcn);

            operandDiv.appendChild(sequenceDiagramLink);
        end

        function addComment(obj,document,operandDiv)
            if strlength(obj.Comment)==0
                return;
            end

            obj.addLineBreak(document,operandDiv);

            commentNode=document.createElement('span');
            commentNode.TextContent=obj.Comment;

            operandDiv.appendChild(commentNode);
        end

        function addLineBreak(~,document,parent)
            brNode=document.createElement('br');
            parent.appendChild(brNode);
        end

        function openSequenceDiagramImpl(obj,modelName)



            if strlength(obj.ParentModelName)~=0
                parentModel=obj.ParentModelName;
            else
                parentModel=modelName;
            end

            ei=sequencediagram.quasiannotation.internal.EditorInterface.getInstance();
            ei.openSequenceDiagram(parentModel,obj.SequenceDiagramName);
        end
    end

    methods(Hidden,Static)
        function openSequenceDiagram(annotationUuid)





            app=sequencediagram.quasiannotation.App.getInstance();
            [annotation,modelManager]=app.findAnnotationFromUuid(annotationUuid);
            if~isempty(annotation)
                modelName=get_param(modelManager.ModelHandle,'name');
                annotation.openSequenceDiagramImpl(modelName);
            end
        end
    end
end


