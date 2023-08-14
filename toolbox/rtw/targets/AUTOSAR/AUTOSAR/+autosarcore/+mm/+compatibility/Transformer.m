




classdef Transformer<M3I.Transformer






    methods
        function rename(self,old,new)




            match=M3I.Context;
            match.RoleName=old;

            function cs=transform(context)
                cs=M3I.ContextSequence;
                ct=context;
                ct.RoleName=new;
                cs.addContext(ct);
            end

            self.addPreTransform(match,@transform);
        end

        function renameClass(self,roleName,typeName,newTypeName)







            match=M3I.Context;
            match.RoleName=roleName;
            function cs=transform(context)
                cs=M3I.ContextSequence;
                ct=context;
                if strcmp(ct.TypeName,typeName)
                    ct.TypeName=newTypeName;
                    ct.TypeUri=self.getTypeUri(newTypeName);
                end
                cs.addContext(ct);
            end
            self.addPreTransform(match,@transform);
            self.addPostTransform(match,@transform);
        end

        function setAttributeValue(self,element,attribute,...
            matchValue,replaceValue)















            match=M3I.Context;
            match.ParentRoleName=element;
            match.RoleName=attribute;

            function cs=transform(context)
                cs=M3I.ContextSequence;
                ct=context;
                newValue=regexprep(ct.getValue(),...
                matchValue,replaceValue);
                ct.setAttributeValue(newValue);
                cs.addContext(ct);
            end

            self.addPreTransform(match,@transform);
        end

        function replaceType(self,element,...
            matchType,newType)












            match=M3I.Context;
            match.ParentRoleName=element;
            function cs=transform(context)
                cs=M3I.ContextSequence;
                ct=context;
                if strcmp(ct.RoleName,'type')&&strcmp(ct.getValue(),matchType)
                    ct.setAttributeValue(newType);
                end
                cs.addContext(ct);
            end
            self.addPreTransform(match,@transform);
        end

        function renameAttribute(self,parentRoleName,parentTypeName,...
            oldAttributeName,newAttributeName)















            match=M3I.Context;
            match.ParentRoleName=parentRoleName;
            match.RoleName=oldAttributeName;

            function cs=transform(context)
                cs=M3I.ContextSequence;
                ct=context;
                if strcmp(context.ParentTypeName,parentTypeName)
                    ct.RoleName=newAttributeName;
                end
                cs.addContext(ct);
            end
            self.addPreTransform(match,@transform);
        end

        function transformAttributeValue(self,parentRoleName,...
            parentTypeName,attributeName,transformationMap)












            match=M3I.Context;
            match.ParentRoleName=parentRoleName;
            match.RoleName=attributeName;

            function cs=transform(context)
                cs=M3I.ContextSequence;
                ct=context;
                if strcmp(ct.ParentTypeName,parentTypeName)
                    switch ct.RoleName
                    case 'MemoryAllocationKeywordPolicy'
                        if transformationMap.isKey(ct.getValue)
                            newValue=transformationMap(ct.getValue);
                            ct.setAttributeValue(newValue);
                        else



                        end
                    case 'SectionType'
                        if transformationMap.isKey(ct.getValue)
                            newValue=transformationMap(ct.getValue);
                            ct.setAttributeValue(newValue);
                        else



                        end
                    otherwise
                        assert(false,'Unexpected field');
                    end
                end
                cs.addContext(ct);
            end
            self.addPreTransform(match,@transform);
        end

        function skipAttribute(self,parentRoleName,parentTypeName,...
            attributeName)













            match=M3I.Context;
            match.ParentRoleName=parentRoleName;
            match.ParentTypeName=parentTypeName;
            match.ParentTypeUri=self.getTypeUri(parentTypeName);
            match.RoleName=attributeName;

            function cs=transform(context)
                cs=M3I.ContextSequence;
                ct=context;
                ct.Skip=1;
                cs.addContext(ct);
            end
            self.addPreTransform(match,@transform);
            self.addPostTransform(match,@transform);
        end

        function skipElement(self,roleName,typeName)










            match=M3I.Context;
            match.RoleName=roleName;
            match.TypeName=typeName;
            match.TypeUri=self.getTypeUri(typeName);
            function cs=transform(context)
                cs=M3I.ContextSequence;
                ct=context;
                ct.Skip=1;
                cs.addContext(ct);
            end
            self.addPreTransform(match,@transform);
            self.addPostTransform(match,@transform);
        end

        function storeAttribute(self,roleName,typeName,...
            attributeName,retainElemToAttributeMap)












            match=M3I.Context;
            match.RoleName=roleName;
            match.TypeName=typeName;
            match.TypeUri=self.getTypeUri(typeName);

            function cs=transform(context)
                cs=M3I.ContextSequence;
                ct=context;
                for ii=1:ct.getAttributeCount
                    attributeLocalName=ct.getAttributeLocalName(ii);
                    if isequal(attributeLocalName,attributeName)
                        retainElemToAttributeMap(ct.getValue)=ct.getAttributeValue(ii);
                    end
                end

                cs.addContext(ct);
            end
            self.addPreTransform(match,@transform);
        end

    end

    methods(Static,Access=private)
        function typeUri=getTypeUri(typeName)


            strs=strsplit(typeName,'.');
            switch strs{3}
            case 'arplatform'
                typeUri='http://schema.mathworks.com/schemas/arplatform.xmi';
            case 'types'
                typeUri='http://schema.mathworks.com/schemas/types.xmi';
            case 'foundation'
                typeUri='http://schema.mathworks.com/schemas/foundation.xmi';
            otherwise
                assert(false,'Cannot form typeUri from typeName %s',typeName);
            end
        end
    end
end


