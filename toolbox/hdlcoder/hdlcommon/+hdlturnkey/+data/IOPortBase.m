


classdef(Abstract)IOPortBase<handle


    properties

        PortName='';
        PortFullName='';


        PortType=hdlturnkey.IOType.IN;

        PortIndex=0;

        PortKind='';


        Type=[];

        Signed=0;
        WordLength=0;
        FractionLength=0;


        isBoolean=false;
        isComplex=false;
        isDouble=false;
        isSingle=false;
        isHalf=false;
        isVector=false;
        isMatrix=false;


        isBus=false;
        isArrayOfBus=false;


        isStreamedPort=false;


        Dimension=0;


        SLDataType='';

        DispDataType='';


        PortRate=0;


        Bidirectional=0;


        IOInterface='';
        IOInterfaceMapping='';
        IOInterfaceOptions={};

    end

    properties(GetAccess=public,SetAccess=protected)


        isTunable=false;



        isTestPoint=false;
    end

    methods

        function obj=IOPortBase(varargin)

            p=inputParser;
            p.addParameter('PortName','');
            p.addParameter('PortFullName','');
            p.addParameter('PortRate','');
            p.addParameter('PortType',hdlturnkey.IOType.IN);
            p.addParameter('PortIndex','');
            p.addParameter('PortKind','');
            p.addParameter('Signed',0);
            p.addParameter('WordLength',0);
            p.addParameter('FractionLength',0);
            p.addParameter('isBoolean',false);
            p.addParameter('isComplex',false);
            p.addParameter('isDouble',false);
            p.addParameter('isSingle',false);
            p.addParameter('isHalf',false);
            p.addParameter('isVector',false);
            p.addParameter('isMatrix',false);
            p.addParameter('isBus',false);
            p.addParameter('isArrayOfBus',false);
            p.addParameter('isStreamedPort',false);
            p.addParameter('Type',[]);
            p.addParameter('Dimension',0);
            p.addParameter('SLDataType','');
            p.addParameter('DispDataType','');
            p.addParameter('Bidirectional',0);
            p.addParameter('IOInterface','');
            p.addParameter('IOInterfaceMapping','');

            p.parse(varargin{:});
            inputArgs=p.Results;

            obj.PortName=inputArgs.PortName;
            obj.PortFullName=inputArgs.PortFullName;
            obj.PortRate=inputArgs.PortRate;
            obj.PortType=inputArgs.PortType;
            obj.PortIndex=inputArgs.PortIndex;
            obj.PortKind=inputArgs.PortKind;
            obj.Signed=inputArgs.Signed;
            obj.WordLength=inputArgs.WordLength;
            obj.FractionLength=inputArgs.FractionLength;
            obj.isBoolean=inputArgs.isBoolean;
            obj.isComplex=inputArgs.isComplex;
            obj.isDouble=inputArgs.isDouble;
            obj.isSingle=inputArgs.isSingle;
            obj.isHalf=inputArgs.isHalf;
            obj.isVector=inputArgs.isVector;
            obj.isMatrix=inputArgs.isMatrix;
            obj.isBus=inputArgs.isBus;
            obj.isArrayOfBus=inputArgs.isArrayOfBus;
            obj.isStreamedPort=inputArgs.isStreamedPort;
            obj.Type=inputArgs.Type;
            obj.Dimension=inputArgs.Dimension;
            obj.SLDataType=inputArgs.SLDataType;
            obj.DispDataType=inputArgs.DispDataType;
            obj.Bidirectional=inputArgs.Bidirectional;
            obj.IOInterface=inputArgs.IOInterface;
            obj.IOInterfaceMapping=inputArgs.IOInterfaceMapping;
        end

        function portTypeStr=getPortTypeStr(obj)

            if obj.PortType==hdlturnkey.IOType.IN

                portTypeStr='Inport';
            else

                portTypeStr='Outport';
            end
        end

        function hSignal=addPirSignal(obj,hN,sigName)

            if nargin<3
                sigName=sprintf('%s_sig',obj.PortName);
            end

            isSigned=obj.Signed;
            wordLength=obj.WordLength;
            fracLength=obj.FractionLength;




            if obj.isDouble
                baseType=pir_ufixpt_t(wordLength,0);
            elseif obj.isSingle
                baseType=pir_ufixpt_t(wordLength,0);
            elseif obj.isHalf
                baseType=pir_ufixpt_t(wordLength,0);
            elseif isSigned
                baseType=pir_sfixpt_t(wordLength,fracLength);
            else
                baseType=pir_ufixpt_t(wordLength,fracLength);
            end

            if obj.isVector
                dimNum=obj.Dimension;
                portType=pirelab.getPirVectorType(baseType,dimNum);
            else
                portType=baseType;
            end

            hSignal=hN.addSignal(portType,sigName);
        end

        function flattenedPortWidth=getFlattenedPortWidth(obj)




            flattenedPortWidth=obj.WordLength*obj.Dimension;
        end

        function flattenedPortWidth=getFlattenedPortWidthStreamingPort(obj)


            flattenedPortWidth=obj.WordLength;
        end

    end
end
