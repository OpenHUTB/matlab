classdef SerDesIBISModel<serdes.internal.ibisami.ibis.AbstractIBISModel

















































    properties
        RiseTime(1,1){mustBeReal,mustBeFinite}=10e-12
        Resistance(1,1){mustBeReal,mustBeFinite}=50
        ResistanceTx(1,1){mustBeReal,mustBeFinite}=50
        ResistanceRx(1,1){mustBeReal,mustBeFinite}=250
        Capacitance(1,1){mustBeReal,mustBeFinite}=2e-13
        Voltage(1,1){mustBeReal,mustBeFinite}=1
        CornerFactor(1,1){mustBeReal,mustBeFinite}=0.1
        AmiModelNameTx(1,1)string{serdes.utilities.mustBeShorterThan(AmiModelNameTx,40)}=""
        AmiModelNameRx(1,1)string{serdes.utilities.mustBeShorterThan(AmiModelNameRx,40)}=""
    end

    properties(Constant)
        RLoad=50
    end
    methods
        function model=SerDesIBISModel(varargin)
            parser=inputParser;
            parser.addParameter('ModelType','Input')
            parser.addParameter('modelname',"unknown")
            parser.addParameter('amimodelnametx',"tx_model")
            parser.addParameter('amimodelnamerx',"rx_model")
            parser.addParameter('risetime',5e-12)
            parser.addParameter('resistance',50)
            parser.addParameter('resistancetx',50)
            parser.addParameter('resistancerx',250)
            parser.addParameter('capacitance',1e-13)
            parser.addParameter('voltage',1)
            parser.addParameter('cornerfactor',0.1)
            parser.parse(varargin{:})
            args=parser.Results;
            model.ModelType=args.ModelType;
            model.ModelName=args.modelname;
            model.AmiModelNameTx=args.amimodelnametx;
            model.AmiModelNameRx=args.amimodelnamerx;
            model.RiseTime=args.risetime;
            model.ModelResistance=args.resistance;
            model.ResistanceTx=args.resistancetx;
            model.ResistanceRx=args.resistancerx;
            model.Capacitance=args.capacitance;
            model.Voltage=args.voltage;
            model.CornerFactor=args.cornerfactor;
            model.calculateModelData
        end
    end
    methods
        function set.AmiModelNameTx(model,modelName)
            model.AmiModelNameTx=modelName;
            model.calculateModelData
        end
        function set.AmiModelNameRx(model,modelName)
            model.AmiModelNameRx=modelName;
            model.calculateModelData
        end
        function set.RiseTime(model,riseTime)
            model.RiseTime=riseTime;
            model.calculateModelData
        end
        function set.ResistanceTx(model,resistance)
            model.ResistanceTx=resistance;
            model.calculateModelData
        end
        function set.ResistanceRx(model,resistance)
            model.ResistanceRx=resistance;
            model.calculateModelData
        end
        function set.Resistance(model,resistance)
            model.Resistance=resistance;
            model.calculateModelData
        end
        function set.Capacitance(model,capacitance)
            model.Capacitance=capacitance;
            model.calculateModelData
        end
        function set.Voltage(model,voltage)
            model.Voltage=voltage;
            model.calculateModelData
        end
        function set.CornerFactor(model,cornerFactor)
            model.CornerFactor=cornerFactor;
            model.calculateModelData
        end
        function setModelName(model,modelName)


            model.ModelName=modelName;
            model.calculateModelData
        end
    end
    methods(Access=public)
        function addModelExecutablesIfNeeded(model)
            [platform,arch,dllExt,compiler]=model.platformArchDllCompiler;
            platformCompilerBits=platform+compiler+"_64";
            if model.ModelType==model.InputType||model.ModelType==model.OutputType
                executable=[platformCompilerBits,model.ModelName+"_"+arch+dllExt,model.ModelName+".ami"];
                model.Executables=model.addOrUpdateExecutable(model.Executables,executable,platform);
            elseif model.ModelType==model.IOType
                executableTx=[platformCompilerBits,model.AmiModelNameTx+"_"+arch+dllExt,model.AmiModelNameTx+".ami"];
                model.ExecutablesTx=model.addOrUpdateExecutable(model.ExecutablesTx,executableTx,platform);
                executableRx=[platformCompilerBits,model.AmiModelNameRx+"_"+arch+dllExt,model.AmiModelNameRx+".ami"];
                model.ExecutablesRx=model.addOrUpdateExecutable(model.ExecutablesRx,executableRx,platform);
            end
        end
        function calculateModelData(model)
            minFactor=1-model.CornerFactor;
            maxFactor=1+model.CornerFactor;
            model.Ccomp=[model.Capacitance,model.Capacitance*minFactor,model.Capacitance*maxFactor];
            model.CcompCorner=[model.Ccomp(1),model.Ccomp(3),model.Ccomp(2)];
            model.TemperatureRange=[25,100,0];
            model.ModelResistance=[model.Resistance,model.Resistance,model.Resistance];
            model.VoltageRange=[model.Voltage,model.Voltage*minFactor,model.Voltage*maxFactor];
            range=model.VoltageRange(1);
            res=model.Resistance;
            bottom=-range/res;
            top=2*range/res;
            if model.ModelType==model.InputType

                if isempty(model.ModelName)||model.ModelName==""
                    model.ModelName="RxModel";
                end
                model.GNDClamp=[-range,bottom,bottom*minFactor,bottom*maxFactor;...
                0,0,0,0;...
                2*range,top,top*minFactor,top*maxFactor];
                model.POWERClamp=[];
                model.Pulldown=[];
                model.Pullup=[];
            elseif model.ModelType==model.OutputType

                if isempty(model.ModelName)||model.ModelName==""
                    model.ModelName="TxModel";
                end
                model.Pulldown=[-range,bottom,bottom*minFactor,bottom*maxFactor;...
                0,0,0,0;...
                2*range,top,top*minFactor,top*maxFactor];


                model.Pullup=[-range,-bottom,-bottom*minFactor,-bottom*maxFactor;...
                0,0,0,0;...
                2*range,-top,-top*minFactor,-top*maxFactor];
                model.GNDClamp=[];
                model.POWERClamp=[];
                dt=serdes.utilities.trf2dt(model.RiseTime,model.Resistance,model.Capacitance,model.RLoad);
                model.DtRising=[dt,dt*minFactor,dt*maxFactor];
                model.DtFalling=model.DtRising;
                model.dV=zeros(1,3);
                model.dV=[.6*model.VoltageRange(1)*50/(model.ModelResistance(1)+50),...
                .6*model.VoltageRange(2)*50/(model.ModelResistance(2)+50/minFactor),...
                .6*model.VoltageRange(3)*50/(model.ModelResistance(3)+50/maxFactor)];
            elseif model.ModelType==model.IOType

