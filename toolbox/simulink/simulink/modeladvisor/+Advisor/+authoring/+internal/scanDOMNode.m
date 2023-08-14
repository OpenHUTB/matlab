function constraint=scanDOMNode(constraintNode)




    constraintType=char(constraintNode.getTagName);
    valueType='';
    switch constraintType
    case 'PositiveBlockParameterConstraint'
        constraint=Advisor.authoring.PositiveBlockParameterConstraint();
        constraint.BlockType=char(constraintNode.getAttribute('BlockType'));
        valueType='Positive';
    case 'NegativeBlockParameterConstraint'
        constraint=Advisor.authoring.NegativeBlockParameterConstraint();
        constraint.BlockType=char(constraintNode.getAttribute('BlockType'));
        valueType='Negative';
    case 'PositiveModelParameterConstraint'
        constraint=Advisor.authoring.internal.PositiveModelParameterConstraint();
        valueType='Positive';
    case 'NegativeModelParameterConstraint'
        constraint=Advisor.authoring.internal.NegativeModelParameterConstraint();
        valueType='Negative';
    case 'PositiveBlockTypeConstraint'
        constraint=Advisor.authoring.PositiveBlockTypeConstraint();
        valueType='Positive';
    case 'NegativeBlockTypeConstraint'
        constraint=Advisor.authoring.NegativeBlockTypeConstraint();
        valueType='Negative';
    otherwise
        DAStudio.error('Advisor:engine:InvalidConstraint',constraintType);
    end


    childNodes=constraintNode.getChildNodes;

    for n=0:childNodes.getLength-1

        if childNodes.item(n).getNodeType==1
            nodeName=char(childNodes.item(n).getNodeName);
            switch nodeName
            case 'dependson'

                constraint.addPreRequisiteConstraintID(Advisor.authoring.internal.getXMLNodeTextContent(childNodes.item(n)));
            case 'parameter'

                constraint.ParameterName=Advisor.authoring.internal.getXMLNodeTextContent(childNodes.item(n));
                constraint.ParameterDataType=char(childNodes.item(n).getAttribute('type'));
            case 'value'
                type=constraint.ParameterDataType;
                if strcmp(type,'string')
                    tempValue=Advisor.authoring.internal.getXMLNodeTextContent(childNodes.item(n));
                else
                    tempValue=parseComplexValueNode(type,childNodes.item(n));
                end

                if strcmp(valueType,'Positive')
                    constraint.addSupportedParameterValue(tempValue);
                else
                    constraint.addUnsupportedParameterValue(tempValue);
                end
            case 'operator'

                constraint.ValueOperator=Advisor.authoring.internal.getXMLNodeTextContent(childNodes.item(n));
            case 'BlockType'
                blockType=Advisor.authoring.internal.getXMLNodeTextContent(childNodes.item(n));
                maskType=char(childNodes.item(n).getAttribute('MaskType'));
                if strcmp(valueType,'Positive')
                    constraint.addSupportedBlockType(blockType,maskType);
                else
                    constraint.addUnsupportedBlockType(blockType,maskType);
                end
            case 'description'

                continue
            otherwise
                DAStudio.error('Advisor:engine:CCUnknownXMLNode',nodeName);
            end
        end
    end
end









function value=parseComplexValueNode(ParameterDataType,node)
    value=[];

    childNodes=node.getChildNodes;

    if childNodes.getLength>0
        for n=0:childNodes.getLength-1

            if childNodes.item(n).getNodeType==1
                nodeName=char(childNodes.item(n).getNodeName);

                if strcmp(ParameterDataType,'struct')





                    nodeValue=Advisor.authoring.internal.getXMLNodeTextContent(childNodes.item(n));


                    value.(nodeName)=nodeValue;
                else

                    if strcmp(nodeName,'element')
                        nodeValue=Advisor.authoring.internal.getXMLNodeTextContent(childNodes.item(n));
                        value{end+1}=nodeValue;%#ok<AGROW>
                    end
                end
            end
        end
    end

    if isempty(value)

        value=Advisor.authoring.internal.getXMLNodeTextContent(node);
    end
end


