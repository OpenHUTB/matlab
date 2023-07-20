function da=updateDataAlignInfo(tr,da,source)










    if ischar(source)
        da=locInheritFromBase(tr,da,source);
    else
        da=locInheritFromOther(da,source);
    end

end


function da=locInheritFromOther(da,newDa)





    if isempty(newDa)...
        ||(da==newDa)
        return;
    end

    missingAlignTypeList=locInitMissingAlignTypeList(da);
    missingComplexTypeList=locInitMissingComplexTypeList(da);


    if~isempty(newDa.AlignmentSpecifications)...
        &&~all(cellfun(@isempty,missingAlignTypeList.values))
        alignSpecArr=newDa.AlignmentSpecifications;
        da=locInheritAlignSpec(da,missingAlignTypeList,alignSpecArr);
    end


    if~isempty(newDa.ComplexTypeAlignment)...
        &&~isempty(missingComplexTypeList)
        cTypeArr=newDa.ComplexTypeAlignment;
        da=locInheritComplexTypeAlign(da,missingComplexTypeList,cTypeArr);
    end


    if newDa.DefaultMallocAlignment~=-1
        if isempty(da)
            da=RTW.DataAlignment;
        end
        if da.DefaultMallocAlignment==-1
            da.DefaultMallocAlignment=newDa.DefaultMallocAlignment;
        end
    end

end


function da=locInheritFromBase(tr,da,baseCrl,varargin)








    p=inputParser;

    p.addOptional('Init',true,@islogical);
    p.parse(varargin{:});

    if~isempty(baseCrl)
        hTfl=coder.internal.getTfl(tr,baseCrl);
    else
        return;
    end

    persistent missingAlignTypeList;
    persistent missingComplexTypeList;
    if p.Results.Init
        missingAlignTypeList=locInitMissingAlignTypeList(da);
        missingComplexTypeList=locInitMissingComplexTypeList(da);
    end


    if~isempty(hTfl.TargetCharacteristics)...
        &&~isempty(hTfl.TargetCharacteristics.DataAlignment)


        if~isempty(hTfl.TargetCharacteristics.DataAlignment.AlignmentSpecifications)...
            &&~all(cellfun(@isempty,missingAlignTypeList.values))
            alignSpecArr=hTfl.TargetCharacteristics.DataAlignment.AlignmentSpecifications;
            [da,missingAlignTypeList]=locInheritAlignSpec(da,missingAlignTypeList,alignSpecArr);
        end


        if~isempty(hTfl.TargetCharacteristics.DataAlignment.ComplexTypeAlignment)...
            &&~isempty(missingComplexTypeList)
            cTypeArr=hTfl.TargetCharacteristics.DataAlignment.ComplexTypeAlignment;
            [da,missingComplexTypeList]=locInheritComplexTypeAlign(da,missingComplexTypeList,cTypeArr);
        end


        if hTfl.TargetCharacteristics.DataAlignment.DefaultMallocAlignment~=-1
            if isempty(da)
                da=RTW.DataAlignment;
            end
            if da.DefaultMallocAlignment==-1
                da.DefaultMallocAlignment=hTfl.TargetCharacteristics.DataAlignment.DefaultMallocAlignment;
            end
        end
    end



    isDone=~isempty(da)...
    &&all(cellfun(@isempty,missingAlignTypeList.values))...
    &&isempty(missingComplexTypeList)...
    &&(da.DefaultMallocAlignment~=-1);
    if~isempty(hTfl.BaseTfl)&&~isDone
        da=locInheritFromBase(tr,da,hTfl.BaseTfl,false);
    else

        clear missingAlignTypeList;
        clear missingComplexTypeList;
    end


end






