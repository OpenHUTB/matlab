classdef SimObserverRepository<handle




    properties(Constant,GetAccess=private)

        SimObserverRepositoryInstance=IRInstrumentation.SimObserverRepository;
    end

    properties(GetAccess=private,SetAccess=private)
        ModelBlockIdObjMap;
    end

    properties(GetAccess=private,SetAccess=private)
        ModelBlockSLIntIdObjMap;
    end

    methods(Static)
        function obj=getInstance

            obj=IRInstrumentation.SimObserverRepository.SimObserverRepositoryInstance;
        end
    end

    methods(Access=private)
        function this=SimObserverRepository
            this.ModelBlockIdObjMap=Simulink.sdi.Map(char('a'),?handle);
            this.ModelBlockSLIntIdObjMap=Simulink.sdi.Map(double(1.0),?handle);

            mlock;
        end
    end

    methods(Hidden)
        allObj=getAllBlockIdObjects(this);
        allSLIdObj=getAllBlockSLInternalIdObjects(this);
        addSLBlockIdObjectToMap(this,uniqueId,blockObj);
        allSLIdObj=addSLInternalIdToMap(this,SLInternalUniqueId,blockObj);
        clearMapSLBlockIdObject(this);
        clearMapSLInternalIdObject(this);
    end

end
