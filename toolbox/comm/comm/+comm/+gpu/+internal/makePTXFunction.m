function mangName=makePTXFunction(name,dt)
    mangName=['X_',name];
    for ii=1:numel(dt)
        mangName=[mangName,'_T',dt{ii},'T'];
    end
    mangName=[mangName,'_X'];
end


