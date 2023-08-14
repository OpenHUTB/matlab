classdef QABManager<dig.QABManager

    properties
        ConfigName='ssc_variable_viewer';
        SubclassName='simscape.state.internal.toolstrip.QABManager';
    end

    methods
        function initDefaults(~,qabEntries)

            d1.Name='helpButtonQab';
            d1.Type='QABPushButton';
            d1.ActionId='helpAction';
            d1.ShowText=false;
            d1.Index=0;


            qabEntries.addEntry(d1);
        end
    end
end