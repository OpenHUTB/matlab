













function delete(this)










    if this.UseTempDir

        if strcmp(this.TempDir,pwd)
            if~isempty(this.OriginalDir)
                cd(this.OriginalDir);




                rmpath(this.OriginalDir);
            else
                cd(prefdir);
            end
        end


        cleanDir(this.TempDir);
    end


    this.deleteMAObjs();

    this.mdlListenerOperation('DetachListener');


    notify(this,'Destroy');
end



function cleanDir(tmpdir)
    mxList=dir(fullfile(tmpdir,['*.',mexext]));

    if~isempty(mxList)
        clearStr='clear ';
        for mx=1:length(mxList)
            clearStr=[clearStr,' ',mxList(mx).name];%#ok<AGROW>
        end
        clearStr=[clearStr,';'];
        eval(clearStr);
    end

    slprivate('removeDir',tmpdir);

end