classdef Utils<handle




    methods(Static)
        function isModifiable=getEntryModifiable(~,selectedEntry)


            isModifiable=~DataTypeWorkflow.Advisor.Utils.isLibraryLinked(selectedEntry)...
            &&DataTypeWorkflow.Advisor.Utils.isPortRecognized(selectedEntry);
        end

        function isUnderLibraryLink=isLibraryLinked(selectedBlockName)



            if isa(selectedBlockName,'Simulink.BlockDiagram')
                isUnderLibraryLink=false;
            else
                isUnderLibraryLink=SimulinkFixedPoint.TracingUtils.IsUnderLibraryLink(selectedBlockName);
            end
        end

        function isLinkedSystem=isSystemLinked(selectedSystemObject)

            isLinkedSystem=selectedSystemObject.isLinked;
        end

        function isUnderReadOnlySystem=isUnderReadOnlySystem(selectedEntry)


            isUnderReadOnlySystem=SimulinkFixedPoint.TracingUtils.IsUnderReadOnlySystem(selectedEntry);
        end

        function entryAsLibraryEntry=getTopLibraryEntry(selectedEntry)

            entryAsLibraryEntry=selectedEntry;
            [~,linkDataList,~]=SimulinkFixedPoint.TracingUtils.GetTraversalLists(selectedEntry);

            if~isempty(linkDataList)
                topEntryPath=linkDataList(end).path;
                if~isempty(topEntryPath)
                    entryAsLibraryEntry=get_param(topEntryPath,'Object');
                end
            end
        end

        function isPortRecognized=isPortRecognized(selectedBlockName)

            portsHandle=selectedBlockName.PortHandles;
            isPortRecognized=~(isempty(portsHandle.Inport)&&isempty(portsHandle.Outport));
        end

        function isDecoupled=isDirectlyUnderDecoupledSubsystem(selectedBlockName)
            parentSubsystem=get_param(selectedBlockName,'Parent');
            tagParent=get_param(parentSubsystem,'Tag');
            isDecoupled=strcmp(tagParent,DataTypeWorkflow.Advisor.internal.ReplacementSetUp.TagUsed);
        end

        function[isConstructed,decoupledBlockName]=isConstructedDecouplingSubsystem(subsystemName)
            tagParent=get_param(subsystemName,'Tag');

            if isempty(tagParent)
                isConstructed=false;
            else
                isConstructed=strcmp(tagParent,DataTypeWorkflow.Advisor.internal.ReplacementSetUp.TagUsed);
            end

            if isConstructed


                listOfPossibleNames=find_system(subsystemName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Name',DataTypeWorkflow.Advisor.internal.ReplacementSetUp.SourceBlockName);
                decoupledBlockName=listOfPossibleNames{1};
            else
                decoupledBlockName='';
            end
        end

        function newSubsystemName=decoupleDTCSubsystem(selectedBlock)


            blockData=FunctionApproximation.internal.serializabledata.BlockDataWithCompile().update(selectedBlock.getFullName);

            modelInfo=DataTypeWorkflow.Advisor.internal.BlockDataToModel().getModelInfo(blockData);

            selectedName=selectedBlock.getFullName;
            decoupledSubsystem=getSubsystemPath(modelInfo);




            if~DataTypeWorkflow.Advisor.Utils.isDirectlyUnderDecoupledSubsystem(selectedName)
                FunctionApproximation.internal.Utils.replaceBlockWithBlock(selectedName,decoupledSubsystem);
                newSubsystemName=selectedName;
            else

                newSubsystemName=get_param(selectedName,'Parent');
            end
        end

        function positionCoordinate=calculateCoordinate(ph)


            portObj=get_param(ph,'Object');
            posBlock=get_param(portObj.Parent,'Position');
            posPort=portObj.Position;
            positionCoordinate=[posBlock(1),posPort(2),posBlock(3)];
        end


        function DTCBlockHandle=DTCInsertionAheadInPort(outph,inph)


            positionCoordinate=DataTypeWorkflow.Advisor.Utils.calculateCoordinate(inph);

            newBlockPosition=[positionCoordinate(1)-50,positionCoordinate(2)-20,positionCoordinate(1)-25,positionCoordinate(2)+20];


            DTCBlockHandle=DataTypeWorkflow.Advisor.Utils.DTCInsertionBetweenPorts(outph,inph,newBlockPosition);

        end

        function DTCBlockHandle=DTCInsertionAfterOutPort(outph,inph)


            positionCoordinate=DataTypeWorkflow.Advisor.Utils.calculateCoordinate(outph);

            newBlockPosition=[positionCoordinate(3)+25,positionCoordinate(2)-20,positionCoordinate(3)+50,positionCoordinate(2)+20];


            DTCBlockHandle=DataTypeWorkflow.Advisor.Utils.DTCInsertionBetweenPorts(outph,inph,newBlockPosition);

        end

        function DTCBlockHandle=DTCInsertionBetweenPorts(outph,inph,newBlockPosition)



            upPortObj=get_param(outph,'Object');
            downPortObj=get_param(inph,'Object');

            upBlock=upPortObj.Parent;
            downBlock=downPortObj.Parent;

            localSystem=get_param(upBlock,'Parent');


            DTCBlockHandle=add_block('built-in/DataTypeConversion',...
            [downBlock,'_boundary_DTC'],'MakeNameUnique','on','Position',...
            newBlockPosition,'ShowName','off');
            dtcPortHandles=get_param(DTCBlockHandle,'PortHandles');

            delete_line(localSystem,outph,inph);


            add_line(localSystem,outph,dtcPortHandles.Inport,'autorouting','on');
            add_line(localSystem,dtcPortHandles.Outport,inph,'autorouting','on');

        end

        function settingValue=getTargetSettingValueFromActiveConfigSet(system)
            settingPropertyValue=struct('ProdHWDeviceType','',...
            'ProdBitPerChar',0,...
            'ProdBitPerShort',0,...
            'ProdBitPerInt',0,...
            'ProdBitPerLong',0,...
            'ProdBitPerLongLong',0,...
            'ProdLongLongMode','off');

            systemObject=get_param(system,'Object');
            if isa(systemObject,'Simulink.BlockDiagram')
                model=system;
            else
                model=bdroot(system);
            end
            cs=getActiveConfigSet(model);


            fieldNames=fieldnames(settingPropertyValue);
            for idx=1:numel(fieldNames)
                propertyName=fieldNames{idx};
                propStruct=configset.getParameterInfo(cs,propertyName);

                if propStruct.IsReadable
                    settingValue.(propertyName)=get_param(cs,propertyName);
                end
            end
        end

        function status=setTargetSettingValueOnActiveConfigSet(system,settingValue)
            systemObject=get_param(system,'Object');
            if isa(systemObject,'Simulink.BlockDiagram')
                model=system;
            else
                model=bdroot(system);
            end
            cs=getActiveConfigSet(model);


            try
                set_param(cs,'ProdHWDeviceType',settingValue);
            catch setParamException %#ok<NASGU>
                status=false;
                return;
            end
            status=true;
        end
    end

end


