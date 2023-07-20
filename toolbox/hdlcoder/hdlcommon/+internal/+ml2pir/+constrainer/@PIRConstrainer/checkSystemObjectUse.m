function checkSystemObjectUse(this,node,instance)




    if~strcmp(node.kind,'ID')


        parent=node.trueparent;
        if strcmp(parent.kind,'CALL')
            fcnName=parent.Left.string;
            if strcmp(fcnName,'step')
                this.addMessage(node,...
                internal.mtree.MessageType.Error,...
                'hdlcommon:matlab2dataflow:UnsupportedFunctionReturningObj');
            end
        end
        return;
    end

    type=this.getType(node);
    if~type.isSystemObject
        return;
    end

    className=type.ClassName;
    if~isempty(this.functionTypeInfo.className)
        if~strcmp(this.functionTypeInfo.className,className)


            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            'hdlcommon:matlab2dataflow:NestedAuthoredSystemObject',...
            className,...
            this.functionTypeInfo.className);
        else
            return;
        end
    end

    if this.isNodeConditional(node)

        this.addMessage(node,...
        internal.mtree.MessageType.Error,...
        'hdlcommon:matlab2dataflow:UnsupportedSysObjInConditional');
    end

    parent=node.trueparent;
    switch parent.kind
    case 'CALL'
        fcnName=parent.Left.string;
        if~type.IsPIRBased

            allowedFunctions={'step','isempty'};
            if~any(strcmp(allowedFunctions,fcnName))

                this.addMessage(node,...
                internal.mtree.MessageType.Error,...
                'hdlcommon:matlab2dataflow:UnsupportedFunctionCallSystemObject',...
                fcnName,...
                className);
            end
        end

        if~type.isSystemObject

            this.addMessage(parent.Left,...
            internal.mtree.MessageType.Error,...
            'hdlcommon:matlab2dataflow:UnsupportedFunctionCall',...
            fcnName);
        elseif strcmp(fcnName,'step')
            if~isempty(instance)
                checkPIRSystemObject(this,parent,type,instance);
            end
            if~this.isConst(node)



                this.addMessage(parent.Left,...
                internal.mtree.MessageType.Error,...
                'hdlcommon:matlab2dataflow:MultipleStepSystemObject',...
                node.tree2str);
            elseif this.isNodeConditional(node)

                this.addMessage(parent.Left,...
                internal.mtree.MessageType.Error,...
                'hdlcommon:matlab2dataflow:ConditionalStepUnsupported');
            end
        end
    case 'PERSISTENT'
    case 'ETC'
    case 'EQUALS'
    otherwise

        this.addMessage(node,...
        internal.mtree.MessageType.Error,...
        'hdlcommon:matlab2dataflow:UnsupportedAuthoredSystemObject',...
        className);
    end

end

function checkPIRSystemObject(this,parent,type,instance)



    if type.IsPIRBased
        allowedSystemObjects={'dsp.Delay','hdl.RAM',...
        'hdl.Delay','hdl.TappedDelay'};
        if~any(strcmp(class(instance),allowedSystemObjects))
            this.addMessage(parent,...
            internal.mtree.MessageType.Error,...
            'hdlcommon:matlab2dataflow:UnsupportedSystemObject',...
            class(instance));
        end
        numOuts=1;
        stepOutput=parent.trueparent;
        if~isempty(stepOutput)&&strcmp(stepOutput.kind,'EQUALS')
            lhs=stepOutput.Left;
            if strcmp(lhs.kind,'LB')
                numOuts=count(lhs.Arg.List);
            end
        elseif strcmp(stepOutput.kind,'EXPR')
            numOuts=0;
        end
        if instance.getNumOutputs~=numOuts
            this.addMessage(parent,...
            internal.mtree.MessageType.Error,...
            'hdlcommon:matlab2dataflow:UnusedOutputsSystemObject',...
            class(instance),...
            instance.getNumOutputs,...
            numOuts);
        end
    end


    if isa(instance,'dsp.Delay')
        objArg=parent.Right;
        inputArg=objArg.Next;
        inputType=getType(this,inputArg);
        if~isScalar(inputType)
            this.addMessage(parent,...
            internal.mtree.MessageType.Error,...
            'hdlcommon:matlab2dataflow:UnsupportedInitDSPDelay');
        end
    end

end


