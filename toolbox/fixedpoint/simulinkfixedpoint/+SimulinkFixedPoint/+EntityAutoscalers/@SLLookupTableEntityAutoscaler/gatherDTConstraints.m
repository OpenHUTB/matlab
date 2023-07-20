function[hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)




    hasDTConstraints=false;
    DTConstraintsSet={};

    if h.hasFloatingPointConstraint(blkObj)

        hasDTConstraints=true;
        inportStr=message('SimulinkFixedPoint:autoscaling:ConstraintFromInport').getString();
        outportStr=message('SimulinkFixedPoint:autoscaling:ConstraintFromOutport').getString();


        pathItems=h.getPathItems(blkObj);

        nPathItems=numel(pathItems);
        pathItemConstraints=cell(1,nPathItems);
        for iPathItem=1:nPathItems

            uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(blkObj,pathItems{iPathItem});


            constraint=SimulinkFixedPoint.AutoscalerConstraints.FloatingPointOnlyConstraint;


            constraint.setSourceInfo(blkObj,[outportStr,' ','1']);


            pathItemConstraints{iPathItem}={uniqueId,constraint};
        end


        curListPorts=h.hShareDTSpecifiedPorts(blkObj,-1,[]);

        nLists=numel(curListPorts);
        inputConstraints=cell(1,nLists);
        for iList=1:nLists

            uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curListPorts{iList}.blkObj,curListPorts{iList}.pathItem);


            constraint=SimulinkFixedPoint.AutoscalerConstraints.FloatingPointOnlyConstraint;


            constraint.setSourceInfo(blkObj,[inportStr,' ',int2str(iList)]);


            inputConstraints{iList}={uniqueId,constraint};
        end

        DTConstraintsSet=[pathItemConstraints,inputConstraints];
    else
        if~strcmp(blkObj.DataSpecification,'Lookup table object')


            hasDTConstraints=true;
            pathItems=getPathItems(h,blkObj);
            for iPathItem=1:numel(pathItems)
                pathItem=pathItems{iPathItem};



                if isPathItemForBlockParam(h,blkObj,pathItem)&&~strcmp(pathItem,'Table')

                    uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(blkObj,pathItem);


                    index=h.getIndexFromBreakpointPathitem(pathItem);
                    dataTypeCreator=h.getDataTypeCreator(blkObj,index);

                    registerMonotonicityConstraint=true;
                    if strcmp(blkObj.BreakpointsSpecification,'Explicit values')...
                        &&strcmp(blkObj.IndexSearchMethod,'Evenly spaced points')
                        registerMonotonicityConstraint=SimulinkFixedPoint.isSpacingPerfectlyEven(dataTypeCreator.Values{1});
                    end

                    if registerMonotonicityConstraint

                        constraint=SimulinkFixedPoint.AutoscalerConstraints.MonotonicityConstraint(dataTypeCreator);
                    else


                        constraint=SimulinkFixedPoint.AutoscalerConstraints.ValuesNotPerfectlyEvenlySpacedConstraint(...
                        SimulinkFixedPoint.AutoscalerConstraints.FloatingPointOnlyConstraint);
                    end


                    constraint.setSourceInfo(blkObj,pathItem);


                    DTConstraintsSet=[DTConstraintsSet,{{uniqueId,constraint}}];%#ok<AGROW>				
                end
            end
        end
    end
end

