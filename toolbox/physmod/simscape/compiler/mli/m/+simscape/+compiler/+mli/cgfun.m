function files=cgfun(tmpDir,funInfo,cgInfo)





    cleanTmpDir=create_dir(tmpDir);%#ok


    create_wrapper_function(tmpDir,funInfo);


    cmdStr=construct_cmd(tmpDir,funInfo);


    eval_cmd(tmpDir,cmdStr);


    files=move_code(tmpDir,funInfo,cgInfo);

end

function create_wrapper_function(targetDir,funInfo)

    fn=funInfo.idxstr;

    fName=[fn,'.m'];
    hName=fullfile(targetDir,fName);
    fid=simscape.compiler.support.open_file_for_write(hName);


    signatureRetrunStr='';
    callReturnStr='';
    curIndex=0;
    for i=funInfo.return_support'
        if i==0
            callReturnStr=[callReturnStr,'~, '];%#ok
        else
            curParam=['r',num2str(curIndex)];
            signatureRetrunStr=[signatureRetrunStr,curParam,', '];%#ok
            callReturnStr=[callReturnStr,curParam,', '];%#ok
            curIndex=curIndex+1;
        end
    end
    signatureRetrunStr=['[ ',signatureRetrunStr(1:end-2),' ]'];
    callReturnStr=['[ ',callReturnStr(1:end-2),' ]'];

    ins=cell(1,length(funInfo.argtys));
    for i=1:length(funInfo.argtys)
        ins{i}=['in',num2str(i)];
    end
    inputStr=simscape.compiler.mli.internal.signature_str(...
    '(',ins,')');


    fprintf(fid,'function %s = %s%s\n',signatureRetrunStr,fn,inputStr);


    fprintf(fid,'   %s = %s%s;\n',callReturnStr,funInfo.name,inputStr);

    fprintf(fid,'end\n');

    fclose(fid);
end

function cmdStr=construct_cmd(tmpDir,funInfo)

    fn=funInfo.idxstr;

    argTys=funInfo.argtys;

    argStr='{';
    for i=1:length(argTys)
        curStr=type_str(argTys(i));
        argStr=[argStr,curStr,','];%#ok
    end
    argStr=[argStr,'}'];

    cmdStr=[...
    'coder.internal.generateSimscape(''-c'', ''-config'', libCfg, ''-feature'', featureObj, ''-d'', ''',tmpDir,''', ''',fn...
    ,''', ''-args'', ''',argStr,''', ''--preserve'', ''tpb3379334_563d_4394_b05f_26c58924749e'')'];

end

function eval_cmd(tmpDir,cmd)
    returnPath=enter_dir(tmpDir);%#ok<NASGU>

    libCfg=coder.config('lib','ecoder',false);
    libCfg.FilePartitionMethod='singlefile';
    libCfg.GenerateExampleMain='DoNotGenerate';
    libCfg.GenCodeOnly=true;
    libCfg.EnableVariableSizing=false;
    libCfg.GenerateNonFiniteFilesIfUsed=false;
    libCfg.TargetLangStandard='C89/C90 (ANSI)';

    featureObj=coder.internal.FeatureControl;
    featureObj.GenerateSimulinkCompatibleRtNonfinite=true;
    evalc(cmd);
end

function cu=enter_dir(tmpDir)
    curPath=pwd;
    cd(tmpDir);
    cu=onCleanup(@()cd(curPath));
end

function typeStr=type_str(typeInfo)

    tid=typeInfo.tid;
    tsz=typeInfo.size;

    szStr='ones(';
    for i=1:length(tsz)
        szStr=[szStr,num2str(tsz(i))];%#ok
        if i<length(tsz)
            szStr=[szStr,', '];%#ok
        end
    end
    szStr=[szStr,')'];

    typeStr=[tid,'( ',szStr,' )'];
end


function cleanup=create_dir(dirname)
    if exist(dirname,'dir')
        simscape.compiler.support.delete_directory(dirname);
    end

    simscape.compiler.support.create_directory(dirname)

    cleanup=onCleanup(@()rmdir(dirname,'s'));
end


function files=move_code(tmpDir,funInfo,cgInfo)

    targetDir=cgInfo.dir;

    fn=funInfo.idxstr;

    files1={};


    files1{end+1}=[fn,'.c'];
    files1{end+1}=[fn,'.h'];
    files1{end+1}=[fn,'_types.h'];
    files1{end+1}='rt_nonfinite.h';
    files1{end+1}='rt_nonfinite.c';
    files1{end+1}='rtGetInf.h';
    files1{end+1}='rtGetInf.c';
    files1{end+1}='rtGetNaN.h';
    files1{end+1}='rtGetNaN.c';

    files=cell(1,length(files1));
    for i=1:length(files)
        src=fullfile(tmpDir,files1{i});
        tgt=fullfile(targetDir,files1{i});
        files{i}=tgt;

        simscape.compiler.support.copy_file(src,tgt);
    end
end
