function varargout=getSPSmaskvalues(block,MaskVariables,VerifyBlockWorkSpace,CheckMaskEntries)




























    MaskWSVariables=get_param(block,'MaskWSVariables');

    if isempty(MaskWSVariables)
        WSStatus=0;
        VariableNames=[];
    else
        VariableNames={MaskWSVariables.Name};
        if isempty(VariableNames)
            WSStatus=0;
        else
            WSStatus=1;
        end
    end

    for i=1:length(MaskVariables)

        Indice=find(strcmp(MaskVariables{i},VariableNames));
        if isempty(Indice)

            Valeur=NaN;
        else
            Valeur=MaskWSVariables(Indice(end)).Value;
            if isempty(Valeur)



                Valeur=NaN;
            end
            switch class(Valeur)
            case 'Simulink.Parameter'

                Valeur=Valeur.Value;
            case 'ureal'


                Valeur=usample(Valeur);
            end
        end
        varargout{i}=Valeur;
    end



    if~exist('VerifyBlockWorkSpace','var')
        VerifyBlockWorkSpace=0;
    end
    if VerifyBlockWorkSpace
        varargout{end+1}=WSStatus;
    end



    if~exist('CheckMaskEntries','var')
        CheckMaskEntries=0;
    end

    if length(MaskVariables)==1&&CheckMaskEntries>0
        MaskEntry=str2num(get_param(block,MaskVariables{1}));%#ok
        if~isequal(Valeur,MaskEntry)

            if~isempty(MaskEntry)&&CheckMaskEntries==1



                varargout{i}=MaskEntry;
            end
            if isempty(MaskEntry)&&CheckMaskEntries==2


                varargout{i}=MaskEntry;
            end
        end
    end