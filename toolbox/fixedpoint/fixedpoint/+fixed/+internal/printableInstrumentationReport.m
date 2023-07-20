function printableInstrumentationReport(key,printablehtml,args,CompilationReport)%#ok<*AGROW>




    doLog2Display=CompilationReport.InstrumentedData.options.doLog2Display;



    doShowCode=CompilationReport.InstrumentedData.options.doShowCode;
    doPrototypeTable=CompilationReport.InstrumentedData.options.doPrototypeTable;
    doShowAttachedFimath=CompilationReport.InstrumentedData.options.doShowAttachedFimath;
    prototypeFimath=CompilationReport.InstrumentedData.options.prototypeFimath;

    instrumentedVariables=CompilationReport.InstrumentedData.InstrumentedVariables;

    out_of_range_colors={'Pink','black'};
    full_range_colors={'yellow','black'};

    IsArginString=getString(message('Coder:reportGen:inputVariable'));
    IsArgoutString=getString(message('Coder:reportGen:outputVariable'));
    IsIOString=getString(message('Coder:reportGen:ioVariable'));
    IsLocalString=getString(message('Coder:reportGen:localVariable'));
    IsGlobalString=getString(message('Coder:reportGen:globalVariable'));
    IsPersistentString=getString(message('Coder:reportGen:persistentVariable'));
    IsStructFieldString=getString(message('Coder:reportGen:structField'));



    for i=1:length(args)
        if isnumeric(args{i})
            args{i}=num2str(args{i});
        elseif isnumerictype(args{i})||isa(args{i},'Simulink.NumericType')
            args{i}=tostring(args{i});
        elseif isfimath(args{i})
            args{i}=fimathToStringRow(args{i});
        end
    end
    args_chars=sprintf(' %s',args{:});
    reproduction_step=sprintf('showInstrumentationResults%s',args_chars);

    html_file=fopen(printablehtml,'W','n','utf8');

    MxInfos=CompilationReport.inference.MxInfos;
    MxArrays=CompilationReport.inference.MxArrays;


    fprintf(html_file,'<!DOCTYPE html>\n');
    fprintf(html_file,'<html lang="en">\n');
    fprintf(html_file,'<head><meta http-equiv="Content-Type" content="text/html; charset=utf-8" /></head>\n');

    fprintf(html_file,'<h1>%s %s</h1>\n',getString(message('fixed:instrumentation:InstrumentationResultsHeader')),key);
    fprintf(html_file,'<h2>%s</h2>\n',getString(message('fixed:instrumentation:SummaryHeader')));
    fprintf(html_file,'<p>%s</p>\n',getString(message('fixed:instrumentation:RecreateHeader')));
    fprintf(html_file,'<pre>  %s</pre>\n\n',reproduction_step);
    fprintf(html_file,'<p>%s</p>\n<pre>%s</pre>\n',getString(message('fixed:instrumentation:MEXNameHeader')),instrumentedVariables.MexFileName);
    fprintf(html_file,'<p>%s</p>\n<pre>%s</pre>\n',getString(message('fixed:instrumentation:TimestampHeader')),instrumentedVariables.TimeStamp);
    fprintf(html_file,'<p>%s</p>\n',getString(message('fixed:instrumentation:OpenReportHeader')));
    fprintf(html_file,'<pre> web(''-browser'',''%s'')</pre>\n',printablehtml);
    fprintf(html_file,'\n');

    Functions=CompilationReport.inference.Functions;













    instrumented_variable_fields=...
    {'Prototype',getString(message('fixed:instrumentation:PrototypeTableHeader')),'%s',''
    'SymbolName',getString(message('Coder:reportGen:expressionColHdr')),'%s',''
    'Scope',getString(message('Coder:reportGen:typeColHdr')),'%s',''
    'Size',getString(message('Coder:reportGen:sizeColHdr')),'%s',''
    'Class',getString(message('Coder:reportGen:classColHdr')),'%s',''
    'LoggedFieldNames',getString(message('Coder:reportGen:LoggedFieldNamesColHdr')),'%s',''
    'Complex',getString(message('Coder:reportGen:complexColHdr')),'%s',''
    'DataType',getString(message('Coder:reportGen:dataTypeModeColHdr')),'%s',''
    'Signedness',getString(message('Coder:reportGen:signedColHdr')),'%s',''
    'WordLength',getString(message('Coder:reportGen:wordLengthColHdr')),'%s',''
    'FractionLength',getString(message('Coder:reportGen:fractionLengthColHdr')),'%s',''
    'Slope',getString(message('Coder:reportGen:slopeColHdr')),'%s',''
    'Bias',getString(message('Coder:reportGen:biasColHdr')),'%s',''
    'ProposedSignedness',getString(message('Coder:reportGen:ProposedSignednessColHdr')),'%s',''
    'ProposedWL',getString(message('Coder:reportGen:ProposedWLColHdr')),'%s',''
    'ProposedFL',getString(message('Coder:reportGen:ProposedFLColHdr')),'%s',''
    'PercentOfRange',getString(message('Coder:reportGen:PercentOfRangeColHdr')),'%s',''
    'IsWholeNumber',getString(message('Coder:reportGen:IsWholeNumberColHdr')),'%s',''
    'SimMin',getString(message('Coder:reportGen:SimMinColHdr')),'%s',''
    'SimMax',getString(message('Coder:reportGen:SimMaxColHdr')),'%s',''
    };
    if~doPrototypeTable

        instrumented_variable_fields(1,:)=[];
    end
    instrumented_variable_table_row_clean=make_html_table_struct(instrumented_variable_fields);

    for i=1:length(instrumentedVariables.Functions)
        FunctionID=instrumentedVariables.Functions(i).FunctionID;
        ThisFunction=Functions(FunctionID);

        ScriptText=CompilationReport.inference.Scripts(ThisFunction.ScriptID).ScriptText;






        functionName=Functions(FunctionID).FunctionName;
        if instrumentedVariables.Functions(i).NumberOfInstances>1
            functionName=[functionName,'&gt;',int2str(instrumentedVariables.Functions(i).InstanceCount)];
        end

        fprintf(html_file,'\n<h2>%s %s </h2>\n\n',getString(message('fixed:instrumentation:FunctionHeader')),functionName);
























        T=mtree(ScriptText);
        functionNodes=mtfind(T,'Kind','FUNCTION');
        functionIndices=functionNodes.indices;
        for functionIndex=functionIndices
            c=strings(Fname(select(functionNodes,functionIndex)));
            if~isempty(c)&&...
                isequal(functionName,...
                c{1})
                break
            end
        end

        if doShowCode
            functionTextStart=lefttreepos(functionNodes.select(functionIndex));
            functionTextEnd=righttreepos(functionNodes.select(functionIndex));
            this_function_script_text=ScriptText(functionTextStart:functionTextEnd);
            fprintf(html_file,'<pre>\n');
            fprintf(html_file,'%s',this_function_script_text);
            fprintf(html_file,'\n</pre>\n');
        end

        if isfield(instrumentedVariables.Functions(i),'NamedVariables')&&...
            ~isempty(instrumentedVariables.Functions(i).NamedVariables)

            index=0;
            instrumented_variable_table=instrumented_variable_table_row_clean;
            if doPrototypeTable&&isfimath(prototypeFimath)
                index=index+1;
                Fstr=fimathToStringRow(prototypeFimath);
                instrumented_variable_table(index).Prototype.value=sprintf('F = %s;',Fstr);
            end
            for k=1:length(instrumentedVariables.Functions(i).NamedVariables)
                v=instrumentedVariables.Functions(i).NamedVariables(k);
                SymbolName=v.SymbolName;
                if v.NumberOfInstances>1
                    SymbolName=[SymbolName,'&gt;',int2str(v.InstanceCount)];
                end
                if v.IsArgin&&v.IsArgout
                    Scope=IsIOString;
                elseif v.IsArgin
                    Scope=IsArginString;
                elseif v.IsArgout
                    Scope=IsArgoutString;
                elseif v.IsGlobal
                    Scope=IsGlobalString;
                elseif v.IsPersistent
                    Scope=IsPersistentString;
                else
                    Scope=IsLocalString;
                end


                mxInfo=MxInfos{v.MxInfoID};
                dt=mxInfo_to_dt_str(mxInfo,MxArrays);

                index=index+1;
                instrumented_variable_table(index)=instrumented_variable_table_row_clean;
                instrumented_variable_table(index).SymbolName.value=SymbolName;
                instrumented_variable_table(index).Scope.value=Scope;
                instrumented_variable_table(index).Size.value=dt.sizeStr;
                instrumented_variable_table(index).Class.value=dt.classStr;
                instrumented_variable_table(index).Complex.value=dt.complexStr;
                instrumented_variable_table(index).DataType.value=dt.DataType;
                instrumented_variable_table(index).Signedness.value=dt.Signedness;
                instrumented_variable_table(index).WordLength.value=dt.WordLength;
                instrumented_variable_table(index).FractionLength.value=dt.FractionLength;
                instrumented_variable_table(index).Slope.value=dt.Slope;
                instrumented_variable_table(index).Bias.value=dt.Bias;

                if~isa(mxInfo,'eml.MxCellInfo')
                    if isfield(v,'LoggedFieldNames')&&~isempty(v.LoggedFieldNames)&&...
                        isfield(v,'LoggedFieldMxInfoIDs')&&...
                        length(v.LoggedFieldMxInfoIDs)==length(v.LoggedFieldNames)

                        for l=1:length(v.LoggedFieldNames)
                            if~isempty(v.LoggedFieldMxInfoIDs{l})
                                mxInfo=MxInfos{v.LoggedFieldMxInfoIDs{l}(end)};
                                dt=mxInfo_to_dt_str(mxInfo,MxArrays);
                                index=index+1;
                                instrumented_variable_table(index)=instrumented_variable_table_row_clean;
                                symbol_name=[SymbolName,'.',v.LoggedFieldNames{l}];
                                if doPrototypeTable
                                    instrumented_variable_table(index).Prototype.value=makePrototypeString(symbol_name,...
                                    v.ProposedSignedness{l},...
                                    v.ProposedWordLengths{l},...
                                    v.ProposedFractionLengths{l},...
                                    mxInfo,MxArrays,...
                                    doShowAttachedFimath,...
                                    prototypeFimath);
                                end
                                instrumented_variable_table(index).SymbolName.value=symbol_name;
                                instrumented_variable_table(index).Scope.value=IsStructFieldString;
                                instrumented_variable_table(index).Size.value=dt.sizeStr;
                                instrumented_variable_table(index).Class.value=dt.classStr;
                                instrumented_variable_table(index).Complex.value=dt.complexStr;
                                instrumented_variable_table(index).DataType.value=dt.DataType;
                                instrumented_variable_table(index).Signedness.value=dt.Signedness;
                                instrumented_variable_table(index).WordLength.value=dt.WordLength;
                                instrumented_variable_table(index).FractionLength.value=dt.FractionLength;
                                instrumented_variable_table(index).Slope.value=dt.Slope;
                                instrumented_variable_table(index).Bias.value=dt.Bias;

                                instrumented_variable_table(index).ProposedSignedness.value=...
                                fixed.internal.loggedFieldNamesStr('',v.ProposedSignedness(l));
                                instrumented_variable_table(index).ProposedWL.value=...
                                fixed.internal.loggedFieldValuesStr(v.ProposedWordLengths(l));
                                instrumented_variable_table(index).ProposedFL.value=...
                                fixed.internal.loggedFieldValuesStr(v.ProposedFractionLengths(l));
                                instrumented_variable_table(index).PercentOfRange.value=...
                                fixed.internal.percentOfRangeStr(v.RatioOfRange(l),...
                                out_of_range_colors,full_range_colors);


                                instrumented_variable_table(index).IsWholeNumber.value=...
                                fixed.internal.loggedFieldValuesStr(v.IsAlwaysInteger(l),false,true,true,false);

                                instrumented_variable_table(index).SimMin.value=...
                                fixed.internal.loggedFieldValuesStr(v.SimMin(l),doLog2Display);

                                instrumented_variable_table(index).SimMax.value=...
                                fixed.internal.loggedFieldValuesStr(v.SimMax(l),doLog2Display);
                            end
                        end
                    else

                        if doPrototypeTable
                            instrumented_variable_table(index).Prototype.value=makePrototypeString(SymbolName,...
                            v.ProposedSignedness{1},...
                            v.ProposedWordLengths{1},...
                            v.ProposedFractionLengths{1},...
                            mxInfo,MxArrays,...
                            doShowAttachedFimath,...
                            prototypeFimath);
                        end
                        instrumented_variable_table(index).ProposedSignedness.value=fixed.internal.loggedFieldNamesStr('',v.ProposedSignedness);
                        instrumented_variable_table(index).ProposedWL.value=fixed.internal.loggedFieldValuesStr(v.ProposedWordLengths);
                        instrumented_variable_table(index).ProposedFL.value=fixed.internal.loggedFieldValuesStr(v.ProposedFractionLengths);
                        instrumented_variable_table(index).PercentOfRange.value=fixed.internal.percentOfRangeStr(v.RatioOfRange,...
                        out_of_range_colors,full_range_colors);

                        instrumented_variable_table(index).IsWholeNumber.value=...
                        fixed.internal.loggedFieldValuesStr(v.IsAlwaysInteger,false,true,true,false);

                        instrumented_variable_table(index).SimMin.value=...
                        fixed.internal.loggedFieldValuesStr(v.SimMin,doLog2Display);

                        instrumented_variable_table(index).SimMax.value=...
                        fixed.internal.loggedFieldValuesStr(v.SimMax,doLog2Display);
                    end
                end
            end
            headline=sprintf('%s %s',getString(message('fixed:instrumentation:LoggedVariablesFor')),functionName);
            make_html_table_all_rows(html_file,headline,instrumented_variable_table);
        else
            fprintf(html_file,'<p>%s</p>\n',getString(message('fixed:instrumentation:NoNamedVariablesLogged')));
        end
    end
    fprintf(html_file,'</html>\n');
    fclose(html_file);
