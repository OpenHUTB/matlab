classdef InportFactory<handle




    properties

InportList

    end


    methods(Static)
        function aFactory=getInstance()
            persistent instance;
            mlock;

            if isempty(instance)
                instance=Simulink.iospecification.InportFactory();
            else



                if any(~cellfun(@isvalid,instance.InportList))
                    instance.updateFactoryRegistry();
                end
            end

            aFactory=instance;
        end
    end


    methods(Access='protected')


        function obj=InportFactory()


            obj.InportList=internal.findSubClasses('Simulink.iospecification',...
            'Simulink.iospecification.Inport');
        end
    end


    methods


        function aInportType=getInportType(obj,blockPath)

            if~ischar(blockPath)&&~ishandle(blockPath)
                DAStudio.error('sl_iospecification:inports:getInportTypeAPI');
            end


            if ischar(blockPath)&&getSimulinkBlockHandle(blockPath)==-1
                DAStudio.error('sl_iospecification:inports:getInportTypeAPI');
            end

            if ischar(blockPath)&&getSimulinkBlockHandle(blockPath)~=-1
                blockPath=getSimulinkBlockHandle(blockPath);
            end

            NUM_TYPES=length(obj.InportList);

            for kType=1:NUM_TYPES

                IS_THIS_PLUGIN=feval([obj.InportList{kType}.Name,'.isa'],blockPath);

                if IS_THIS_PLUGIN

                    aInportType=feval(obj.InportList{kType}.Name,blockPath);
                    return;
                end

            end

            DAStudio.error('sl_iospecification:inports:noInportInFactory',getfullname(blockPath));
        end


        function updateFactoryRegistry(obj)
            obj.InportList=internal.findSubClasses('Simulink.iospecification',...
            'Simulink.iospecification.Inport');
        end

    end

end
