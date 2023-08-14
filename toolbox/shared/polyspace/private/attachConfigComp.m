

function attachConfigComp(systemH,silentMode)

    narginchk(1,2);

    if nargin<2
        silentMode=false;
    end

    modelH=bdroot(systemH);
    if strcmpi(get_param(modelH,'BlockDiagramType'),'library')
        warning(message('polyspace:gui:pslink:modelIsLib',getfullname(modelH)))
        return
    end






    [pslinkcc,configSet,configSetRefVarName]=getConfigComp(modelH);


    if strcmpi(get_param(modelH,'SimulationStatus'),'stopped')
        if~isa(pslinkcc,'pslink.ConfigComp')
            if~isempty(configSetRefVarName)&&~silentMode
                systemName=getfullname(systemH);
                modelName=get_param(modelH,'Name');
                if~strcmp(modelName,systemName)
                    toBeAnalyzedComponent=sprintf('model ''%s''',modelName);
                else
                    toBeAnalyzedComponent=sprintf('subsystem ''%s''',systemName);
                end
                str=message('polyspace:gui:pslink:attachCCompDlg',modelName,...
                configSetRefVarName,toBeAnalyzedComponent,configSetRefVarName).getString();
                answer=questdlg(str,message('polyspace:gui:pslink:attachCCompDlgTitle').getString(),'Yes','No','No');
                if strcmpi(answer,'No')
                    return
                end
            end

            pslinkcc=pslink.ConfigComp(systemH);
            attachComponent(configSet,pslinkcc);
        end
    end

