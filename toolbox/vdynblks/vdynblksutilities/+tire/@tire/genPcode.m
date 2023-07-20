function genPcode(tire,pcodeName,pwd)




    [tirStruct,~,~]=CreateStruct(tire);%#OK is in fact used in the workspace by matlab.io.saveVariablesToScript
    matlab.io.saveVariablesToScript(pcodeName,'tirStruct');
    S=fileread([pcodeName,'.m']);
    S=[['function tirStruct = ',pcodeName,'(pwd)'],newline,...
    'if isequal(double(pwd),[',num2str(double(pwd)),'])',newline,...
    S,newline,...
    'else',newline,...
    'tirStruct=[];',newline,...
    'end'];
    fileID=fopen([pcodeName,'.m'],'w');
    if fileID==-1,error('Cannot open file %s',FileName);end
    fwrite(fileID,S,'char');
    fclose(fileID);
    pcode([pcodeName,'.m']);
    if exist([pcodeName,'.m'],'file')==2
        delete([pcodeName,'.m']);
    end
end
