function[update,eof]=sldvAsyncRead(chn)














    update=[];
    eof=false;


    if isempty(chn)
        eof=true;
        return;
    end




    warnBTModeName='backtrace';
    warnBTModeState=warning('query',warnBTModeName);
    warning('off',warnBTModeName);


    restoreWarnings=onCleanup(@()warning(warnBTModeState.state,warnBTModeName));

    is=chn.InputStream;

    if is.DataAvailable()

        update=readStream(is);



        if(1==slavteng('feature','MockingDvoAnalyzer'))
            recordMockedResults(update);
        end
    elseif is.isEndOfStream()














        eof=true;
    end

end

function update=readStream(is)
    update=is.read(is.DataAvailable());


    update=strtrim(update);

    update=update(cellfun(@(x)~isempty(x),update));

    update=cellfun(@(x)[x,';'],update,'UniformOutput',false);

    return;
end


function recordMockedResults(update)

    session_obj=sldvprivate('sldvGetActiveSession',get_param(Sldv.Token.get.getTestComponent.analysisInfo.designModelH,'Name'));


    logPath_filename=session_obj.getMockLogPath();


    if(~isempty(update))
        fid=fopen(logPath_filename,'a+');
        if(fid>0)
            fprintf(fid,'%s\n',update{:});
            fclose(fid);
        end
    end
end