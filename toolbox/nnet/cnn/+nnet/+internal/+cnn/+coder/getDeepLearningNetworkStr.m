function fnstr=getDeepLearningNetworkStr(filename,weights)

%#codegen
    coder.allowpcode('plain');
    coder.internal.prefer_const(filename);

    if strcmpi(weights,'imagenet')
        fnstr=filename;
    else
        fnstr=[filename,'(''weights'',''',weights,''')'];
    end

end