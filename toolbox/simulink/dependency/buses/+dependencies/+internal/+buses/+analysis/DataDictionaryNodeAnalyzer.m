classdef DataDictionaryNodeAnalyzer<dependencies.internal.analysis.FileAnalyzer




    properties(Constant)
        Extensions=".sldd";
        BaseType="DataDictionary";
    end

    methods
        function deps=analyze(this,handler,fileNode)
            file=fileNode.Location{1};
            [~,name,ext]=fileparts(file);
            source=strcat(name,ext);

            wasOpen=ismember(file,Simulink.data.dictionary.getOpenDictionaryPaths);
            dictionary=Simulink.data.dictionary.open(file);
            section=dictionary.getSection('Design Data');

            buses=i_findEntries(section,'Simulink.Bus',source);
            signals=i_findEntries(section,'Simulink.Signal',source);
            structs=i_findEntries(section,'struct',source);

            import dependencies.internal.buses.util.analyzeBusObjects;
            import dependencies.internal.buses.util.analyzeSignalObjects;
            import dependencies.internal.buses.util.analyzeBusStructs;
            deps=[analyzeBusObjects(handler.Analyzers.Bus.BusNode,fileNode,buses,this.BaseType)...
            ,analyzeSignalObjects(handler.Analyzers.Bus.BusNode,fileNode,signals,this.BaseType)...
            ,analyzeBusStructs(handler.Analyzers.Bus.BusNode,fileNode,structs,this.BaseType)];
            if~wasOpen
                try
                    Simulink.data.dictionary.closeAll(source)
                catch


                end
            end
        end
    end

end

function data=i_findEntries(section,type,source)
    entries=section.find('-value','-isa',type);
    entries=entries(strcmp({entries.DataSource},source));
    if~isrow(entries)
        entries=entries';
    end
    data=struct;
    for entry=entries
        data.(entry.Name)=entry.getValue;
    end
end
