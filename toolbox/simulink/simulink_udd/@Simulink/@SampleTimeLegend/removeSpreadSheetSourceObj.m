function removeSpreadSheetSourceObj(this,model)





    nSrc=length(this.ssSource);
    for idx=1:nSrc
        if(~isempty(this.ssSource{idx})&&strcmp(this.ssSource{idx}.mTopModelName,model))
            this.ssSource(idx)=[];
        end
    end
end