end

function table=make_html_table_struct(fields)
    for i=1:size(fields,1)
        table.(fields{i,1}).header=fields{i,2};
        table.(fields{i,1}).format=fields{i,3};
        table.(fields{i,1}).value=fields{i,4};
    end
end

function make_html_table_all_rows(html_file,headline,instrumented_variable_table)
    field_names=fieldnames(instrumented_variable_table);
    nonempty_fields=false(size(field_names));

    for i=1:length(instrumented_variable_table)
        for j=1:length(field_names)
            if~nonempty_fields(j)&&...
                ~isempty(instrumented_variable_table(i).(field_names{j}).value)
                nonempty_fields(j)=true;
            end
        end
    end
    make_html_table_header(html_file,headline,instrumented_variable_table(1),nonempty_fields);
    for i=1:length(instrumented_variable_table)
        make_html_table_row(html_file,instrumented_variable_table(i),nonempty_fields);
    end
    make_html_table_end(html_file);
end

function make_html_table_header(html_file,headline,table,nonempty_fields)
    fprintf(html_file,'<table style="border-collapse: collapse; border: solid;" border="1">\n');
    fprintf(html_file,'<caption><b>%s</b></caption>\n',headline);
    fprintf(html_file,'<tr>');
    fields=fieldnames(table);
    N=1:length(fields);
    N=N(nonempty_fields);
    for i=N
        fprintf(html_file,'<th>%s</th>',table.(fields{i}).header);
    end
    fprintf(html_file,'</tr>\n');
