classdef DefinitionFiles




    properties(Hidden=true)
        factory;
    end

    methods(Hidden=true)
        function type=DefinitionFiles(factory)
            type.factory=factory;
        end

        function factory=getFactory(type)
            factory=type.factory;
        end
    end

    enumeration
        SingleFile(com.mathworks.toolbox.slproject.project.metadata.monolithic.MonolithicManagerFactory);
        FixedPathMultiFile(com.mathworks.toolbox.slproject.project.metadata.fixedpath_v2.FixedPathMetadataManagerFactoryV2);
        MultiFile(com.mathworks.toolbox.slproject.project.metadata.distributed.DistributedMetadataManagerFactory);
    end

end

