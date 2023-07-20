classdef TreeCompatibleInterface<handle






    methods(Abstract)
        getBusElementNames(obj,treeObject)
        getTreeObjectElement(obj,treeObject,elementNames,idx)
    end

    methods


        function[IS_COMPATIBLE,errMsg]=isInputCompatibleWithTree(obj,treeObject,inputVariable)

            errMsg=[];
            IS_COMPATIBLE=false;
            elementNames=getBusElementNames(obj,treeObject);
            leafNames=getInputVarLeafNames(obj,inputVariable);



            if~obj.ALLOW_PARTIAL&&~all(ismember(elementNames,leafNames))||...
                ~obj.ALLOW_PARTIAL&&(length(elementNames)~=length(leafNames))
                errMsg=DAStudio.message('sl_iospecification:inports:busObjNotFullySpecified');
                return;
            end

            if obj.ALLOW_PARTIAL&&~any(ismember(elementNames,leafNames))
                errMsg=DAStudio.message('sl_iospecification:inports:noLeafsMatch',inputVariable.Name);
                return;
            end






            NUM_EL=numel(inputVariable.Value);
            NUM_LEAVES=length(leafNames);


            for kEl=1:NUM_EL


                for kLeaf=1:NUM_LEAVES
                    inputPlugin=[];

                    idx=strcmp(elementNames,leafNames{kLeaf});




                    if any(idx)
                        leafValue=getBusLeaf(inputVariable,leafNames{kLeaf},kEl);
                        if Simulink.iospecification.BusInput.isa(leafValue)

                            inputPlugin=Simulink.iospecification.BusInput(leafNames{kLeaf},leafValue);

                        elseif Simulink.iospecification.TSArrayInput.isa(leafValue)

                            inputPlugin=Simulink.iospecification.TSArrayInput(leafNames{kLeaf},leafValue);

                        elseif Simulink.iospecification.TimetableInput.isa(leafValue)

                            inputPlugin=Simulink.iospecification.TimetableInput(leafNames{kLeaf},leafValue);

                        elseif Simulink.iospecification.TimeseriesInput.isa(leafValue)

                            inputPlugin=Simulink.iospecification.TimeseriesInput(leafNames{kLeaf},leafValue);

                        elseif Simulink.iospecification.GroundInput.isa(leafValue)

                            inputPlugin=Simulink.iospecification.GroundInput(leafNames{kLeaf},leafValue);

                        end


                        treeObjectElement=getTreeObjectElement(obj,treeObject,elementNames,idx);


                        busElPlugin=getTreePlugin(obj,treeObjectElement);

                        busElPlugin.USE_COMPILED_PARAMS=obj.USE_COMPILED_PARAMS;
                        IS_COMPATIBLE_CALL_FROM_BLOCK=busElPlugin.areCompatible(inputPlugin);

                        if~IS_COMPATIBLE_CALL_FROM_BLOCK.status||IS_COMPATIBLE_CALL_FROM_BLOCK.status==2
                            IS_COMPATIBLE=IS_COMPATIBLE_CALL_FROM_BLOCK.status;
                            return;
                        end
                    end
                end
            end

            IS_COMPATIBLE=true;

        end


        function BusObjectName=parseBusObjectNameFromDataType(obj,dataTypeStr)
            idxOfColon=strfind(dataTypeStr,':');
            if~isempty(idxOfColon)
                dataTypeStr=strtrim(dataTypeStr(idxOfColon+1:end));
            end
            BusObjectName=dataTypeStr;
        end


        function BusObject=getBusObjectDefinition(obj,BusObjectName)

            [BusObject,~]=resolveParameterValue(obj,BusObjectName);

            if~isa(BusObject,'Simulink.Bus')&&exist(BusObjectName,'file')


                try

                    [~,fileName,~]=fileparts(BusObjectName);
                    BusObject=slprivate('constructSLBusUsingMLClass',fileName,false);


                    if~isa(BusObject,'Simulink.Bus')

                        DAStudio.error('sl_iospecification:inports:portSetToBusNoDefinition',BusObjectName);
                    end

                catch ME

                    DAStudio.error('sl_iospecification:inports:portSetToBusNoDefinition',BusObjectName);
                end

            elseif~isa(BusObject,'Simulink.Bus')

                DAStudio.error('sl_iospecification:inports:portSetToBusNoDefinition',BusObjectName);
            end

        end


        function leafNames=getInputVarLeafNames(obj,inputVariable)
            leafNames={};

            if isa(inputVariable,'Simulink.iospecification.BusInput')
                leafNames=fieldnames(inputVariable.Value);
            elseif isa(inputVariable,'Simulink.iospecification.TSArrayInput')

                for kMem=length(inputVariable.Value.Members):-1:1
                    leafNames{kMem}=inputVariable.Value.Members(kMem).name;
                end
            elseif isa(inputVariable,'Simulink.iospecification.LoggedSignalInput')
                leafNames=fieldnames(inputVariable.Value.Values);
            end
        end
    end

end
