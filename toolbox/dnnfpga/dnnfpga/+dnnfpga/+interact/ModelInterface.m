classdef ModelInterface<handle




    properties
Model
SystemObject
    end

    properties(Dependent)
DebugMode
    end


    methods
        function obj=ModelInterface(modelName)
            if~bdIsLoaded(modelName)
                error(sprintf("The model: '%s' is not loaded.\n",modelName));
            end
            obj.Model=modelName;
            sb=dnnfpga.interact.SystemBeatStore.getSystemBeat(modelName);
            if isempty(sb)
                sb=dnnfpga.interact.SystemBeat(modelName);
                dnnfpga.interact.SystemBeatStore.registerSystemBeat(sb);
            end
            sb.Count=uint32(0);
            obj.SystemObject=sb;
        end
    end

    methods
        function enableHeartBeat(obj,path)
            if obj.hasParameter(path,'HB_ENABLED')
                current=obj.getParameter(path,'HB_ENABLED');
                if strcmp(current,'1')&&obj.DebugMode
                    fprintf("The Heartbeat block '%s' is already enabled.\n",path);
                    fprintf("Nothing to do.\n");
                else
                    obj.setParameter(path,'HB_ENABLED','1');
                end

            else
                fprintf("The block '%s' is not a HeartBeat block.\n",path);
            end
        end


        function enableBackDoor(obj,path,id)
            if obj.hasParameter(path,'selectBD')
                current=obj.getParameter(path,'selectBD');
                if strcmp(current,'on')&&obj.DebugMode
                    fprintf("The block '%s' is already enabled for back door access.\n",path);
                    fprintf("Nothing to do.\n");
                else
                    obj.setParameter(path,'selectBD','on');
                end
                if nargin>2
                    obj.setParameter(path,'ID',num2str(id));
                end
            elseif obj.hasParameter(path,'BD_ENABLED')
                current=obj.getParameter(path,'BD_ENABLED');
                if strcmp(current,'1')&&obj.DebugMode
                    fprintf("The block '%s' is already enabled for back door access.\n",path);
                    fprintf("Nothing to do.\n");
                else
                    obj.setParameter(path,'BD_ENABLED','1');
                end
                if nargin>2
                    obj.setParameter(path,'ID',num2str(id));
                end
            else
                fprintf("The block '%s' does not support back door access.\n",path);
            end
        end
        function hasIt=hasParameter(obj,path,param)
            hasIt=false;
            struct=obj.getParameter(path,'ObjectParameters');
            fields=fieldnames(struct);
            for i=1:numel(fields)
                field=fields{i};
                if strcmp(param,field)
                    hasIt=true;
                    break;
                end
            end
        end

        function value=getParameter(obj,path,param)

            value={};
            ppath=strcat(obj.Model,'/',path);
            try
                ignore=get_param(ppath,'ObjectParameters');
            catch E
                throwAsCaller(E);
            end
            try
                ppath=strcat(obj.Model,'/',path);
                value=get_param(ppath,param);
            catch E
                throwAsCaller(E);
            end
        end

        function setParameter(obj,path,param,value)

            ppath=strcat(obj.Model,'/',path);
            try
                ignore=get_param(ppath,'ObjectParameters');
            catch E
                throwAsCaller(E);
            end
            try
                if isnumeric(value)
                    value=num2str(value);
                end
                set_param(ppath,param,value);
            catch E
                throwAsCaller(E);
            end
        end

    end


    methods
        function status=getStatus(obj)
            status=get_param(obj.Model,'SimulationStatus');
        end
        function tm=getSimulationTime(obj)
            tm=get_param(obj.Model,'SimulationTime');
        end
    end

    methods
        function close(obj)
            close_system(obj.Model,false);
        end
        function cont(obj)
            set_param(obj.Model,'SimulationCommand','continue');
        end
        function pause(obj)
            set_param(obj.Model,'SimulationCommand','pause');
        end
        function setStopTime(obj,num)
            set_param(obj.Model,'StopTime',num2str(num));
        end


        function writeConstantValues(obj,values)
            ddrMem=obj.getMem(0);
            for i=1:numel(values)
                constantAddr=values(i).memoryRegion.getAddr();
                constantValue=values(i).constValue;
                ddrMem.write(constantAddr,constantValue);
            end
        end
        function start(obj)
            dnnfpga.disp(sprintf("Compiling Simulink model '%s' ...",obj.Model));
            set_param(obj.Model,'SimulationCommand','start');
            dnnfpga.disp(sprintf("Complete Simulink model '%s' compilation.",obj.Model));
        end
        function startAndPause(obj)
            dnnfpga.disp(sprintf("Compiling Simulink model '%s' ...",obj.Model));
            set_param(obj.Model,'SimulationCommand','start');
            set_param(obj.Model,'SimulationCommand','pause');
            dnnfpga.disp(sprintf("Complete Simulink model '%s' compilation.",obj.Model));
        end
        function stop(obj)
            set_param(obj.Model,'SimulationCommand','stop');
        end

        function update(obj)
            set_param(obj.Model,'SimulationCommand','update');
        end
    end
    methods













        function awaitAdvance(obj,num)
            if nargin<2
                num=1;
            end

            num=uint32(num);
            now=obj.SystemObject.Count;
            later=now;
            while later<now+num
                later=obj.SystemObject.Count;
                pause(0.01);
            end
        end

        function awaitPause(obj)
            while true
                pause(0.5);
                status=obj.getStatus();
                if strcmp(status,'paused')
                    break;
                end
            end
        end

        function awaitStopped(obj)
            while true
                pause(0.5);
                status=obj.getStatus();
                if strcmp(status,'stopped')
                    break;
                end
            end
        end
    end

    methods
        function mem=getMem(obj,id)
            mem=dnnfpga.interact.SimMemStore.getMem(obj.Model,id);
        end
    end

    methods
        function valid=get.DebugMode(~)
            valid=strcmp(dnnfpgafeature('Debug'),'on');
        end

    end
end


