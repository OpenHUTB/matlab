function addListeners(h)





    len=h.signalInfo.blockPath_.getLength();
    bpath=h.signalInfo.blockPath_.getBlock(len);
    hBlock=get_param(bpath,'Object');
    h.listeners=...
    Simulink.listener(hBlock,'NameChangeEvent',...
    @(s,e)locNameChanged(h,s,e));

end


function locNameChanged(h,ed,~)



    name=Simulink.SimulationData.BlockPath.manglePath(ed.Name);
    bpath=ed.getFullName;


    sub_path=h.signalInfo.blockPath_.SubPath;
    fullPath=h.signalInfo.blockPath_.convertToCell;
    fullPath{end}=bpath;
    h.signalInfo.BlockPath=fullPath;
    h.signalInfo.blockPath_.SubPath=sub_path;


    if~isempty(h.signalInfo.blockPath_.SubPath)
        h.SourcePath=name;
    else
        h.SourcePath=sprintf('%s:%d',name,h.signalInfo.outputPortIndex_);
    end


    h.firePropertyChange;

end
