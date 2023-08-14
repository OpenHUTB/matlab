function data=callbackExportResult(blk)







    saved=get_param([blk,'/Tuning Parameters'],'UserData');
    if isempty(saved)
        errordlg(getString(message('SLControllib:focautotuner:errTuningResultsNotFound')));
        return
    end


    Loops=fieldnames(saved);
    for ii=1:numel(Loops)
        currLoop=Loops{ii};
        typeidx=saved.(currLoop).typeidx;
        formidx=saved.(currLoop).formidx;
        IFidx=saved.(currLoop).IFidx;
        DFidx=saved.(currLoop).DFidx;
        Ts=saved.(currLoop).Ts;
        P=saved.(currLoop).P;
        I=saved.(currLoop).I;
        D=saved.(currLoop).D;
        N=saved.(currLoop).N;


        [c,gains]=focautotuner.utilGeneratePIDObject(typeidx,formidx,1,Ts,IFidx,DFidx,P,I,D,N);


        switch typeidx
        case 1
            params={'P'};
        case 2
            params={'I'};
        case 3
            params={'P','I'};
        case 4
            params={'P','D'};
        case 5
            params={'P','D','N'};
        case 6
            params={'P','I','D'};
        case 7
            params={'P','I','D','N'};
        end

        dataLoop=cell2struct(num2cell(gains),params,2);
        dataLoop.TargetBandwidth=saved.(currLoop).targetBandwidth;
        dataLoop.TargetPhaseMargin=saved.(currLoop).targetPM;
        dataLoop.EstimatedPhaseMargin=saved.(currLoop).achievedPM;
        dataLoop.Controller=c;
        dataLoop.Plant=saved.(currLoop).plant;
        dataLoop.PlantNominal=struct('u',saved.(currLoop).nominal(1),'y',saved.(currLoop).nominal(2));


        data.(currLoop)=dataLoop;
        clear dataLoop
    end


    if nargout==0
        oldvar='FOCTuningResult';
        newvar=matlab.lang.makeUniqueStrings(oldvar,evalin('base','who'));
        assignin('base',newvar,data);

        maskObj=Simulink.Mask.get(blk);
        object=maskObj.getDialogControl('DisplayText');
        object.Prompt=getString(message('SLControllib:focautotuner:infoExportResult',newvar));
    end
