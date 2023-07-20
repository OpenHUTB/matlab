classdef(Abstract,Hidden)NamedElement<Simulink.interface.dictionary.BaseElement





    properties(Dependent=true)
        Name{mustBeTextScalar}
    end

    methods
        function this=NamedElement(zcImpl,dictImpl)
            this@Simulink.interface.dictionary.BaseElement(zcImpl,dictImpl);
        end

        function set.Name(this,name)
            this.setName(name);
        end

        function name=get.Name(this)
            name=this.getName();
        end

        function show(this)



            dictObj=this.getDictionary();
            dictObj.show();
            studioApp=sl.interface.dictionaryApp.StudioApp.findStudioAppForDict(dictObj.filepath());

            studioApp.showEntry(this);
        end
    end


    methods(Access=protected)
        function value=getName(this)
            zcWrapper=this.getZCWrapper();
            if~isempty(zcWrapper)

                value=this.getZCWrapper().Name;
            else

                value=this.getZCImpl.getName;
            end
        end

        function setName(this,value)
            this.getZCWrapper().setName(value);
        end

        function setDDEntryPropValue(this,propName,newValue)
            this.getDictionary().getDesignDataContents().setDDEntryPropertyValue(...
            this.Name,propName,newValue)
        end

        function value=getDDEntryPropValue(this,propName)
            value=this.getDictionary().getDesignDataContents().getDDEntryPropertyValue(...
            this.Name,propName);
        end
    end
end


