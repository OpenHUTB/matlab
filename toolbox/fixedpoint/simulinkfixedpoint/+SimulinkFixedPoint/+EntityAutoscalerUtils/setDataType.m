function setDataType(pvPairs,proposedDT)






    for i=1:length(pvPairs)
        strategyClass=pvPairs{i}{1};

        switch strategyClass
        case 'FullDataTypeStrategy'
            blockPath=pvPairs{i}{2};
            paramNameToBeSet=pvPairs{i}{3};
            set_param(blockPath,paramNameToBeSet,proposedDT);

        case 'WordLengthStrategy'
            proposedDTNumType=SimulinkFixedPoint.DTContainerInfo(proposedDT,[]);
            paramValueToBeSet=num2str(proposedDTNumType.evaluatedNumericType.WordLength);
            blockPath=pvPairs{i}{2};
            paramNameToBeSet=pvPairs{i}{3};
            set_param(blockPath,paramNameToBeSet,paramValueToBeSet);

        case 'FractionLengthStrategy'
            proposedDTNumType=SimulinkFixedPoint.DTContainerInfo(proposedDT,[]);
            paramValueToBeSet=num2str(proposedDTNumType.evaluatedNumericType.FractionLength);
            blockPath=pvPairs{i}{2};
            paramNameToBeSet=pvPairs{i}{3};
            set_param(blockPath,paramNameToBeSet,paramValueToBeSet);

        case 'SignednessStrategy'
            blockPath=pvPairs{i}{2};
            paramNameToBeSet='isSigned';
            proposedDTNumType=SimulinkFixedPoint.DTContainerInfo(proposedDT,[]);
            blkIsSignedPrmVal='off';
            if(proposedDTNumType.evaluatedNumericType.SignednessBool==1)
                blkIsSignedPrmVal='on';
            end
            set_param(blockPath,paramNameToBeSet,blkIsSignedPrmVal);

        case 'AutoSignednessDataTypeStrategy'
            resolvedUDT=SimulinkFixedPoint.DTContainerInfo(proposedDT,[]);
            if resolvedUDT.isFixed
                proposedDT=sprintf('fixdt([],%d,%d)',...
                resolvedUDT.evaluatedNumericType.WordLength,resolvedUDT.evaluatedNumericType.FractionLength);
            end
            blockPath=pvPairs{i}{2};
            paramNameToBeSet=pvPairs{i}{3};
            set_param(blockPath,paramNameToBeSet,proposedDT);

        case 'GenericPropertyStrategy'
            blockPath=pvPairs{i}{2};
            paramNameToBeSet=pvPairs{i}{3};
            paramValueToBeSet=pvPairs{i}{4};
            set_param(blockPath,paramNameToBeSet,paramValueToBeSet);

        case 'DataTypeObjectStrategy'
            dataObjectWrapper=pvPairs{i}{2};

            switch dataObjectWrapper.WorkspaceType
            case{SimulinkFixedPoint.AutoscalerVarSourceTypes.Base,...
                SimulinkFixedPoint.AutoscalerVarSourceTypes.DataDictionary}


                dataSource=dataObjectWrapper.getDataSource;
                modifiedObject=dataObjectWrapper.Object;
                modifiedObject.DataType=proposedDT;
                dataSource.assignin(dataObjectWrapper.Name,modifiedObject);
            otherwise
                dataObjectWrapper.Object.DataType=proposedDT;
            end

        case 'AliasTypeObjectStrategy'
            dataObjectWrapper=pvPairs{i}{2};
            dataSource=dataObjectWrapper.getDataSource;
            modifiedObj=dataObjectWrapper.Object;
            DTConInfo=SimulinkFixedPoint.DTContainerInfo(proposedDT,[]);
            if DTConInfo.isDouble
                modifiedObj.BaseType='double';
            elseif DTConInfo.isSingle
                modifiedObj.BaseType='single';
            elseif DTConInfo.isBoolean
                modifiedObj.BaseType='boolean';
            elseif DTConInfo.isFixed

                modifiedObj.BaseType=proposedDT;
            end
            dataSource.assignin(dataObjectWrapper.Name,modifiedObj);

        case 'NumericTypeObjectStrategy'
            dataObjectWrapper=pvPairs{i}{2};
            dataSource=dataObjectWrapper.getDataSource;
            modifiedObj=dataObjectWrapper.Object;
            DTConInfo=SimulinkFixedPoint.DTContainerInfo(proposedDT,[]);
            newNT=DTConInfo.evaluatedNumericType;
            modifiedObj.DataTypeMode=newNT.DataTypeMode;
            modifiedObj.Signedness=newNT.Signedness;
            modifiedObj.WordLength=newNT.WordLength;
            modifiedObj.FractionLength=newNT.FractionLength;
            dataSource.assignin(dataObjectWrapper.Name,modifiedObj);

        case 'BreakPointObjectStrategy'
            dataObjectWrapper=pvPairs{i}{2};
            dataSource=getDataSource(dataObjectWrapper);
            modifiedObj=dataObjectWrapper.Object;
            DTConInfo=SimulinkFixedPoint.DTContainerInfo(proposedDT,[]);
            modifiedObj.Breakpoints.DataType=DTConInfo.evaluatedDTString;
            dataSource.assignin(dataObjectWrapper.Name,modifiedObj);

        case 'LUTObjectStrategy'
            dataObjectWrapper=pvPairs{i}{2};
            pathItem=pvPairs{i}{3};
            dataSource=getDataSource(dataObjectWrapper);
            modifiedObj=dataObjectWrapper.Object;

            DTConInfo=SimulinkFixedPoint.DTContainerInfo(proposedDT,[]);

            baseType=DTConInfo.evaluatedDTString;
            if strcmp(pathItem,'Table')
                modifiedObj.Table.DataType=baseType;
            else
                index=SimulinkFixedPoint.EntityAutoscalers.LookupTableObjectEntityAutoscaler.getIndexFromBreakpointPathitem(pathItem);
                modifiedObj.Breakpoints(index).DataType=baseType;
            end
            dataSource.assignin(dataObjectWrapper.Name,modifiedObj);

        case 'BusObjectStrategy'
            busObjectHandle=pvPairs{i}{2};
            pathItem=pvPairs{i}{3};
            busObjectHandle.setElementDataType(pathItem,proposedDT);

        case 'StateflowStrategy'
            blkObj=pvPairs{i}{2};
            blkObj.DataType=proposedDT;

        end

    end
end

