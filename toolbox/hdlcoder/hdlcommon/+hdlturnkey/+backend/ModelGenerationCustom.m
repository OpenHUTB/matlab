


classdef ModelGenerationCustom<hdlturnkey.backend.ModelGeneration


    properties

    end


    methods

        function obj=ModelGenerationCustom(hTurnkey)


            obj=obj@hdlturnkey.backend.ModelGeneration(hTurnkey);
            obj.messageString='Custom Software Interface';
            obj.maskString='Custom \nAXI Interface';

        end

        function[status,result,validateCell]=generateModelWithoutLibraryBlock(obj)

            status=true;
            result='';


            [status,result]=obj.initModelGen(status,result);


            [status,result,validateCell]=obj.configureTIFDUT(status,result);


            [status,result]=obj.finishModelGen(status,result);

        end


        function[status,result]=generateLibraryBlock(~)

            error('This method is broken');

        end



        function validateLicense(~)

        end


        function warnMsg=warnAboutECoderLicense(~)

            warnMsg='';
        end

    end

    methods(Access=protected)


        function[status,result,validateCell]=configureTIFDUT(obj,status,result)



            obj.createSubsystemOnTopLevel;



            dutPath=obj.createTunableConstantsUnderDUT();


            ipcoreinfo=obj.generateIPCoreInfo;


            [status,result]=obj.callCustomCallback(ipcoreinfo,status,result);
            validateCell={};




            obj.addMaskOnDeviceUnderTestBlock(dutPath);



            customGMConfig(obj);
        end

    end

end






