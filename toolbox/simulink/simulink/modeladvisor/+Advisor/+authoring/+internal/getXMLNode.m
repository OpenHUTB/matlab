


function constraintNode=getXMLNode(constraint,doc)

    IdString=constraint.ID;

    if isa(constraint,'Advisor.authoring.internal.ModelParameterConstraint')||...
        isa(constraint,'Advisor.authoring.ModelParameterConstraint')||...
        isa(constraint,'Advisor.authoring.BlockParameterConstraint')

        if isa(constraint,'Advisor.authoring.PositiveBlockParameterConstraint')
            constraintTitle='PositiveBlockParameterConstraint';
            ValueType='Positive';
        elseif isa(constraint,'Advisor.authoring.NegativeBlockParameterConstraint')
            constraintTitle='NegativeBlockParameterConstraint';
            ValueType='Negative';
        elseif isa(constraint,'Advisor.authoring.internal.PositiveModelParameterConstraint')||...
            isa(constraint,'Advisor.authoring.PositiveModelParameterConstraint')
            constraintTitle='PositiveModelParameterConstraint';
            ValueType='Positive';
        elseif isa(constraint,'Advisor.authoring.internal.NegativeModelParameterConstraint')||...
            isa(constraint,'Advisor.authoring.NegativeModelParameterConstraint')
            constraintTitle='NegativeModelParameterConstraint';
            ValueType='Negative';
        end

        constraintNode=doc.createElement(constraintTitle);
        if isa(constraint,'Advisor.authoring.BlockParameterConstraint')
            constraintNode.setAttribute('BlockType',constraint.BlockType);
        end

        if~isempty(IdString)
            constraintNode.setAttribute('id',IdString);
        end



        parameterNode=doc.createElement('parameter');
        parameterNode.setTextContent(constraint.ParameterName);
        parameterNode.setAttribute('type',constraint.ParameterDataType)
        constraintNode.appendChild(parameterNode);


        if strcmp(ValueType,'Positive')
            values=constraint.SupportedParameterValues;
        else
            values=constraint.UnsupportedParameterValues;
        end

        for i=1:length(values)
            valueNode=doc.createElement('value');
            if any(strcmp(constraint.ParameterDataType,{'struct','array'}))
                Advisor.authoring.ModelParameterConstraint.createComplexValueNode(doc,valueNode,values{i});
            else
                valueNode.setTextContent(values{i});
            end

            constraintNode.appendChild(valueNode);
        end

        if~(isa(constraint,'Advisor.authoring.internal.ModelParameterConstraint')||...
            isa(constraint,'Advisor.authoring.ModelParameterConstraint'))
            operaterNode=doc.createElement('operator');
            operaterNode.setTextContent(constraint.ValueOperator);
            constraintNode.appendChild(operaterNode);
        end
    else
        if isa(constraint,'Advisor.authoring.PositiveBlockTypeConstraint')
            constraintTitle='PositiveBlockTypeConstraint';
            ValueType='Positive';
        elseif isa(constraint,'Advisor.authoring.NegativeBlockTypeConstraint')
            constraintTitle='NegativeBlockTypeConstraint';
            ValueType='Negative';
        end

        constraintNode=doc.createElement(constraintTitle);
        if~isempty(constraint.ID)
            constraintNode.setAttribute('id',constraint.ID);
        end


        if strcmp(ValueType,'Positive')
            values=constraint.SupportedBlockTypes;
        else
            values=constraint.UnsupportedBlockTypes;
        end

        for n=1:length(values)
            valueNode=doc.createElement('BlockType');
            BlockTypeStruct=values{n};
            valueNode.setTextContent(BlockTypeStruct.BlockType);
            valueNode.setAttribute('MaskType',BlockTypeStruct.MaskType);
            constraintNode.appendChild(valueNode);
        end
    end

    if isprop(constraint,'Description')&&~isempty(constraint.Description)
        descriptionNode=doc.createElement('description');
        descriptionNode.setTextContent(constraint.Description);
        descriptionNode.setAttribute('type','string');
        constraintNode.appendChild(descriptionNode);
    end

    PreRequisiteConstraintIDs=constraint.getPreRequisiteConstraintIDs();
    if~isempty(PreRequisiteConstraintIDs)
        for n=1:length(PreRequisiteConstraintIDs)
            dependsOnNode=doc.createElement('dependson');
            dependsOnNode.setTextContent(PreRequisiteConstraintIDs{n});
            constraintNode.appendChild(dependsOnNode);
        end
    end
end