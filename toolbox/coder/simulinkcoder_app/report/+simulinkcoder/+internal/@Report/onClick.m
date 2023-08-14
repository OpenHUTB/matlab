function onClick(obj,data)



    switch data.action
    case{'line2mdl','token2mdl'}
        mdl=data.build;
        file=data.file;
        line=data.line;
        if~isfield(data,'col')
            loc=num2str(line);
        else
            loc=[num2str(line),'c',num2str(data.col)];
        end
        rtw.report.code2model(mdl,file,loc);

    case 'hdl_line2mdl'
        sids=data.sids;
        if~isempty(sids)
            simulinkcoder.internal.HDLCodeView.highlightBlock(sids);
        end

    case 'blk2mdl'
        sids=data.sids;
        if isempty(sids)
            try
                sids={Simulink.ID.getSID(data.code)};
            catch
            end
        end
        coder.internal.highlightBlocks(sids);
    case 'code2req'
        ud=data.userData;
        sid=ud.sid;
        reqId=ud.reqId;
        rtw.report.code2req(sid,reqId);
    end
