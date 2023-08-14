


classdef FPGA<matlab.mixin.Copyable

    properties
        Vendor='';
        Family='';
        Device='';
        Package='';
        Speed='';
        JTAGChainPosition=1;
        UseDigilentPlugIn=false;
    end
    properties(Access=private)
        InterfaceList;
    end

    methods
        function obj=FPGA
            obj.InterfaceList=containers.Map;
        end
        function set.JTAGChainPosition(obj,value)
            if~isnumeric(value)||isnan(value)||value<1
                error(message('EDALink:boardmanager:FPGAInvalidChainPosition'));
            end
            obj.JTAGChainPosition=value;
        end
        function interface=addInterface(obj,Name)
            if ischar(Name)
                interface=eda.internal.boardmanager.InterfaceManager.getInterfaceInstance(Name);
            else
                interface=Name;
            end
            setInterface(obj,interface);
        end

        function removeInterface(obj,Name)
            if obj.InterfaceList.isKey(Name);
                obj.InterfaceList.remove(Name);
            end
        end

        function interface=getInterface(obj,Name)
            if~obj.InterfaceList.isKey(Name)
                error(message('EDALink:boardmanager:FPGAInvalidInterfaceKey',Name));
            end
            interface=obj.InterfaceList(Name);
        end

        function setInterface(obj,Interface)


            ethBaseClass='eda.internal.boardmanager.EthInterface';
            if isa(Interface,ethBaseClass)
                removeInterfaceByClass(obj,ethBaseClass)
            end
            obj.InterfaceList(Interface.Name)=Interface;
        end

        function removeInterfaceByClass(obj,ClassName)
            keys=obj.InterfaceList.keys;
            for m=1:numel(keys)
                interf=obj.InterfaceList(keys{m});
                if isa(interf,ClassName)
                    removeInterface(obj,interf.Name);
                end
            end
        end

        function removeFILInterface(obj)
            ethBaseClass='eda.internal.boardmanager.FILCommInterface';
            removeInterfaceByClass(obj,ethBaseClass);
        end

        function removeTurnkeyInterface(obj)
            removeInterface(obj,eda.internal.boardmanager.UserdefinedInterface.Name);
        end

        function clk=getClock(obj)
            clk=obj.InterfaceList(eda.internal.boardmanager.ClockInterface.Name);
        end
        function r=hasClock(obj)
            r=obj.InterfaceList.isKey(eda.internal.boardmanager.ClockInterface.Name);
        end
        function r=hasReset(obj)
            r=obj.InterfaceList.isKey(eda.internal.boardmanager.ResetInterface.Name);
        end
        function r=getReset(obj)
            r=obj.InterfaceList(eda.internal.boardmanager.ResetInterface.Name);
        end

        function r=hasGMII(obj)
            r=obj.InterfaceList.isKey(eda.internal.boardmanager.GMII.Name);
        end
        function r=hasRGMII(obj)
            r=obj.InterfaceList.isKey(eda.internal.boardmanager.RGMII.Name);
        end

        function r=hasMII(obj)
            r=obj.InterfaceList.isKey(eda.internal.boardmanager.MII.Name);
        end

        function r=hasSGMII(obj)
            r=obj.InterfaceList.isKey(eda.internal.boardmanager.SGMII.Name);
        end

        function r=hasUserIO(obj)
            r=obj.InterfaceList.isKey(eda.internal.boardmanager.UserdefinedInterface.Name);
        end
        function r=getUserIO(obj)
            r=obj.InterfaceList(eda.internal.boardmanager.UserdefinedInterface.Name);
        end
        function r=hasInterface(obj,Name)
            r=obj.InterfaceList.isKey(Name);
        end


        function r=getIOTableTypeInterface(obj)
            r=obj.InterfaceList.keys;

            indx=strcmpi(eda.internal.boardmanager.ClockInterface.Name,r);
            r(indx)=[];
            indx=strcmpi(eda.internal.boardmanager.ResetInterface.Name,r);
            r(indx)=[];
        end

        function r=getInterfaceList(obj)
            r=obj.InterfaceList.keys;
        end

        function r=hasFILInterface(obj)
            r=~isempty(getFILInterface(obj));
        end

        function r=getFILInterface(obj)
            r={};
            list=obj.getInterfaceList;
            for m=1:numel(list)
                interface=obj.getInterface(list{m});


                if isa(interface,'eda.internal.boardmanager.EthInterface')
                    r=[{interface},r];%#ok<AGROW>
                elseif isa(interface,'eda.internal.boardmanager.FILCommInterface')
                    r{end+1}=interface;%#ok<AGROW>
                end
            end
        end

        function r=hasExternalIO(obj)
            r=hasFILInterface(obj)||obj.hasUserIO;
        end

        function validateFPGAFamilyForFIL(obj)
            availableList=eda.internal.boardmanager.InterfaceManager.getSupportedFILInterfaces(obj.Vendor,obj.Family);
            availalbeListClass=cellfun(@(x)class(x),availableList,'UniformOutput',false);
            interfList=getFILInterface(obj);
            if isempty(availableList)
                error(message('EDALink:boardmanager:FamilyNotSupportedByFIL',obj.Family));
            else
                for m=1:numel(interfList)
                    if~any(strcmpi(class(interfList{m}),availalbeListClass))
                        error(message('EDALink:boardmanager:EthInterfaceNotSupported',obj.Family,interfList{m}.Name));
                    end
                end
            end
        end

        function validate(obj)
            if~any(strcmp(obj.Vendor,{'Altera','Xilinx','Microsemi'}))
                error(message('EDALink:boardmanager:InvalidVendor',obj.Vendor));
            end

            if hasFILInterface(obj)
                validateFPGAFamilyForFIL(obj);
            end

            if~hasClock(obj)
                error(message('EDALink:boardmanager:FPGANoClock'));
            end

            if~hasExternalIO(obj)
                error(message('EDALink:boardmanager:FPGANoExternalIO'));
            end

            if(obj.hasGMII+obj.hasRGMII+obj.hasMII+obj.hasSGMII)>1
                error(message('EDALink:boardmanager:FPGAMoreThanOneEthInterface'));
            end

            keys=obj.InterfaceList.keys;
            for m=1:numel(keys)
                interface=obj.InterfaceList(keys{m});
                interface.validate;
            end

            if obj.hasGMII||obj.hasRGMII||obj.hasSGMII
                obj.getClock.validateGigaEthFreq;
            end
        end
    end
    methods(Access=protected)

        function cpObj=copyElement(obj)

            cpObj=copyElement@matlab.mixin.Copyable(obj);

            cpObj.InterfaceList=eda.internal.boardmanager.copyContainersMap(obj.InterfaceList);
        end
    end
end


