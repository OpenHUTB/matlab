classdef ConstraintUtils

    methods(Static)

        function aStandaloneMaskObject=addParameterConstraintsToStandaloneMask(aMaskObj,aStandaloneMaskObject)
            iNumParameterConstraints=length(aMaskObj.ParameterConstraints);
            for m=1:iNumParameterConstraints
                singleParamConstraint=Simulink.Mask.Constraints;
                singleParamConstraint.Name=aMaskObj.ParameterConstraints(m).Name;
                ruleLength=length(aMaskObj.ParameterConstraints(m).ConstraintRules);
                for r=1:ruleLength
                    singleRule=aMaskObj.ParameterConstraints(m).ConstraintRules(r);
                    singleParamConstraint.addParameterConstraintRule('Complexity',...
                    singleRule.Complexity,'Dimension',singleRule.Dimension,'Sign',singleRule.Sign,...
                    'Finiteness',singleRule.Finiteness,'Minimum',singleRule.Minimum,...
                    'Maximum',singleRule.Maximum,'CustomConstraint',singleRule.CustomConstraint,...
                    'CustomErrorMessage',singleRule.CustomErrorMessage);
                    rule=singleParamConstraint.ConstraintRules(r);


                    rule.DataTypes=singleRule.DataTypes;
                    rule.DataType=singleRule.DataType;
                    rule.Fraction=singleRule.Fraction;
                end
                aStandaloneMaskObject.ParameterConstraints{m}=singleParamConstraint;
            end
        end

        function aStandaloneMaskObject=addCrossParameterConstraintsToStandaloneMask(aMaskObj,aStandaloneMaskObject)
            iNumCrossParamConstraints=length(aMaskObj.CrossParameterConstraints);
            for k=1:iNumCrossParamConstraints
                existingCrossParamConstraint=aMaskObj.CrossParameterConstraints(k);

                crossParamConstraint=Simulink.Mask.CrossParameterConstraints;
                crossParamConstraint.Name=existingCrossParamConstraint.Name;
                crossParamConstraint.MATLABexpression=existingCrossParamConstraint.MATLABexpression;
                crossParamConstraint.ErrorMessage=existingCrossParamConstraint.ErrorMessage;

                aStandaloneMaskObject.CrossParameterConstraints{k}=crossParamConstraint;
            end
        end

        function aStandaloneMaskObject=addPortConstraintsToStandaloneMask(aMaskObj,aStandaloneMaskObject)
            iNumPortConstraints=length(aMaskObj.PortConstraints);
            for k=1:iNumPortConstraints
                existingPortConstraint=aMaskObj.PortConstraints(k);

                portConstraint=Simulink.Mask.PortConstraint;
                portConstraint.Name=existingPortConstraint.Name;
                existingPortConstraintRule=existingPortConstraint.Rule;
                portConstraint.setRule('DataType',existingPortConstraintRule.DataType,...
                'Dimension',existingPortConstraintRule.Dimension,...
                'Complexity',existingPortConstraintRule.Complexity);
                existingPortConstraintPC=existingPortConstraint.ParameterConditions;
                for iPC=1:length(existingPortConstraintPC)
                    portConstraint.addParameterCondition('Name',existingPortConstraintPC(iPC).Name,...
                    'Values',existingPortConstraintPC(iPC).Values);
                end
                portConstraint.DiagnosticLevel=existingPortConstraint.DiagnosticLevel;
                portConstraint.DiagnosticMessage=existingPortConstraint.DiagnosticMessage;

                aStandaloneMaskObject.PortConstraints{k}=portConstraint;
            end
        end

        function aStandaloneMaskObject=addPortIdentifiersToStandaloneMask(aMaskObj,aStandaloneMaskObject)
            iNumPortIdentifeirs=length(aMaskObj.PortIdentifiers);
            for k=1:iNumPortIdentifeirs
                existingPortIdentifier=aMaskObj.PortIdentifiers(k);
                portIdentifier=Simulink.Mask.PortIdentifier;
                portIdentifier.Name=existingPortIdentifier.Name;
                portIdentifier.Type=existingPortIdentifier.Type;
                portIdentifier.IdentifierType=existingPortIdentifier.IdentifierType;
                portIdentifier.Identifier=existingPortIdentifier.Identifier;

                aStandaloneMaskObject.PortIdentifiers{k}=portIdentifier;
            end
        end

        function aStandaloneMaskObject=addPortConstraintAssociationsToStandaloneMask(aMaskObj,aStandaloneMaskObject)
            aStandaloneMaskObject.PortConstraintAssociations=aMaskObj.getAllPortConstraintAssociations();
        end



        function SaveOldConstraintsToMaskObj(aMaskObj,aOldMaskObj)

            aMaskObj.removeAllCrossParameterConstraints();
            if isfield(aOldMaskObj,'CrossParameterConstraints')
                numCrossParamConstraint=length(aOldMaskObj.CrossParameterConstraints);
                for crossParamIndex=1:numCrossParamConstraint
                    crossParamConstraint=aOldMaskObj.CrossParameterConstraints{crossParamIndex};
                    aMaskObj.addCrossParameterConstraint('Name',crossParamConstraint.Name,'MATLABexpression',crossParamConstraint.MATLABexpression,...
                    'ErrorMessage',crossParamConstraint.ErrorMessage);
                end
            end

            aMaskObj.removeAllParameterConstraints();
            if isfield(aOldMaskObj,'ParameterConstraints')
                numSingleParamConstraint=length(aOldMaskObj.ParameterConstraints);
                for singleParamIndex=1:numSingleParamConstraint
                    aMaskObj.addParameterConstraint(aOldMaskObj.ParameterConstraints{singleParamIndex});
                end
            end

            aMaskObj.removeAllPortConstraints();
            if isfield(aOldMaskObj,'PortConstraints')
                numSinglePortConstraint=length(aOldMaskObj.PortConstraints);
                for singleParamIndex=1:numSinglePortConstraint
                    aMaskObj.addPortConstraint(aOldMaskObj.PortConstraints{singleParamIndex});
                end
            end

            aMaskObj.removeAllPortIdentifiers();
            if isfield(aOldMaskObj,'PortIdentifiers')
                numSinglePortIdentifier=length(aOldMaskObj.PortIdentifiers);
                for singleIndex=1:numSinglePortIdentifier
                    aMaskObj.addPortIdentifier(aOldMaskObj.PortIdentifiers{singleIndex});
                end
            end

            aMaskObj.removeAllPortConstraintAssociations();
            allPortAssociations=aOldMaskObj.PortConstraintAssociations;
            for i=1:length(allPortAssociations)
                portConstraintName=allPortAssociations(i).PortConstraintName;
                assPortIdentifiers=allPortAssociations(i).PortIdentifiers;
                aMaskObj.addPortConstraintAssociation(portConstraintName,assPortIdentifiers);
            end
        end
    end
end
