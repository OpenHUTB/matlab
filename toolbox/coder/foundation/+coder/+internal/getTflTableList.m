function[MFileLst,numOmitted]=getTflTableList(lTargetRegistry,varargin)

















    refresh(lTargetRegistry,'RTW.TflRegistry')

    MFileLst={};
    numOmitted=int32(0);
    langTflMFileLst={};
    forceOverrideLangStdTfls=false;
    tflsWithLangStdTfl=struct('TflName',{},'LangBaseTfl',{});
    warnAboutIncludingLangTfl=false;

    if nargin==1
        existTables=get(lTargetRegistry.TargetFunctionLibraries,'TableList');
        MFileLst=RTW.unique(cat(1,existTables{:}));
    else
        TflNamesList=varargin{1};
        if~iscell(TflNamesList)
            TflNamesList={TflNamesList};
        else




            TflNamesList=unique(TflNamesList,'stable');
        end
        for i_tfl=1:numel(TflNamesList)
            Tfl_QueryString=TflNamesList{i_tfl};
            NextTfl=coder.internal.getTfl(lTargetRegistry,Tfl_QueryString);
            if~isempty(NextTfl)
                isaSimTfl=NextTfl.IsSimTfl;
                forceOverrideLangStdTfls=forceOverrideLangStdTfls||NextTfl.OverrideLangStdTfls;
                if(~NextTfl.IsLangStdTfl||(~forceOverrideLangStdTfls&&isempty(langTflMFileLst)))
                    while(~isempty(NextTfl))
                        if(NextTfl.IsLangStdTfl)
                            langTflMFileLst=[langTflMFileLst;NextTfl.TableList];%#ok<AGROW>
                            if~isaSimTfl
                                tflsWithLangStdTfl(end+1).TflName=Tfl_QueryString;%#ok<AGROW>
                                tflsWithLangStdTfl(end).LangBaseTfl=NextTfl.Name;
                            end
                        end

                        MFileLst=[MFileLst;NextTfl.TableList];%#ok

                        NextTfl=coder.internal.getTfl(lTargetRegistry,NextTfl.BaseTfl);
                    end
                else
                    numOmitted=numOmitted+1;


                    if forceOverrideLangStdTfls
                        warnAboutIncludingLangTfl=false;
                    elseif~isempty(tflsWithLangStdTfl)&&~ismember(NextTfl.TableList{1},MFileLst)
                        warnAboutIncludingLangTfl=true;
                    end
                end
            end
        end
        if numel(TflNamesList)>1
            MFileLst=RTW.unique(MFileLst);
        end
        for i=1:length(MFileLst)
            MFileLst{i}=strrep(MFileLst{i},'$(MATLAB_ROOT)',matlabroot);%#ok
        end
    end

    if(forceOverrideLangStdTfls&&~isempty(langTflMFileLst))

        langTflMFileLst=unique(langTflMFileLst);
        MFileLst=setdiff(MFileLst,langTflMFileLst,'stable');
    end

    if(warnAboutIncludingLangTfl)
        for i_tfl=1:numel(tflsWithLangStdTfl)
            MSLDiagnostic('RTW:targetRegistry:tflsWithLangStdTflWarning',...
            tflsWithLangStdTfl(i_tfl).TflName,...
            tflsWithLangStdTfl(i_tfl).LangBaseTfl).reportAsWarning;
        end
    end





