%#codegen

function[data]=fetchLoggedData()
    coder.allowpcode('plain')
    coder.extrinsic('createLogger');
    coder.extrinsic('coder.internal.f2ffeature');
    coder.extrinsic('generic_logger_lib');
    coder.extrinsic('f2f_overflow_lib');

    if coder.const(coder.internal.f2ffeature('OverflowLogging'))
        data.Overflows.Table=f2f_overflow_logger;
        data.Overflows.Info=coder.const(f2f_overflow_lib('gen_overflow_info'));
    end

    mode=coder.const(coder.internal.f2ffeature('MEXLOGGING'));
    if mode==2
        data.buffers=generic_logger;


        ids=coder.const(generic_logger_lib('gen_logger_lib'));
        data.info=ids;
        return;
    elseif mode==1
        [~,uniqFcnList,exprIDLists,loggerLists,filePathLists]=coder.const(@createLogger);
        fcnInfoList=cell(1,length(uniqFcnList));
        for ii=coder.unroll(1:length(uniqFcnList))
            uniqFcn=uniqFcnList{ii};
            filePath=filePathLists{ii};

            ids=exprIDLists{ii};
            varLoggers=loggerLists{ii};



            fcnInfo=cell(1,3);
            exprInfos=cell(1,length(ids));
            for jj=coder.unroll(1:length(ids))
                id=ids{jj};
                loggerFcn=str2func(varLoggers{jj});
                exprInfos{jj}=loggerFcn();
            end





            fcnInfo{1}=uniqFcn;
            fcnInfo{2}=filePath;
            fcnInfo{3}=exprInfos;
            fcnInfoList{ii}=fcnInfo;
        end
        data=fcnInfoList;
    end
end