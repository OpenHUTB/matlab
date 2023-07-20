function[MFileLst,forceOverrideLangStdTfls]=getTflTableListForLibrary(lTargetRegistry,varargin)
















    refreshCRL(lTargetRegistry);
    forceOverrideLangStdTfls=false;
    TflNamesList=varargin{1};
    targetLangStdTfl=varargin{3};
    if iscell(targetLangStdTfl)
        targetLangStdTfl=targetLangStdTfl{1};
    end
    if~iscell(TflNamesList)
        TflNamesList={TflNamesList};
    else




        TflNamesList=unique(TflNamesList,'stable');
    end

    Tfl_QueryString=TflNamesList{1};
    currentLib=coder.internal.getTfl(lTargetRegistry,Tfl_QueryString);
    if isempty(currentLib)
        MFileLst={};
    elseif~currentLib.IsLangStdTfl
        [MFileLst,forceOverrideLangStdTfls]=getNonLangStdTflForLib(lTargetRegistry,currentLib,targetLangStdTfl);%#ok<ASGLU>
    else
        MFileLst=getLangStdTflForLib(lTargetRegistry,currentLib,targetLangStdTfl,Tfl_QueryString);%#ok<NASGU>
    end

    for i=1:length(MFileLst)
        MFileLst{i}=strrep(MFileLst{i},'$(MATLAB_ROOT)',matlabroot);%#ok
    end

end

function[MFileLst,overrideLangStdTfls]=getNonLangStdTflForLib(lTargetRegistry,currentLib,targetLangStdTfl)
    MFileLst={};
    overrideLangStdTfls=false;
    previousLib=currentLib;
    while(~isempty(currentLib))
        overrideLangStdTfls=(overrideLangStdTfls||currentLib.OverrideLangStdTfls);
        if~currentLib.IsLangStdTfl
            MFileLst=[MFileLst;currentLib.TableList];%#ok<AGROW>
            previousLib=currentLib;
            currentLib=coder.internal.getTfl(lTargetRegistry,currentLib.BaseTfl);
        else

            tflsWithLangStdTfl.TflName=previousLib.Name;
            if iscell(currentLib.Alias)
                tflsWithLangStdTfl.LangBaseTfl=currentLib.Alias{1};
            else
                tflsWithLangStdTfl.LangBaseTfl=currentLib.Alias;
            end




            if~overrideLangStdTfls&&...
                ~isempty(targetLangStdTfl)&&...
                ~strcmp(tflsWithLangStdTfl.LangBaseTfl,targetLangStdTfl)
                loc_warnOrError(tflsWithLangStdTfl,targetLangStdTfl);
            end



            break;
        end
    end
end

function MFileLst=getLangStdTflForLib(lTargetRegistry,currentLib,targetLangStdTfl,currentLibStr)
    MFileLst={};




    if iscell(currentLib.Alias)
        currentAlias=currentLib.Alias{1};
    else
        currentAlias=currentLib.Alias;
    end
    libToLoad=currentLib;
    if~strcmp(currentAlias,targetLangStdTfl)
        if loc_isHigherThan(currentAlias,targetLangStdTfl)
            DAStudio.error('RTW:targetRegistry:langStdTflUsedError',...
            currentLibStr,...
            loc_getTargetLangStandard(targetLangStdTfl));
        else
            MSLDiagnostic('RTW:targetRegistry:langStdTflUsedWarning',...
            currentLibStr,...
            loc_getTargetLangStandard(targetLangStdTfl)).reportAsWarning;
            libToLoad=coder.internal.getTfl(lTargetRegistry,targetLangStdTfl);
        end
    end

    while(~isempty(libToLoad))


        assert(libToLoad.IsLangStdTfl);
        MFileLst=[MFileLst;libToLoad.TableList];%#ok<AGROW>
        libToLoad=coder.internal.getTfl(lTargetRegistry,libToLoad.BaseTfl);
    end
end

function loc_warnOrError(libWithLangStdTfl,configLangStdTfl)
    if loc_isHigherThan(libWithLangStdTfl.LangBaseTfl,configLangStdTfl)


        DAStudio.error('RTW:targetRegistry:tflsWithLangStdTflError',...
        libWithLangStdTfl.TflName,...
        libWithLangStdTfl.LangBaseTfl,...
        loc_getTargetLangStandard(configLangStdTfl));
    else



        MSLDiagnostic('RTW:targetRegistry:tflsWithLangStdTflWarning',...
        libWithLangStdTfl.TflName,...
        libWithLangStdTfl.LangBaseTfl).reportAsWarning;
    end
end

function isHigher=loc_isHigherThan(langStdTfl1,langStdTfl2)
    switch langStdTfl1
    case 'ANSI_C'

        isHigher=false;
    case 'ISO_C'

        isHigher=strcmpi(langStdTfl2,'ANSI_C');
    case 'ISO_C++'

        isHigher=strcmpi(langStdTfl2,'ANSI_C');
    case 'ISO_C++11'

        isHigher=strcmpi(langStdTfl,'ANSI_C')||strcmpi(langStdTfl,'ISO_C')||strcmpi(langStdTfl,'ISO_C++');
    otherwise
        isHigher=false;%#ok<NASGU>
        DAStudio.error('CoderFoundation:tfl:UnsupportedLangStandardTfl',langStdTfl1);
    end
end

function targetLangStd=loc_getTargetLangStandard(langStdTfl)
    switch langStdTfl
    case 'ANSI_C'
        targetLangStd='C89/C90 (ANSI)';
    case 'ISO_C'
        targetLangStd='C99 (ISO)';
    case 'ISO_C++'
        targetLangStd='C++03 (ISO)';
    case 'ISO_C++11'
        targetLangStd='C++11 (ISO)';
    otherwise
        targetLangStd='';%#ok<NASGU>
        DAStudio.error('CoderFoundation:tfl:UnsupportedLangStandardTfl',langStdTfl);
    end
end

