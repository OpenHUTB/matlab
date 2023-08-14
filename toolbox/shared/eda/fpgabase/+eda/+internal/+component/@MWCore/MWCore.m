


classdef(ConstructOnLoad)MWCore<eda.internal.component.WhiteBox



    properties

    end

    methods
        dutEnb=ClkEnbRouting(this,dut_clkenb);
        dutReset=ResetRouting(this);
        ChIf2DutRoute(this,input);
        Dut2ChifRoute(this,outPort,dut_dout,outDataWidthBits,actualOutDataWidth);
        addChannelIO(this);
        addSYSClock(this);
    end
end





