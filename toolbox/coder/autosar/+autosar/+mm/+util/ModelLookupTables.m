classdef ModelLookupTables<handle






    properties(SetAccess=private,GetAccess=public)
        HasNDLookupTable;
        HasAllRowMajorNDLookupTables;
    end

    methods(Access=public)
        function this=ModelLookupTables(m3iComponent,slModelName)
            m3iLUTSequence=autosar.mm.Model.findObjectByMetaClass(m3iComponent.rootModel,...
            Simulink.metamodel.types.LookupTableType.MetaClass,true);

            applicationTypeMapper=autosar.mm.sl2mm.ApplicationTypeMapper(slModelName);

            this.HasNDLookupTable=false;
            this.HasAllRowMajorNDLookupTables=true;

            for i=1:m3iLUTSequence.size()
                m3iLUTAppType=m3iLUTSequence.at(i);

                if m3iLUTAppType.Axes.size()>1
                    this.HasNDLookupTable=true;
                    m3iLUTImpType=applicationTypeMapper.mappedTo(m3iLUTAppType);


                    if~this.isRowMajorLookupTable(m3iLUTAppType,m3iLUTImpType)
                        this.HasAllRowMajorNDLookupTables=false;
                        break;
                    end
                end
            end
            if~this.HasNDLookupTable


                this.HasAllRowMajorNDLookupTables=false;
            end
        end
    end

    methods(Access=private)
        function isRowMajorLUT=isRowMajorLookupTable(this,m3iLUTType,m3iLUTImpType)
            if m3iLUTType.SwRecordLayout.isvalid()
                m3iSwRecordLayoutGroup=m3iLUTType.SwRecordLayout.SwRecordLayoutGroup;
                groupCategories=this.getRecordLayoutGroupCategories(m3iSwRecordLayoutGroup);
            else
                groupCategories='';
            end
            isRowMajorLUT=contains(groupCategories,'ROW_DIR','IgnoreCase',true);

            if~isRowMajorLUT&&...
                isa(m3iLUTImpType,'Simulink.metamodel.types.Structure')
                isRowMajorLUT=autosar.mm.sl2mm.utils.DaVinciLUT.isRowMajorLookupTable(m3iLUTImpType);
            end
        end

        function groupCategories=getRecordLayoutGroupCategories(this,m3iSwRecordLayoutGroup)


            if~m3iSwRecordLayoutGroup.isvalid()
                groupCategories='';
                return;
            end
            groupCategories=m3iSwRecordLayoutGroup.Category;
            m3iSubRecordLayoutGroup=m3iSwRecordLayoutGroup.SwRecordLayoutGroup;
            for idx=1:m3iSubRecordLayoutGroup.size()
                groupCategories=strcat(groupCategories,...
                this.getRecordLayoutGroupCategories(m3iSubRecordLayoutGroup.at(idx)));
            end
        end

    end
end

