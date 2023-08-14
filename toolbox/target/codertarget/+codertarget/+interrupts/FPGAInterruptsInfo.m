classdef FPGAInterruptsInfo<codertarget.Info




    properties
        DefinitionFileName=''
        TargetFolder=''
        TargetName=''
FPGAInterrupts

    end

    properties(Dependent)
NumOfInterfaces
TotalNumInterrupts
    end

    properties(Hidden,Constant)
        InterruptInterfaceTag='InterruptInterface';
        InterfacePortNameTag='InterfacePortName';
        InterfacePortWidthTag='InterfacePortWidth';
        NumOfInterfacesTag='NumOfInterfaces';
        TotalNumInterruptsTag='TotalNumInterrupts';
    end

    methods
        function obj=FPGAInterruptsInfo(filePathName)
            if(nargin==1)
                obj.DefinitionFileName=filePathName;
                obj.TargetFolder=fileparts(fileparts(fileparts(obj.DefinitionFileName)));
                obj.deserialize;
            end
        end
    end

    methods
        function ret=get.NumOfInterfaces(obj)
            ret=numel(obj.FPGAInterrupts);
        end

        function ret=get.TotalNumInterrupts(obj)
            ret=sum([obj.FPGAInterrupts.InterfacePortWidth]);
        end

        function addNewFPGAInterrupt(obj,info)
            fpgaIntrObj=codertarget.interrupts.FPGAInterrupts;
            fpgaIntrObj.InterfacePortName=info.InterfacePortName;
            fpgaIntrObj.InterfacePortWidth=info.InterfacePortWidth;
            obj.FPGAInterrupts=[obj.FPGAInterrupts,fpgaIntrObj];
        end

        function serialize(obj)
            docObj=obj.createDocument('productinfo');
            docObj.item(0).setAttribute('version','3.0');
            obj.setElement(docObj,obj.NumOfInterfacesTag,obj.NumOfInterfaces);
            obj.setElement(docObj,obj.TotalNumInterruptsTag,obj.TotalNumInterrupts);
            for i=1:obj.NumOfInterfaces
                obj.setElement(docObj,obj.InterruptInterfaceTag,...
                struct(obj.InterfacePortNameTag,obj.FPGAInterrupts(i).InterfacePortName,...
                obj.InterfacePortWidthTag,obj.FPGAInterrupts(i).InterfacePortWidth));
            end

            obj.write(codertarget.utils.replacePathSep(obj.DefinitionFileName),docObj);
        end

        function deserialize(obj)
            docObj=obj.read(obj.DefinitionFileName);
            prodInfoList=docObj.getElementsByTagName('productinfo');
            rootItem=prodInfoList.item(0);
            numInterfaces=obj.getElement(rootItem,obj.NumOfInterfacesTag,'numeric',0);
            for i=0:numInterfaces-1
                info=obj.getElement(rootItem,obj.InterruptInterfaceTag,'struct',i);
                info.InterfacePortWidth=str2double(info.InterfacePortWidth);
                obj.addNewFPGAInterrupt(info);
            end
        end
    end
end