classdef ServiceInterface<coder.preview.internal.CodePreviewBase




    properties
EntryType
IdentifierResolver
    end

    properties(Access=protected)
Entry
    end

    methods
        function obj=ServiceInterface(sourceDD,type,name)

            obj@coder.preview.internal.CodePreviewBase(sourceDD);
            obj.IdentifierResolver=coder.preview.internal.IdentifierResolver(...
            'Placeholder','on');
            obj.IdentifierResolver.dR=obj.ModelName;
            if nargin>1
                obj.EntryType=type;
                obj.EntryName=name;
                obj.Entry=obj.getEntry;
                obj.IdentifierResolver.dG=name;
            end
        end

        out=getPreview(obj)

        function out=getDeclaration(~)



            out='';
        end

        function out=getDefinition(~)



            out='';
        end

        function out=getUsage(~)



            out='';
        end
    end


    methods
        function out=getServiceHeaderFileName(obj)

            out=obj.DD.ServicesHeaderFileName;
        end

        function out=getProperty(obj,name)

            out=obj.Entry.(name);
        end

        function out=getUsageHeader(obj)

            out=obj.getHTMLElement('span','previewHeader',...
            message('SimulinkCoderApp:ui:Usage').getString);
        end

        out=getFunctionName(obj,namingRule)
        out=getFunctionPrototype(obj,returnType,name,arg)
        out=getCallableFunctionPreview(obj,namingRule,body,options)
    end

    methods(Static)
        out=create(sourceDD,entryType,entryName)

        function out=slfeature(newValue)

            persistent value
            if isempty(value)
                value=1;
            end
            out=value;
            if nargin>0
                value=newValue;
            end
        end
    end
end


