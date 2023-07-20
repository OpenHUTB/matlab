


classdef(Hidden=true)TestPointPortList<handle


    properties

        TestPointPorts={};
    end

    methods
        function obj=TestPointPortList(hTurnkey)

            try
                obj.TestPointPorts={};

                obj.buildTestPointPortList(hTurnkey);
            catch me
                throwAsCaller(me);
            end
        end
    end

    methods(Access=private)
        function buildTestPointPortList(obj,hTurnkey)



            hCHandle=hTurnkey.hCHandle;

            hDI=hTurnkey.hD;






            testPointNamesMap=containers.Map();


            inputPortNames=hTurnkey.hTable.hIOPortList.InputPortNameList;
            outputPortNames=hTurnkey.hTable.hIOPortList.OutputPortNameList;
            mapKeys=horzcat(inputPortNames,outputPortNames);
            if~isempty(mapKeys)
                mapValues=ones(1,numel(inputPortNames)+numel(outputPortNames));
                testPointNamesMap=[testPointNamesMap;containers.Map(mapKeys,mapValues)];
            end


            allModels=hCHandle.AllModels;
            for mdlIdx=1:numel(allModels)

                p=pir(allModels(mdlIdx).modelName);

                topNet=p.getTopNetwork;

                topNetFullPath=hdlturnkey.data.getTopNetFullPath(topNet,hDI);

                hN=p.Networks;

                for nwIdx=1:numel(hN)

                    hSignals=hN(nwIdx).Signals;

                    for sigIdx=1:numel(hSignals)
                        if hSignals(sigIdx).getTestpoint


                            hSignal=hSignals(sigIdx);
                            hSignalSLHandle=hSignal.SimulinkHandle;


                            testPointName=get_param(hSignalSLHandle,'Name');

                            if isempty(testPointName)||isKey(testPointNamesMap,testPointName)



                                error(message('hdlcommon:workflow:TestPointNamesNotUnique'));
                            else

                                testPointNamesMap(testPointName)=1;

                                portName=testPointName;


                                testPointSignalDriver=get_param(hSignalSLHandle,'Parent');


                                testPointSignalPortIndex=get_param(hSignalSLHandle,'PortNumber');


                                if hSignal.Type.isRecordType
                                    hDataType=hdlturnkey.data.TypeBus();
                                else
                                    hDataType=hdlturnkey.data.TypeFixedPt();
                                end
                                hDataType.initFromPirType(hSignal.Type);

                                dataTypeInfo=pirgetdatatypeinfo(hSignal.Type);


                                if dataTypeInfo.isvector
                                    dispTypeStr=sprintf('%s (%d)',dataTypeInfo.sltype,dataTypeInfo.dims);
                                elseif hSignal.Type.isRecordType
                                    dispTypeStr=sprintf('bus');
                                else
                                    dispTypeStr=dataTypeInfo.sltype;
                                end


                                if strcmp(dataTypeInfo.sltype,'boolean')
                                    isBoolean=1;
                                else
                                    isBoolean=0;
                                end

                                hTestPointPort=hdlturnkey.data.IOPortTestPoint(...
                                'PortName',portName,...
                                'PortFullName',sprintf('%s/%s',topNetFullPath,portName),...
                                'PortRate',hSignal.SimulinkRate,...
                                'PortType',hdlturnkey.IOType.OUT,...
                                'PortIndex',-1,...
                                'PortKind','data',...
                                'Signed',dataTypeInfo.issigned,...
                                'WordLength',dataTypeInfo.wordsize,...
                                'FractionLength',dataTypeInfo.binarypoint,...
                                'isBoolean',isBoolean,...
                                'isComplex',dataTypeInfo.iscomplex,...
                                'isDouble',dataTypeInfo.isdouble,...
                                'isSingle',dataTypeInfo.issingle,...
                                'isVector',dataTypeInfo.isvector,...
                                'isBus',hSignal.Type.isRecordType,...
                                'Type',hDataType,...
                                'Dimension',dataTypeInfo.dims,...
                                'SLDataType',dataTypeInfo.sltype,...
                                'DispDataType',dispTypeStr,...
                                'Bidirectional',0,...
                                'IOInterface','',...
                                'IOInterfaceMapping','');



                                busPortName=hTestPointPort.PortName;

                                if hSignal.Type.isRecordType&&hTestPointPort.isTestPoint
                                    error(message('hdlcommon:workflow:BusNotSupported',busPortName));
                                end

                                hTestPointPort.TestPointSignalDriver=testPointSignalDriver;
                                hTestPointPort.TestPointSignalPortIndex=testPointSignalPortIndex;


                                obj.TestPointPorts{end+1}=hTestPointPort;
                            end
                        end
                    end
                end
            end
        end
    end
end