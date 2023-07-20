function out=makeVariableTable(c,varList,d)




    adSL=rptgen_sl.appdata_sl;
    currContext=getContextType(adSL,c,false);

    if c.isWorkspaceIO&&strcmp(currContext,'Model')
        simVars=LocGetWorkspaceIO(get(rptgen_sl.appdata_sl,'CurrentModel'));
        varList=[varList;simVars];
    end

    if isempty(varList)
        out='';
        c.status(getString(message('RptgenSL:rsl_csl_obj_fun_var:noVariablesLabel')),2);
        return;
    end

    varListLength=size(varList,1);


    varTable=cell(varListLength+1,1);
    varTable{1}=getString(message('RptgenSL:rsl_csl_obj_fun_var:variableNameLabel'));

    ps=rptgen_sl.propsrc_sl_blk;
    for i=1:varListLength
        if(isa(varList{i,5},'Simulink.Parameter'))
            varTable{i+1,1}=ps.makeLinkScalar(varList{i,5},'var','anchor',d,varList{i,1});
        else
            varTable{i+1,1}=varList{i,1};
        end;
    end;

    cWid=1;

    if c.VariableTableParentBlock
        varTable(:,end+1)=[{getString(message('RptgenSL:rsl_csl_obj_fun_var:parentBlocksLabel'))};varList(:,2)];
        cWid=[cWid,3];
    end

    if c.VariableTableCallingString
        varTable(:,end+1)=[{getString(message('RptgenSL:rsl_csl_obj_fun_var:callingStringLabel'))};varList(:,3)];
        cWid=[cWid,2];
    end

    if c.isShowVariableSize||...
        c.isShowVariableMemory||...
        c.isShowVariableClass

        for i=varListLength:-1:1
            tempVar=varList{i,5};
            if isa(tempVar,'Simulink.Parameter')

                if c.isShowVariableSize
                    sizeCol{i+1,1}=locSizeString(tempVar.Dimensions);
                end

                if c.isShowVariableMemory
                    try
                        v=eval(sprintf('%s(%d)',...
                        tempVar.DataType,tempVar.Value));%#ok<NASGU>
                        whosInfo=whos('v');
                        memCol{i+1,1}=whosInfo.bytes;
                    catch %#ok<CTCH>
                        memCol{i+1,1}=' ';
                    end
                end

                if c.isShowVariableClass
                    classCol{i+1,1}=tempVar.DataType;
                end

            else

                whosInfo=whos('tempVar');

                if c.isShowVariableSize
                    sizeCol{i+1,1}=locSizeString(whosInfo.size);
                end

                if c.isShowVariableMemory
                    memCol{i+1,1}=whosInfo.bytes;
                end

                if c.isShowVariableClass
                    classCol{i+1,1}=whosInfo.class;
                end
            end
        end

        if c.isShowVariableSize
            sizeCol{1}=getString(message('RptgenSL:rsl_csl_obj_fun_var:sizeLabel'));
            varTable(:,end+1)=sizeCol;
            cWid=[cWid,1];
            clear sizeCol;
        end

        if c.isShowVariableMemory
            memCol{1}=getString(message('RptgenSL:rsl_csl_obj_fun_var:bytesLabel'));
            varTable(:,end+1)=memCol;
            clear memCol;
            cWid=[cWid,1];
        end

        if c.isShowVariableClass
            classCol{1}=getString(message('RptgenSL:rsl_csl_obj_fun_var:classLabel'));
            varTable(:,end+1)=classCol;
            clear classCol;
            cWid=[cWid,1];
        end
    end

    if c.isShowVariableValue
        valCol={getString(message('RptgenSL:rsl_csl_obj_fun_var:valueLabel'))};
        for i=varListLength:-1:1
            tempVar=varList{i,5};
            if isa(tempVar,'Simulink.Parameter')
                tempVar=tempVar.Value;
            end
            valCol{i+1,1}=rptgen.toString(tempVar);
        end
        varTable(:,end+1)=valCol;
        clear valCol;
        cWid=[cWid,2];
    end

    if c.isShowTunableProps
        classCol=[{getString(message('RptgenSL:rsl_csl_obj_fun_var:storageClassLabel'))};cell(varListLength,1)];
        [tunableNames,tunableClasses,warnStr]=LocTunableProps(adSL);

        if(~isempty(warnStr))
            c.status(warnStr,6);
        end;

        for i=varListLength:-1:1
            if isa(varList{i,5},'Simulink.Parameter')
                val=varList{i,5}.CoderInfo.StorageClass;
            else
                listIndex=find(strcmp(tunableNames,varList{i,1}));
                if isempty(listIndex)
                    val='Auto';
                elseif strcmpi(tunableClasses{listIndex(1)},'auto')
                    val='SimulinkGlobal';
                else
                    val=tunableClasses{listIndex(1)};
                end
            end
            classCol{i+1}=val;
        end
        varTable(:,end+1)=classCol;
        cWid=[cWid,2];
    end

    propNames=c.ParameterProps(find(~cellfun('isempty',c.ParameterProps)));%#ok-MLINT
    if~isempty(propNames)
        propNames=propNames(:)';
        paramCells=cell(varListLength,length(propNames));
        for i=varListLength:-1:1
            val=varList{i,5};
            if isa(val,'Simulink.Parameter')
                for j=1:length(propNames)
                    try
                        paramCells{i,j}=subsref(val,locMakeSubsref(propNames{j}));



                    catch ex %#ok<NASGU>
                        paramCells{i,j}='N/A';
                    end
                end
            else
                [paramCells{i,:}]=deal('N/A');
            end
        end
        okCols=find(~all(strcmp(paramCells,'N/A'),1));

        if~isempty(okCols)
            propNames=propNames(okCols);
            paramCells=paramCells(:,okCols);
            varTable=[varTable,[propNames;paramCells]];
            cWid=[cWid,2*ones(1,length(okCols))];
        end
    end

    tm=makeNodeTable(d,...
    varTable,0,true);

    if strcmp(c.VariableTableTitleType,'auto')
        if isempty(currContext)||strcmpi(currContext,'none')
            tTitle=getString(message('RptgenSL:rsl_csl_obj_fun_var:allVariablesInAllModelsTitle'));
        else
            tTitle=sprintf(getString(message('RptgenSL:rsl_csl_obj_fun_var:variablesMsg')),currContext);
        end
    else
        tTitle=rptgen.parseExpressionText(c.VariableTableTitle);
    end

    tm.setTitle(tTitle);
    tm.setColWidths(cWid);
    tm.setBorder(c.isBorder);
    tm.setNumHeadRows(1);

    out=tm.createTable;


    function sString=locSizeString(sInfo)


        sString=sprintf('%ix',sInfo);
        sString=sString(1:end-1);


        function ioVals=LocGetWorkspaceIO(vModel)

            ioVals=cell(0,5);

            simParams={'LoadExternalInput','ExternalInput','Sim:ExternalInput'
            'SaveTime','TimeSaveName','Sim: Save Time'
            'SaveState','StateSaveName','Sim: Save State'
            'SaveOutput','OutputSaveName','Sim: Save Output'
            'LoadInitialState','Initial State','Sim: Initial State'
            'SaveFinalState','FinalStateName','Sim: Final State'};

            for i=1:size(simParams,1)
                if strcmp(get_param(vModel,simParams{i,1}),'on')
                    try
                        varName=get_param(vModel,simParams{i,2});
                    catch ex %#ok<NASGU>
                        varName='';
                    end

                    if~isempty(varName)
                        try
                            varValue=evalin('base',varName);
                        catch ex %#ok<NASGU>
                            varValue=nan;
                        end

                        ioVals(end+1,:)={varName,...
                        simParams{i,3},...
                        'Workspace IO',...
                        vModel,...
                        varValue};%#ok<AGROW> - does not grow predictably
                    end
                end
            end


            function[tNames,tClasses,warnStr]=LocTunableProps(adSL)

                tNames={};
                tClasses={};
                warnStr='';

                hModel=get(adSL,'CurrentModel');

                tunableVarsName=get_param(hModel,'TunableVars');
                tunableVarsStorageClass=get_param(hModel,'TunableVarsStorageClass');
                tunableVarsTypeQualifier=get_param(hModel,'TunableVarsTypeQualifier');




                sep=',';
                sepNameIndx=findstr(tunableVarsName,sep);
                sepSCIndx=findstr(tunableVarsStorageClass,sep);
                sepTQIndx=findstr(tunableVarsTypeQualifier,sep);




                if~isempty(tunableVarsName)
                    numberVars=length(sepNameIndx)+1;
                else
                    numberVars=0;
                end

                if numberVars



                    if length(sepSCIndx)+1~=numberVars
                        warnStr=...
                        getString(message('RptgenSL:rsl_csl_obj_fun_var:nameStorageClassMismatchWarning'));
                        return;
                    elseif length(sepTQIndx)+1~=numberVars
                        warnStr=...
                        getString(message('RptgenSL:rsl_csl_obj_fun_var:nameQualifierMismatchWarning'));
                        return;
                    elseif length(sepTQIndx)~=length(sepSCIndx)
                        warnStr=...
                        getString(message('RptgenSL:rsl_csl_obj_fun_var:storageQualifierMismatchWarning'));
                        return;
                    end








                    sepNameIndx=[0,sepNameIndx,length(tunableVarsName)+1];
                    sepSCIndx=[0,sepSCIndx,length(tunableVarsStorageClass)+1];
                    sepTQIndx=[0,sepTQIndx,length(tunableVarsTypeQualifier)+1];

                    tNames=cell(numberVars,1);
                    tClasses=cell(numberVars,1);
                    for i=1:numberVars

                        nameTmp=tunableVarsName(sepNameIndx(i)+1:sepNameIndx(i+1)-1);
                        nameTmp=deblankall(nameTmp);
                        tNames{i}=nameTmp;

                        scTmp=tunableVarsStorageClass(sepSCIndx(i)+1:sepSCIndx(i+1)-1);
                        scTmp=deblankall(scTmp);

                        tqTmp=tunableVarsTypeQualifier(sepTQIndx(i)+1:sepTQIndx(i+1)-1);
                        tqTmp=deblankall(tqTmp);

                        if isempty(tqTmp)
                            tClasses{i}=scTmp;
                        else
                            tClasses{i}=[scTmp,' (',tqTmp,')'];
                        end

                    end
                end


                function str=deblankall(str)

                    if isempty(str)
                        str='';
                    else

                        [r,c]=find(str~=' '&str~=0);
                        if isempty(c)
                            str='';
                        else
                            str=str(min(c):max(c));
                        end
                    end


                    function sref=locMakeSubsref(propName)



                        sTerms=strread(propName,'%s','delimiter','.');

                        sref=cell(1,length(sTerms)*2);

                        [sref{1:2:end-1}]=deal('.');
                        [sref{2:2:end}]=deal(sTerms{:});

                        sref=substruct(sref{:});
