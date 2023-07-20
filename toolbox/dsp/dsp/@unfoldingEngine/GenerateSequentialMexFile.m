function GenerateSequentialMexFile(obj)



    pStr=StringWriter();

    data=obj.data;


    pStrFile=StringWriter();
    filename=fullfile(obj.data.workdirectory,'codegen',[obj.data.tempname,'original'],[obj.data.fname,'.h']);

    readfile(pStrFile,filename);

    hfile=cellstr(pStrFile);
    startln=find(contains(hfile,[' ',obj.data.fname,'(']));
    endline=find(contains(hfile(startln:end),';'));


    coder.internal.errorIf(isempty(startln)||isempty(endline),'dsp:dspunfold:InternalError');

    startln=startln(1);
    endline=endline(1);
    declaration=[hfile{startln:startln+endline-1}];
    declaration=strrep(declaration,'extern ','');
    declaration=strrep(declaration,';','');

    for i=1:numel(data.TopFunctionInputs)
        data.TopFunctionInputs{i}.VarType.Interface.Class='';
        data.TopFunctionInputs{i}.VarType.Interface.Pointer=false;
        data.TopFunctionInputs{i}.VarType.Interface.Name='';
    end
    for i=1:numel(data.TopFunctionOutputs)
        data.TopFunctionOutputs{i}.VarType.Interface.Class='';
        data.TopFunctionOutputs{i}.VarType.Interface.Pointer=false;
        data.TopFunctionOutputs{i}.VarType.Interface.Name='';
    end



    indx=strfind(declaration,[obj.data.fname,'(']);
    coder.internal.errorIf(isempty(indx),'dsp:dspunfold:InternalError');
    output_index=1;
    if(~contains(declaration(1:indx-1),'void'))
        data.TopFunctionOutputs{1}.VarType.Interface.Class=strtrim(strrep(strrep(strrep(declaration(1:indx-1),'*',''),'static',''),'inline',''));
        if(contains(declaration(1:indx-1),'*'))
            data.TopFunctionOutputs{1}.VarType.Interface.Pointer=true;
        end
        output_index=2;
    end


    indx_start=indx+length([obj.data.fname,'(']);
    topHasSD=false;
    stackIdx=strfind(declaration(indx_start:end),'*SD');
    if~isempty(stackIdx)
        topHasSD=true;
        indx_start=indx_start+stackIdx+2;
        indx=strfind(declaration(indx_start:end),',');
        if isempty(indx)
            indx=strfind(declaration(indx_start:end),')');
            coder.internal.errorIf(isempty(indx),'dsp:dspunfold:InternalError');
        end
        indx_start=indx_start+min(indx);
    end

    for i=1:numel(data.TopFunctionInputs)
        if isa(obj.InputArgs{i},'coder.Constant')
            continue;
        end
        indx_comma=strfind(declaration(indx_start:end),',');
        indx_par=strfind(declaration(indx_start:end),')');
        coder.internal.errorIf(isempty(indx_comma)&&isempty(indx_par),'dsp:dspunfold:InternalError');
        if isempty(indx_comma)
            indx_end=min(indx_par);
        else
            indx_end=min(min(indx_comma),min(indx_par));
        end

        current_arg=strtrim(declaration(indx_start:indx_start+indx_end-2));


        indx_bracket=strfind(current_arg,'[');
        if~isempty(indx_bracket)||~isempty(strfind(current_arg,'*'))%#ok
            data.TopFunctionInputs{i}.VarType.Interface.Pointer=true;
            if~isempty(indx_bracket)
                indx_bracket=min(indx_bracket);
                current_arg=strtrim(current_arg(1:indx_bracket-1));
            end
            current_arg=strtrim(strrep(current_arg,'*',''));
        end


        spaceidx=strfind(current_arg,' ');
        idx=spaceidx(end);
        data.TopFunctionInputs{i}.VarType.Interface.Class=strtrim(current_arg(1:idx));


        data.TopFunctionInputs{i}.VarType.Interface.Name=strtrim(current_arg(idx:end));

        indx_start=indx_start+indx_end;
    end


    for i=output_index:numel(data.TopFunctionOutputs)
        indx_comma=strfind(declaration(indx_start:end),',');
        indx_par=strfind(declaration(indx_start:end),')');
        coder.internal.errorIf(isempty(indx_comma)&&isempty(indx_par),'dsp:dspunfold:InternalError');
        if isempty(indx_comma)
            indx_end=min(indx_par);
        else
            indx_end=min(min(indx_comma),min(indx_par));
        end

        current_arg=strtrim(declaration(indx_start:indx_start+indx_end-2));


        indx_bracket=strfind(current_arg,'[');
        if~isempty(indx_bracket)||~isempty(strfind(current_arg,'*'))%#ok
            data.TopFunctionOutputs{i}.VarType.Interface.Pointer=true;
            if~isempty(indx_bracket)
                indx_bracket=min(indx_bracket);
                current_arg=strtrim(current_arg(1:indx_bracket-1));
            end
            current_arg=strtrim(strrep(current_arg,'*',''));
        end


        spaceidx=strfind(current_arg,' ');
        idx=spaceidx(end);
        data.TopFunctionOutputs{i}.VarType.Interface.Class=strtrim(current_arg(1:idx));


        data.TopFunctionOutputs{i}.VarType.Interface.Name=strtrim(current_arg(idx:end));

        indx_start=indx_start+indx_end;
    end


    pStr.addcr('#include "mex.h"');
    pStr.addcr('#include <stdio.h>')
    pStr.addcr('#include "%s_seq.h"',obj.data.tempname)
    pStr.addcr('#include "%s_seq_initialize.h"',obj.data.tempname)
    if topHasSD
        pStr.addcr('#include "%s.h"',obj.data.fname)
    end


    pStr.addcr();
    pStr.addcr('%s',declaration);
    pStr.addcr('{');
    pStr.addcr('static bool mex_initialized=false;');


    pStr.addcr();
    pStr.addcr('/*Initialize the sequential mex*/');
    pStr.addcr('if (!mex_initialized) {');
    if topHasSD
        pStr.addcr('%s_seq_initialize((%s_seqStackData *)SD);',obj.data.tempname,obj.data.tempname);
    else
        pStr.addcr('%s_seq_initialize();',obj.data.tempname);
    end
    pStr.addcr('mex_initialized=true;');
    pStr.addcr('}');


    pStr.addcr();
    if(output_index==2)
        pStr.add('return ');
    end
    pStr.add('%s_seq(',obj.data.tempname);
    if topHasSD
        pStr.add('(%s_seqStackData *)SD',obj.data.tempname);
        if(numel(data.TopFunctionOutputs)>0)||(numel(data.TopFunctionInputs)>numCoderConstant(obj))
            pStr.add(',');
        end
    end
    for i=1:numel(obj.data.TopFunctionInputs)
        if isa(obj.InputArgs{i},'coder.Constant')
            continue;
        end
        if i>1
            pStr.add(',');
        end
        pStr.add('%s',data.TopFunctionInputs{i}.VarType.Interface.Name);
    end
    for i=output_index:numel(obj.data.TopFunctionOutputs)
        if(i==output_index)&&(numel(data.TopFunctionInputs)>numCoderConstant(obj))
            pStr.add(',');
        end
        pStr.add('%s',data.TopFunctionOutputs{i}.VarType.Interface.Name);
        if i<numel(obj.data.TopFunctionOutputs)
            pStr.add(',');
        end
    end
    pStr.addcr(');');
    pStr.addcr('}');


    pStr.addcr('void %s_xil_terminate(void)',obj.data.fname);
    pStr.addcr('{');
    pStr.addcr('}');

    pStr.addcr('void %s_xil_shutdown(void)',obj.data.fname);
    pStr.addcr('{');
    pStr.addcr('}');


    if(chars(pStr)>0)
        indentCode(pStr,'c');
        write(pStr,fullfile(obj.data.workdirectory,[obj.data.tempname,'_seq_mex.c']));
    end
end


function num=numCoderConstant(obj)
    num=0;
    for i=1:numel(obj.InputArgs)
        if isa(obj.InputArgs{i},'coder.Constant')
            num=num+1;
        end
    end
end






