



classdef InterfaceList<hdlturnkey.interface.InterfaceListBase


    properties(Access=protected)


        hTurnkey=[];


        SupportedInterfaceIDList={};


        DispInterfaceMap=[];


        EmptyInterfaceID='No Interface Specified';
        AddMoreInterfaceID='Add more...';
        CustomInterfaceID='Specify FPGA Pin {''LSB'',...,''MSB''}';
    end

    methods

        function obj=InterfaceList(hTurnkey)

            obj=obj@hdlturnkey.interface.InterfaceListBase();

            obj.hTurnkey=hTurnkey;
            obj.DispInterfaceMap=containers.Map();

        end

        function initInterfaceList(obj)


            obj.clearInterfaceList;


            obj.addSupportedInterface(...
            hdlturnkey.interface.InterfaceEmpty(obj.EmptyInterfaceID));


            if~obj.hTurnkey.hD.isIPCoreGen
                obj.addSupportedInterface(...
                hdlturnkey.interface.InterfaceCustom(obj.CustomInterfaceID));
            end
        end

        function finalizeInterfaceList(obj)



            if obj.hTurnkey.hD.isGenericIPPlatform&&~obj.hTurnkey.hD.isMLHDLC
                obj.addSupportedInterface(...
                hdlturnkey.interface.InterfaceAddMore(obj.AddMoreInterfaceID));
            end
        end



        function list=getSupportedInterfaceIDList(obj)

            list=obj.SupportedInterfaceIDList;
        end


        function interfaceID=getInterfaceIDFromDispStr(obj,interfaceStr)
            interfaceID=obj.DispInterfaceMap(interfaceStr);
        end


        function hEmptyInterface=getEmptyInterface(obj)
            hEmptyInterface=obj.getInterface(obj.EmptyInterfaceID);
        end


        function addSupportedInterface(obj,hInterface)







            obj.addInterface(hInterface);


            supportedTool=hInterface.SupportedTool;
            if~isempty(supportedTool)
                toolName=obj.hTurnkey.hD.get('Tool');
                matchToolName=any(strcmp(supportedTool,toolName));
                if~matchToolName
                    return;
                end
            end




            isLiberoTool=obj.hTurnkey.hD.isLiberoSoc;
            if isLiberoTool
                supportedFamily=hInterface.SupportedLiberoFamily;
                if~isempty(supportedFamily)
                    familyName=obj.hTurnkey.hD.get('Family');
                    matchFamilyName=any(strcmp(supportedFamily,familyName));
                    if~matchFamilyName
                        return;
                    end
                end
            end



            if isa(hInterface,'hdlturnkey.interface.JTAGDataCapture')&&obj.hTurnkey.isVersalPlatform
                return;
            end


            obj.SupportedInterfaceIDList{end+1}=hInterface.InterfaceID;
        end



        function updateInterfaceList(obj)



























            obj.SupportedInterfaceIDList={};


            if isempty(obj.hTurnkey.hBoard)
                return;
            end


            obj.hTurnkey.clearDefaultBusInterface;



            obj.initInterfaceList;



            if obj.hTurnkey.hD.isIPCoreGen&&...
                obj.hTurnkey.hD.hIP.isRDListLoaded
                hRD=obj.hTurnkey.hD.hIP.getReferenceDesignPlugin;
                if~isempty(hRD)
                    rdInterfaceIDList=hRD.getInterfaceIDList;
                    for ii=1:length(rdInterfaceIDList)
                        interfaceID=rdInterfaceIDList{ii};
                        hInterface=hRD.getInterface(interfaceID);


                        obj.addSupportedInterface(hInterface);
                    end
                end
            end


            boardInterfaceIDList=obj.hTurnkey.hBoard.getInterfaceIDList;
            for ii=1:length(boardInterfaceIDList)
                interfaceID=boardInterfaceIDList{ii};
                hInterface=obj.hTurnkey.hBoard.getInterface(interfaceID);


                obj.addSupportedInterface(hInterface);
            end



            if obj.hTurnkey.hD.isGenericIPPlatform
                dynamicInterfaceIDList=obj.hTurnkey.getDynamicInterfaceIDList;
                for ii=1:length(dynamicInterfaceIDList)
                    interfaceID=dynamicInterfaceIDList{ii};
                    hInterface=obj.hTurnkey.getDynamicInterface(interfaceID);


                    obj.addSupportedInterface(hInterface);
                end
            end











            hInterface=hdlturnkey.interface.AXI4SlaveEmpty('IsGenericIP',true);
            obj.addSupportedInterface(hInterface);


            obj.finalizeInterfaceList;


            obj.refreshTableInterface;
        end

        function refreshTableInterface(obj)



            obj.InputInterfaceIDList={};
            obj.OutputInterfaceIDList={};
            obj.DispInterfaceMap=containers.Map();


            obj.hTurnkey.refreshDefaultBusInterface;

            supportedInterfaceIDList=obj.getSupportedInterfaceIDList;
            for ii=1:length(supportedInterfaceIDList)
                interfaceID=supportedInterfaceIDList{ii};
                hInterface=obj.getInterface(interfaceID);


                if~hInterface.showInInterfaceChoice(obj.hTurnkey)
                    continue;
                end


                [inputInterfaceStrList,outputInterfaceStrList]=...
                hInterface.getTableInterfaceStrList;


                for jj=1:length(inputInterfaceStrList)
                    obj.populateDispInterfaceMap(interfaceID,inputInterfaceStrList{jj});
                end
                for jj=1:length(outputInterfaceStrList)
                    obj.populateDispInterfaceMap(interfaceID,outputInterfaceStrList{jj});
                end


                if hInterface.InterfaceType==hdlturnkey.IOType.IN
                    obj.InputInterfaceIDList=[obj.InputInterfaceIDList,inputInterfaceStrList];
                elseif hInterface.InterfaceType==hdlturnkey.IOType.OUT
                    obj.OutputInterfaceIDList=[obj.OutputInterfaceIDList,outputInterfaceStrList];
                else
                    obj.InputInterfaceIDList=[obj.InputInterfaceIDList,inputInterfaceStrList];
                    obj.OutputInterfaceIDList=[obj.OutputInterfaceIDList,outputInterfaceStrList];
                end
            end
        end

    end

    methods(Access=protected)

        function populateDispInterfaceMap(obj,interfaceID,dispInterfaceStr)

            if~obj.DispInterfaceMap.isKey(dispInterfaceStr)
                obj.DispInterfaceMap(dispInterfaceStr)=interfaceID;
            else

                storedInterfaceID=obj.DispInterfaceMap(dispInterfaceStr);
                if~strcmp(storedInterfaceID,interfaceID)
                    error(message('hdlcommon:hdlturnkey:InterfaceDispConflict',dispInterfaceStr,storedInterfaceID,interfaceID));
                end
            end
        end

    end


end

