function isFileNameGood=cb_FileNameTyped(State)







    isFileNameGood=false;


    if isequal(State.exportTo,'exMatFile')&&...
        ~isempty(State.matFile)


        [~,~,ext]=fileparts(State.matFile);

        extGood=isempty(ext)||strcmpi(ext,'.mat')||strcmpi(ext,'.xls')||strcmpi(ext,'.xlsx')||strcmpi(ext,'.csv');


        isFileNameGood=extGood;

    end

end