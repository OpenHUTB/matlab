function res=checkInteraction(source)

    errors=string.empty;
    if source.ownedLifelines.Size==0

        error("sequencediagram:execution:invaliddiagram","The sequence diagram is empty");
    end

    if~isempty(source.rootFragment)&&source.rootFragment.operands.Size==1
        errors=checkOperand(source.rootFragment.operands.toArray,errors);
    else
        error("sequencediagram:execution:invaliddiagram","The sequence diagram is empty");
    end

    if~isempty(errors)
        errorString=errors.join(sprintf("\n\n"));
        error("sequencediagram:execution:invaliddiagram",errorString);
    end
    res=true;
end

function errors=checkOperand(operand,errors)
    if operand.messages.Size>0||operand.compositeFragments.Size>0

        for message=operand.messages.toArray
            if~isempty(message.definition)&&~isempty(message.definition.trigger)
                if(message.definition.trigger.element.backendElements.Size==0)
                    errors(end+1)=sprintf("The trigger of message '%s', doesn't refer to a valid source element",message.definition.condition);
                else
                    errors=checkConstraint(message.definition.constraint,errors);
                end
            else
                startName=string.empty;
                endName=string.empty;
                if isa(message.start,'sequencediagram.lang.syntax.MessageEvent')
                    startName=message.start.coveredLifeline.name;
                end
                if isa(message.end,'sequencediagram.lang.syntax.MessageEvent')
                    endName=message.end.coveredLifeline.name;
                end
                if~isempty(startName)
                    nameString="Message from "+startName;
                else
                    nameString=string.empty;
                end
                if~isempty(endName)
                    if isempty(nameString)
                        nameString="Message to "+endName;
                    else
                        nameString=nameString+" to "+endName;
                    end
                end
                errors(end+1)=sprintf("%s doesn't have a valid definition",nameString);
            end
        end

        info=operand.operandInfo;
        if isa(info,'sequencediagram.lang.syntax.OptOperandInfo')||...
            isa(info,'sequencediagram.lang.syntax.LoopOperandInfo')||...
            isa(info,'sequencediagram.lang.syntax.AltOperandInfo')

            errors=checkConstraint(info.constraint,errors);
        end

        current=operand.headFragment.next;
        tail=operand.tailFragment;
        while current~=tail
            if isa(current,'sequencediagram.lang.syntax.CompositeFragment')

                for op=current.operands.toArray
                    errors=checkOperand(op,errors);
                end
            end
            current=current.next;
        end
    else
        errors(end+1)="Operand is empty";
    end
end

function errors=checkConstraint(constraint,errors)
    if~isempty(constraint)
        if~isempty(constraint.expression)
            if constraint.element.Size>0
                for elt=constraint.element.toArray
                    if elt.backendElements.Size==0
                        errors(end+1)=sprintf("Constraint '%s' has one or more invalid references",constraint.expression);
                    end
                end
            else
                errors(end+1)=sprintf("Constraint '%s' has no valid references",constraint.expression);
            end
        end
    end
end