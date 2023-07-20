function[dataList]=ec_get_info_for_aliastype(modelName)















    dataList={};


    [dataList_u,dataNameList_u]=get_user_type_info_for_aliastype;
    dataList=dataList_u;


    if(nargin==1)
        if feature('RTWReplacementTypes')&&~isempty(modelName)...
            &&strcmp(get_param(modelName,'IsERTTarget'),'on')...
            &&strcmp(get_param(modelName,'EnableUserReplacementTypes'),'on');
            [repTypes,slTypes]=ec_get_replacetype_mapping_list(modelName);
            dataList_r={};
            dataNameList_r={};
            if~isempty(repTypes)
                ctr=0;
                for i=1:length(repTypes)
                    if~ismember(repTypes{i},dataNameList_u)


                        if(existsInGlobalScope(modelName,repTypes{i})&&...
                            evalinGlobalScope(modelName,['isa(',repTypes{i},',''Simulink.AliasType'')';]));

                            continue;
                        elseif ismember(repTypes{i},dataNameList_r)

                            continue;
                        end
                        ctr=ctr+1;
                        dataList_r{ctr}.name=repTypes{i};
                        dataList_r{ctr}.type='AliasType';
                        dataList_r{ctr}.HeaderFile='';
                        dataList_r{ctr}.Description='';
                        dataNameList_r{ctr}=dataList_r{ctr}.name;
                        if strcmp(slTypes{i},'int')||strcmp(slTypes{i},'uint')

                            intBits=get_param(modelName,'TargetBitPerInt');
                            dataList_r{ctr}.BaseType=[slTypes{i},num2str(intBits)];
                        elseif strcmp(slTypes{i},'char')

                            charBits=get_param(modelName,'TargetBitPerChar');
                            dataList_r{ctr}.BaseType=['int',num2str(charBits)];
                        else

                            dataList_r{ctr}.BaseType=slTypes{i};
                        end
                    end
                end
                dataList={dataList_u{:},dataList_r{:}};
            end
        end
    end


