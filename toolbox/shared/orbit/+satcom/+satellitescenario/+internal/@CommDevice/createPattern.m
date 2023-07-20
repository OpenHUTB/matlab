function pat=createPattern(trx,fq,varargin)






    scenario=trx(1).Scenario;


    try
        [viewer,args]=matlabshared.satellitescenario.ScenarioGraphic.parseViewerInput(scenario.Viewers,scenario,varargin{:});
    catch e
        throwAsCaller(e);
    end

    for idx=numel(trx):-1:1

        if isscalar(fq)
            f=fq;
        else
            f=fq(idx);
        end
        if isempty(trx(idx).Pattern)



            pat(idx)=satcom.satellitescenario.Pattern(trx(idx),f,args{:});


            scenario.addToScenarioGraphics(pat(idx));


            scenario.NeedToSimulate=true;


            trx(idx).Pattern=pat(idx);
        else



            pat(idx)=trx(idx).Pattern;


            pat(idx).parseShowInputs(args{:});
        end

        initializePatternData(pat(idx),trx(idx).Antenna,f);
    end



    showIfAutoShow(pat,scenario,viewer);
end