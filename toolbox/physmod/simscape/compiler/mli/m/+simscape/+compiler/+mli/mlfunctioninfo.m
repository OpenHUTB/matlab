function[fn,inputs,outputs,pfn,code]=mlfunctioninfo(fp)
























    ffullpath=which(fp);

    [~,~,ext]=fileparts(ffullpath);


    if~strcmpi(ext,'.m')
        pm_error('physmod:simscape:compiler:mli:support:MustBeMATLABCode',fp);
    end


    pfn=ffullpath;


    codeo=fileread(ffullpath);


    pstr=simscape.compiler.mli.internal.get_prototype_str(codeo);

    if isempty(pstr)
        pm_error('physmod:simscape:compiler:mli:support:InvalidMATLABFile',fp);
    end

    [~,inputs,outputs]=simscape.compiler.mli.internal.parse_ml_fun(pstr);

    if isempty(outputs)
        pm_error('physmod:simscape:compiler:mli:support:RequireOutput',fp);
    end


    fn='sscwapper_internal__';

    inputStr=simscape.compiler.mli.internal.signature_str(...
    '(',inputs,')');

    outputStr=simscape.compiler.mli.internal.signature_str(...
    '[',outputs,']');

    code=sprintf('function %s = %s%s\n   %s = %s%s;\nend\n',...
    outputStr,fn,inputStr,outputStr,fp,inputStr);
end
