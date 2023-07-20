



function emitPWorkUpdate(~,codeWriter,funSpec)


    stmts={};
    funSpec.forEachArg(@(f,a)xformData(a.Data));

    if~isempty(stmts)
        codeWriter.wNewLine;
        codeWriter.wCmt('Update the PWorks');
        cellfun(@(aLine)codeWriter.wLine(aLine),stmts);
    end

    function xformData(dataSpec)

        if dataSpec.isDWork()&&~isempty(dataSpec.pwIdx)
            stmts{end+1}=sprintf('ssSetPWorkValue(S, %d, work%d);',...
            dataSpec.pwIdx-1,dataSpec.Id);
        end
    end
end


