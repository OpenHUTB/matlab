function sigStr=signature_str(lb,params,rb)
    sigStr='   ';
    for i=1:length(params)
        sigStr=[sigStr,params{i},', '];%#ok
    end
    sigStr=sigStr(1:end-2);
    sigStr=[lb,' ',sigStr,' ',rb];
end
