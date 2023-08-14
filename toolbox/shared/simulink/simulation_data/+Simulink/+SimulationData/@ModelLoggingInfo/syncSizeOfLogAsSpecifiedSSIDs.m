

function this=syncSizeOfLogAsSpecifiedSSIDs(this)



    for objIdx=1:length(this)
        if(~isequal(...
            size(this(objIdx).logAsSpecifiedByModelsSSIDs_),...
            size(this(objIdx).logAsSpecifiedByModels_)))

            this(objIdx).logAsSpecifiedByModelsSSIDs_=...
            cell(size(this(objIdx).logAsSpecifiedByModels_));


            for idx=1:length(this(objIdx).logAsSpecifiedByModels_)
                this(objIdx).logAsSpecifiedByModelsSSIDs_{idx}='';
            end
            this(objIdx).assertSizeOfLogAsSpecifiedMatch();
        end
    end
end
