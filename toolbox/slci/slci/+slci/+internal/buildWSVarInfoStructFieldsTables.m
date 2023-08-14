function[WSVarInfoTable,structureFieldsTable,structureIndicesTable]=...
    buildWSVarInfoStructFieldsTables(mdl_name,is_top_mdl,paramsTable)










    TOP_MODEL=1;
    REF_MODEL=0;
    BOTH_TOP_REF=2;

    WSVarInfoTable=containers.Map;



    mgr=slci.internal.ModelStateMgr(mdl_name);
    assert(mgr.isCompiled());


    vars=Simulink.findVars(mdl_name,'searchmethod','cached');



    var_info_tab=containers.Map;

    for i=1:numel(vars)
        data_obj=getDataObj(vars(i));
        prop=slci.internal.extractDataObjectInfo(mdl_name,data_obj,vars(i).Users{1});


        if(~isempty(prop))
            if(strcmpi(prop.CSCName,'GetSet'))
                expression='\$N';
                replace=vars(i).Name;
                newStr_get=regexprep(data_obj.CoderInfo.CustomAttributes.GetFunction,...
                expression,replace);
                prop.CSCGetFuncName=newStr_get;
                newStr_set=regexprep(data_obj.CoderInfo.CustomAttributes.SetFunction,...
                expression,replace);
                prop.CSCSetFuncName=newStr_set;
                prop.CSCHeaderFile=data_obj.CoderInfo.CustomAttributes.HeaderFile;
            end
        end


        if isempty(prop)&&(strcmpi(vars(i).SourceType,'base workspace'))
            prop=slci.WSVarInfo;
            prop.StorageClass='Auto';
            prop.DataType=class(data_obj);
            prop.InitialValue=data_obj;
            prop.IsStruct=isstruct(data_obj);
        end

        if isempty(prop)&&isa(data_obj,'Simulink.LookupTable')
            prop=slci.WSVarInfo;
            prop.StorageClass=data_obj.CoderInfo.StorageClass;
            prop.DataType=class(data_obj);
            prop.InitialValue=data_obj;
            prop.IsStruct=true;
        end

        if(~isempty(prop))
            name=vars(i).Name;

            prop.RTWName=name;
            var_info_tab([vars(i).Source,':',name])=prop;
        end

    end







    need_appending_tunable_param=...
    (((is_top_mdl==TOP_MODEL)&&~slci.internal.hasModelRefBlocks(mdl_name))...
    ||(is_top_mdl==BOTH_TOP_REF)...
    );
    appendingTunableParameter(mdl_name,need_appending_tunable_param,var_info_tab);


    need_appending_mdl_arg=(is_top_mdl==REF_MODEL||is_top_mdl==BOTH_TOP_REF);
    appendMdlArg(mdl_name,need_appending_mdl_arg,var_info_tab);





    [structureFieldsTable,structureIndicesTable]=...
    populateWSVarInfoTable(vars,var_info_tab,WSVarInfoTable,...
    paramsTable);


    appendGlobalDSM(mdl_name,var_info_tab,WSVarInfoTable);


end

function[structureFieldsTable,structureIndicesTable]=...
    populateWSVarInfoTable(vars,var_info_tab,WSVarInfoTable,paramsTable)





    vars_tab=containers.Map;
    buildVarsTable(vars,vars_tab);

    [vars_indirect_tab,structureFieldsTable,structureIndicesTable]=...
    slci.internal.buildIndirectTable(vars,vars_tab,paramsTable);


    populateIndirectUsers(vars_indirect_tab,vars_tab,var_info_tab,WSVarInfoTable);
end

function populateIndirectUsers(vars_exclusion_tab,vars_tab,var_info_tab,WSVarInfoTable)
    keys=vars_exclusion_tab.keys;
    for i=1:numel(keys)
        if isKey(var_info_tab,keys{i})
            prop=var_info_tab(keys{i});
            indirects=vars_exclusion_tab(keys{i});
            for j=1:numel(indirects)
                assert(isKey(vars_tab,indirects{j}));
                indirect_var=vars_tab(indirects{j});

                user2prop=containers.Map;
                if(isKey(WSVarInfoTable,indirect_var.Name))
                    user2prop=WSVarInfoTable(indirect_var.Name);
                end
                for k=1:numel(indirect_var.Users)
                    user2prop(indirect_var.Users{k})=prop;
                end
                WSVarInfoTable(indirect_var.Name)=user2prop;
            end

            assert(isKey(vars_tab,keys{i}));
            curr_var=vars_tab(keys{i});
            user2prop=containers.Map;
            if(isKey(WSVarInfoTable,curr_var.Name))
                user2prop=WSVarInfoTable(curr_var.Name);
            end
            for k=1:numel(curr_var.Users)
                user2prop(curr_var.Users{k})=prop;
            end
            WSVarInfoTable(curr_var.Name)=user2prop;
        end
    end
end

