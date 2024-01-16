function handleMaskParams(this,slBlockName,slHandle,hRefNtwk,isPort,newPortNum)

    if nargin<6
        newPortNum='';
    end

    if any(hasmaskdlg(slHandle))||any(hasmask(slHandle)==2)
        pv=getMaskParams(this,slHandle);
        for i=1:length(pv)
            if strcmp(pv{i,1},'MaskInitialization')
                if~isempty(pv{i,2})
                    if~isempty(hRefNtwk)&&(hRefNtwk.renderCodegenPir||hRefNtwk.shouldDraw)

                        pv{i,2}=getUpdatedMaskInitScript(this,slHandle,hRefNtwk);

                        if isstring(pv{i,2})
                            pv{i,2}=string(strjoin(pv{i,2}));
                        end
                    end
                end
            end

            if strcmp(pv{i,1},'MaskStyles')
                pv{i,2}=regexprep(pv{i,2},'promote(.*)','edit');
            end
        end
        [success,statusMsg]=setMaskParams(this,slBlockName,pv);
        if~success
            warnObj=message('hdlcoder:engine:MdlGenMaskInfoWarn',...
            hdlMsgWithLink(getfullname(slHandle)),statusMsg);
            this.reportCheck('Warning',warnObj);
            return;
        end
        setResolvedRuntimeMaskValues(this,slHandle,slBlockName);
    else
        pv=getMaskDlgParams(this,slHandle);
        setMaskDlgParams(this,slBlockName,pv);
        if~isPort
            set_param(slBlockName,'Permissions','ReadWrite');
        end
    end

    if isPort&&~isempty(newPortNum)
        set_param(slBlockName,'Port',num2str(newPortNum));
    end
end


function setResolvedRuntimeMaskValues(this,slHandle,slBlockName)
    diagParams=get_param(slHandle,'DialogParameters');
    if isempty(diagParams)
        return;
    end
    maskParamNames=get_param(slHandle,'MaskNames');
    if isempty(maskParamNames)
        return;
    end
    dialogParamNames=fields(diagParams);
    idx=zeros(length(dialogParamNames),1);
    for ii=1:length(dialogParamNames)
        idx(ii)=find(strcmpi(maskParamNames,dialogParamNames{ii}),1);
    end
    maskParamTypes=get_param(slHandle,'MaskStyles');
    if~isempty(maskParamTypes)
        for ii=1:length(idx)
            maskParamName=maskParamNames{idx(ii)};
            maskParamType=maskParamTypes{idx(ii)};
            if strcmpi(maskParamType,'edit')
                maskVariable=get_param(slHandle,maskParamName);
                if~isempty(maskVariable)
                    formatMaskValue=true;
                    if strncmp(maskVariable,'Enum:',5)
                        maskValue=maskVariable;
                        set_param(slBlockName,maskParamName,maskValue);
                        continue;
                    else
                        try
                            maskValue=slResolve(maskVariable,slHandle,'expression');
                            if~isnumeric(maskValue)
                                maskValue=maskVariable;
                                formatMaskValue=false;
                            end
                        catch me
                            if strcmp(me.identifier,'Simulink:Data:SlResolveNotResolved')
                                maskValue=maskVariable;
                                formatMaskValue=false;
                            else
                                me.rethrow;
                            end
                        end
                    end
                    if formatMaskValue
                        if ischar(maskValue)

                            maskValue=strrep(maskValue,'''','''''');

                            maskValue=['''',maskValue,''''];%#ok<AGROW>
                        elseif isa(maskValue,'Simulink.Signal')||isa(maskValue,'Simulink.Bus')
                            maskValue=maskVariable;
                        else
                            maskValue=formatMaskVal(this,maskValue,false);
                        end
                    end
                    set_param(slBlockName,maskParamName,maskValue);
                end
            end
        end
    end
end


function maskInitScript=getUpdatedMaskInitScript(this,slHandle,hN)

    maskInitScript='';
    if hN.isMaskedSubsystemLibBlock||hN.isMaskedSubsystem
        maskWorkSpaceVars=get_param(slHandle,'MaskWSVariables');
        for jj=1:length(maskWorkSpaceVars)
            var=maskWorkSpaceVars(jj).Name;
            val=maskWorkSpaceVars(jj).Value;
            if ischar(val)
                val=['''',strrep(val,newline,'\n'),''''];
            elseif isstring(val)
                val=strrep(val,newline,'\n');
                val=sprintf("""%s""",val);
            elseif islogical(val)
                if val
                    val='double(1)';
                else
                    val='double(0)';
                end
            elseif isnumeric(val)||isstruct(val)||...
                isnumerictype(val)||isa(val,'Simulink.NumericType')
                val=formatMaskVal(this,val,false);
            else
                continue;
            end
            maskInitScript=[maskInitScript,var...
            ,' = ',val,';',newline];%#ok<*AGROW> 
        end
    end
end


function retval=formatMaskVal(this,val,isUsedInEval)
    narginchk(3,3);
    if isstruct(val)
        retval=formatStructVal(this,val,isUsedInEval);
    else
        retval=formatMatrixVal(this,val,isUsedInEval);
    end
end


function retval=formatStructVal(this,val,isUsedInEval)
    narginchk(3,3);
    retval='struct(';
    names=fieldnames(val);
    numfields=numel(names);
    for ii=1:numfields
        if ii==numfields
            finalstr=')';
        else
            finalstr=', ';
        end
        fieldvalue=val.(names{ii});
        if ischar(fieldvalue)
            fieldvalue=strrep(fieldvalue,'''','''''');
            fieldval=sprintf('''%s''',fieldvalue);
        elseif isstring(fieldvalue)
            fieldval=strrep(fieldvalue,newline,'\n');
            fieldval=sprintf("""%s""",fieldval);
        else
            fieldval=formatMaskVal(this,fieldvalue,isUsedInEval);
        end
        retval=sprintf('%s''%s'', %s%s',retval,names{ii},fieldval,finalstr);
    end
end
