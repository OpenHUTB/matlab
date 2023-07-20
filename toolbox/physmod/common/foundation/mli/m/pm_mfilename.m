function f=pm_mfilename(stackNum)










    s=dbstack('-completenames');
    if nargin==0
        stackNum=2;
    else

        stackNum=stackNum+1;
    end
    f='';
    if numel(s)>=stackNum
        f=s(stackNum).file;
    end


    [fileDir,fileName]=fileparts(f);
    pFile=fullfile(fileDir,[fileName,'.p']);
    if exist(pFile,'file')
        f=pFile;
    end

end
