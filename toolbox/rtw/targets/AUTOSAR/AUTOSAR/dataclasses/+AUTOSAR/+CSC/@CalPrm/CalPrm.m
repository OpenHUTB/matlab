classdef CalPrm<Coder.CSC.SingleEntityCodeGeneration









    methods(Access=private)


        function prefix=APIPrefix(this,recordIdentifier)
            mappingManager=get_param(bdroot,'MappingManager');
            modelMapping=mappingManager.getActiveMappingFor('AutosarTarget');
            prefix=[];
            if isa(modelMapping,'Simulink.AutosarTarget.ModelMapping')
                lutMapping=modelMapping.LookupTables.findobj('LookupTableName',recordIdentifier);
                if~isempty(lutMapping)
                    switch lutMapping.MappedTo.ParameterAccessMode
                    case{'Shared','PerInstance'}
                        prefix=['Rte_CData_',lutMapping.MappedTo.Parameter];
                    case 'PortParameter'
                        if AUTOSAR.CSC.IsAutosar(bdroot)
                            rtePrefix='Rte_Prm_';
                        else
                            rtePrefix='Rte_Calprm_';
                        end
                        prefix=[rtePrefix,lutMapping.MappedTo.Port,'_',lutMapping.MappedTo.Parameter];
                    case 'Const'
                        assert(true,'No prefix needed for ConstantMemory.');
                    end
                end
            end
            if isempty(prefix)
                if strcmp(this.Name,'InternalCalPrm')
                    prefix=['Rte_CData_',recordIdentifier];
                else
                    assert(strcmp(this.Name,'CalPrm'));
                    ca=this.CustomAttributes;
                    if AUTOSAR.CSC.IsAutosar(bdroot)
                        rtePrefix='Rte_Prm_';
                    else
                        rtePrefix='Rte_Calprm_';
                    end
                    prefix=[rtePrefix,ca.PortName,'_',ca.ElementName];
                end
            end
        end
    end

    methods(Access=public)





        function retStr=VarDeclaration(~,~,~,~,~)
            retStr='';
        end

        function retStr=VarDefinition(~,~,~,~,~,~,~)
            retStr='';
        end



        function retStr=ReadAccess(this,readAccessInfo)

            recordIdentifier=readAccessInfo.varName;
            width=readAccessInfo.dimension;
            arrIndex=readAccessInfo.arrIndex;
            isAddress=readAccessInfo.isAddress;
            isStruct=readAccessInfo.isStruct;
            isPointerToFirstElement=readAccessInfo.isPointerToMatrixFirstElem;

            retStr=[APIPrefix(this,recordIdentifier),'('];
            if AUTOSAR.CSC.IsAutosar(bdroot)&&strcmp(get_param(bdroot,'CodeInterfacePackaging'),'Reusable function')
                retStr=[retStr,AUTOSAR.CSC.getRTEInstanceName()];
            end
            retStr=[retStr,')'];
            if~isempty(width)||isStruct


                if AUTOSAR.CSC.IsAutosar(bdroot)

                    if~isAddress&&~isempty(width)
                        retStr=['(',retStr,')'];
                    elseif~isAddress&&isStruct
                        retStr=['(*',retStr,')'];
                    end
                else
                    if~isAddress||isPointerToFirstElement





                        retStr=['(*',retStr,')'];
                    end
                end

                if~isempty(arrIndex)&&~isPointerToFirstElement
                    retStr=[retStr,'[',arrIndex,']'];
                    if isAddress
                        retStr=['&(',retStr,')'];
                    end
                end
            end
        end



        function retStr=WriteAccess(~,~,~,~,~,~,~,~,~)

            assert(false,'Should not be called as this is a CalPrm.');
            retStr='';
        end

        function retStr=GetDeclareComment(~)
            retStr='';
        end

        function retStr=GetDefineComment(~)
            retStr='';
        end
    end
end


