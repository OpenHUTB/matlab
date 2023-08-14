classdef CodePreview<coder.preview.internal.CodePreviewBase














    properties
        DataType='DATATYPE'
        DataName='DATANAME'
        EntryType='StorageClass'
        CustomSymbolStrType='$N$R$M_T'
        TopModelName='TOPMODEL';
    end
    methods
        function obj=CodePreview(sourceDD,type,name)
            obj@coder.preview.internal.CodePreviewBase(sourceDD);
            if nargin>1
                obj.EntryType=type;
                obj.EntryName=name;
            end
        end
        out=getPreview(obj);

        out=getDeclaration(obj);

        out=getDefinition(obj);

        out=getDataAccess(obj);
    end
    methods(Access=private)

        out=pvt_getEntryStruct(obj);

        out=pvt_getDeclarationAndDefinitionPreview(obj,type);
        [msComment,msPreStatement,msPostStatement]=pvt_getMemorySection(obj,property,comment,prePragma,postPragma);

        function out=pvt_getDeclarationPreview(obj)
            out=obj.pvt_getDeclarationAndDefinitionPreview('Declaration');
        end
        function out=pvt_getDefinitionPreview(obj)
            out=obj.pvt_getDeclarationAndDefinitionPreview('Definition');
        end
    end
    methods(Static)
        function out=isSupportedType(type)
            out=any(strcmp(type,{'StorageClass','MemorySection','RTEDefinitions'}));
        end
    end
    methods
        function set.EntryType(obj,value)
            if~obj.isSupportedType(value)
                error('Type must be ''StorageClass'', ''MemorySection'', or ''RTEDefinitions''');
            end
            obj.EntryType=value;
        end
        function[ret,tokenStr]=resolveAccessFunctionNameToken(obj,fcnName)
            tokenStr=obj.getCodePreviewUsingNamingService(obj.ModelName,fcnName,obj.DataName,'',obj.CustomToken);
            tooltipStr=[message('SimulinkCoderApp:core:FunctionClassFunctionNameColumn').getString,': ',fcnName];
            classStr='tk';
            propertyStr=obj.DataName;
            previewStr=tokenStr;
            ret=obj.getPropertyPreview(tooltipStr,classStr,propertyStr,previewStr);
        end
        function[ret,tokenStr]=resolveHeaderFileToken(obj,str,headerFile,def)
            import coder.preview.internal.CodePreview
            tokenStr=obj.getCodePreviewUsingNamingService(obj.ModelName,str,obj.ModelName,def.Name,obj.CustomToken);
            tokenStr=obj.escapeHTML(tokenStr);

            tokenStr=regexprep(tokenStr,'^([^"<]*[^">])$','"$1"');
            tooltipStr=[message('SimulinkCoderApp:core:CoderGroupHeaderFileColumn').getString,': ',headerFile];
            classStr='tk';
            propertyStr='HeaderFile';
            previewStr=tokenStr;
            ret=obj.getPropertyPreview(tooltipStr,classStr,propertyStr,previewStr);
        end
        function[ret,tokenStr]=resolveDefinitionFileToken(obj,str,defFile,def)
            tokenStr=obj.getCodePreviewUsingNamingService(obj.ModelName,str,obj.ModelName,def.Name,obj.CustomToken);
            tokenStr=regexprep(tokenStr,'^([^"<]*[^">])$','"$1"');
            tooltipStr=[message('SimulinkCoderApp:core:CoderGroupDefinitionFileColumn').getString,': ',defFile];
            classStr='tk';
            propertyStr='DefinitionFile';
            previewStr=tokenStr;
            ret=obj.getPropertyPreview(tooltipStr,classStr,propertyStr,previewStr);
        end
        function[ret,tokenStr]=resolveStructTypeToken(obj,scType,dG,dR,dN,isSingleInstance)
            scTypeReplaced=scType;
            if~contains(scType,'$R')&&isempty(dN)


                scTypeReplaced=strrep(scType,'$N','$R');
            end
            if isSingleInstance
                tooltipStr=[message('SimulinkCoderApp:core:CoderGroupStructureTypeNameColumn').getString,': ',scType];
                propertyStr='TypeNamingRule';
            else
                tooltipStr=[message('SimulinkCoderApp:core:CoderGroupStructureTypeNameColumn').getString,' (',...
                message('SimulinkCoderApp:core:MultiInstanceStorage').getString,'): ',scType];
                propertyStr='MultiInstance.TypeNamingRule';
            end
            tokenStr=obj.escapeHTML(obj.getCodePreviewUsingNamingService(dR,scTypeReplaced,dN,dG,obj.CustomToken));
            classStr='tk';
            previewStr=tokenStr;
            ret=obj.getPropertyPreview(tooltipStr,classStr,propertyStr,previewStr);
        end
        function[ret,tokenStr]=resolveStructInstanceToken(obj,scInstanceName,dG,dR,dN,isSingleInstance)
            scInstanceNameReplaced=scInstanceName;
            if~contains(scInstanceName,'$R')&&isempty(dN)


                scInstanceNameReplaced=strrep(scInstanceName,'$N','$R');
            end
            if isSingleInstance
                tooltipStr=[message('SimulinkCoderApp:core:CoderGroupStructureInstanceNameColumn').getString,': ',scInstanceName];
                propertyStr='InstanceNamingRule';
            else
                tooltipStr=[message('SimulinkCoderApp:core:CoderGroupStructureInstanceNameColumn').getString,' (',...
                message('SimulinkCoderApp:core:MultiInstanceStorage').getString,'): ',scInstanceName];
                propertyStr='MultiInstance.InstanceNamingRule';
            end
            tokenStr=obj.escapeHTML(obj.getCodePreviewUsingNamingService(dR,scInstanceNameReplaced,dN,dG,obj.CustomToken));
            classStr='tk';
            previewStr=tokenStr;
            ret=obj.getPropertyPreview(tooltipStr,classStr,propertyStr,previewStr);
        end

        function[ret,pointerToParent]=resolvePlacement(obj,placementValue)
            if strcmp(placementValue,'InParent')
                pointerToParent='*';
                value=message('SimulinkCoderApp:core:InParentEnumLabel').getString;
            else
                pointerToParent='';
                value=message('SimulinkCoderApp:core:InSelfEnumLabel').getString;
            end
            tooltipStr=[message('SimulinkCoderApp:core:StructuredImplementationPlacementColumn').getString,': ',value];
            classStr='tk';
            propertyStr='Placement';
            ret=obj.getPropertyPreview(tooltipStr,classStr,propertyStr,pointerToParent);
        end
        function ret=getCodePreviewUsingNamingService(~,dR,token,dN,dG,dU)
            identifierResolver=coder.preview.internal.IdentifierResolver(...
            'R',dR,'N',dN,'G',dG,'U',dU);
            ret=identifierResolver.getIdentifier(token);
        end


        function text=addPragmaAroundDeclOrDefn(obj,text,msDefn,dName)


            if isempty(text)
                return;
            end
            ftMSComment='<span class="comment">';feMSComment='</span>';
            if~isempty(msDefn)&&~isempty(msDefn.PrePragma)
                assert(~isempty(dName));
                if strcmp(obj.EntryType,'MemorySection')
                    tooltipStr=[message('SimulinkCoderApp:core:MemorySectionPreStatementColumn').getString,': ',msDefn.PrePragma];
                else
                    tooltipStr=message('SimulinkCoderApp:ui:PreStatementOfMemorySectionTooltip').getString;
                end
                classStr='';
                propertyStr='PreStatement';
                previewStr=strrep(msDefn.PrePragma,'$N',obj.DataName);
                previewStr=strrep(previewStr,'$R',obj.ModelName);
                previewStr=obj.escapeHTML(previewStr);
                prePragma=obj.getPropertyPreview(tooltipStr,classStr,propertyStr,previewStr);
                if~isempty(prePragma)
                    text=[prePragma,newline,text];
                end
            end

            if~isempty(msDefn)&&~isempty(msDefn.PostPragma)
                assert(~isempty(dName));
                if strcmp(obj.EntryType,'MemorySection')
                    tooltipStr=[message('SimulinkCoderApp:core:MemorySectionPostStatementColumn').getString,': ',msDefn.PostPragma];
                else
                    tooltipStr=message('SimulinkCoderApp:ui:PostStatementOfMemorySectionTooltip').getString;
                end
                classStr='';
                propertyStr='PostStatement';
                previewStr=strrep(msDefn.PostPragma,'$N',obj.DataName);
                previewStr=strrep(previewStr,'$R',obj.ModelName);
                previewStr=obj.escapeHTML(previewStr);
                postPragma=obj.getPropertyPreview(tooltipStr,classStr,propertyStr,previewStr);
                if~isempty(postPragma)
                    text=[text,newline,postPragma];
                end
            end

            if~isempty(msDefn)&&~isempty(msDefn.Comment)
                if strcmp(obj.EntryType,'MemorySection')
                    tooltipStr=[message('SimulinkCoderApp:core:MemorySectionCommentColumn').getString,': ',msDefn.Comment];
                else
                    tooltipStr=message('SimulinkCoderApp:ui:CommentOfMemorySectionTooltip').getString;
                end
                classStr='';
                propertyStr='Comment';
                previewStr=obj.escapeHTML(msDefn.Comment);
                text=...
                [ftMSComment,...
                obj.getPropertyPreview(tooltipStr,classStr,propertyStr,previewStr),...
                feMSComment,newline...
                ,text];
            end
        end
    end
    methods(Access=private,Static=true)

        function ret=highlightSyntax(str)
            keywords={'static','extern'};
            ret=str;
            for i=1:length(keywords)
                ret=strrep(ret,keywords{i},['<span class="kw">',keywords{i},'</span>']);
            end
        end


        function txt=getKW(kw)
            txt=['<span class="kw">',kw,'</span>'];
        end
        function txt=getTK(txt)
            txt=['<span class="tk">',txt,'</span>'];
        end
        function txt=getPP(txt)
            txt=['<span class="pp">',txt,'</span>'];
        end
    end
    methods(Access=private)

        function section=FormatHeader(obj,header,content)








            section=obj.getPreviewSectionDiv(header,content);
        end

    end
end