...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
                if isempty(model.ModelName)||model.ModelName==""
                    model.ModelName="io_model";
                end
                V=model.Voltage;
                TxR=model.ResistanceTx;
                RxR=model.ResistanceRx;

                bottom=-V/RxR;
                top=2*V/RxR;
                model.GNDClamp=[-V,bottom,bottom*minFactor,bottom*maxFactor;...
                0,0,0,0;...
                2*V,top,top*minFactor,top*maxFactor];

                model.POWERClamp=[-V,0,0,0;...
                0,0,0,0;...
                2*V,0,0,0];

                bottom=(-V/TxR)+(V/RxR);
                top=(2*V/TxR)-(2*V/RxR);
                model.Pulldown=[-V,bottom,bottom*minFactor,bottom*maxFactor;...
                0,0,0,0;...
                2*V,top,top*minFactor,top*maxFactor];

                bottom=(V/TxR)-(2*V/RxR);
                middle=-V/RxR;
                top=(-2*V/TxR)+(V/RxR);
                model.Pullup=[-V,bottom,bottom*minFactor,bottom*maxFactor;...
                0,middle,middle*minFactor,middle*maxFactor;...
                2*V,top,top*minFactor,top*maxFactor];

                dt=serdes.utilities.trf2dt(model.RiseTime,model.Resistance,model.Capacitance,model.RLoad);
                model.DtRising=[dt,dt*minFactor,dt*maxFactor];
                model.DtFalling=model.DtRising;
                dVbase=.6*V*50/(TxR+50);
                model.dV=[dVbase,...
                dVbase/minFactor,...
                dVbase/maxFactor];
            end
        end
    end
    methods(Access=private)
        function newExecutables=addOrUpdateExecutable(model,executables,executable,platform)
            if ismac

                newExecutables=executables;
            elseif isempty(executables)

                newExecutables={executable};
            else
                newExecutables=executables;
                idx=model.indexOfPlatform(executables,platform);
                if idx<1

                    newExecutables{end+1}=executable;
                else

                    newExecutables{idx}=executable;
                end
            end
        end
    end
    methods(Static,Access=private)
        function idx=indexOfPlatform(executables,platform)


            for idx=1:numel(executables)
                executable=executables{idx};
                platformCompilerBits=executable(1);
                if startsWith(platformCompilerBits,platform)
                    return
                end
            end
            idx=0;
        end
    end
end