function appendWSVarInfoTable(mdl_name,dataObj,dataName,blkObj,var_info_tab,WSVarInfoTable)
    prop=slci.internal.extractDataObjectInfo(mdl_name,dataObj,blkObj.getFullName);
    if isempty(prop)&&(isKey(var_info_tab,['base workspace:',dataName]))
        prop=var_info_tab(['base workspace:',dataName]);
    end

    if~isempty(prop)
        prop.RTWName=dataName;
        if isKey(WSVarInfoTable,dataName)
            user_tab=WSVarInfoTable(dataName);
            assert(~isempty(user_tab));
        else
            user_tab=containers.Map;
        end
        user_tab(blkObj.getFullName)=prop;
        WSVarInfoTable(dataName)=user_tab;%#ok
    end
end



function appendGlobalDSM(mdl_name,var_info_tab,WSVarInfoTable)
    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
    try
        obj=get_param(mdl_name,'Object');
        blks=obj.SortedList;
        for i=1:numel(blks)
            blk=blks(i);
            blkObj=get_param(blk,'Object');
            blkSid=Simulink.ID.getSID(blkObj);
            if strcmp(get_param(blk,'BlockType'),'DataStoreMemory')&&...
                blkObj.isSynthesized
                dsName=get_param(blk,'DataStoreName');
                sigObj=slResolve(dsName,blkSid);
                appendWSVarInfoTable(mdl_name,sigObj,dsName,blkObj,...
                var_info_tab,WSVarInfoTable);

                assert(isa(sigObj,'Simulink.Signal'))
                initVal=sigObj.InitialValue;
                data_obj=slResolve(initVal,blkSid);
                appendWSVarInfoTable(mdl_name,data_obj,initVal,blkObj,...
                var_info_tab,WSVarInfoTable);
            end
        end
    catch
    end
end


function appendingTunableParameter(mdl_name,need_appending_tunable_param,var_info_tab)



    if need_appending_tunable_param

        TunableVars=get_param(mdl_name,'TunableVars');
        TunableVars=regexp(TunableVars,',','split');
        TunableVarsStorageClass=get_param(mdl_name,'TunableVarsStorageClass');
        TunableVarsStorageClass=regexp(TunableVarsStorageClass,',','split');
        assert(numel(TunableVars)==numel(TunableVarsStorageClass));
        TunableVarsTypeQualifier=get_param(mdl_name,'TunableVarsTypeQualifier');
        TunableVarsTypeQualifier=regexp(TunableVarsTypeQualifier,',','split');
        assert(numel(TunableVars)==numel(TunableVarsTypeQualifier));
        for i=1:numel(TunableVars)
            name=TunableVars{i};
            if~isempty(name)
                try
                    prop=slci.WSVarInfo;
                    sc_str=TunableVarsStorageClass{i};
                    if(strcmpi(sc_str,'Auto'))
                        sc_str='SimulinkGlobal';
                    end
                    prop.StorageClass=sc_str;
                    prop.RTWName=name;
                    base_var=slResolve(name,mdl_name);
                    if isstruct(base_var)
                        prop.IsStruct=true;
                    end
                    if strcmp(TunableVarsTypeQualifier{i},'const')
                        prop.IsConst=true;
                    end
                    prop.DataType=class(base_var);

                    var_info_tab(['base workspace:',name])=prop;
                catch
                end
            end
        end
    end
end

function appendMdlArg(mdl_name,need_appending_mdl_arg,var_info_tab)
    if(need_appending_mdl_arg)

        ParameterArgumentValues=get_param(mdl_name,'ParameterArgumentNames');
        if(~isempty(ParameterArgumentValues))
            mdlargs=regexp(ParameterArgumentValues,',','split');
            for i=1:numel(mdlargs)
                mdl_arg_name=mdlargs{i};
                key=[mdl_name,':',mdl_arg_name];
                if isKey(var_info_tab,key)
                    prop=var_info_tab(key);

                    prop.IsMdlArg=true;
                    var_info_tab(key)=prop;
                else

                    mdl_arg_var=Simulink.findVars(mdl_name,...
                    'Name',mdl_arg_name,...
                    'Source',mdl_name,...
                    'searchmethod','cached');


                    if(~isempty(mdl_arg_var))
                        data_obj=getDataObj(mdl_arg_var);
                        assert(~isa(data_obj,'Simulink.Data'));
                        prop=slci.WSVarInfo;
                        prop.RTWName=mdl_arg_name;
                        prop.InitialValue=data_obj;
                        prop.IsStruct=isstruct(data_obj);
                        prop.DataType=class(data_obj);
                        prop.IsMdlArg=true;
                        var_info_tab(key)=prop;
                    end
                end
            end
        end
    end
end

function data_obj=getDataObj(var)
    assert(isa(var,'Simulink.VariableUsage'));
    data_obj=[];



    try
        if~isempty(var.Users)
            assert(iscell(var.Users));
            data_obj=slResolve(var.Name,var.Users{1},'variable');
        end
    catch
    end
end

function buildVarsTable(vars,vars_tab)



    for i=1:numel(vars)
        name=vars(i).Name;
        source=vars(i).Source;
        assert(~isempty(source));
        key=[source,':',name];
        assert(~isKey(vars_tab,key));
        vars_tab(key)=vars(i);
    end

end





