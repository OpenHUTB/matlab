function masks(obj)




    aDataTypeOptions=[];

    if isR2021bOrEarlier(obj.ver)

        aDataTypeOptions=[aDataTypeOptions,{'image','valuetype'}];
    end

    if isR2020bOrEarlier(obj.ver)
        if obj.ver.isSLX

            obj.appendRule('<Mask<MaskParameter<Type|"promote":repval "edit">>>','/simulink/modelMask.xml');
        end
    end


    if isR2020aOrEarlier(obj.ver)

        aDataTypeOptions=[aDataTypeOptions,{'string'}];
    end

    if~isempty(aDataTypeOptions)
        removeDataTypeOptions(obj,aDataTypeOptions);
    end


    if isR2022aOrEarlier(obj.ver)


        transformationRules=getDataTypesToDataTypeTransformationRules(obj);
        obj.appendRules(transformationRules);


        obj.appendRule('<ParameterConstraints<ParameterConstraintRule<StringList<PropName|DataTypes>:remove>>>');
        obj.appendRule('<ParameterConstraints<ParameterConstraintRule<StringList<PropName|Fraction>:remove>>>');
        obj.appendRule('<Object<$ClassName|"Simulink.Mask.ParameterConstraintRules"><DataTypes:remove>>');
        obj.appendRule('<Object<$ClassName|"Simulink.Mask.ParameterConstraintRules"><Fraction:remove>>');
        obj.appendRule('<Object<$ClassName|"Simulink.Mask.ParameterConstraintRules"><DataRange:remove>>');

    end
end

function removeDataTypeOptions(aObj,aDataTypeOptions)
    aAllMaskedBlocks=aObj.findBlocks('Mask','on');
    for i=1:length(aAllMaskedBlocks)
        aMaskObj=Simulink.Mask.get(aAllMaskedBlocks{i});
        aMaskParameters=aMaskObj.Parameters;
        for j=1:length(aMaskParameters)
            aMaskParameter=aMaskParameters(j);
            aType=aMaskParameter.Type;
            if startsWith(aType,'unidt')
                for k=1:length(aDataTypeOptions)
                    aDataTypeOption=aDataTypeOptions{k};
                    if~isempty(regexp(aType,['u=.*',aDataTypeOption],'once'))
                        aValue=aMaskParameter.Value;
                        aType=strrep(aType,['|',aDataTypeOption],'');
                        aType=strrep(aType,aDataTypeOption,'');
                        aMaskParameter.Type=aType;
                        aMaskParameter.Value=aValue;
                    end
                end
            end
        end
    end
end

function transformationRules=getDataTypesToDataTypeTransformationRules(aObj)

    transformationRules={};

    aAllMaskedBlocks=aObj.findBlocks('Mask','on');
    for i=1:length(aAllMaskedBlocks)
        aMaskObj=Simulink.Mask.get(aAllMaskedBlocks{i});
        aSID=get_param(aAllMaskedBlocks{i},'SID');
        aParameterConstraints=aMaskObj.ParameterConstraints;
        for j=1:length(aParameterConstraints)
            aParamConstraint=aParameterConstraints(j);
            aParamConstraintName=aParamConstraint.Name;
            for r=1:length(aParamConstraint.ConstraintRules)
                rule=aParamConstraint.ConstraintRules(r);
                aDataTypes=rule.DataTypes;
                aFraction=rule.Fraction;

                aDeducedDataType="double";

                if length(aDataTypes)==1
                    aDataType=aDataTypes{1};
                    if aDataType=="boolean"||aDataType=="string"||startsWith(aDataType,"enum")||...
                        startsWith(aDataType,"int")||startsWith(aDataType,"uint")||...
                        aDataType=="single"||aDataType=="half"
                        aDeducedDataType=aDataType;
                    elseif(aDataType=="numeric"||aDataType=="double")&&~isempty(aFraction)&&all(contains(aFraction,"integer"))
                        aDeducedDataType="integer";
                    end
                end


                identifying_rule=sprintf('<Block<SID|"%s"><Mask<ParameterConstraints<Name|"%s"><ParameterConstraintRule',aSID,aParamConstraintName);
                transformationRules{end+1}=[identifying_rule,'<StringList<PropName|"DataTypes"><String:rename "DataType">>>>>>'];
                replaceRule=sprintf('<StringList<PropName|"DataTypes"><DataType:repval "%s">>',aDeducedDataType);
                transformationRules{end+1}=[identifying_rule,replaceRule,'>>>>'];
                transformationRules{end+1}=[identifying_rule,'<StringList<PropName|"DataTypes"><DataType:remove>>><ParameterConstraintRule:insert>>>>'];


                identifying_rule_mdl=sprintf('<Object<$ClassName<Block<SID|"%s"><Simulink.Mask.ParameterConstraints<Name|"%s"><Simulink.Mask.ParameterConstraintRules',aSID,aParamConstraintName);
                transformationRules{end+1}=[identifying_rule_mdl,'<StringList<PropName|"DataTypes"><String:rename "DataType">>>>>>>'];
                replaceRule_mdl=sprintf('<StringList<PropName|"DataTypes"><DataType:repval "%s">>',aDeducedDataType);
                transformationRules{end+1}=[identifying_rule_mdl,replaceRule_mdl,'>>>>>'];
                transformationRules{end+1}=[identifying_rule_mdl,'<StringList<PropName|"DataTypes"><DataType:remove>>><ParameterConstraintRule:insert>>>>>'];

            end
        end
    end
end
