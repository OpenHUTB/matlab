classdef Information<handle




    properties(Hidden)
Release
Platform
ModelName
SubModels
SlprjVersion
SupportsModelReferenceSimTarget
SupportsModelReferenceRTWTarget
SupportsRapidAccelerator
SupportsAccelerator
SupportsVarCache
IsVMAcceleratorTarget
        Checksums=struct('ModelReferenceSimTarget','',...
        'RapidAccelerator','',...
        'Accelerator','',...
        'VarCache','')
    end





    properties(Hidden,Transient,GetAccess=private,SetAccess=immutable)
        LicensesEditTime={}
        LicensesRunTime={}
        ProductsUsed={}
    end

    methods



        function result=supportsModelReferenceSimTarget(obj)
            result=obj.SupportsModelReferenceSimTarget;
        end


        function result=supportsRapidAccelerator(obj)
            result=obj.SupportsRapidAccelerator;
        end


        function result=supportsAccelerator(obj)
            result=obj.SupportsAccelerator;
        end


        function result=supportsVarCache(obj)
            result=obj.SupportsVarCache;
        end


        function result=getIsVMAcceleratorTarget(obj)
            result=obj.IsVMAcceleratorTarget;
        end


        function result=getSlprjVersion(obj)
            result=obj.SlprjVersion;
        end


        function result=getSubModels(obj)
            result=obj.SubModels;
        end


        function result=getSimTargetChecksum(obj)
            result=obj.Checksums.ModelReferenceSimTarget;
        end


        function result=getRapidAcceleratorChecksum(obj)
            result=obj.Checksums.RapidAccelerator;
        end

        function result=getAcceleratorChecksum(obj)
            result=obj.Checksums.Accelerator;
        end

        function result=getVarCacheChecksum(obj)
            result=obj.Checksums.VarCache;
        end

    end


    methods(Static)


        function result=loadobj(s)

            props={'SupportsAccelerator','IsVMAcceleratorTarget','SupportsVarCache'};
            checksumProps={'Accelerator','VarCache'};
            for i=1:numel(props)
                aProp=props{i};
                if isempty(s.(aProp))
                    s.(aProp)=false;
                end
            end
            for i=1:numel(checksumProps)
                aProp=checksumProps{i};
                if~isfield(s.Checksums,aProp)
                    s.Checksums.(aProp)='';
                end
            end

            result=s;
        end
    end
end


