function[boardList,workflow]=hdlcoder_board_customization









    boardList={...
    'dnnfpga.generic.plugin_board_xilinx',...
    'dnnfpga.generic.plugin_board_intel',...
    };

    workflow=hdlcoder.Workflow.DeepLearningProcessor;

end


