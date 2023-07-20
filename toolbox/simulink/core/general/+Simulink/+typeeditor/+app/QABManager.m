classdef QABManager<dig.QABManager




    properties
        ConfigName='typeEditorToolStrip';
        PrefFile=['.',filesep,'sl_qabprefs.mat'];
        SubclassName='Simulink.typeeditor.app.QABManager';
    end

    methods
        function initDefaults(~,qabEntries)
            d0.Name='qabCutButton';
            d0.Type='QABPushButton';
            d0.ActionId='cutActionBE';
            d0.ShowText=false;
            d0.Index=0;

            d1.Name='qabCopyButton';
            d1.Type='QABPushButton';
            d1.ActionId='copyActionBE';
            d1.ShowText=false;
            d1.Index=1;

            d2.Name='qabPasteButton';
            d2.Type='QABPushButton';
            d2.ActionId='pasteAction';
            d2.ShowText=false;
            d2.Index=2;

            d3.Name='qabHelpButton';
            d3.Type='QABPushButton';
            d3.ActionId='helpAction';
            d3.ShowText=false;
            d3.Index=4;


            qabEntries.addEntry(d0);
            qabEntries.addEntry(d1);
            qabEntries.addEntry(d2);
            qabEntries.addEntry(d3);
        end


        function savePreferences(~,~)

        end
    end
end