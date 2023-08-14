classdef LiteralPrefixHelper<handle




    properties(Access=private)
        EnumQName2LiteralPrefixMap;
    end

    methods(Access=public)

        function this=LiteralPrefixHelper(m3iComponent)
            this.initLiteralPrefixMap(m3iComponent);
        end


        function literalPrefix=getLiteralPrefix(this,m3iType)


            literalPrefix='';
            qName=m3iType.qualifiedName;
            if this.EnumQName2LiteralPrefixMap.isKey(qName)
                literalPrefix=this.EnumQName2LiteralPrefixMap(qName);
            end

        end

    end

    methods(Access=private)

        function initLiteralPrefixMap(this,m3iSWC)

            this.EnumQName2LiteralPrefixMap=containers.Map();

            isMappedToAdaptiveApp=isa(m3iSWC,'Simulink.metamodel.arplatform.component.AdaptiveApplication');

            if~isMappedToAdaptiveApp

                for setIdx=1:m3iSWC.Behavior.IncludedDataTypeSets.size()
                    m3iIncludedDataTypeSet=m3iSWC.Behavior.IncludedDataTypeSets.at(setIdx);
                    literalPrefix=m3iIncludedDataTypeSet.LiteralPrefix;
                    if isempty(literalPrefix)
                        continue
                    end

                    for dtIdx=1:m3iIncludedDataTypeSet.DataTypes.size()
                        dt=m3iIncludedDataTypeSet.DataTypes.at(dtIdx);
                        if isa(dt,'Simulink.metamodel.types.Enumeration')
                            this.EnumQName2LiteralPrefixMap(dt.qualifiedName)=literalPrefix;
                        end
                    end
                end
            end

        end

    end

end


