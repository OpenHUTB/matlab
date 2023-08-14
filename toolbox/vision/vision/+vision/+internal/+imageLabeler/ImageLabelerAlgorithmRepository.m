



classdef ImageLabelerAlgorithmRepository<vision.internal.labeler.AlgorithmRepository

    properties(Constant)


        PackageRoot='vision.labeler';



        TemporalContextClass='vision.labeler.mixin.Temporal';



        BlockedAutomationContextClass='vision.labeler.mixin.BlockedImageAutomation';

    end

    methods(Static)

        function repo=getInstance()
            persistent repository
            if isempty(repository)||~isvalid(repository)
                repository=vision.internal.imageLabeler.ImageLabelerAlgorithmRepository();
            end
            repo=repository;
        end
    end

    methods

        function tf=isAutomationAlgorithm(this,metaClass)

            tf=isAutomationAlgorithm@vision.internal.labeler.AlgorithmRepository(this,metaClass);

            tf=tf&&~hasTemporalContext(this,metaClass);
        end


        function tf=isBlockedAutomationAlgorithm(this,idx)

            tf=hasBlockedAutomationContext(this,idx);
        end


    end

    methods(Access=protected)

        function tf=hasTemporalContext(this,metaClass)



            metaSuperclass=metaClass.SuperclassList;
            superclasses={metaSuperclass.Name};

            expectedClass=this.TemporalContextClass;
            tf=ismember(expectedClass,superclasses);
        end


        function tf=hasBlockedAutomationContext(this,idx)


            algName=this.AlgorithmList{idx};
            metaClass=meta.class.fromName(algName);
            try
                metaSuperclass=metaClass.SuperclassList;
                superclasses={metaSuperclass.Name};
            catch
                tf=false;
                return;
            end

            expectedClass=this.BlockedAutomationContextClass;
            tf=ismember(expectedClass,superclasses);
        end
    end
end