



classdef TunableParamPortList<handle


    properties

        TunableParamNameList={};


        TunableParamPortMap=[];



        TunableParamSLTypeMap=[];
    end

    methods


        function obj=TunableParamPortList()
            obj.TunableParamPortMap=containers.Map();
            obj.TunableParamSLTypeMap=containers.Map();
        end


        function buildTunableParamPortList(obj,hdlC,hDI)

            allModels=hdlC.AllModels;

            for mdlIdx=1:numel(allModels)

                cm=hdlC.getConfigManager(allModels(mdlIdx).modelName);

                p=pir(allModels(mdlIdx).modelName);

                topNet=p.getTopNetwork;

                topNetFullPath=hdlturnkey.data.getTopNetFullPath(topNet,hDI);

                hN=p.Networks;

                for nwIdx=1:numel(hN)

                    hC=hN(nwIdx).Components;

                    for compIdx=1:numel(hC)

                        compSLHandle=hC(compIdx).SimulinkHandle;
                        try
                            compFullName=getfullname(compSLHandle);

                            impl=cm.getImplementationForBlock(compFullName);

                            tunableParameterInfo=impl.getTunableParameterInfo(compSLHandle);
                        catch
                            tunableParameterInfo=[];
                            compFullName='';
                        end

                        obj.createTunableParamPort(topNetFullPath,compFullName,tunableParameterInfo);
                    end
                end
            end
        end

    end

    methods(Access=protected)


        function createTunableParamPort(obj,topNetFullPath,compFullName,tunableParameterInfo)
            if~isempty(tunableParameterInfo)

                for ii=1:numel(tunableParameterInfo)

                    portName=tunableParameterInfo(ii).ParameterName;

                    if~isKey(obj.TunableParamPortMap,portName)

                        obj.TunableParamNameList{end+1}=portName;

                        sampleTime=tunableParameterInfo(ii).SampleTime;

                        tunableParamDataType=tunableParameterInfo(ii).DataType;
                        if tunableParamDataType.isRecordType
                            hDataType=hdlturnkey.data.TypeBus();
                        else
                            hDataType=hdlturnkey.data.TypeFixedPt();
                        end
                        hDataType.initFromPirType(tunableParamDataType);

                        dataType=pirgetdatatypeinfo(tunableParamDataType);

                        if dataType.isvector
                            dispTypeStr=sprintf('%s (%d)',dataType.sltype,dataType.dims);
                        elseif tunableParamDataType.isRecordType
                            dispTypeStr=sprintf('bus');
                        else
                            dispTypeStr=dataType.sltype;
                        end

                        if strcmp(dataType.sltype,'boolean')
                            isBoolean=1;
                        else
                            isBoolean=0;
                        end

                        issingle=(dataType.isfloat)&&(dataType.wordsize==32)&&(dataType.binarypoint==23);
                        isdouble=(dataType.isfloat)&&(dataType.wordsize==64)&&(dataType.binarypoint==52);
                        ishalf=(dataType.isfloat)&&(dataType.wordsize==16)&&(dataType.binarypoint==10);


                        hTunablePort=hdlturnkey.data.IOPortTunable(...
                        'PortName',portName,...
                        'PortFullName',sprintf('%s/%s',topNetFullPath,portName),...
                        'PortRate',sampleTime,...
                        'PortType',hdlturnkey.IOType.IN,...
                        'PortIndex',-1,...
                        'PortKind','data',...
                        'Signed',dataType.issigned,...
                        'WordLength',dataType.wordsize,...
                        'FractionLength',dataType.binarypoint,...
                        'isBoolean',isBoolean,...
                        'isComplex',dataType.iscomplex,...
                        'isDouble',isdouble,...
                        'isSingle',issingle,...
                        'isHalf',ishalf,...
                        'isVector',dataType.isvector,...
                        'isBus',tunableParamDataType.isRecordType,...
                        'Type',hDataType,...
                        'Dimension',dataType.dims,...
                        'SLDataType',dataType.sltype,...
                        'DispDataType',dispTypeStr,...
                        'Bidirectional',0,...
                        'IOInterface','',...
                        'IOInterfaceMapping','');
                        hTunablePort.CompFullName=compFullName;
                        obj.TunableParamPortMap(portName)=hTunablePort;


                        obj.TunableParamSLTypeMap(portName)=getslsignaltype(tunableParameterInfo(ii).DataType);
                    end
                end
            end
        end

    end
end
