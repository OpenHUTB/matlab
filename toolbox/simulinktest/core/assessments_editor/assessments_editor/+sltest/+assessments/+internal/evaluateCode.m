function res=evaluateCode(codeText,saveToFile)
    if nargin<2
        saveToFile=true;
    end

    if saveToFile
        filename=fullfile(tempdir,['assessmentCodeEvaluation',datestr(now,30),'.m']);
        fid=fopen(filename,'w');
        fprintf(fid,'%s',codeText);
        fclose(fid);
        res.filename=filename;
        run(filename);
    else
        eval(codeText);
    end
    res.resultList=cellfun(@(r)r.getSDITree(),resultList,'UniformOutput',false);
end
