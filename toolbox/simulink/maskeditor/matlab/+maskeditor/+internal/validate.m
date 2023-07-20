function ret=validate(aMEInstance,aBlockHandle)




    ret=struct;

    MEModel=aMEInstance.m_MEData;

    ret.ErrorValue=false;

    paramIndices=[];
    iNumDialogElements=MEModel.widgets.Size;
    AllNamesArray=cell(iNumDialogElements,1);
    AllAliasArray=cell(iNumDialogElements,1);

    for i=1:iNumDialogElements
        widget=MEModel.widgets.at(i);
        AllNamesArray{i}=strtrim(widget.getPropertyByKey('Name').value);
        if(isParameterTypeWidget(widget.getPropertyByKey('Type').value))
            AllAliasArray{i}=strtrim(widget.getPropertyByKey('Alias').value);
            paramIndices(end+1)=i;%#ok
        else
            AllAliasArray{i}='';
        end
    end

    iNumParams=length(paramIndices);
    ParamNameArray=cell(iNumParams,1);
    AliasArray=cell(iNumParams,1);


    aUsedNamesList={};
    aUsedModelNamesList={};

    ret.InvalidNames={};
    ret.InvalidAliases={};
    ret.ShadowedNames={};

    ret.InvalidNameIndices=[];
    ret.InvalidAliasIndices=[];
    ret.ShadowedNameIndices=[];
    ret.NameAliasClashIndices=[];

    try
        aBlockType=get_param(aBlockHandle,'BlockType');
        aParameters=get_param(['built-in/',aBlockType],'ObjectParameters');
        aUsedNamesList=fieldnames(aParameters);

        if MEModel.context.maskOnModel

            aModelParameters=get_param(bdroot(aBlockHandle),'ObjectParameters');
            aUsedModelNamesList=fieldnames(aModelParameters);
        end
    catch
    end

    iParamIndex=0;
    for i=1:iNumDialogElements
        aVarName=AllNamesArray{i};
        aAlias=AllAliasArray{i};
        widget=MEModel.widgets.at(i);
        bIsMaskParameter=isParameterTypeWidget(widget.getPropertyByKey('Type').value);
        if(bIsMaskParameter)
            iParamIndex=iParamIndex+1;
            ParamNameArray{iParamIndex}=aVarName;
            AliasArray{iParamIndex}=aAlias;
        end


        bValid=isVariableValidMATLABName(aVarName);
        if~bValid
            ret.InvalidNames{end+1}=aVarName;
            ret.InvalidNameIndices(end+1)=i;
        end


        bValid=isVariableValidMATLABName(aAlias);
        if~bValid
            ret.InvalidAliases{end+1}=aAlias;
            ret.InvalidAliasIndices(end+1)=i;
        end


        bValid=isVariableNameShadowingExistingParameter(aVarName,aUsedNamesList);
        if~bValid

            if(bIsMaskParameter&&widget.widgetMetaData.isPromotedParameter)
                promotedParameters=widget.getPropertyByKey('PromotedParametersList');
                if~isempty(promotedParameters.value)
                    promotedParameters=jsondecode(promotedParameters.value);
                    if any(cellfun(@(x)strcmpi(x,aVarName),promotedParameters))
                        bValid=true;
                    end
                end
            end

            if~bValid
                ret.ShadowedNames{end+1}=aVarName;
                ret.ShadowedNameIndices(end+1)=i;
            end
        end


        bValid=isVariableNameShadowingExistingParameter(aVarName,aUsedModelNamesList);
        if~bValid
            ret.ShadowedNames{end+1}=aVarName;
            ret.ShadowedNameIndices{end+1}=i;
        end

    end


    ret.ShadowedNames=unique(ret.ShadowedNames);
    ret.InvalidNames=unique(ret.InvalidNames);
    ret.InvalidAliases=unique(ret.InvalidAliases);


    if(~isempty(ret.InvalidNames)||~isempty(ret.ShadowedNames)...
        ||~isempty(ret.InvalidAliases))
        ret.ErrorValue=true;
    end

    aAliasVariableList={};
    for i=1:iNumParams
        if(~isempty(AliasArray{i}))
            aAliasVariableList{end+1}=AliasArray{i};%#ok
        end
    end


    ret.NameAliasClash=intersect(ParamNameArray,aAliasVariableList);
    if(~isempty(ret.NameAliasClash))
        ret.ErrorValue=true;
    end
    for i=1:length(ret.NameAliasClash)
        for j=1:iNumDialogElements
            if strcmpi(AllNamesArray{j},ret.NameAliasClash{i})||...
                strcmpi(AllAliasArray{j},ret.NameAliasClash{i})

                ret.NameAliasClashIndices(end+1)=j;

            end
        end
    end















    AllNamesWithOnlyLCVarsNamesArray=cell(size(AllNamesArray));
    AllNamesWithOnlyLCVarsNamesArray(:)={' '};
    AllNamesWithOnlyLCVarsNamesArray(paramIndices)=lower(AllNamesArray(paramIndices));





    LCVarNamesArray=lower(ParamNameArray);
    [~,n]=unique(LCVarNamesArray);
    aRepeatedLCVariablesNames=LCVarNamesArray;
    aRepeatedLCVariablesNames(n)=[];
    aRepeatedLCVariablesNames=unique(aRepeatedLCVariablesNames);
    repeatVarIndices=find(ismember(AllNamesWithOnlyLCVarsNamesArray,aRepeatedLCVariablesNames));
    aRepeatedVariablesNames=AllNamesArray(repeatVarIndices);






    [~,n]=unique(AllNamesArray);
    aRepeatedDlgElementNames=AllNamesArray;
    aRepeatedDlgElementNames(n)=[];
    aRepeatedDlgElementNames=unique(aRepeatedDlgElementNames);
    repeatDlgElementIndices=find(ismember(AllNamesArray,aRepeatedDlgElementNames));

    ret.RepeatedNameIndices=union(repeatVarIndices,repeatDlgElementIndices);
    ret.RepeatedNames=union(aRepeatedVariablesNames,aRepeatedDlgElementNames,'stable');

    if~isempty(ret.RepeatedNames)
        ret.ErrorValue=true;
    end



    [~,n]=unique(AliasArray);
    aRepeatedAliasArray=AliasArray;
    aRepeatedAliasArray(n)=[];

    aRepeatedAliasArray=aRepeatedAliasArray(cellfun(@(x)~isempty(x),aRepeatedAliasArray));
    aRepeatedAliasArray=unique(aRepeatedAliasArray);
    RepeatedAliasIndices=find(ismember(AllAliasArray,aRepeatedAliasArray));
    ret.RepeatedAliases=aRepeatedAliasArray;
    ret.RepeatedAliasIndices=RepeatedAliasIndices;

    if~isempty(ret.RepeatedAliases)
        ret.ErrorValue=true;
    end



    ret.EmptyNameIndices={};
    for i=1:iNumDialogElements
        if isempty(AllNamesArray{i})
            ret.EmptyNameIndices{end+1}=i;
        end
    end

    if~isempty(ret.EmptyNameIndices)
        ret.ErrorValue=true;
    end


    ret.RepeatedAliasIndices=ret.RepeatedAliasIndices-1;
    ret.ShadowedNameIndices=ret.ShadowedNameIndices-1;
    ret.RepeatedNameIndices=ret.RepeatedNameIndices-1;
    ret.NameAliasClashIndices=ret.NameAliasClashIndices-1;
end



function bValid=isVariableValidMATLABName(aVarName)
    if isempty(aVarName)
        bValid=true;
        return;
    end

    bValid=isvarname(aVarName);
end
function bValid=isVariableNameShadowingExistingParameter(aVarName,aUsedNamesList)
    if isempty(aVarName)
        bValid=true;
        return;
    end

    bValid=isempty(find(strcmpi(aUsedNamesList,aVarName),1));
end
function result=isParameterTypeWidget(maskStyle)

    parameterTypes=["edit","checkbox","popup","combobox","listbox","radiobutton","slider",...
    "dial","spinbox","unit","textarea","customtable","datatypestr","unidt","min","max"];

    result=any(strcmp(parameterTypes,maskStyle));
end
