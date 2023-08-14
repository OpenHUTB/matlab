classdef VMgrQABManager<dig.QABManager






    properties
        ConfigName='VMgrUIToolstripConfig';
        SubclassName='slvariants.internal.manager.ui.toolstrip.VMgrQABManager';


        PrefFile='qabprefs.txt';
    end

    methods
        function initDefaults(~,qabEntries)
            w1.Name='gettingStartedButton';
            w1.Type='QABPushButton';
            w1.ActionId='gettingStartedAction';
            w1.ShowText=false;
            w1.Index=0;

            w2.Name='helpButton';
            w2.Type='QABPushButton';
            w2.ActionId='helpAction';
            w2.ShowText=false;
            w2.Index=1;


            qabEntries.addEntry(w1);
            qabEntries.addEntry(w2);
        end
    end
end


