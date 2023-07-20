function[hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)






    hasDTConstraints=false;
    DTConstraintsSet={};

    inportStr=DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport');
    outportStr=DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromOutport');

    try
        blockType=blkObj.BlockType;
    catch
        return;
    end

    switch blockType
    case 'AllpoleFilter'
        hasDTConstraints=true;

        pathItems=getPathItems(h,blkObj);


        curListPorts=SimulinkFixedPoint.AutoscalerUtils.getSignalDrivingPort(h,blkObj,-1,-1);

        DTConstraintsSet=cell(numel(curListPorts)+numel(pathItems),1);

        for idx=1:numel(pathItems)
            uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(blkObj,pathItems{idx});
            signedConstraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint('Signed',[],[]);
            signedConstraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport'),' 1']);
            DTConstraintsSet{idx}={uniqueId,signedConstraint};
        end

        startingIdx=numel(pathItems);

        for idx=1:numel(curListPorts)
            uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curListPorts{idx}.blkObj,curListPorts{idx}.pathItem);
            signedConstraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint('Signed',[],[]);
            signedConstraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport'),' 1']);
            DTConstraintsSet{idx+startingIdx}={uniqueId,signedConstraint};
        end
    case 'DiscreteZeroPole'
        hasDTConstraints=true;

        curListPorts=SimulinkFixedPoint.AutoscalerUtils.getSignalDrivingPort(h,blkObj,-1,-1);

        DTConstraintsSet=cell(numel(curListPorts),1);
        for idx=1:numel(curListPorts)
            uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curListPorts{idx}.blkObj,curListPorts{idx}.pathItem);
            floatingPointOnlyConstraint=SimulinkFixedPoint.AutoscalerConstraints.FloatingPointOnlyConstraint;
            floatingPointOnlyConstraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport'),' 1']);
            DTConstraintsSet{idx}={uniqueId,floatingPointOnlyConstraint};
        end
    case 'Abs'
        inObj=get_param(blkObj.PortHandle.Inport,'Object');
        isInputComplex=inObj.CompiledPortComplexSignal;

        if 1==isInputComplex
            hasDTConstraints=true;
            uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(blkObj,'1');
            constraint=SimulinkFixedPoint.AutoscalerConstraints.ComplexModeConstraint(...
            SimulinkFixedPoint.AutoscalerConstraints.FloatingPointOnlyConstraint);
            constraint.setSourceInfo(blkObj,[outportStr,' 1']);
            DTConstraintsSet{1}={uniqueId,constraint};
        end

    case 'DataTypeConversion'
        valStr=blkObj.OutDataTypeStr;
        dataTypeContainer=SimulinkFixedPoint.DTContainerInfo(valStr,blkObj);
        if dataTypeContainer.isEnum()
            hasDTConstraints=true;
            curListPorts=h.hShareDTSpecifiedPorts(blkObj,1,[]);
            DTConstraintsSet=cell(numel(curListPorts),1);
            for idx=1:numel(curListPorts)
                uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curListPorts{idx}.blkObj,curListPorts{idx}.pathItem);
                constraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint([],[8,16,32],0);
                constraint.setSourceInfo(blkObj,[inportStr,' 1']);
                DTConstraintsSet{idx}={uniqueId,constraint};
            end
        end

    case 'Selector'
        if(blkObj.Ports(1)>1)

            hasDTConstraints=true;
            curListPorts=h.hShareDTSpecifiedPorts(blkObj,'2:end',[]);
            DTConstraintsSet=cell(numel(curListPorts),1);
            for idx=1:numel(curListPorts)
                uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curListPorts{idx}.blkObj,curListPorts{idx}.pathItem);
                constraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint([],[8,16,32],0);
                constraint.setSourceInfo(blkObj,[inportStr,int2str(idx+1)]);
                DTConstraintsSet{idx}={uniqueId,constraint};
            end
        end

    case 'Delay'
        hasDelayLengthPort=false;
        isResetPortPresent=false;
        isEnablePortPresent=false;

        dialogParams=get_param(blkObj.handle,'DialogParameters');
        nonDataPortIndex=2;

        if isfield(dialogParams,'DelayLengthSource')&&strcmp(blkObj.DelayLengthSource,'Input port')
            curListPortsToDelayLength=SimulinkFixedPoint.AutoscalerUtils.getSignalDrivingPort(h,blkObj,nonDataPortIndex,[]);


            hasDelayLengthPort=~isempty(curListPortsToDelayLength);

            nonDataPortIndex=nonDataPortIndex+1;
        end

        if isfield(dialogParams,'ShowEnablePort')&&~strcmp(blkObj.ShowEnablePort,'off')
            curListPortsToEnablePort=SimulinkFixedPoint.AutoscalerUtils.getSignalDrivingPort(h,blkObj,nonDataPortIndex,[]);
            isEnablePortPresent=~isempty(curListPortsToEnablePort);

            nonDataPortIndex=nonDataPortIndex+1;
        end

        if isfield(dialogParams,'ExternalReset')&&~strcmp(blkObj.ExternalReset,'None')
            curListPortsToResetPort=SimulinkFixedPoint.AutoscalerUtils.getSignalDrivingPort(h,blkObj,nonDataPortIndex,[]);
            isResetPortPresent=~isempty(curListPortsToResetPort);
        end

        DTConstraintsSet=cell(isEnablePortPresent+isResetPortPresent+hasDelayLengthPort,1);
        if numel(DTConstraintsSet)>0
            hasDTConstraints=true;
            startIndex=0;
            if hasDelayLengthPort

                for idx=1:numel(curListPortsToDelayLength)
                    uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curListPortsToDelayLength{idx}.blkObj,curListPortsToDelayLength{idx}.pathItem);
                    constraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint([],[],0);
                    constraint.setSourceInfo(blkObj,[inportStr,' ',int2str(2)]);
                    DTConstraintsSet{idx}={uniqueId,constraint};
                    startIndex=startIndex+idx;
                end
            end
            if isEnablePortPresent

                enablePortIdx=1+hasDelayLengthPort+isEnablePortPresent;
                for runningIndex=1:numel(curListPortsToEnablePort)
                    idx=startIndex+runningIndex;
                    uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curListPortsToEnablePort{runningIndex}.blkObj,curListPortsToEnablePort{runningIndex}.pathItem);
                    constraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint([],[1,8,16,32],0);
                    constraint.setSourceInfo(blkObj,[inportStr,' ',int2str(enablePortIdx)]);
                    DTConstraintsSet{idx}={uniqueId,constraint};
                    startIndex=startIndex+1;
                end
            end
            if isResetPortPresent


                resetPortIdx=1+hasDelayLengthPort+isEnablePortPresent+isResetPortPresent;
                for runningIndex=1:numel(curListPortsToResetPort)
                    idx=startIndex+runningIndex;
                    uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curListPortsToResetPort{runningIndex}.blkObj,curListPortsToResetPort{runningIndex}.pathItem);
                    constraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint([],[1,8,16,32],0);
                    constraint.setSourceInfo(blkObj,[inportStr,' ',int2str(resetPortIdx)]);
                    DTConstraintsSet{idx}={uniqueId,constraint};
                    startIndex=startIndex+1;
                end
            end
        end

    case{'DiscreteFilter','DiscreteTransferFcn'}
        hasDTConstraints=true;
        pathItems=h.getPathItems(blkObj);
        curInputPorts=h.hShareDTSpecifiedPorts(blkObj,-1,[]);
        curOutputPorts=h.hShareDTSpecifiedPorts(blkObj,[],-1);

        DTConstraintsSet=cell(numel(pathItems)+numel(curInputPorts)+numel(curOutputPorts),1);
        for idx=1:numel(pathItems)
            uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(blkObj,pathItems{idx});
            constraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint('Signed',[],[]);
            constraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport'),' 1']);
            DTConstraintsSet{idx}={uniqueId,constraint};
        end

        startingIdx=numel(pathItems);
        for idx=1:numel(curOutputPorts)
            uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curOutputPorts{idx}.blkObj,curOutputPorts{idx}.pathItem);
            constraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint('Signed',[],[]);
            constraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport'),' 1']);
            DTConstraintsSet{idx+startingIdx}={uniqueId,constraint};
        end

        startingIdx=numel(pathItems)+numel(curOutputPorts);
        resetPortIdx=0;
        isResetPortOn=~strcmp(blkObj.ExternalReset,'None');
        if isResetPortOn
            if strcmp(blkObj.NumeratorSource,'Dialog')
                hasNumeratorPort=false;
            else
                hasNumeratorPort=true;
            end
            if strcmp(blkObj.DenominatorSource,'Dialog')
                hasDenominatorPort=false;
            else
                hasDenominatorPort=true;
            end
            resetPortIdx=1+hasNumeratorPort+hasDenominatorPort+1;
        end


        for idx=1:numel(curInputPorts)
            if isResetPortOn&&idx==resetPortIdx
                uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curInputPorts{idx}.blkObj,curInputPorts{idx}.pathItem);
                constraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint([],[1,8,16,32],0);
                constraint.setSourceInfo(blkObj,[inportStr,int2str(resetPortIdx)]);
                DTConstraintsSet{idx+startingIdx}={uniqueId,constraint};
            else
                uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curInputPorts{idx}.blkObj,curInputPorts{idx}.pathItem);
                constraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint('Signed',[],[]);
                constraint.setSourceInfo(blkObj,[inportStr,int2str(idx)]);
                DTConstraintsSet{idx+startingIdx}={uniqueId,constraint};
            end
        end



    case 'Assignment'
        if isempty(regexp(blkObj.IndexOptions,'(port)','ONCE'))
            return;
        end
        if strcmp(blkObj.OutputInitialize,'Initialize using input port <Y0>')
            dataPort=2;
            portStr='3:end';
        else
            dataPort=1;
            portStr='2:end';
        end

        if(blkObj.Ports(1)>dataPort)

            hasDTConstraints=true;
            curListPorts=h.hShareDTSpecifiedPorts(blkObj,portStr,[]);
            DTConstraintsSet=cell(numel(DTConstraintsSet),1);
            for idx=1:numel(curListPorts)
                uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curListPorts{idx}.blkObj,curListPorts{idx}.pathItem);
                constraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint([],[8,16,32],0);
                constraint.setSourceInfo(blkObj,[inportStr,int2str(idx+1)]);
                DTConstraintsSet{idx}={uniqueId,constraint};
            end
        end

    case 'Math'
        if any(strcmp(blkObj.Operator,{'mod','rem'}))
            hasDTConstraints=true;
            curListPorts=h.hShareDTSpecifiedPorts(blkObj,-1,[]);
            DTConstraintsSet=cell(numel(curListPorts),1);
            for idx=1:numel(curListPorts)
                uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curListPorts{idx}.blkObj,curListPorts{idx}.pathItem);
                constraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint([],[8,16,32],0);
                constraint.setSourceInfo(blkObj,[inportStr,' ',int2str(idx)]);
                DTConstraintsSet{idx}={uniqueId,constraint};
            end

        elseif strcmp(blkObj.Operator,'reciprocal')
            inObj=get_param(blkObj.PortHandle.Inport,'Object');
            isInputComplex=inObj.CompiledPortComplexSignal;

            if isInputComplex==1
                hasDTConstraints=true;
                if strcmp(blkObj.OutDataTypeStr,'Inherit: Same as first input')
                    curListPorts=h.hShareDTSpecifiedPorts(blkObj,-1,[]);
                    nListInport=numel(curListPorts);
                    DTConstraintsSet=cell(nListInport+1,1);
                    for idx=1:nListInport
                        uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curListPorts{idx}.blkObj,curListPorts{idx}.pathItem);
                        constraint=SimulinkFixedPoint.AutoscalerConstraints.FloatingPointOnlyConstraint;
                        constraint.setSourceInfo(blkObj,[inportStr,' ',int2str(idx)]);
                        DTConstraintsSet{idx}={uniqueId,constraint};
                    end
                else
                    nListInport=0;
                end


                uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(blkObj,'1');
                constraint=SimulinkFixedPoint.AutoscalerConstraints.FloatingPointOnlyConstraint;
                constraint.setSourceInfo(blkObj,[outportStr,' ','1']);
                DTConstraintsSet{nListInport+1}={uniqueId,constraint};
            end

        elseif any(strcmp(blkObj.Operator,{'exp','log','10^u','log10','pow','hypot'}))
            hasDTConstraints=true;
            curListPorts=h.hShareDTSpecifiedPorts(blkObj,-1,[]);
            nListInport=numel(curListPorts);
            DTConstraintsSet=cell(nListInport,1);
            for idx=1:nListInport
                uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curListPorts{idx}.blkObj,curListPorts{idx}.pathItem);
                constraint=SimulinkFixedPoint.AutoscalerConstraints.FloatingPointOnlyConstraint;
                constraint.setSourceInfo(blkObj,[inportStr,' ',int2str(idx)]);
                DTConstraintsSet{idx}={uniqueId,constraint};
            end


            uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(blkObj,'1');
            constraint=SimulinkFixedPoint.AutoscalerConstraints.FloatingPointOnlyConstraint;
            constraint.setSourceInfo(blkObj,[outportStr,' ','1']);
            DTConstraintsSet{nListInport+1}={uniqueId,constraint};

        elseif any(strcmp(blkObj.Operator,{'conj','hermitian'}))
            hasDTConstraints=true;
            curListPorts=h.hShareDTSpecifiedPorts(blkObj,-1,[]);
            DTConstraintsSet=cell(numel(curListPorts),1);
            for idx=1:numel(curListPorts)
                uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curListPorts{idx}.blkObj,curListPorts{idx}.pathItem);
                constraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint('Signed',[],[]);
                constraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport'),' ','1']);
                DTConstraintsSet{1}={uniqueId,constraint};
            end
        end

    case{'Backlash','SwitchCase'}
        hasDTConstraints=true;
        curListPorts=h.hShareDTSpecifiedPorts(blkObj,-1,[]);
        DTConstraintsSet=cell(numel(curListPorts),1);
        for idx=1:numel(curListPorts)
            uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curListPorts{idx}.blkObj,curListPorts{idx}.pathItem);
            constraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint([],[8,16,32],0);
            constraint.setSourceInfo(blkObj,[inportStr,int2str(idx)]);
            DTConstraintsSet{idx}={uniqueId,constraint};
        end

    case 'LookupNDDirect'
        totalNumInput=blkObj.Ports(1);
        if(totalNumInput==0)

            return;
        end
        if strcmp(blkObj.TableIsInput,'on')

            if totalNumInput>1
                idxPort=(1:(totalNumInput-1));
                curListPorts=h.hShareDTSpecifiedPorts(blkObj,idxPort,[]);
            else

                return;
            end
        else

            idxPort=(1:totalNumInput);
            curListPorts=h.hShareDTSpecifiedPorts(blkObj,-1,[]);
        end
        if~isempty(curListPorts)
            hasDTConstraints=true;
            DTConstraintsSet=cell(numel(curListPorts),1);
            for idx=1:numel(curListPorts)
                uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curListPorts{idx}.blkObj,curListPorts{idx}.pathItem);
                constraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint([],[],0);
                constraint.setSourceInfo(blkObj,[inportStr,int2str(idxPort(idx))]);
                DTConstraintsSet{idx}={uniqueId,constraint};
            end
        end

    case 'Width'
        if~strcmp(blkObj.OutDataTypeMode,'Choose intrinsic data type')
            hasDTConstraints=true;
            curListPorts=h.hShareDTSpecifiedPorts(blkObj,1,[]);
            DTConstraintsSet=cell(numel(curListPorts),1);
            for idx=1:numel(curListPorts)
                uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curListPorts{idx}.blkObj,curListPorts{idx}.pathItem);
                constraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint([],[8,16,32],0);
                constraint.setSourceInfo(blkObj,[inportStr,' 1']);
                DTConstraintsSet{idx}={uniqueId,constraint};
            end
        end
    case 'Sqrt'
        operatorType=get_param(blkObj.getFullName,'Operator');
        if strcmpi(operatorType,'signedSqrt')||strcmpi(operatorType,'rSqrt')
            hasDTConstraints=true;
            curListPorts=h.hShareDTSpecifiedPorts(blkObj,[],-1);
            DTConstraintsSet=cell(numel(curListPorts),1);
            for idx=1:numel(curListPorts)
                uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curListPorts{idx}.blkObj,curListPorts{idx}.pathItem);
                constraint=SimulinkFixedPoint.AutoscalerConstraints.FloatingPointOnlyConstraint;
                constraint.setSourceInfo(blkObj,[inportStr,' 1']);
                DTConstraintsSet{idx}={uniqueId,constraint};
            end
        end

    case 'UnaryMinus'
        hasDTConstraints=true;
        uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(blkObj,'1');
        constraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint('Signed',[],[]);
        DTConstraintsSet{1}={uniqueId,constraint};

    otherwise
        return;
    end




    if hasDTConstraints==false
        DTConstraintsSet={};
    end