end

function make_html_table_row(html_file,table,nonempty_fields)
    fields=fieldnames(table);
    fprintf(html_file,'<tr>');
    N=1:length(fields);
    N=N(nonempty_fields);
    for i=N
        fmt=sprintf('<td><code>%s</code></td>',table.(fields{i}).format);
        fprintf(html_file,fmt,table.(fields{i}).value);
    end
    fprintf(html_file,'</tr>\n');
end

function make_html_table_end(html_file)
    fprintf(html_file,'</table>\n');
end

function sizeStr=mxInfo_to_size_str(mxInfo)




    sizeStr='';
    if~isempty(mxInfo.SizeDynamic)
        staticDynamic=~any(mxInfo.SizeDynamic);
    else
        staticDynamic=false;
    end
    for i=1:length(mxInfo.Size)
        if i>1
            sizeStr=[sizeStr,'&nbsp;x&nbsp;'];
        end
        if mxInfo.Size(i)==-1
            dimSize='?';
        else
            dimSize=int2str(mxInfo.Size(i));
        end
        if i<=numel(mxInfo.SizeDynamic)&&mxInfo.SizeDynamic(i)
            dimSize=['<b>:</b>',dimSize];
        end
        sizeStr=[sizeStr,dimSize];
    end
    if staticDynamic
        sizeStr=[sizeStr,'&nbsp;*'];
    end

