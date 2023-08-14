


classdef ModelCodegenIOMultiMap<handle





    properties

        ModelIOToCodegenIOMap=[];


        CodegenIOToModelIOMap=[];


        AddrFlattenedPortNameToCodegenIONameMap=[];
    end

    properties(Access=protected)

    end

    methods

        function obj=ModelCodegenIOMultiMap()

            obj.ModelIOToCodegenIOMap=containers.Map();
            obj.CodegenIOToModelIOMap=containers.Map();
            obj.AddrFlattenedPortNameToCodegenIONameMap=containers.Map();
        end

        function[dutPortNameList,extraPortIndex]=portReOrderTransform(obj,hN,hModelIOPort,extraPortIndex)














            portIndex=hModelIOPort.PortIndex+extraPortIndex;
            if hModelIOPort.isBus
                dutPortNameList={};
                portType=hModelIOPort.PortType;
                hDataType=hModelIOPort.Type;
                [dutPortNameList,portIndexNew]=obj.getDUTPortNameListForBusPort(hN,portIndex,portType,hDataType,...
                hModelIOPort.PortName,dutPortNameList);
                extraPortIndex=extraPortIndex+(portIndexNew-portIndex)-1;
            else
                if hModelIOPort.PortType==hdlturnkey.IOType.IN
                    dutPortNameList=hN.getHDLInputPortNames(portIndex);
                else
                    dutPortNameList=hN.getHDLOutputPortNames(portIndex);
                end
            end
        end

        function[dutPortNameList,portIndex]=getDUTPortNameListForBusPort(obj,hN,portIndex,portType,hDataType,flattenedAddrDispName,dutPortNameList)





            if(isa(hDataType,'hdlturnkey.data.TypeBus'))

                memberIDList=hDataType.getMemberIDList;
                for idx=1:length(memberIDList)
                    memberName=memberIDList{idx};
                    hMemberDataType=hDataType.getMemberType(memberName);
                    flattenedAddrDispNameNew=[flattenedAddrDispName,'_',memberName];
                    [dutPortNameList,portIndex]=obj.getDUTPortNameListForBusPort(hN,portIndex,portType,hMemberDataType,flattenedAddrDispNameNew,dutPortNameList);
                end
            else

                if portType==hdlturnkey.IOType.IN
                    dutPortNameListBusElement=hN.getHDLInputPortNames(portIndex);
                else
                    dutPortNameListBusElement=hN.getHDLOutputPortNames(portIndex);
                end



                if~iscell(dutPortNameListBusElement)
                    dutPortNameListBusElement={dutPortNameListBusElement};
                end
                listLength=numel(dutPortNameListBusElement);

                for idx=1:listLength
                    dutPortNameList{end+1}=dutPortNameListBusElement{idx};%#ok<AGROW>
                end



                obj.AddrFlattenedPortNameToCodegenIONameMap(flattenedAddrDispName)=dutPortNameListBusElement;
                portIndex=portIndex+1;
            end
        end



        function buildModelIOToCodegenIOMap(obj,modelIOPortList,codegenIOPortList,hPirInstance,hTurnkey)






            obj.ModelIOToCodegenIOMap=containers.Map();
            obj.CodegenIOToModelIOMap=containers.Map();


            hN=hPirInstance.getTopNetwork;
            hInports=hN.PirInputPorts;
            hOutports=hN.PirOutputPorts;


            extraPortIndex=0;
            for ii=1:length(modelIOPortList.InputPortNameList)

                modelPortName=modelIOPortList.InputPortNameList{ii};
                hModelIOPort=modelIOPortList.getIOPort(modelPortName);

                if hModelIOPort.isTunable





                    dutPortNameList={};
                    for jj=1:numel(hInports)

                        if strcmp(modelPortName,hInports(jj).getTunableName)
                            dutPortNameList{end+1}=hInports(jj).Name;%#ok<AGROW>
                        end
                    end

                else

                    hInterface=hTurnkey.hTable.hTableMap.getInterface(modelPortName);
                    if hInterface.isIPInterface&&hInterface.isAXI4StreamInterface...
                        &&hInterface.isFrameMode


                        modelInterfaceStr=hModelIOPort.IOInterface;


                        dutPortNameList=obj.getAXI4StreamDUTPortForFrameMode(codegenIOPortList.InputPortNameList,...
                        codegenIOPortList,modelInterfaceStr,hModelIOPort.isComplex);
                        if(hInterface.isFrameToSample)

                            dutPortNameList{end+1}=obj.getAXI4StreamDUTReadyPortForFrameMode(codegenIOPortList.OutputPortNameList,...
                            codegenIOPortList,modelInterfaceStr);
                        end
                    else




                        [dutPortNameList,extraPortIndex]=obj.portReOrderTransform(hN,hModelIOPort,extraPortIndex);
                    end
                end



                if~iscell(dutPortNameList)
                    dutPortNameList={dutPortNameList};
                end
                obj.ModelIOToCodegenIOMap(modelPortName)=dutPortNameList;


                for jj=1:length(dutPortNameList)
                    dutPortName=dutPortNameList{jj};
                    obj.CodegenIOToModelIOMap(dutPortName)=modelPortName;
                end
            end


            extraPortIndex=0;
            for ii=1:length(modelIOPortList.OutputPortNameList)

                modelPortName=modelIOPortList.OutputPortNameList{ii};
                hModelIOPort=modelIOPortList.getIOPort(modelPortName);

                if~hModelIOPort.isTestPoint

                    hInterface=hTurnkey.hTable.hTableMap.getInterface(modelPortName);
                    if hInterface.isIPInterface&&hInterface.isAXI4StreamInterface...
                        &&hInterface.isFrameMode


                        modelInterfaceStr=hModelIOPort.IOInterface;


                        dutPortNameList=obj.getAXI4StreamDUTPortForFrameMode(codegenIOPortList.OutputPortNameList,...
                        codegenIOPortList,modelInterfaceStr,hModelIOPort.isComplex);
                        if(hInterface.isFrameToSample)

                            dutPortNameList{end+1}=obj.getAXI4StreamDUTReadyPortForFrameMode(codegenIOPortList.InputPortNameList,...
                            codegenIOPortList,modelInterfaceStr);
                        end

                    else




                        [dutPortNameList,extraPortIndex]=obj.portReOrderTransform(hN,hModelIOPort,extraPortIndex);
                    end
                else


                    dutPortNameList={};
                    for jj=1:numel(hOutports)





                        testPointSignalDriver=hOutports(jj).getTestpointSignalDriver;
                        if~isempty(testPointSignalDriver)



                            testPointSignalPortIndex=hOutports(jj).getTestpointSignalPortIndex;
                            if strcmp(testPointSignalDriver,hModelIOPort.TestPointSignalDriver)&&(testPointSignalPortIndex==hModelIOPort.TestPointSignalPortIndex)




                                dutPortNameList{end+1}=hOutports(jj).Name;%#ok<AGROW>
                            end
                        end
                    end
                end



                if~iscell(dutPortNameList)
                    dutPortNameList={dutPortNameList};
                end
                obj.ModelIOToCodegenIOMap(modelPortName)=dutPortNameList;


                for jj=1:length(dutPortNameList)
                    dutPortName=dutPortNameList{jj};
                    obj.CodegenIOToModelIOMap(dutPortName)=modelPortName;
                end
            end
        end

        function codegenPortNameList=getCodegenPortNameList(obj,modelPortName)
            codegenPortNameList=obj.ModelIOToCodegenIOMap(modelPortName);
        end

        function modelPortName=getModelPortName(obj,codegenPortName)
            modelPortName=obj.CodegenIOToModelIOMap(codegenPortName);
        end

        function codegenPortName=getCodegenPortNameFromAddrFlattenedPortName(obj,addrFlattenedPortName)
            codegenPortName=obj.AddrFlattenedPortNameToCodegenIONameMap(addrFlattenedPortName);
        end
    end

    methods(Access=protected)

        function dutPortNameList=getAXI4StreamDUTPortForFrameMode(~,codegenPortNameList,...
            codegenIOPortList,modelInterfaceStr,isComplex)




            dataIndex=1;
            if isComplex

                validIndex=3;
                dutPortNameList=cell(1,3);
            else
                validIndex=2;
                dutPortNameList=cell(1,2);
            end

            for ii=1:length(codegenPortNameList)
                codegenPortName=codegenPortNameList{ii};
                hCodeGenIOPort=codegenIOPortList.getIOPort(codegenPortName);



                if strcmp(hCodeGenIOPort.IOInterface,modelInterfaceStr)
                    if strcmp(hCodeGenIOPort.IOInterfaceMapping,'Data')
                        dutPortNameList{dataIndex}=hCodeGenIOPort.PortName;
                        dataIndex=dataIndex+1;
                    elseif strcmp(hCodeGenIOPort.IOInterfaceMapping,'Valid')
                        dutPortNameList{validIndex}=hCodeGenIOPort.PortName;
                    end
                end
            end
        end
        function dutReadyPortName=getAXI4StreamDUTReadyPortForFrameMode(~,codegenPortNameList,...
            codegenIOPortList,modelInterfaceStr)




            for ii=1:length(codegenPortNameList)
                codegenPortName=codegenPortNameList{ii};
                hCodeGenIOPort=codegenIOPortList.getIOPort(codegenPortName);



                if strcmp(hCodeGenIOPort.IOInterface,modelInterfaceStr)
                    if strcmp(hCodeGenIOPort.IOInterfaceMapping,'Ready')
                        dutReadyPortName=hCodeGenIOPort.PortName;
                    end
                end
            end
        end
    end
end

