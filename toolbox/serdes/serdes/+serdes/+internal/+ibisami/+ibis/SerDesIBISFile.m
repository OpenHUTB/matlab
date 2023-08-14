classdef SerDesIBISFile<serdes.internal.ibisami.ibis.AbstractIBISFile



...
...
...
...
...
...
...
...
...



    properties(Constant)

        TxAndRx=int32(1)
        IO=int32(2)
        Redriver=int32(3)
        Retimer=int32(4)
    end
    properties(SetAccess=private)
RxModel
TxModel
IOModel
    end
    properties
        CreateIbisFile(1,1)logical=true;
        CreateAmiFiles(1,1)logical=true;
        UseSwitchableModulation(1,1)logical=false;
        CreateDlls(1,1)logical=true;
        PathToExport(1,1)string="";
    end
    properties(Dependent,SetObservable=true)
        DesignName(1,1)string
        ModelNameTx(1,1)string
        ModelNameRx(1,1)string
        ModelNameIO(1,1)string
        Voltage(1,1){mustBeReal,mustBeFinite}
        RiseTime(1,1){mustBeReal,mustBeFinite}
        ResistanceTx(1,1){mustBeReal,mustBeFinite}
        ResistanceRx(1,1){mustBeReal,mustBeFinite}
        CapacitanceTx(1,1){mustBeReal,mustBeFinite}
        CapacitanceRx(1,1){mustBeReal,mustBeFinite}
        Differential(1,1){serdes.utilities.mustBeA(Differential,'logical')}
        CornerFactor(1,1){mustBeReal,mustBeFinite}
        ModelTypes(1,1)string
        TxDLL(1,1)string
        RxDLL(1,1)string
        ModelConfiguration int32
    end
    properties(Access=private)
        ModelTypesBack="Both Tx and Rx"
        ModelConfigurationBack=int32(1)
    end
    methods
        function set.DesignName(ibs,designName)
            ibs.Component.ComponentName=designName;
            ibs.fileChanged
        end
        function designName=get.DesignName(ibs)
            designName=ibs.Component.ComponentName;
        end
        function set.Differential(ibs,differential)
            ibs.Component.Differential=differential;
            ibs.fileChanged
        end
        function differential=get.Differential(ibs)
            differential=ibs.Component.Differential;
        end
        function set.Voltage(ibs,voltage)
            ibs.TxModel.Voltage=voltage;
            ibs.RxModel.Voltage=voltage;
            ibs.fileChanged
        end
        function voltage=get.Voltage(ibs)
            voltage=ibs.RxModel.Voltage;
        end
        function set.CornerFactor(ibs,cornerFactor)
            ibs.TxModel.CornerFactor=cornerFactor;
            ibs.RxModel.CornerFactor=cornerFactor;
            ibs.fileChanged
        end
        function voltage=get.CornerFactor(ibs)
            voltage=ibs.RxModel.CornerFactor;
        end
        function set.RiseTime(ibs,riseTime)
            ibs.TxModel.RiseTime=riseTime;
            ibs.RxModel.RiseTime=riseTime;
            ibs.fileChanged
        end
        function riseTime=get.RiseTime(ibs)
            riseTime=ibs.TxModel.RiseTime;
        end
        function set.ResistanceTx(ibs,resistanceTx)
            ibs.TxModel.Resistance=resistanceTx;
            ibs.IOModel.ResistanceTx=resistanceTx;
            ibs.fileChanged
        end
        function modelNameTx=get.ModelNameTx(ibs)
            modelNameTx=ibs.TxModel.ModelName;
        end
        function set.ModelNameIO(ibs,modelNameIO)

            ibs.IOModel.setModelName(modelNameIO);
            ibs.Component.IOModelName=modelNameIO;
            ibs.fileChanged
        end
        function modelNameIO=get.ModelNameIO(ibs)
            modelNameIO=ibs.IOModel.ModelName;
        end
        function set.ModelNameTx(ibs,modelNameTx)
            ibs.TxModel.setModelName(modelNameTx);
            ibs.IOModel.AmiModelNameTx=modelNameTx;
            ibs.Component.TxModelName=modelNameTx;
            ibs.fileChanged
        end
        function modelNameRx=get.ModelNameRx(ibs)
            modelNameRx=ibs.RxModel.ModelName;
        end
        function set.ModelNameRx(ibs,modelNameRx)
            ibs.RxModel.setModelName(modelNameRx);
            ibs.IOModel.AmiModelNameRx=modelNameRx;
            ibs.Component.RxModelName=modelNameRx;
            ibs.fileChanged
        end
        function resistanceTx=get.ResistanceTx(ibs)
            resistanceTx=ibs.TxModel.Resistance;
        end
        function set.ResistanceRx(ibs,resistanceRx)
            ibs.RxModel.Resistance=resistanceRx;
            ibs.IOModel.ResistanceRx=resistanceRx;
            ibs.fileChanged
        end
        function resistanceRx=get.ResistanceRx(ibs)
            resistanceRx=ibs.RxModel.Resistance;
        end
        function set.CapacitanceTx(ibs,capacitanceTx)
            ibs.TxModel.Capacitance=capacitanceTx;
            ibs.IOModel.Capacitance=(ibs.TxModel.Capacitance+ibs.RxModel.Capacitance)/2;
            ibs.fileChanged
        end
        function capacitanceTx=get.CapacitanceTx(ibs)
            capacitanceTx=ibs.TxModel.Capacitance;
        end
        function set.CapacitanceRx(ibs,capacitanceRx)
            ibs.RxModel.Capacitance=capacitanceRx;
            ibs.IOModel.Capacitance=(ibs.TxModel.Capacitance+ibs.RxModel.Capacitance)/2;
            ibs.fileChanged
        end
        function capacitanceRx=get.CapacitanceRx(ibs)
            capacitanceRx=ibs.RxModel.Capacitance;
        end
        function set.ModelTypes(ibs,modelTypes)
            ibs.Component.ModelTypes=modelTypes;
            ibs.ModelTypesBack=modelTypes;
            ibs.hideModels
        end
        function hideModels(ibs)
            switch ibs.ModelConfigurationBack
            case ibs.TxAndRx
                switch ibs.ModelTypesBack
                case "Tx only"
                    ibs.RxModel.Hidden=true;
                    ibs.TxModel.Hidden=false;
                    ibs.IOModel.Hidden=true;
                case "Rx only"
                    ibs.RxModel.Hidden=false;
                    ibs.TxModel.Hidden=true;
                    ibs.IOModel.Hidden=true;
                otherwise
                    ibs.RxModel.Hidden=false;
                    ibs.TxModel.Hidden=false;
                    ibs.IOModel.Hidden=true;
                end
            case ibs.IO
                ibs.RxModel.Hidden=true;
                ibs.TxModel.Hidden=true;
                ibs.IOModel.Hidden=false;
            case ibs.Redriver
                ibs.RxModel.Hidden=false;
                ibs.TxModel.Hidden=false;
                ibs.IOModel.Hidden=true;
            case ibs.Retimer
                ibs.RxModel.Hidden=false;
                ibs.TxModel.Hidden=false;
                ibs.IOModel.Hidden=true;
            otherwise
                ibs.RxModel.Hidden=false;
                ibs.TxModel.Hidden=false;
                ibs.IOModel.Hidden=true;
            end
            ibs.fileChanged
        end
        function set.ModelConfiguration(ibs,modelConfiguration)
            if modelConfiguration<ibs.TxAndRx||modelConfiguration>ibs.Retimer
                modelConfiguration=ibs.TxAndRx;
            end
            ibs.ModelConfigurationBack=modelConfiguration;
            ibs.Component.isIO=modelConfiguration==ibs.IO;


            ibs.Component.IOModelName=ibs.ModelNameIO;
            ibs.Component.isRepeater=modelConfiguration==ibs.Redriver||modelConfiguration==ibs.Retimer;
            ibs.hideModels
        end
        function modelConfig=get.ModelConfiguration(ibs)
            modelConfig=ibs.ModelConfigurationBack;
        end
        function txDLL=get.TxDLL(ibs)
            txDLL=ibs.TxModel.Executable(2);
        end
        function rxDLL=get.RxDLL(ibs)
            rxDLL=ibs.RxModel.Executable(2);
        end

    end
    methods

        function ibs=SerDesIBISFile(varargin)
            parser=inputParser;
            parser.addParameter('name',"Untitled")
            parser.addParameter('modelnametx',"serdes_tx")
            parser.addParameter('modelnamerx',"serdes_rx")
            parser.addParameter('modelnameio',"io_model")
            parser.addParameter('voltage',1)
            parser.addParameter('risetime',10e-12)
            parser.addParameter('resistancetx',50)
            parser.addParameter('capacitancetx',1e-13)
            parser.addParameter('resistancerx',50)
            parser.addParameter('capacitancerx',2e-13)
            parser.addParameter('differential',true)
            parser.addParameter('cornerfactor',0.1)
            parser.addParameter('modeltypes',"Both Tx And Rx")
            parser.parse(varargin{:})
            args=parser.Results;

            ibs.Copyright="Copyright "+year(datetime)+", All Rights Reserved";
            ibs.Source="MathWorks SerDes Toolbox";
            ibs.Component=serdes.internal.ibisami.ibis.SerDesIBISComponent('componentName',args.name,...
            'differential',args.differential,...
            'ModelNameRx',args.modelnamerx,...
            'ModelNameTx',args.modelnametx...
            );
            ibs.TxModel=serdes.internal.ibisami.ibis.SerDesIBISModel('ModelType','Output',...
            'RiseTime',args.risetime,...
            'ModelName',args.modelnametx,...
            'Resistance',args.resistancetx,...
            'Capacitance',args.capacitancetx,...
            'CornerFactor',args.cornerfactor,...
            'Voltage',args.voltage);
            ibs.Models(end+1)=ibs.TxModel;
            ibs.RxModel=serdes.internal.ibisami.ibis.SerDesIBISModel('ModelType','Input',...
            'ModelName',args.modelnamerx,...
            'RiseTime',args.risetime,...
            'Resistance',args.resistancerx,...
            'Capacitance',args.capacitancerx,...
            'CornerFactor',args.cornerfactor,...
            'Voltage',args.voltage);
            ibs.Models(end+1)=ibs.RxModel;
            ibs.ModelTypes=args.modeltypes;
            capacitanceio=(args.capacitancerx+args.capacitancetx)/2;
            ibs.IOModel=serdes.internal.ibisami.ibis.SerDesIBISModel('ModelType','I/O',...
            'ModelName',args.modelnameio,...
            'AmiModelNameTx',args.modelnametx,...
            'AmiModelNameRx',args.modelnamerx,...
            'RiseTime',args.risetime,...
            'ResistanceRx',args.resistancerx,...
            'ResistanceTx',args.resistancetx,...
            'Capacitance',capacitanceio,...
            'CornerFactor',args.cornerfactor,...
            'Voltage',args.voltage);
            ibs.Models(end+1)=ibs.IOModel;
            ibs.IOModel.Hidden=true;
        end
        function updateAsNeeded(ibs)
            if isempty(ibs.IOModel)||...
                ~isa(ibs.IOModel,'serdes.internal.ibisami.ibis.SerDesIBISModel')
                ibs.IOModel=serdes.internal.ibisami.ibis.SerDesIBISModel('ModelType','I/O',...
                'RiseTime',10e-12,...
                'ResistanceRx',250,...
                'ResistanceTx',50,...
                'Capacitance',2e-13,...
                'CornerFactor',0.1,...
                'Voltage',1);
                ibs.Models(end+1)=ibs.IOModel;
                ibs.IOModel.Hidden=true;
            end
        end
        function addModelExecutablesIfNeeded(ibs,model)
            model.addModelExecutablesIfNeeded;
            ibs.fileChanged
        end
    end
end

