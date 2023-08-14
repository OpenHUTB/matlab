classdef TypeBuilder<autosar.mm.mm2ara.ARABuilder













    properties
        RefTypesQNameToARADataMap;
        App2ImpTypeQNameMap;
        ImpTypeQNameToM3iTypeMap;
    end
    methods(Access=public)



        function this=TypeBuilder(araGenerator,m3iComponent)
            this=this@autosar.mm.mm2ara.ARABuilder(araGenerator,m3iComponent);
            this.RefTypesQNameToARADataMap=containers.Map;
            this.App2ImpTypeQNameMap=containers.Map();
            this.ImpTypeQNameToM3iTypeMap=containers.Map();



            m3iModel=m3iComponent.rootModel;
            m3iDataTypeMappingSeq=M3I.SequenceOfClassObject.make(m3iModel);
            autosar.mm.arxml.Exporter.findByBaseType(...
            m3iDataTypeMappingSeq,m3iModel,...
            'Simulink.metamodel.arplatform.common.DataTypeMappingSet');
            for mIdx=1:m3iDataTypeMappingSeq.size()
                dtMapVec=m3iDataTypeMappingSeq.at(mIdx).dataTypeMap;

                for idx=1:dtMapVec.size
                    dtMap=dtMapVec.at(idx);
                    appTypeQName=dtMap.ApplicationType.qualifiedName;
                    impTypeQName=dtMap.ImplementationType.qualifiedName;
                    this.App2ImpTypeQNameMap(appTypeQName)=impTypeQName;
                    this.ImpTypeQNameToM3iTypeMap(impTypeQName)=dtMap.ImplementationType;
                end
            end
        end



        function[isAppType,impType]=isAppType(this,qName)
            autosar.mm.util.validateArg(qName,'char');
            impType=[];
            isAppType=this.App2ImpTypeQNameMap.isKey(qName);
            if isAppType
                impTypeQName=this.App2ImpTypeQNameMap(qName);
                impType=this.ImpTypeQNameToM3iTypeMap(impTypeQName);
            end
        end



        function build(this)%#ok<MANU>
        end



        function addReferencedType(this,m3iType,m3iIntf)
            assert(isa(m3iType,'Simulink.metamodel.foundation.ValueType')||...
            isa(m3iType,'Simulink.metamodel.arplatform.common.ModeDeclarationGroup'),...
            'Unsupported m3iType class %s for addReferencedType.',class(m3iType));
            qname=m3iType.qualifiedName;





            if~this.RefTypesQNameToARADataMap.isKey(qname)&&...
                ~any(strcmp(autosarcore.mm.sl2mm.SwBaseTypeBuilder.getAdaptivePlatformTypes(),m3iType.Name))
                [isAppType,impType]=this.isAppType(m3iType.qualifiedName);
                if isAppType
                    this.RefTypesQNameToARADataMap(qname)=impType;
                else
                    this.RefTypesQNameToARADataMap(qname)=m3iType;
                end
                switch(class(m3iType))
                case 'Simulink.metamodel.types.Matrix'
                    this.addReferencedType(m3iType.BaseType,m3iIntf);
                case 'Simulink.metamodel.types.Structure'
                    busElements=m3iType.Elements;
                    for i=1:busElements.size
                        busElement=busElements.at(i);
                        if busElement.Type.isvalid()
                            this.addReferencedType(busElement.Type,m3iIntf);
                        else
                            this.addReferencedType(busElement.ReferencedType,m3iIntf);
                        end
                    end
                case{'Simulink.metamodel.types.SharedAxisType',...
                    'Simulink.metamodel.types.LookupTableType'}
                    [isAppType,impType]=this.isAppType(m3iType.qualifiedName);
                    assert(isAppType,'%s should be an application type.',m3iType.qualifiedName);
                    this.addReferencedType(impType,m3iIntf);
                case{'Simulink.metamodel.types.FixedPoint',...
                    'Simulink.metamodel.types.Integer',...
                    'Simulink.metamodel.types.FloatingPoint',...
                    'Simulink.metamodel.types.Enumeration',...
                    'Simulink.metamodel.types.Boolean',...
                    'Simulink.metamodel.arplatform.common.ModeDeclarationGroup',...
                    'Simulink.metamodel.types.VoidPointer'}

                case 'Simulink.metamodel.types.String'


                    if slfeature('AUTOSARStringsAdaptive')==0
                        DAStudio.error('autosarstandard:validation:stringNotSupported','string');
                    end
                otherwise
                    assert(false,'Unknown m3iType "%s".',class(m3iType));
                end
            end
        end
    end
end



