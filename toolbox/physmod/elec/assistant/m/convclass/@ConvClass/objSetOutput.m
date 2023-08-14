function out=objSetOutput(obj)

    out.NewBlockPath=obj.NewBlockPath;
    out.NewInstanceData=[];


    NewDropdownNames=fieldnames(obj.NewDropdown);
    nNewDropdown=numel(NewDropdownNames);
    for dropdownIdx=1:nNewDropdown
        out.NewInstanceData(dropdownIdx).Name=NewDropdownNames{dropdownIdx};
        out.NewInstanceData(dropdownIdx).Value=obj.NewDropdown.(NewDropdownNames{dropdownIdx});
    end


    NewDirectParamNames=fieldnames(obj.NewDirectParam);
    nNewDirectParam=numel(NewDirectParamNames);
    for paramIdx=1:nNewDirectParam
        out.NewInstanceData(nNewDropdown+paramIdx).Name=NewDirectParamNames{paramIdx};
        if isnumeric(obj.NewDirectParam.(NewDirectParamNames{paramIdx}))&&~isempty(obj.NewDirectParam.(NewDirectParamNames{paramIdx}))
            if numel(obj.NewDirectParam.(NewDirectParamNames{paramIdx}))==1
                out.NewInstanceData(nNewDropdown+paramIdx).Value=num2str(obj.NewDirectParam.(NewDirectParamNames{paramIdx}));
            else
                out.NewInstanceData(nNewDropdown+paramIdx).Value=strcat('[',num2str(obj.NewDirectParam.(NewDirectParamNames{paramIdx})),']');
            end
        else
            out.NewInstanceData(nNewDropdown+paramIdx).Value=obj.NewDirectParam.(NewDirectParamNames{paramIdx});
        end
    end


    OldDropdownNames=fieldnames(obj.OldDropdown);
    OldParamNames=fieldnames(obj.OldParam);
    className=class(obj);
    methodsList=methods(className,'-full');
    constructorLineIdx=find(contains(methodsList,className));
    if numel(constructorLineIdx)==1
        constructorLine=methodsList{constructorLineIdx};
        temp=split(constructorLine,{'(',')'});
        if numel(split(constructorLine,{'(',')'}))==3
            funcParamNames=strtrim(split(temp{2},','));
            nFuncParam=numel(funcParamNames);
            funcParamValues=cell(nFuncParam,1);
            funcParamStr='';
            for Idx=1:nFuncParam
                if~isempty(find(strcmp(OldParamNames,funcParamNames{Idx}),1))
                    funcParamValues{Idx}=obj.OldParam.(funcParamNames{Idx});
                end
                if~isempty(find(strcmp(OldDropdownNames,funcParamNames{Idx}),1))
                    funcParamValues{Idx}=strcat('''',obj.OldDropdown.(funcParamNames{Idx}),'''');
                end
                if isnumeric(funcParamValues{Idx})
                    funcParamStr=strcat(funcParamStr,mat2str(funcParamValues{Idx}),',');
                else
                    funcParamStr=strcat(funcParamStr,funcParamValues{Idx},',');
                end
            end
            funcParamStr=funcParamStr(1:end-1);
        end
    end


    NewDerivedParamNames=fieldnames(obj.NewDerivedParam);
    nNewDerivedParam=numel(NewDerivedParamNames);
    for paramIdx=1:nNewDerivedParam
        out.NewInstanceData(nNewDropdown+nNewDirectParam+paramIdx).Name=NewDerivedParamNames{paramIdx};
        strTemp=strcat(className,'(',funcParamStr,').','objParamMappingDerived.NewDerivedParam.',NewDerivedParamNames{paramIdx});
        out.NewInstanceData(nNewDropdown+nNewDirectParam+paramIdx).Value=strTemp;
    end


    for Idx=nNewDerivedParam+nNewDirectParam+nNewDropdown:-1:1
        if isempty(out.NewInstanceData(Idx).Value)
            out.NewInstanceData(Idx)=[];
        end
    end

end