end

function dt=mxInfo_to_dt_str(mxInfo,MxArrays)




    dt.sizeStr=mxInfo_to_size_str(mxInfo);
    dt.classStr=mxInfo.Class;
    dt.complexStr='';
    dt.DataType='';
    dt.dtStr='';
    dt.Signedness='';
    dt.WordLength='';
    dt.FractionLength='';
    dt.Slope='';
    dt.Bias='';

    if isa(mxInfo,'eml.MxFiInfo')

        dt.complexStr=bool2str(mxInfo.Complex);
        T=MxArrays{mxInfo.NumericTypeID};
        dt.dtStr=tostring(T);
        if isscaleddouble(T)||~isscaledtype(T)
            dt.DataType=T.DataType;
        end
        if isscaledtype(T)
            dt.Signedness=T.Signedness;
            dt.WordLength=sprintf('%d',T.WordLength);
            if isscalingslopebias(T)
                e=fix(log2(T.Slope));
                if T.Slope==2^e
                    dt.Slope=sprintf('2^%d',e);
                else
                    dt.Slope=fixed.internal.compactButAccurateNum2Str(T.Slope);
                end
                dt.Bias=fixed.internal.compactButAccurateNum2Str(T.Bias);
            else
                dt.FractionLength=sprintf('%d',T.FractionLength);
            end
        end
    elseif isa(mxInfo,'eml.MxNumericInfo')
        dt.complexStr=bool2str(mxInfo.Complex);
    end
