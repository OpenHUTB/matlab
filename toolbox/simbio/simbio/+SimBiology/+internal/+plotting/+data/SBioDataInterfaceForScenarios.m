classdef SBioDataInterfaceForScenarios<SimBiology.internal.plotting.data.SBioDataInterfaceForScalarData

    properties(Access=private)
        samplesTable=[];
    end




    methods(Access=public)
        function obj=SBioDataInterfaceForScenarios(sbiodata,dataSource,~,~)
            obj.dataSource=dataSource;

            obj.data=sbiodata;
        end
    end




    methods(Access=public)
        function paramTable=getIndependentParameterTable(obj)
            paramTable=obj.getProcessedSamplesTable();

        end

        function paramTable=getDependentParameterTable(obj)
            paramTable=[];
        end

        function paramNames=getIndependentParameterNames(obj)
            paramNames=transpose(obj.getSamplesTable().Properties.VariableDescriptions);
        end

        function paramNames=getDependentParameterNames(obj)
            paramNames={};
        end
    end

    methods(Access=private)
        function samplesTable=getSamplesTable(obj)
            if isempty(obj.samplesTable)
                obj.samplesTable=obj.data.generate;
            end
            samplesTable=obj.samplesTable;
        end

        function sampleTable=getProcessedSamplesTable(obj)
            sampleTable=obj.getSamplesTable();
            for j=1:size(sampleTable,2)

                if isa(sampleTable{1,j},'SimBiology.Variant')||isa(sampleTable{1,j},'SimBiology.Dose')
                    names=get(sampleTable{:,j},'Name');
                    if ischar(names)
                        names={names};
                    end
                    names=categorical(names);
                    valueset=unique(names,'stable');
                    sampleTable.(sampleTable.Properties.VariableNames{j})=categorical(names,valueset,'Ordinal',true);
                end
            end
        end
    end
end