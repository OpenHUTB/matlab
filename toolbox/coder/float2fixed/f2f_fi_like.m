%#codegen

function fival=f2f_fi_like(fcn,fcnPath,exprStart,exprLength,val,type)
    coder.inline('always');
    coder.extrinsic('f2f_overflow_lib');
    coder.allowpcode('plain');
    fival=cast(val,'like',type);

    if isfi(type)
        coder.varsize('val_f','fival_f',[1,inf]);
        fival_f=fival(:)';
        val_f=val(:)';

        idx=coder.const(f2f_overflow_lib('newIdx',fcn,fcnPath,exprStart,exprLength));

        check_overflow(idx,fival_f,val_f);
    end
end

function check_overflow(idx,fival_f,val_f)
    fmf=flip_fm(fimath(fival_f));
    eg=fi(0,numerictype(fival_f),fmf);

    for ii=1:numel(val_f)
        f=cast(val_f,'like',eg);
        if f~=fival_f
            f2f_overflow_logger(idx);
        end
    end
end


function fmf=flip_fm(fm)
    switch fm.OverflowAction
    case 'Saturate',fmf=fimath(fm,'OverflowAction','Wrap');
    case 'Wrap',fmf=fimath(fm,'OverflowAction','Saturate');
    end
end
