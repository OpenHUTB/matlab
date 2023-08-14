classdef(Hidden)UnnamedElement<handle




    properties(Constant,Access=private)






        EncodedNamePrefix='temp-';
    end

    methods(Static)


        function isUnanmed=isUnnamed(elementName)
            isUnanmed=~isempty(strfind(elementName,...
            autosar.api.UnnamedElement.EncodedNamePrefix));
        end



        function[propertyName,indexOfElement]=decodeName(unnamedElement)
            if contains(unnamedElement,'(')
                s=regexp(unnamedElement,...
                [autosar.api.UnnamedElement.EncodedNamePrefix...
                ,'(?<propertyName>\w+)\((?<indexOfElement>\d+)\)'],'names');
                indexOfElement=str2double(s.indexOfElement);
            else
                s=regexp(unnamedElement,...
                [autosar.api.UnnamedElement.EncodedNamePrefix...
                ,'(?<propertyName>\w+)'],'names');
                indexOfElement=[];
            end
            propertyName=s.propertyName;
        end





        function elementPath=getQualifiedName(m3iObj)

            function str=nGetName(obj)
                name=obj.getOne('Name');
                if name.isvalid()
                    str=name.toString();
                else


                    [propName,elementIndex]=autosar.api.UnnamedElement.getPropertyNameAndIndexOnParent(obj);
                    str=autosar.api.UnnamedElement.encodeName(propName,elementIndex);
                end
            end


            elementPath=nGetName(m3iObj);
            rootModel=m3iObj.rootModel;
            parent=m3iObj.containerM3I;
            while parent.isvalid()
                if parent==rootModel
                    break
                end
                str=nGetName(parent);
                elementPath=sprintf('%s/%s',str,elementPath);
                parent=parent.containerM3I;
            end


            elementPath=regexprep(elementPath,'^AUTOSAR','');
        end
    end

    methods(Static,Access='private')


        function[parentPropName,index]=getPropertyNameAndIndexOnParent(m3iObj)
            index=-1;

            parentPropertyAttr=Simulink.metamodel.arplatform.ModelFinder.getContainmentAttribute(m3iObj);
            parentPropName=parentPropertyAttr.name;
            isParentPropertySeq=~strcmp(parentPropertyAttr.upper,'1');
            if isParentPropertySeq
                m3iParent=m3iObj.containerM3I;
                index=autosar.mm.Model.findObjectIndexInSequence(m3iParent.(parentPropName),m3iObj);
            end
        end



        function elementName=encodeName(propertyName,index)
            if(index==-1)

                elementName=[autosar.api.UnnamedElement.EncodedNamePrefix,propertyName];
            else
                assert(isnumeric(index),'index is expected to be numeric');
                index=num2str(index);
                elementName=[autosar.api.UnnamedElement.EncodedNamePrefix...
                ,propertyName,'(',index,')'];
            end
        end
    end
end
