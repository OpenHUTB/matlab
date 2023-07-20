function checkInputs(h,myNargin,myVarargin)






    if(myNargin==0)
        DAStudio.error('SimulinkUpgradeEngine:engine:needModelName');
    end


    if(myNargin==1)
        h.Prompt=1;


    elseif(myNargin==2)
        setPrompt(h,myVarargin{1});


    else

        h.Prompt=[];


        if(rem(int8(myNargin-1),int8(2))==int8(0))
            for k=1:2:(myNargin-1)
                argStr=lower(myVarargin{k});
                switch argStr
                case 'prompt'
                    setPrompt(h,myVarargin{k+1});
                case 'operatingmode'


                    opModeStr=lower(myVarargin{k+1});
                    opModeList={'update',...
                    'updateCompiled',...
                    'updateReplaceBlocks',...
                    'analyze',...
                    'analyzeCompiled',...
                    'analyzeReplaceBlocks'};
                    switch opModeStr
                    case 'update'

                        h.CheckFlags.BlockReplace=true;
                        h.CheckFlags.Compiled=true;
                        h.CheckFlags.LinkRestore=true;
                        h.OnlyAnalysis=false;
                    case 'updatecompiled'
                        h.CheckFlags.BlockReplace=false;
                        h.CheckFlags.Compiled=true;
                        h.CheckFlags.LinkRestore=false;
                        h.OnlyAnalysis=false;
                    case 'updatereplaceblocks'
                        h.CheckFlags.BlockReplace=true;
                        h.CheckFlags.Compiled=false;
                        h.CheckFlags.LinkRestore=true;
                        h.OnlyAnalysis=false;
                    case 'analyze'
                        h.CheckFlags.BlockReplace=true;
                        h.CheckFlags.Compiled=true;
                        h.CheckFlags.LinkRestore=true;
                        h.OnlyAnalysis=true;
                    case 'analyzecompiled'
                        h.CheckFlags.BlockReplace=false;
                        h.CheckFlags.Compiled=true;
                        h.CheckFlags.LinkRestore=false;
                        h.OnlyAnalysis=true;
                    case 'analyzereplaceblocks'
                        h.CheckFlags.BlockReplace=true;
                        h.CheckFlags.Compiled=false;
                        h.CheckFlags.LinkRestore=true;
                        h.OnlyAnalysis=true;
                    otherwise
                        opModeListStr=sprintf('%s ',opModeList{:});
                        DAStudio.error('SimulinkUpgradeEngine:engine:invalidEnumValue',...
                        opModeStr,opModeListStr);
                    end

                otherwise
                    DAStudio.error('SimulinkUpgradeEngine:engine:nameValuePairs');
                end


                stat=get_param(h.MyModel,'SimulationStatus');
                if(strcmpi(stat,'paused')&&(strcmpi(opModeStr,'analyzecompiled')||strcmpi(opModeStr,'updatecompiled')))
                    h.CompileState=ModelUpdater.COMPILED;
                elseif strcmpi(stat,'stopped')
                    h.CompileState=ModelUpdater.PRECOMPILE;
                else
                    DAStudio.error('Simulink:tools:modelBadStateForCheck',h.MyModel);
                end


                if isempty(h.Prompt)
                    if(h.OnlyAnalysis)
                        h.Prompt=0;
                    else
                        h.Prompt=1;
                    end
                else
                    if h.OnlyAnalysis&&h.Prompt
                        MSLDiagnostic('SimulinkUpgradeEngine:engine:noPromptAnalyze').reportAsWarning;
                        h.Prompt=0;
                    end
                end
            end
        else
            DAStudio.error('SimulinkUpgradeEngine:engine:nameValuePairs');
        end
    end

end


function setPrompt(h,val)
    if ischar(val)
        PromptStr=lower(val);
        PromptList={'on','off'};
        if~any(strcmp(PromptStr,PromptList))

            PromptListStr=sprintf('%s,',PromptList{:});
            PromptListStr=PromptListStr(1:end-1);
            DAStudio.error('SimulinkUpgradeEngine:engine:invalidEnumValue',...
            PromptStr,PromptListStr);
        else
            if strcmp(PromptStr,'on')
                h.Prompt=1;
            else
                h.Prompt=0;
            end
        end
    else
        if isnumeric(val)
            if(abs(val)<0.00001)
                h.Prompt=0;
            else
                h.Prompt=1;
            end
        end
    end
end
