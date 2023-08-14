function ssDirty=findDirtyStylesheet(this,id)




    ssDirty=[];

    openSS=find(this,...
    '-depth',1,...
    '-isa','RptgenML.StylesheetEditor',...
    'ID',id);

    for i=1:length(openSS)
        if getDirty(openSS(i))
            ssDirty=openSS(i);
            return;
        end
    end
