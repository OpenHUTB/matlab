classdef IRModifierManager<handle



    properties(Constant,GetAccess=private)

        IRModifierManagerInstance=IRInstrumentation.IRModifierManager;
    end

    properties(GetAccess=private,SetAccess=private)
        ModIDObjMap;
    end

    methods(Static)
        function obj=getInstance

            obj=IRInstrumentation.IRModifierManager.IRModifierManagerInstance;
        end
    end

    methods(Access=private)
        function this=IRModifierManager
            this.ModIDObjMap=Simulink.sdi.Map(char('a'),?handle);

            mlock;
        end
    end

    methods(Access=private)
        function check=isaBus(~,blockPath)
            check=false;

            portHandles=get_param(blockPath,'PortHandles');
            if numel(portHandles)==1
                sigHierarchy=get_param(portHandles.Outport,...
                'SignalHierarchy');
                if~isempty(sigHierarchy.BusObject)
                    check=true;
                end
            end
        end

        function ID=getIDFromPathAndPort(obj,blockPath,portNumber,...
            sigName)
            if getSimulinkBlockHandle(blockPath)==-1
                ID='';
            else

                portHandles=get_param(blockPath,'PortHandles');


                if numel(portHandles.Outport)<portNumber
                    ID='';
                else

                    if isempty(sigName)&&~obj.isaBus(blockPath)

                        ID=strcat(blockPath,'::',num2str(portNumber));
                    elseif~isempty(sigName)&&obj.isaBus(blockPath)


                        sigHierarchy=get_param(portHandles.Outport,...
                        'SignalHierarchy');
                        assert(numel(sigHierarchy)==1);
                        ID=strcat(blockPath,'::',...
                        num2str(portNumber),'::',...
                        sigName);
                    else
                        ID='';
                    end
                end
            end
        end

        function ID=getIDFromHandleAndPort(obj,blockHandle,...
            portNumber,sigName)
            try
                path=getfullname(blockHandle);
            catch
                ID='';
                return;
            end
            ID=obj.getIDFromPathAndPort(path,portNumber,sigName);
        end

    end

    methods

        function mod=getIRModifier(obj,blockID,portNumber,sigName)



            if nargin==3
                sigName='';
            end



            if nargin==2
                warning('IRModifierManager:InvalidArguments',...
                'Invalid number of arguments');
                ID='';
            else



                if isa(blockID,'double')

                    ID=obj.getIDFromHandleAndPort(blockID,...
                    portNumber,sigName);
                    if isempty(ID)
                        warning('IRModifierManager:InvalidHandleAndPort',...
                        'handle and/or signal not valid');
                    end
                else

                    ID=obj.getIDFromPathAndPort(blockID,...
                    portNumber,sigName);
                    if isempty(ID)
                        warning('IRModifierManager:InvalidPathAndPort',...
                        'handle and/or signal not valid');
                    end
                end
            end

            if isempty(ID)



                mod=IRInstrumentation.IRModifier('');
            elseif obj.ModIDObjMap.isKey(ID)


                mod=obj.ModIDObjMap.getDataByKey(ID);
            else

                mod=IRInstrumentation.IRModifier(ID);
                obj.ModIDObjMap.insert(ID,mod);
            end
        end

        function mod=lookupIRModifier(obj,modID)

            if obj.ModIDObjMap.isKey(modID)
                ID=modID;
            else
                warning('IRModifierManager:IDNotFound',...
                'Modifier ID not found');
                ID='';
            end
            if isempty(ID)



                mod=IRInstrumentation.IRModifier('');
            else


                mod=obj.ModIDObjMap.getDataByKey(ID);
            end
        end

        function size=getRegisterSize(obj)

            size=obj.ModIDObjMap.getCount();
        end

        function upload(obj)


            for mIdx=1:obj.getRegisterSize()
                mod=obj.ModIDObjMap.getDataByIndex(mIdx);
                mod.upload();
            end
        end

        function clear(obj)

            for mIdx=1:obj.getRegisterSize()
                mod=obj.ModIDObjMap.getDataByIndex(mIdx);
                obj.deleteIRModifier(mod.ID);
            end


            obj.ModIDObjMap.Clear();
        end

        function deleteIRModifier(obj,modID)

            if obj.ModIDObjMap.isKey(modID)
                mod=obj.ModIDObjMap.getDataByKey(modID);
                mod.deregisterModifier();


                obj.ModIDObjMap.deleteDataByKey(modID);
            end
        end
    end

end
