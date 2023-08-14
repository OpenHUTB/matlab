%#codegen

function val=f2f_log(fcn,fcnPath,loggerOutDir,id,val)
    coder.allowpcode('plain');
    coder.extrinsic('createLogger');
    coder.extrinsic('coder.internal.f2ffeature');
    coder.extrinsic('generic_logger_lib');
    coder.inline('never');

    eml_heisenfun;

    if~eml_is_constant_folding
        if coder.target('mex')&&coder.internal.isConst(numel(val))&&(isnumeric(val)||isstruct(val)||islogical(val))
            mode=coder.const(coder.internal.f2ffeature('MEXLOGGING'));
            if mode==2
                if~isreal(val)

                    f2f_log(fcn,fcnPath,loggerOutDir,coder.const([id,'.re']),real(val));
                    f2f_log(fcn,fcnPath,loggerOutDir,coder.const([id,'.im']),imag(val));
                    return;
                end
                if~isstruct(val)
                    [~,idx]=coder.const(@generic_logger_lib,'newIdx',fcn,fcnPath,id);
                    idx=nonConstIdx(idx);
                    if coderEnableLog(idx)
                        generic_logger(idx,val);
                    end
                else
                    for ii=1:numel(val)
                        v=val(ii);
                        f2f_log_struct(fcn,fcnPath,loggerOutDir,id,v);
                    end
                end
            else
                h=str2func(coder.const(createLogger(fcn,fcnPath,loggerOutDir,id)));
                h(id,val);
            end
        end
    end
end

function f2f_log_struct(fcn,fcnPath,loggerOutDir,id,val)
    coder.inline('never');
    coder.extrinsic('generic_logger_lib');
    nFields=eml_numfields(val);
    isAlwaysEmpty=coder.const(coder.internal.isConst(isempty(val))&&isempty(val));
    if nFields>0&&~isAlwaysEmpty

        for ii=coder.unroll(0:nFields-1)
            fieldname=eml_getfieldname(val,ii);
            fieldvalue=val(1).(fieldname);

            fieldId=coder.const([id,'.',fieldname]);
            if isstruct(fieldvalue)

                f2f_log_struct(fcn,fcnPath,loggerOutDir,fieldId,fieldvalue);
            else

                [~,idx]=coder.const(@generic_logger_lib,'newIdx',fcn,fcnPath,fieldId);
                idx=nonConstIdx(idx);
                if coderEnableLog(idx)
                    generic_logger(idx,fieldvalue);
                end
            end
        end
    else

    end
end

function idx=nonConstIdx(idx)
    coder.inline('never');
    coder.extrinsic('generic_logger_lib');
    persistent pOffset
    if isempty(pOffset)
        pOffset=uint32(0);
        pOffset=generic_logger_lib('idxOffset');
    end
    idx=idx+pOffset;
end
