


classdef(Abstract)InterfaceCustomBase<hdlturnkey.interface.InterfaceBase


    properties


    end

    methods

        function obj=InterfaceCustomBase(interfaceID)



            obj=obj@hdlturnkey.interface.InterfaceBase(interfaceID);

        end

    end


    methods

    end


    methods

        function assignBitRange(obj,portName,bitRangeStr,hTableMap)


            hIOPort=hTableMap.hTable.hIOPortList.getIOPort(portName);
            fpgaPin=obj.parseBitRangeStr(hIOPort,bitRangeStr);

            hTableMap.setBitRangeData(portName,fpgaPin);
        end

        function fpgaPin=parseBitRangeStr(~,hIOPort,bitRangeStr)

            try
                fpgaPin=eval(bitRangeStr);
            catch ME
                error(message('hdlcommon:workflow:InvalidBitRange',bitRangeStr));
            end





            if isempty(bitRangeStr)
                return;
            end


            if~iscell(fpgaPin)
                error(message('hdlcommon:workflow:InvalidBitRange',bitRangeStr));
            end

            portWidth=hIOPort.WordLength;
            portDimension=hIOPort.Dimension;
            fpgaPinSize=length(fpgaPin);
            if fpgaPinSize~=portWidth*portDimension
                error(message('hdlcommon:workflow:FPGAOutPortWidthBound',bitRangeStr,fpgaPinSize,hIOPort.PortName,portWidth*portDimension));
            end
        end

        function validatePortForInterface(obj,hIOPort,~)


            if hIOPort.isSingle
                error(message('hdlcommon:workflow:SinglePortUnsupported',obj.InterfaceID,hIOPort.PortName));
            end

            if hIOPort.isVector
                error(message('hdlcommon:workflow:VectorPortUnsupported',obj.InterfaceID,hIOPort.PortName));
            end
        end
    end


    methods

        function fpgaPinStr=getTableCellBitRangeStr(~,portName,hTableMap)

            fpgaPin=hTableMap.getBitRangeData(portName);
            if~isempty(fpgaPin)
                pinStr=sprintf('''%s'',',fpgaPin{:});
                fpgaPinStr=sprintf('{%s}',pinStr(1:end-1));
            else
                fpgaPinStr='';
            end
        end
    end


    methods

    end


    methods

        function elaborate(obj,hN,hElab)



            obj.populatePortNameFromDut(hElab);


            hInterfaceSignal=obj.addInterfacePort(hN);


            obj.connectInterfacePort(hN,hElab,hInterfaceSignal);

        end

        function populatePortNameFromDut(obj,hElab)



            obj.InportNames={};
            obj.InportWidths={};
            obj.OutportNames={};
            obj.OutportWidths={};
            obj.DUTInportNames={};
            obj.DUTOutportNames={};


            dutPortNames=hElab.hTurnkey.hTable.hTableMap.getConnectedPortList(obj.InterfaceID);

            for ii=1:length(dutPortNames)
                dutPortName=dutPortNames{ii};
                hIOPort=hElab.hTurnkey.hTable.hIOPortList.getIOPort(dutPortName);
                portWidth=hIOPort.WordLength;
                portDimension=hIOPort.Dimension;




                postCodeGenDutPortNames=hElab.getCodegenPortNameList(dutPortName);

                postCodeGenDutPortName=postCodeGenDutPortNames{1};
                postCodeGenDutPortNameLength=length(postCodeGenDutPortNames);

                if(postCodeGenDutPortNameLength>1)
                    postCodeGenDutPortNameLength=strlength(postCodeGenDutPortName);
                    postCodeGenDutPortName=postCodeGenDutPortName(1:postCodeGenDutPortNameLength-2);
                end



                if hIOPort.PortType==hdlturnkey.IOType.IN
                    obj.InportNames{end+1}=postCodeGenDutPortName;
                    obj.InportWidths{end+1}=portWidth*portDimension;
                    obj.DUTInportNames{end+1}=dutPortName;
                else
                    obj.OutportNames{end+1}=postCodeGenDutPortName;
                    obj.OutportWidths{end+1}=portWidth*portDimension;
                    obj.DUTOutportNames{end+1}=dutPortName;
                end
            end
        end

        function connectInterfacePort(obj,hN,hElab,hInterfaceSignal)



            hInportSignals=hInterfaceSignal.hInportSignals;


            dutPortNames=hElab.hTurnkey.hTable.hTableMap.getConnectedPortList(obj.InterfaceID);


            for ii=1:length(obj.DUTInportNames)


                hInportSignal=hInportSignals(ii);
                dutPortName=dutPortNames{ii};


                postCodeGenDutPortName=obj.DUTInportNames{ii};
                hDutPortSignals=hElab.getCodegenPirSignalForPort(postCodeGenDutPortName);
                if~iscell(hDutPortSignals)
                    hDutPortSignals={hDutPortSignals};
                end




                hIOPort=hElab.hTurnkey.hTable.hIOPortList.getIOPort(dutPortName);
                portwidth=hIOPort.WordLength;




                sliceLSB=0;
                sliceMSB=sliceLSB+portwidth-1;



                for i=1:numel(hDutPortSignals)

                    pirtarget.getInPortBitSliceComp(hN,hInportSignal,hDutPortSignals{i},sliceMSB,sliceLSB);


                    sliceLSB=sliceMSB+1;
                    sliceMSB=sliceMSB+portwidth;
                end
            end



            hOutportSignals=hInterfaceSignal.hOutportSignals;


            for ii=1:length(obj.DUTOutportNames)

                hOutportSignal=hOutportSignals(ii);


                postCodeGenDutPortName=obj.DUTOutportNames{ii};
                hDutPortSignals=hElab.getCodegenPirSignalForPort(postCodeGenDutPortName);
                if~iscell(hDutPortSignals)
                    hDutPortSignals={hDutPortSignals};
                end


                pirtarget.getOutPortBitConcatComp(hN,hDutPortSignals',hOutportSignal);
            end

        end
    end


    methods

        function constrainCell=generateFPGAPinConstrain(obj,hElab)






            obj.populateFPGAPinMap(hElab);


            constrainCell=obj.getFPGAPinConstraintCell;

        end
    end


    methods(Access=protected)

        function populateFPGAPinMap(obj,hElab)


            obj.FPGAPinMap={};


            dutPortNames=hElab.hTurnkey.hTable.hTableMap.getConnectedPortList(obj.InterfaceID);

            for ii=1:length(dutPortNames)
                dutPortName=dutPortNames{ii};

                fpgaPin=hElab.hTurnkey.hTable.hTableMap.getBitRangeData(dutPortName);



                postCodeGenDutPortNames=hElab.getCodegenPortNameList(dutPortName);
                postCodeGenDutPortName=postCodeGenDutPortNames{1};

                if~isempty(fpgaPin)


                    defaultIOPadConstrain=hElab.hTurnkey.hBoard.DefaultIOPadConstrain;


                    pinMapping={postCodeGenDutPortName,fpgaPin,defaultIOPadConstrain};
                    obj.FPGAPinMap{end+1}=pinMapping;
                end
            end
        end

    end

end