end

function proto=makePrototypeString(symbol_name,...
    proposedSignedness,...
    proposedWordLength,...
    proposedFractionLength,...
    mxInfo,MxArrays,...
    doShowAttachedFimath,...
    prototypeFimath)
    if isempty(proposedSignedness)&&...
        isempty(proposedWordLength)&&...
        isempty(proposedFractionLength)
        proto=makeOriginalPrototypeString(symbol_name,mxInfo,MxArrays,doShowAttachedFimath);
    else
        proto=makeProposedPrototypeString(symbol_name,...
        proposedSignedness,...
        proposedWordLength,...
        proposedFractionLength,...
        mxInfo,MxArrays,...
        prototypeFimath);
    end
    if isempty(proto)


        proto='%';
    else
        proto=[proto,'; %'];
    end
end

function proto=makeProposedPrototypeString(symbol_name,...
    proposedSignedness,...
    proposedWordLength,...
    proposedFractionLength,...
    mxInfo,MxArrays,...
    prototypeFimath)
    value=getPrototypeValue(mxInfo);
    T=[];
    if isempty(proposedSignedness)
        T=MxArrays{mxInfo.NumericTypeID};
        proposedSignedness=T.Signedness;
    end
    if isequal(proposedSignedness,'Signed')
        signed='true';
    else
        signed='false';
    end
    if isempty(proposedWordLength)
        T=MxArrays{mxInfo.NumericTypeID};
        proposedWordLength=T.WordLength;
    end
    if isempty(proposedFractionLength)
        T=MxArrays{mxInfo.NumericTypeID};
        proposedFractionLength=T.FractionLength;
    end
    proto=sprintf('T.%s=fi(%s,%s,%d,%d)',symbol_name,...
    value,signed,proposedWordLength,proposedFractionLength);
    if~isempty(T)&&isscaleddouble(T)
        proto=strrep(proto,')',',''DataType'',''ScaledDouble'')');
    end
    if isfimath(prototypeFimath)
        proto=strrep(proto,')',',''fimath'',F)');
    end
end


function proto=makeOriginalPrototypeString(symbol_name,mxInfo,MxArrays,doShowAttachedFimath)
    if isa(mxInfo,'eml.MxFiInfo')
        value=getPrototypeValue(mxInfo);
        T=MxArrays{mxInfo.NumericTypeID};
        if isscaleddouble(T)
            T.DataType='Fixed';
            Tstr=tostring(T);
            Tstr=strrep(Tstr,')',',''DataType'',''ScaledDouble'')');
        else
            Tstr=tostring(T);
        end
        proto=['T.',symbol_name,'='];
        proto=[proto,strrep(Tstr,'numerictype(',['fi(',value,','])];
        if doShowAttachedFimath
            if mxInfo.FiMathLocal

                F=MxArrays{mxInfo.FiMathID};
                Fstr=fimathToStringRow(F);

                Fstr=strrep(Fstr,'fimath(','');
                proto=strrep(proto,')',[',',Fstr]);
            end
        end
    elseif isa(mxInfo,'eml.MxNumericInfo')
        value=getPrototypeValue(mxInfo);

        proto=['T.',symbol_name,'='];
        proto=[proto,mxInfo.Class,'(',value,')'];
    else
        proto='';
    end
end

function value=getPrototypeValue(mxInfo)
    if mxInfo.Complex
        value='1i';
    else
        value='[]';
    end
end

function Fstr=fimathToStringRow(F)
    Fstr=tostring(F);

    Fstr=strrep(Fstr,char([46,46,46,10]),'');

    Fstr=strrep(Fstr,' ','');
end






function str=bool2str(val)
    if val==0
        str='No';
    else
        str='Yes';
    end
end