function missingAlignTypeList=locInitMissingAlignTypeList(da)

    missingAlignTypeList=containers.Map;
    missingAlignTypeList('c')={'DATA_ALIGNMENT_GLOBAL_VAR'...
    ,'DATA_ALIGNMENT_WHOLE_STRUCT'...
    ,'DATA_ALIGNMENT_STRUCT_FIELD'...
    ,'DATA_ALIGNMENT_LOCAL_VAR'};
    missingAlignTypeList('c++')=missingAlignTypeList('c');

    if~isempty(da)&&~isempty(da.AlignmentSpecifications)
        newAlignTypes=containers.Map;
        for i_spec=1:numel(da.AlignmentSpecifications)
            langList=locGetSupportedLang(da.AlignmentSpecifications(i_spec));
            for i_lang=1:numel(langList)
                lang=langList{i_lang};
                newAlignTypes=locAddToMap(newAlignTypes,lang...
                ,da.AlignmentSpecifications(i_spec).AlignmentType(:));
            end
        end
        langList=newAlignTypes.keys;
        for i_key=1:numel(langList)
            lang=langList{i_key};
            missingAlignTypeList(lang)=setdiff(missingAlignTypeList(lang),newAlignTypes(lang));
        end
    end

end


function missingComplexTypeList=locInitMissingComplexTypeList(da)


    missingComplexTypeList={'cint8'...
    ,'cuint8'...
    ,'cint16'...
    ,'cuint16'...
    ,'cint32'...
    ,'cuint32'...
    ,'cinteger'...
    ,'cuinteger'...
    ,'clong'...
    ,'culong'...
    ,'clong_long'...
    ,'culong_long'...
    ,'csingle'...
    ,'cdouble'...
    };
    if~isempty(da)&&~isempty(da.ComplexTypeAlignment)
        newCTypes=strtrim(strtok(da.ComplexTypeAlignment,','));
        missingComplexTypeList=setdiff(missingComplexTypeList,newCTypes);
    end

end


function[da,missingAlignTypeList]=locInheritAlignSpec(da,missingAlignTypeList,alignSpecArr)










    if isempty(da)
        da=RTW.DataAlignment;
        addAll=true;
    else
        addAll=false;
    end
    newAlignSpec=containers.Map;
    for i_spec=1:numel(alignSpecArr)
        as=alignSpecArr(i_spec);
        for i_type=1:numel(as.AlignmentType)
            at=as.AlignmentType(i_type);
            langList=locGetSupportedLang(as);
            for i_lang=1:numel(langList)
                lang=langList{i_lang};
                if addAll||ismember(at,missingAlignTypeList(lang))
                    newAlignSpec=locAddToMap(newAlignSpec,lang,at);
                    asNew=RTW.AlignmentSpecification;
                    asNew.AlignmentType=at;
                    asNew.AlignmentPosition=as.AlignmentPosition;
                    asNew.AlignmentSyntaxTemplate=as.AlignmentSyntaxTemplate;
                    asNew.SupportedLanguages={lang};
                    da.addAlignmentSpecification(asNew);
                end
            end
        end
    end


    langList=newAlignSpec.keys;
    for i_lang=1:numel(langList)
        lang=langList{i_lang};
        missingAlignTypeList(lang)=setdiff(missingAlignTypeList(lang),newAlignSpec(lang));
    end

end


function[da,missingComplexTypeList]=locInheritComplexTypeAlign(da,missingComplexTypeList,cTypeArr)










    if isempty(da)
        da=RTW.DataAlignment;
        addAll=true;
    else
        addAll=false;
    end
    newComplexTypes={};
    for i_ct=1:numel(cTypeArr)
        alignInfo=regexp(cTypeArr{i_ct},'\s*,\s*','split');
        ct=alignInfo{1};
        align=str2double(alignInfo{2});
        if addAll||ismember(ct,missingComplexTypeList)
            da.addComplexTypeAlignment(ct,align);
            newComplexTypes{end+1}=ct;%#ok<AGROW>
        end
    end


    missingComplexTypeList=setdiff(missingComplexTypeList,newComplexTypes);

end


function langList=locGetSupportedLang(as)




    langList=as.SupportedLanguages;
    if~iscell(langList)
        langList={langList};
    end

end


function map=locAddToMap(map,key,value)





    if map.isKey(key)
        map(key)=[map(key);value];
    else
        map(key)=value;
    end

end









