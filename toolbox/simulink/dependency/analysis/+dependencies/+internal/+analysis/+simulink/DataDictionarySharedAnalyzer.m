classdef DataDictionarySharedAnalyzer<dependencies.internal.analysis.SharedAnalyzer




    properties(Constant)
        Name="SLDD";
    end

    properties(Constant,Access=private)
        SLDDFilter=dependencies.internal.graph.NodeFilter.fileExists(".sldd")
    end

    properties(GetAccess=private,SetAccess=immutable)
        Dictionaries;
    end

    methods

        function this=DataDictionarySharedAnalyzer()
            this.Dictionaries=containers.Map;
        end

        function vars=getVariables(this,dictionary)
            info=this.getInfo(dictionary);
            vars=info.Variables;
        end

        function refs=getReferences(this,dictionary)
            info=this.getInfo(dictionary);
            refs=info.References;
        end

        function deps=finalize(~)
            deps=dependencies.internal.graph.Dependency.empty;
        end

    end

    methods(Access=private)

        function info=getInfo(this,dictionary)
            if this.Dictionaries.isKey(dictionary)
                info=this.Dictionaries(dictionary);
            else


                info=struct('Variables',{{}},'References',{{}});
                this.Dictionaries(dictionary)=info;

                [vars,subdict,refs]=Simulink.loadsave.findAll(...
                dictionary,...
                "/DataSource/Object[Class='DD.ENTRY']/Name",...
                "/DataSource/Object[Class='DD.DICTIONARYREFERENCE']/Subdictionary",...
                "/MF0/Dictionary/Reference/URI");

                info.Variables={vars{1}.Value};

                references={subdict{1}.Value,refs{1}.Value};
                if isempty(references)
                    info.References=dependencies.internal.graph.Node.empty(1,0);
                else
                    info.References=cellfun(@dependencies.internal.analysis.findFile,references);
                end

                for node=this.SLDDFilter.filter(info.References)
                    refinfo=this.getInfo(node.Path);
                    info.Variables=[info.Variables,refinfo.Variables];
                end

                this.Dictionaries(dictionary)=info;
            end
        end

    end

end
