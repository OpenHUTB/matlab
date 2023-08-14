classdef DataDictionary<stm.internal.VariableReader.Base

    methods
        function this=DataDictionary(param,model)
            this=this@stm.internal.VariableReader.Base(param,model);
        end

        function value=getCurrentValue(this)
            sldd=Simulink.data.dictionary.open(this.getSlddName);
            dds=sldd.getSection('Design Data');
            name=this.Param.Name;
            if~dds.exist(name)
                dds=sldd.getSection('Configurations');
            end
            entry=dds.getEntry(name);
            value=entry.getValue;
        end

        function property=getSimInProperty(this)
            property=this.getSimInVariable;
        end

        function workspace=getVariableWorkspace(this)
            mdlRef=this.Param.ModelReference;
            if strlength(mdlRef)==0
                workspace='global-workspace';
            else
                workspace=mdlRef;
            end
        end
    end

    methods(Static)
        function mask=isSldd(sourceTypes)
            mask=endsWith(lower(sourceTypes),'.sldd')|sourceTypes=="data dictionary";
        end
    end

    methods(Access=private)
        function name=getSlddName(this)
            if strcmpi(this.Param.SourceType,'data dictionary')

                name=get_param(this.Model,'DataDictionary');
            else

                name=this.Param.SourceType;
            end
        end
    end
end
