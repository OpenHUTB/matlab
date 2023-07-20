classdef(Abstract)CodePreviewBase<handle




    properties
DD
EntryName
        ModelName='MODELNAME'
        FunctionName='FUNCTIONNAME'
        CustomToken='CUSTOMTOKEN'
        MangledToken='MANGLEDNAME'
    end

    properties(Abstract)
EntryType
    end

    methods
        function obj=CodePreviewBase(sourceDD,type,name)

            obj.DD=sourceDD;
            if nargin>1
                obj.EntryType=type;
                obj.EntryName=name;
            end
        end


        out=getEntry(obj)
    end

    methods(Abstract)

        out=getPreview(obj)
    end


    methods
        function out=getDefaultCallableFunctionName(obj)
            resolver=coder.preview.internal.IdentifierResolver(...
            'R',obj.ModelName,'N',obj.FunctionName);
            out=resolver.getIdentifier('$R$N');
        end

        function out=getPreviewNotAvailable(~)

            out.previewStr=message('SimulinkCoderApp:sdp:CodePreviewNotAvailable').getString;
            out.type='info';
        end

        function out=getPreviewSection(obj,text,type)

            out.previewStr=['<pre>',obj.getHTMLElement('div','previewSection',text),'</pre>'];
            out.type=type;
        end

        function out=getDeclarationHeader(obj)

            out=obj.getHTMLElement('span','previewHeader',...
            message('Simulink:dialog:CSCUIDeclaration').getString);
        end

        function out=getDefinitionHeader(obj)

            out=obj.getHTMLElement('span','previewHeader',...
            message('Simulink:dialog:CSCUIDefinition').getString);
        end

        function out=getPreviewSectionDiv(~,header,content)

            out=['<div class="previewSection">',header,...
            '<div class="previewcode">',content,'</div></div>'];
        end

        function out=getPreviewCodeDiv(obj,code)

            out=obj.getHTMLElement('div','previewcode',code);
        end

        function out=getComment(obj,text)

            out=obj.getHTMLElement('span','comment',text);
        end

        function out=getHTMLElement(~,tag,class,text)

            out=['<',tag,' class="',class,'">',text,'</',tag,'>'];
        end

        function str=getPropertyPreview(obj,tooltipStr,classStr,propertyStr,previewStr)

            str=sprintf('<span title="%s" class="property %s" property="%s">%s</span>',...
            obj.escapeHTML(tooltipStr),classStr,propertyStr,previewStr);
        end

        function txt=escapeHTML(~,txt)

            txt=strrep(txt,'&','&amp;');
            txt=strrep(txt,'"','&quot;');
            txt=strrep(txt,'<','&lt;');
            txt=strrep(txt,'>','&gt;');
            txt=strrep(txt,'%','&#37;');
            txt=strrep(txt,'\n',newline);
        end
    end
end



