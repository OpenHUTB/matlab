


classdef ModelGenerationECoder<hdlturnkey.backend.ModelGeneration




    properties(Abstract,Access=protected)

eCoderSPID

AXI4SlaveResetFunction
    end

    properties(Access=protected)
        IPCoreDeviceFile='/dev/mwipcore';
    end

    methods(Abstract)

        callECoderCallback(obj,ipcoreinfo)
    end

    methods(Abstract,Access=protected)
        setCustomMessageString(obj)
        configureModelForCoderTarget(obj,modelName,boardName,familyName,operatingSystem)
    end

    methods

        function obj=ModelGenerationECoder(hTurnkey)

            obj=obj@hdlturnkey.backend.ModelGeneration(hTurnkey);
        end


        function[status,result,validateCell]=generateModelWithoutLibraryBlock(obj)
            status=true;
            result='';

            obj.validateLicense;


            [status,result]=obj.initModelGen(status,result);


            [status,result,validateCell]=obj.configureTIFDUT(status,result);


            [status,result]=obj.finishModelGen(status,result);

        end


        function[status,result,validateCell]=generateHostModelWithoutLibraryBlock(obj)
            status=true;
            result='';


            [status,result]=obj.initModelGen(status,result);


            [status,result,validateCell]=obj.configureHIFDUT(status,result);


            [status,result]=obj.finishHostModelGen(status,result);

        end

        function[status,result,validateCell]=generateLibraryBlock(obj)


            obj.validateLicense;


            [status,result]=obj.initLibraryBlockGen;





            validateCell=obj.generateInterfaceDrivers;


            obj.setECoderParameters;


            obj.addMaskOnDeviceUnderTestBlock(obj.blockPath);


            [status,result]=obj.finishLibraryBlockGen(status,result);

        end



        function validateLicense(obj)

            hDI=obj.hTurnkey.hD;
            if hDI.isIPWorkflow
                [isInstalled,spName]=hdlturnkey.isECoderSPInstalled(obj.eCoderSPID);
                if~isInstalled
                    taskNameObj=message('hdlcommon:workflow:HDLWAEmbeddedModelGen');
                    error(message('hdlcommon:workflow:ECoderPackageUnavailable',spName,taskNameObj.getString));
                end
                if~hdlturnkey.isECoderInstalled
                    taskNameObj=message('hdlcommon:workflow:HDLWAEmbeddedModelGen');
                    error(message('hdlcommon:workflow:ECoderLicenseUnavailable',taskNameObj.getString));
                end
            end
        end



        function warnMsg=warnAboutECoderLicense(obj)

            warnMsg='';
            hDI=obj.hTurnkey.hD;
            if hDI.isIPWorkflow
                [isInstalled,spName]=hdlturnkey.isECoderSPInstalled(obj.eCoderSPID);
                if~isInstalled
                    taskNameObj=message('hdlcommon:workflow:HDLWAEmbeddedModelGen');
                    msgObj=message('hdlcommon:workflow:ECoderPackageUnavailable',spName,taskNameObj.getString);
                    warnMsg=msgObj.getString;
                    return;
                end
                if~hdlturnkey.isECoderInstalled
                    taskNameObj=message('hdlcommon:workflow:HDLWAEmbeddedModelGen');
                    msgObj=message('hdlcommon:workflow:ECoderLicenseUnavailable',taskNameObj.getString);
                    warnMsg=msgObj.getString;
                    return;
                end
            end
        end

    end

    methods(Access=protected)


        function[status,result,validateCell]=configureTIFDUT(obj,status,result)



            obj.createSubsystemOnTopLevel;





            dutPath=obj.addTestPointPortsOnDUT();



            dutPath=obj.createTunableConstantsUnderDUT();


            validateCell=obj.generateInterfaceDrivers;


            obj.setECoderParameters;




            obj.addMaskOnDeviceUnderTestBlock(dutPath);



            customGMConfig(obj);
        end


        function[status,result,validateCell]=configureHIFDUT(obj,status,result)



            obj.createSubsystemOnTopLevel;





            dutPath=obj.addTestPointPortsOnDUT();



            dutPath=obj.createTunableConstantsUnderDUT();


            validateCell=obj.generateHostInterfaceDrivers;







            obj.addMaskOnDeviceUnderTestBlock(dutPath);


            set_param(dutPath,'InitFcn',sprintf(['intfConfig = hdlverifier.internal.AXIMaster.SimulinkBlock.getConfig(); \n',...
            'intfConfig.setConfig(''JTAG'');']));




            customGMConfig(obj);
        end

        function setECoderParameters(obj)
            dutPath=obj.tifDutPath;
            modelName=obj.tifMdlName;


            obj.addResetBlock(dutPath);


            set_param(dutPath,'TreatAsAtomicUnit','on');


            set_param(dutPath,'SystemSampleTime','-1');


            set_param(modelName,'SystemTargetFile','ert.tlc');


            set_param(modelName,'Dirty','off');


            boardName=obj.hTurnkey.hD.get('Board');
            familyName=obj.hTurnkey.hD.get('Family');
            operatingSystem=obj.hTurnkey.hD.hIP.getOperatingSystem;
            obj.configureModelForCoderTarget(modelName,boardName,familyName,operatingSystem);


            codertarget.arm_cortex_a.internal.setConcurrentExecution(modelName);


            if obj.hTurnkey.isCoProcessorMode
                set_param(dutPath,'InitFcn',sprintf('codertarget.resourcemanager.register(gcbh, ''AXI4InterfaceCommon'',''CoProcessingMode'',%d)',1));
            end
        end

        function addResetBlock(obj,dutPath)








            systemInit=[dutPath,'/AXI4Reset'];
            add_block('custcode/System Start',systemInit);
            resetFcn=[obj.AXI4SlaveResetFunction,'("%s");\n'];
            dataInit=sprintf(resetFcn,obj.IPCoreDeviceFile);
            rtwData=get_param(systemInit,'RTWdata');
            rtwData.TLCFile='custcode';
            rtwData.Top=dataInit;
            rtwData.Location='System Start Function';
            set_param(systemInit,'RTWdata',rtwData);

            modelSource=[dutPath,'/AXI4ResetModelSource'];
            add_block('custcode/Model Source',modelSource);
            rtwDataMdlSrc.TLCFile='custcode';
            rtwDataMdlSrc.Location='Model Source';
            rtwDataMdlSrc.Top=sprintf('#include "axi_lct.h"\n');
            set_param(modelSource,'RTWdata',rtwDataMdlSrc);
        end

        function selectedBoard=getAvailableBoard(~,desiredBoard,availableBoards)
            selectedBoard='';
            for i=1:numel(availableBoards)

                name1=lower(regexprep(desiredBoard,'[^0-9a-zA-Z]+',''));
                name2=lower(regexprep(availableBoards{i},'[^0-9a-zA-Z]+',''));

                if(any(strfind(name1,name2)))
                    selectedBoard=availableBoards{i};
                    break;
                end
            end
        end

    end

end
