function hf=updateInputInfo(this,hf,inputformat,arith)%#ok<INUSL>






    if strcmpi(arith,'double')
        hf.inputsltype='double';
    elseif strcmpi(arith,'single')
        hf.inputsltype='single';
    else
        [~,hf.inputsltype]=hdlgettypesfromsizes(inputformat(1),inputformat(2),inputformat(3));
    end

end
