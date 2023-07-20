classdef BusObjectCompatibleInterface<Simulink.iospecification.TreeCompatibleInterface




    methods


        function[IS_COMPATIBLE,errMsg]=isInputCompatibleWithBusObj(obj,BusObject,inputVariable)
            errMsg=[];
            IS_COMPATIBLE=false;
            elementNames=getBusElementNames(obj,BusObject);
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


                        IS_BUS=false;

                        dataTypeStr_EL=formatIfEnum(obj,BusObject.Elements(idx).DataType);

                        IS_ENUM=~strcmp(dataTypeStr_EL,BusObject.Elements(idx).DataType);

                        if~isbuiltin(obj,BusObject.Elements(idx).DataType)&&~IS_ENUM
                            try
                                busDTStr=parseBusObjectNameFromDataType(obj,BusObject.Elements(idx).DataType);
                                BusObject_Leaf=getBusObjectDefinition(obj,busDTStr);
                                IS_BUS=true;
                            catch ME

                            end
                        end


                        if IS_BUS

                            busElPlugin=Simulink.iospecification.BusObjectElementLeafBus(BusObject.Elements(idx),obj.Handle);
                            busElPlugin.Handle=obj.Handle;
                            busElPlugin.ALLOW_PARTIAL=obj.ALLOW_PARTIAL;
                        else
                            busElPlugin=Simulink.iospecification.BusObjectElementLeaf(BusObject.Elements(idx),obj.Handle);
                        end





                        IS_COMPATIBLE_CALL_FROM_BLOCK=busElPlugin.areCompatible(inputPlugin);

                        if~IS_COMPATIBLE_CALL_FROM_BLOCK.status
                            return;
                        end
                    end
                end
            end

            IS_COMPATIBLE=true;
        end


        function treeObjectEl=getTreeObjectElement(obj,treeObject,elementNames,idx)

            treeObjectEl=treeObject.Elements(idx);

        end


        function busElPlugin=getTreePlugin(obj,treeObjectElement)


            IS_BUS=false;

            dataTypeStr_EL=formatIfEnum(obj,treeObjectElement.DataType);

            IS_ENUM=~strcmp(dataTypeStr_EL,treeObjectElement.DataType);

            if~isbuiltin(obj,treeObjectElement.DataType)&&~IS_ENUM
                try
                    busDTStr=parseBusObjectNameFromDataType(obj,treeObjectElement.DataType);
                    BusObject_Leaf=getBusObjectDefinition(obj,busDTStr);
                    IS_BUS=true;
                catch ME

                end
            end


            if IS_BUS

                busElPlugin=Simulink.iospecification.BusObjectElementLeafBus(treeObjectElement,obj.Handle);
                busElPlugin.Handle=obj.Handle;
                busElPlugin.ALLOW_PARTIAL=obj.ALLOW_PARTIAL;
            else
                busElPlugin=Simulink.iospecification.BusObjectElementLeaf(treeObjectElement,obj.Handle);
            end

        end


        function[BusObject,out2]=resolveParameterValue(obj,BusObjectName)
            blockH=obj.Handle;

            [BusObject,out2]=slResolve(BusObjectName,getfullname(blockH));
        end


        function elementNames=getBusElementNames(obj,BusObject)

            Elements=BusObject.Elements;
            elementNames=cell(1,length(Elements));
            for k=1:length(Elements)
                elementNames{k}=Elements(k).Name;
            end
        end

    end

end
