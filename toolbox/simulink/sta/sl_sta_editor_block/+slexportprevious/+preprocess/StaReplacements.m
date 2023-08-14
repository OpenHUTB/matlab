function StaReplacements(obj)




    if isR2017aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('SignalEditorBlockLib/Signal Editor');
    else
        origSeBlks=getfullname(Simulink.findBlocks(obj.origModelName,'MaskType','SignalEditor'));
        if~iscell(origSeBlks)
            origSeBlks={origSeBlks};
        end
        exportedSeBlks=getfullname(Simulink.findBlocks(obj.modelName,'MaskType','SignalEditor'));
        if~iscell(exportedSeBlks)
            exportedSeBlks={exportedSeBlks};
        end
        for b=1:length(origSeBlks)
            origDataModel=get_param([origSeBlks{b},'/Model Info'],'UserData');
            copyDataModel=copy(origDataModel);
            set_param([exportedSeBlks{b},'/Model Info'],'UserData',copyDataModel);
            Simulink.signaleditorblock.cb_PreSaveFcn(exportedSeBlks{b});
        end
    end