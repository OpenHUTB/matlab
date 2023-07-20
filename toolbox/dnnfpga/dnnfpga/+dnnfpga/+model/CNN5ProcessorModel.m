classdef CNN5ProcessorModel<dnnfpga.model.ProcessorModelBase





    properties

params
deployableNW
    end

    methods
        function obj=CNN5ProcessorModel(hPC,verbose)
            if nargin<2
                verbose=1;
            end

            obj.hPC=hPC;
            obj.Verbose=verbose;
            obj.ModelName='testbench';
            obj.HWChipName='DUT';
            obj.ModelRelativePath='cnn5processor';
        end

        function processor=getProcessor(obj)

            processor=obj.hPC.createProcessorObject;
        end

        function preModelSetup(obj)







            rng('default');
            imageSize=[1,1,1];
            weightSize=[1];
            [sn,image]=dnnfpga.dagnet.shared.createNewNetworkforSim2(imageSize,weightSize);
            obj.hPC.ModelManager.preModelSetup(sn,image,false);
        end







        function postModelSetup(obj,hPC)




            hdlset_param('testbench/DUT/start','IOInterface','AXI4');
            hdlset_param('testbench/DUT/start','IOInterfaceMapping','x"138"');


            hdlset_param('testbench/DUT/debugEnable','IOInterface','AXI4');
            hdlset_param('testbench/DUT/debugEnable','IOInterfaceMapping','x"140"');


            hdlset_param('testbench/DUT/debugDMAEnable','IOInterface','AXI4');
            hdlset_param('testbench/DUT/debugDMAEnable','IOInterfaceMapping','x"144"');


            hdlset_param('testbench/DUT/debugDMALength','IOInterface','AXI4');
            hdlset_param('testbench/DUT/debugDMALength','IOInterfaceMapping','x"148"');


            hdlset_param('testbench/DUT/debugSelect','IOInterface','AXI4');
            hdlset_param('testbench/DUT/debugSelect','IOInterfaceMapping','x"14C"');


            hdlset_param('testbench/DUT/debugDMAWidth','IOInterface','AXI4');
            hdlset_param('testbench/DUT/debugDMAWidth','IOInterfaceMapping','x"150"');


            hdlset_param('testbench/DUT/debugDMAOffset','IOInterface','AXI4');
            hdlset_param('testbench/DUT/debugDMAOffset','IOInterfaceMapping','x"154"');


            hdlset_param('testbench/DUT/debugDMADirection','IOInterface','AXI4');
            hdlset_param('testbench/DUT/debugDMADirection','IOInterfaceMapping','x"158"');


            hdlset_param('testbench/DUT/debugDMAStart','IOInterface','AXI4');
            hdlset_param('testbench/DUT/debugDMAStart','IOInterfaceMapping','x"15C"');


            hdlset_param('testbench/DUT/image_valid','IOInterface','AXI4');
            hdlset_param('testbench/DUT/image_valid','IOInterfaceMapping','x"160"');


            hdlset_param('testbench/DUT/image_addr','IOInterface','AXI4');
            hdlset_param('testbench/DUT/image_addr','IOInterfaceMapping','x"164"');


            hdlset_param('testbench/DUT/image_data','IOInterface','AXI4');
            hdlset_param('testbench/DUT/image_data','IOInterfaceMapping','x"168"');


            hdlset_param('testbench/DUT/read_addr','IOInterface','AXI4');
            hdlset_param('testbench/DUT/read_addr','IOInterfaceMapping','x"16C"');


            hdlset_param('testbench/DUT/dma_from_ddr4_done','IOInterface','AXI4');
            hdlset_param('testbench/DUT/dma_from_ddr4_done','IOInterfaceMapping','x"184"');


            hdlset_param('testbench/DUT/dma_to_ddr4_done','IOInterface','AXI4');
            hdlset_param('testbench/DUT/dma_to_ddr4_done','IOInterfaceMapping','x"188"');


            hdlset_param('testbench/DUT/debug_read_data','IOInterface','AXI4');
            hdlset_param('testbench/DUT/debug_read_data','IOInterfaceMapping','x"17C"');


            hdlset_param('testbench/DUT/has_handShaking','IOInterface','AXI4');
            hdlset_param('testbench/DUT/has_handShaking','IOInterfaceMapping','x"338"');


            hdlset_param('testbench/DUT/hs_ddr_addr','IOInterface','AXI4');
            hdlset_param('testbench/DUT/hs_ddr_addr','IOInterfaceMapping','x"33C"');


            hdlset_param('testbench/DUT/adder_lc_addr','IOInterface','AXI4');
            hdlset_param('testbench/DUT/adder_lc_addr','IOInterfaceMapping','x"340"');


            hdlset_param('testbench/DUT/adder_lc_len','IOInterface','AXI4');
            hdlset_param('testbench/DUT/adder_lc_len','IOInterfaceMapping','x"348"');



            hdlset_param('testbench/DUT/dut_rd_m2s','IOInterface','AXI4 Master Activation Data Read');
            hdlset_param('testbench/DUT/dut_rd_m2s','IOInterfaceMapping','Read Master to Slave Bus');


            hdlset_param('testbench/DUT/dut_wr_s2m','IOInterface','AXI4 Master Activation Data Write');
            hdlset_param('testbench/DUT/dut_wr_s2m','IOInterfaceMapping','Write Slave to Master Bus');


            hdlset_param('testbench/DUT/dut_rd_data','IOInterface','AXI4 Master Activation Data Read');
            hdlset_param('testbench/DUT/dut_rd_data','IOInterfaceMapping','Data');


            hdlset_param('testbench/DUT/dut_wr_m2s','IOInterface','AXI4 Master Activation Data Write');
            hdlset_param('testbench/DUT/dut_wr_m2s','IOInterfaceMapping','Write Master to Slave Bus');


            hdlset_param('testbench/DUT/dut_rd_s2m','IOInterface','AXI4 Master Activation Data Read');
            hdlset_param('testbench/DUT/dut_rd_s2m','IOInterfaceMapping','Read Slave to Master Bus');


            hdlset_param('testbench/DUT/dut_wr_data','IOInterface','AXI4 Master Activation Data Write');
            hdlset_param('testbench/DUT/dut_wr_data','IOInterfaceMapping','Data');



            hdlset_param('testbench/DUT/weight_rd_m2s','IOInterface','AXI4 Master Weight Data Read');
            hdlset_param('testbench/DUT/weight_rd_m2s','IOInterfaceMapping','Read Master to Slave Bus');


            hdlset_param('testbench/DUT/weight_rd_data','IOInterface','AXI4 Master Weight Data Read');
            hdlset_param('testbench/DUT/weight_rd_data','IOInterfaceMapping','Data');


            hdlset_param('testbench/DUT/weight_rd_s2m','IOInterface','AXI4 Master Weight Data Read');
            hdlset_param('testbench/DUT/weight_rd_s2m','IOInterfaceMapping','Read Slave to Master Bus');



            hdlset_param('testbench/DUT/debug_wr_s2m','IOInterface','AXI4 Master Debug Write');
            hdlset_param('testbench/DUT/debug_wr_s2m','IOInterfaceMapping','Write Slave to Master Bus');


            hdlset_param('testbench/DUT/debug_rd_data','IOInterface','AXI4 Master Debug Read');
            hdlset_param('testbench/DUT/debug_rd_data','IOInterfaceMapping','Data');


            hdlset_param('testbench/DUT/debug_rd_s2m','IOInterface','AXI4 Master Debug Read');
            hdlset_param('testbench/DUT/debug_rd_s2m','IOInterfaceMapping','Read Slave to Master Bus');


            hdlset_param('testbench/DUT/debug_rd_m2s','IOInterface','AXI4 Master Debug Read');
            hdlset_param('testbench/DUT/debug_rd_m2s','IOInterfaceMapping','Read Master to Slave Bus');


            hdlset_param('testbench/DUT/debug_wr_data','IOInterface','AXI4 Master Debug Write');
            hdlset_param('testbench/DUT/debug_wr_data','IOInterfaceMapping','Data');


            hdlset_param('testbench/DUT/debug_wr_m2s','IOInterface','AXI4 Master Debug Write');
            hdlset_param('testbench/DUT/debug_wr_m2s','IOInterfaceMapping','Write Master to Slave Bus');





            if strcmp(hPC.RunTimeControl,'port')


                hdlset_param('testbench/DUT/inputStart','IOInterface','External Port');
                hdlset_param('testbench/DUT/inputStart','IOInterfaceMapping','');


                hdlset_param('testbench/DUT/InputStop','IOInterface','External Port');
                hdlset_param('testbench/DUT/InputStop','IOInterfaceMapping','');


                hdlset_param('testbench/DUT/FrameCount','IOInterface','External Port');
                hdlset_param('testbench/DUT/FrameCount','IOInterfaceMapping','');

            else


                hdlset_param('testbench/DUT/inputStart','IOInterface','AXI4');
                hdlset_param('testbench/DUT/inputStart','IOInterfaceMapping','x"224"');


                hdlset_param('testbench/DUT/InputStop','IOInterface','AXI4');
                hdlset_param('testbench/DUT/InputStop','IOInterfaceMapping','x"374"');


                hdlset_param('testbench/DUT/FrameCount','IOInterface','AXI4');
                hdlset_param('testbench/DUT/FrameCount','IOInterfaceMapping','x"24C"');

            end



            if strcmp(hPC.RunTimeStatus,'port')


                hdlset_param('testbench/DUT/done','IOInterface','External Port');
                hdlset_param('testbench/DUT/done','IOInterfaceMapping','');






                hdlset_param('testbench/DUT/StreamingDone','IOInterface','External Port');
                hdlset_param('testbench/DUT/StreamingDone','IOInterfaceMapping','');

            else


                hdlset_param('testbench/DUT/done','IOInterface','AXI4');
                hdlset_param('testbench/DUT/done','IOInterfaceMapping','x"220"');






                hdlset_param('testbench/DUT/StreamingDone','IOInterface','AXI4');
                hdlset_param('testbench/DUT/StreamingDone','IOInterfaceMapping','x"370"');

            end



            if strcmp(hPC.SetupControl,'port')


                hdlset_param('testbench/DUT/StreamingMode','IOInterface','External Port');
                hdlset_param('testbench/DUT/StreamingMode','IOInterfaceMapping','');




                hdlset_param('testbench/DUT/UseCustomBaseAddr','IOInterface','External Port');
                hdlset_param('testbench/DUT/UseCustomBaseAddr','IOInterfaceMapping','');


                hdlset_param('testbench/DUT/InputBaseAddr','IOInterface','External Port');
                hdlset_param('testbench/DUT/InputBaseAddr','IOInterfaceMapping','');


                hdlset_param('testbench/DUT/OutputBaseAddr','IOInterface','External Port');
                hdlset_param('testbench/DUT/OutputBaseAddr','IOInterfaceMapping','');

            else


                hdlset_param('testbench/DUT/StreamingMode','IOInterface','AXI4');
                hdlset_param('testbench/DUT/StreamingMode','IOInterfaceMapping','x"34C"');




                hdlset_param('testbench/DUT/UseCustomBaseAddr','IOInterface','AXI4');
                hdlset_param('testbench/DUT/UseCustomBaseAddr','IOInterfaceMapping','x"380"');


                hdlset_param('testbench/DUT/InputBaseAddr','IOInterface','AXI4');
                hdlset_param('testbench/DUT/InputBaseAddr','IOInterfaceMapping','x"384"');


                hdlset_param('testbench/DUT/OutputBaseAddr','IOInterface','AXI4');
                hdlset_param('testbench/DUT/OutputBaseAddr','IOInterfaceMapping','x"388"');

            end




            hdlset_param('testbench/DUT/preLoadingStart','IOInterface','AXI4');
            hdlset_param('testbench/DUT/preLoadingStart','IOInterfaceMapping','x"228"');


            hdlset_param('testbench/DUT/fc_weight_ddr_addr','IOInterface','AXI4');
            hdlset_param('testbench/DUT/fc_weight_ddr_addr','IOInterfaceMapping','x"294"');


            hdlset_param('testbench/DUT/fc_lc_ddr_len','IOInterface','AXI4');
            hdlset_param('testbench/DUT/fc_lc_ddr_len','IOInterfaceMapping','x"298"');


            hdlset_param('testbench/DUT/fc_lc_ddr_addr','IOInterface','AXI4');
            hdlset_param('testbench/DUT/fc_lc_ddr_addr','IOInterfaceMapping','x"29C"');


            hdlset_param('testbench/DUT/fc_layerNum','IOInterface','AXI4');
            hdlset_param('testbench/DUT/fc_layerNum','IOInterfaceMapping','x"300"');


            hdlset_param('testbench/DUT/fc_modeIn','IOInterface','AXI4');
            hdlset_param('testbench/DUT/fc_modeIn','IOInterfaceMapping','x"304"');


            hdlset_param('testbench/DUT/skd_ddr_addr','IOInterface','AXI4');
            hdlset_param('testbench/DUT/skd_ddr_addr','IOInterfaceMapping','x"308"');


            hdlset_param('testbench/DUT/skd_ddr_len','IOInterface','AXI4');
            hdlset_param('testbench/DUT/skd_ddr_len','IOInterfaceMapping','x"30C"');


            hdlset_param('testbench/DUT/add_ip_addr','IOInterface','AXI4');
            hdlset_param('testbench/DUT/add_ip_addr','IOInterfaceMapping','x"310"');


            hdlset_param('testbench/DUT/add_op_addr','IOInterface','AXI4');
            hdlset_param('testbench/DUT/add_op_addr','IOInterfaceMapping','x"314"');


            hdlset_param('testbench/DUT/wr_reqCounter','IOInterface','AXI4');
            hdlset_param('testbench/DUT/wr_reqCounter','IOInterfaceMapping','x"318"');


            hdlset_param('testbench/DUT/nc_LCtotalLength_IP0','IOInterface','AXI4');
            hdlset_param('testbench/DUT/nc_LCtotalLength_IP0','IOInterfaceMapping','x"31C"');


            hdlset_param('testbench/DUT/nc_LCtotalLength_Conv','IOInterface','AXI4');
            hdlset_param('testbench/DUT/nc_LCtotalLength_Conv','IOInterfaceMapping','x"320"');


            hdlset_param('testbench/DUT/nc_LCtotalLength_OP0','IOInterface','AXI4');
            hdlset_param('testbench/DUT/nc_LCtotalLength_OP0','IOInterfaceMapping','x"324"');


            hdlset_param('testbench/DUT/nc_LCoffset_IP0','IOInterface','AXI4');
            hdlset_param('testbench/DUT/nc_LCoffset_IP0','IOInterfaceMapping','x"328"');


            hdlset_param('testbench/DUT/nc_LCoffset_Conv','IOInterface','AXI4');
            hdlset_param('testbench/DUT/nc_LCoffset_Conv','IOInterfaceMapping','x"32C"');


            hdlset_param('testbench/DUT/nc_LCoffset_OP0','IOInterface','AXI4');
            hdlset_param('testbench/DUT/nc_LCoffset_OP0','IOInterfaceMapping','x"330"');


            hdlset_param('testbench/DUT/conv_weight_ddr_addr','IOInterface','AXI4');
            hdlset_param('testbench/DUT/conv_weight_ddr_addr','IOInterfaceMapping','x"334"');





            if strcmp(hPC.InputStreamControl,'port')&&strcmp(hPC.InputDataInterface,'External Memory')


                hdlset_param('testbench/DUT/InputNext','IOInterface','External Port');
                hdlset_param('testbench/DUT/InputNext','IOInterfaceMapping','');


                hdlset_param('testbench/DUT/InputValid','IOInterface','External Port');
                hdlset_param('testbench/DUT/InputValid','IOInterfaceMapping','');


                hdlset_param('testbench/DUT/InputAddr','IOInterface','External Port');
                hdlset_param('testbench/DUT/InputAddr','IOInterfaceMapping','');


                hdlset_param('testbench/DUT/InputSize','IOInterface','External Port');
                hdlset_param('testbench/DUT/InputSize','IOInterfaceMapping','');

            else


                hdlset_param('testbench/DUT/InputNext','IOInterface','AXI4');
                hdlset_param('testbench/DUT/InputNext','IOInterfaceMapping','x"350"');


                hdlset_param('testbench/DUT/InputValid','IOInterface','AXI4');
                hdlset_param('testbench/DUT/InputValid','IOInterfaceMapping','x"354"');


                hdlset_param('testbench/DUT/InputAddr','IOInterface','AXI4');
                hdlset_param('testbench/DUT/InputAddr','IOInterfaceMapping','x"358"');


                hdlset_param('testbench/DUT/InputSize','IOInterface','AXI4');
                hdlset_param('testbench/DUT/InputSize','IOInterfaceMapping','x"35C"');

            end

            if strcmp(hPC.OutputStreamControl,'port')&&strcmp(hPC.OutputDataInterface,'External Memory')


                hdlset_param('testbench/DUT/OutputNext','IOInterface','External Port');
                hdlset_param('testbench/DUT/OutputNext','IOInterfaceMapping','');


                hdlset_param('testbench/DUT/OutputValid','IOInterface','External Port');
                hdlset_param('testbench/DUT/OutputValid','IOInterfaceMapping','');


                hdlset_param('testbench/DUT/OutputAddr','IOInterface','External Port');
                hdlset_param('testbench/DUT/OutputAddr','IOInterfaceMapping','');


                hdlset_param('testbench/DUT/OutputSize','IOInterface','External Port');
                hdlset_param('testbench/DUT/OutputSize','IOInterfaceMapping','');

            else


                hdlset_param('testbench/DUT/OutputNext','IOInterface','AXI4');
                hdlset_param('testbench/DUT/OutputNext','IOInterfaceMapping','x"360"');


                hdlset_param('testbench/DUT/OutputValid','IOInterface','AXI4');
                hdlset_param('testbench/DUT/OutputValid','IOInterfaceMapping','x"364"');


                hdlset_param('testbench/DUT/OutputAddr','IOInterface','AXI4');
                hdlset_param('testbench/DUT/OutputAddr','IOInterfaceMapping','x"368"');


                hdlset_param('testbench/DUT/OutputSize','IOInterface','AXI4');
                hdlset_param('testbench/DUT/OutputSize','IOInterfaceMapping','x"36C"');

            end




            if strcmp(hPC.InputDataInterface,'AXI4-Stream')


                hdlset_param('testbench/DUT/AXIStreamInData','IOInterface','AXI4 Stream Master');
                hdlset_param('testbench/DUT/AXIStreamInData','IOInterfaceMapping','Data');


                hdlset_param('testbench/DUT/AXIStreamInValid','IOInterface','AXI4 Stream Master');
                hdlset_param('testbench/DUT/AXIStreamInValid','IOInterfaceMapping','Valid');


                hdlset_param('testbench/DUT/AXIStreamInReady','IOInterface','AXI4 Stream Master');
                hdlset_param('testbench/DUT/AXIStreamInReady','IOInterfaceMapping','Ready');
            else


                hdlset_param('testbench/DUT/AXIStreamInData','IOInterface','AXI4');
                hdlset_param('testbench/DUT/AXIStreamInData','IOInterfaceMapping','');


                hdlset_param('testbench/DUT/AXIStreamInValid','IOInterface','AXI4');
                hdlset_param('testbench/DUT/AXIStreamInValid','IOInterfaceMapping','');


                hdlset_param('testbench/DUT/AXIStreamInReady','IOInterface','AXI4');
                hdlset_param('testbench/DUT/AXIStreamInReady','IOInterfaceMapping','');

            end

            hdlset_param('testbench/DUT/AXIStreamOutSize','IOInterface','AXI4');
            hdlset_param('testbench/DUT/AXIStreamOutSize','IOInterfaceMapping','x"3C8"');


            if strcmp(hPC.OutputDataInterface,'AXI4-Stream')


                hdlset_param('testbench/DUT/AXIStreamOutData','IOInterface','AXI4 Stream Slave');
                hdlset_param('testbench/DUT/AXIStreamOutData','IOInterfaceMapping','Data');


                hdlset_param('testbench/DUT/AXIStreamOutValid','IOInterface','AXI4 Stream Slave');
                hdlset_param('testbench/DUT/AXIStreamOutValid','IOInterfaceMapping','Valid');


                hdlset_param('testbench/DUT/AXIStreamOutReady','IOInterface','AXI4 Stream Slave');
                hdlset_param('testbench/DUT/AXIStreamOutReady','IOInterfaceMapping','Ready');


            else


                hdlset_param('testbench/DUT/AXIStreamOutData','IOInterface','AXI4');
                hdlset_param('testbench/DUT/AXIStreamOutData','IOInterfaceMapping','');


                hdlset_param('testbench/DUT/AXIStreamOutValid','IOInterface','AXI4');
                hdlset_param('testbench/DUT/AXIStreamOutValid','IOInterfaceMapping','');


                hdlset_param('testbench/DUT/AXIStreamOutReady','IOInterface','AXI4');
                hdlset_param('testbench/DUT/AXIStreamOutReady','IOInterfaceMapping','');

            end


            hdlset_param('testbench/DUT/PerfCounterOverflow','IOInterface','AXI4');
            hdlset_param('testbench/DUT/PerfCounterOverflow','IOInterfaceMapping','x"37C"');

        end
    end
end





