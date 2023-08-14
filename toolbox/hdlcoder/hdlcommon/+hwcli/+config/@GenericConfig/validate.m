function validate(obj,varargin)



    validate@hwcli.base.GenericBase(obj,varargin{:});


    p=inputParser;


    p.addParameter('Warn',true);

    p.parse(varargin{:});
    inputArgs=p.Results;




    isVivado=strcmp(obj.SynthesisTool,'Xilinx Vivado');

    if ismember(obj.Tasks,'RunTaskAnnotateModelWithSynthesisResult')
        isAnnotate=obj.RunTaskAnnotateModelWithSynthesisResult;
    else
        isAnnotate=false;
    end


    if(isAnnotate)
        if(isVivado)
            if(~obj.RunTaskRunSynthesis&&~obj.RunTaskRunImplementation)
                if(inputArgs.Warn==true)
                    warning(message('hdlcoder:workflow:MustHaveRunTimingBefore'));
                end
            elseif(obj.SkipPreRouteTimingAnalysis&&~obj.RunTaskRunImplementation)
                error(message('hdlcoder:workflow:MustRunTiming'))
            elseif(obj.SkipPreRouteTimingAnalysis&&~strcmp(obj.CriticalPathSource,'post-route'))
                error(message('hdlcoder:workflow:MustSelectPreRoute'))
            elseif(~obj.SkipPreRouteTimingAnalysis&&~obj.RunTaskRunImplementation&&~strcmp(obj.CriticalPathSource,'pre-route'))
                error(message('hdlcoder:workflow:MustSelectPostRoute'))
            end
        else
            if(~obj.RunTaskPerformMapping&&~obj.RunTaskPerformPlaceAndRoute)
                if(inputArgs.Warn==true)
                    warning(message('hdlcoder:workflow:MustHaveRunTimingBefore'));
                end
            elseif(obj.SkipPreRouteTimingAnalysis&&~obj.RunTaskPerformPlaceAndRoute)
                error(message('hdlcoder:workflow:MustRunTiming'))
            elseif(obj.SkipPreRouteTimingAnalysis&&~strcmp(obj.CriticalPathSource,'post-route'))
                error(message('hdlcoder:workflow:MustSelectPreRoute'))
            elseif(~obj.SkipPreRouteTimingAnalysis&&~obj.RunTaskPerformPlaceAndRoute&&~strcmp(obj.CriticalPathSource,'pre-route'))
                error(message('hdlcoder:workflow:MustSelectPostRoute'))
            end
        end
    end

end