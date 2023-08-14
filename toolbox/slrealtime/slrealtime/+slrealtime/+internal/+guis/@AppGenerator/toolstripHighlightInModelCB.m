function toolstripHighlightInModelCB(this)






    try
        if~isempty(this.BindingTable.Selection)
            sels=this.BindingTable.Selection;
            if numel(sels)>1,return;end

            idx=sels;

            if this.isTableSelectionParameter()



                blkpath=this.BindingData{idx}.BlockPath;
                slrealtime.internal.highlightParameter(blkpath);
            else



                blkpath=this.BindingData{idx}.BlockPath;
                portidx=this.BindingData{idx}.PortIndex;
                slrealtime.internal.highlightSignal(Simulink.SimulationData.BlockPath(blkpath),portidx);
            end
        else

        end
    catch ME
        this.errorDlg('slrealtime:appdesigner:HighlightModelError',ME.message);
        return;
    end
end
