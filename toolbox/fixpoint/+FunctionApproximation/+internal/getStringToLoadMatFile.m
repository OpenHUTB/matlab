function loadMatFileString=getStringToLoadMatFile(tableValues,filename)





    loadMatFileString='';
    if numel(tableValues)>=1000
        loadMatFileString=[newline,'data = load(''',filename,'.mat'');'];
    end
end