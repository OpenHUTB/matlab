classdef ImplementationConfigCallback<handle





    properties
        m_compToCallback;
    end


    methods
        function self=CharacterizationConfigCallback()
            self.m_compToCallback=containers.Map('KeyType','char','ValueType','any');
            self.init();
        end

        function init(self)
            self.m_compToCallback('hdldefaults.BitOps')=@paramProcessBitOps;
        end

        function config=transformConfig(self,name,config)
            if self.m_compToCallback.isKey(name)
                fhandle=self.m_compToCallback(name);
                config=fhandle(self,config);
            end
        end


        function config=paramProcessBitOps(~,config)

            newParams={};
            portCount=-1;
            for i=1:2:numel(config.currentParamSettings)

                if strcmpi('NumInputPorts',config.currentParamSettings{i})==true
                    portCount=str2double(config.currentParamSettings{i+1});
                    continue;
                end

                newParams{end+1}=config.currentParamSettings{i};
                newParams{end+1}=config.currentParamSettings{i+1};
            end

            if portCount==-1
                error('Incorrect setting NumInputPorts for BitOps');
            end

            config.currentParamSettings=newParams;
            config.currentWidthSettings={1,portCount};
        end

    end
end
