function onVisualRendered(this,hScope)








    handles=this.Handles;

    if isfield(hScope.Handles,'frameStatus')
        timeStr=sprintf('T=%s',num2str(this.SimulationTime));
        set(hScope.Handles.frameStatus,'Width',50,'AutoGrowMin',60,'Text',timeStr);
    end

    set(handles.TimeOffsetStatus,'Width',60,'AutoGrowMin',100,'Text',[this.OffsetLabel,'0 s']);

    timeResStr=[getString(message('dspshared:SpectrumAnalyzer:TimeResStatusBarLabel')),'--'];
    set(handles.TimeResolutionStatus,'Text',timeResStr);

    strSampleRate=[getString(message('dspshared:SpectrumAnalyzer:SampleRateString')),'=--'];
    set(handles.SampleRateStatus,'Text',strSampleRate);

    set(handles.RBWStatus,'Text','RBW=--');





    if~this.SimscapeMode
        hScope=this.Application;
        pSources=hScope.getExtInst('Sources');
        hToolbar=hScope.Handles.mainToolbar;
        oldOrder=allchild(hToolbar);
        if strcmpi(pSources.Type,'Streaming')&&~isdeployed()

            newOrder=[oldOrder(1:6);oldOrder(end-1);oldOrder(7:9);oldOrder(11:end)];
        else

            newOrder=[oldOrder(1:5);oldOrder(9);oldOrder(6:8);oldOrder(10:end)];
        end
        hToolbar.Children=newOrder;
    end


    delete(this.RenderedListener);
    this.RenderedListener=[];
