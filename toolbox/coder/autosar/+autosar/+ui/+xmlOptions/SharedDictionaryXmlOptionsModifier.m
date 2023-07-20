classdef SharedDictionaryXmlOptionsModifier<autosar.ui.xmlOptions.XmlOptionsModifier





    properties(Constant,Access=protected)
        MoveElementsMode='Alert';
    end

    properties(Access=private)
        M3IModelContext;
    end

    methods(Access=public)
        function this=SharedDictionaryXmlOptionsModifier(dialog,m3iModel)

            this@autosar.ui.xmlOptions.XmlOptionsModifier(dialog,m3iModel);


            [isSharedDictionary,dictFullName]=autosar.dictionary.Utils.isSharedM3IModel(m3iModel);
            assert(isSharedDictionary,'SharedDictionaryXmlOptionsModifier expects a shared m3iModel!');
            this.M3IModelContext=autosar.api.internal.M3IModelContext.createContext(dictFullName);
        end
    end

    methods(Access=protected)

        function value=getXmlOptionValue(this,optionName)
            import autosar.mm.util.XmlOptionsAdapter;
            m3iRoot=this.M3IModel.RootPackage.front();

            if XmlOptionsAdapter.isProperty(optionName)
                value=XmlOptionsAdapter.get(m3iRoot,optionName);
            elseif m3iRoot.has(optionName)
                value=m3iRoot.(optionName);
            else
                assert(false,'Unexpected xmlOption');
            end
        end

        function setXmlOption(this,optionName,newValue)
            m3iRoot=this.M3IModel.RootPackage.front();
            trans=M3I.Transaction(this.M3IModel);
            autosar.api.getAUTOSARProperties.setXmlOptionProperty(m3iRoot,...
            optionName,newValue,this.MoveElementsMode,this.M3IModelContext);
            trans.commit();
        end

        function[status,errMsg]=performConsistencyChecks(~)



            status=1;
            errMsg='';
        end
    end
end
