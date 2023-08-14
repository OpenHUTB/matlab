


classdef IOBit<handle


    properties


        BitIndex=0;


        IOBitPortName='';
        IOBitPinName='';


        IOBitTypeMap=[];


        Assigned=false;
        AssignedPortName='';
        AssignedPortType=hdlturnkey.IOType.IN;
        AssignedIOStandard='';
        AssignedInterfaceID='';

    end

    methods

        function obj=IOBit(bitIndex)


            obj.BitIndex=bitIndex;
            obj.IOBitTypeMap=containers.Map('default',hdlturnkey.IOType.INOUT);

        end

        function IOType=getIOBitType(obj,IOStandard)


            if nargin<2||isempty(IOStandard)
                IOStandard='default';
            end

            IOType=obj.IOBitTypeMap(IOStandard);

        end

        function setIOBitType(obj,IOType,IOStandard)


            if nargin<3||isempty(IOStandard)
                IOStandard='default';
            end

            obj.IOBitTypeMap(IOStandard)=IOType;

        end

    end

end

