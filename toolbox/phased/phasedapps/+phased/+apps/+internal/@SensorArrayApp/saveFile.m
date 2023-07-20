function saveSuccessflag=saveFile(obj,varargin)



    if isempty(varargin)

        if isempty(obj.MatFilePath)
            matPath=getMatFilePath(obj);
            if isequal(matPath,0)
                saveSuccessflag=false;
                return;
            end
        else
            matPath=obj.MatFilePath;
        end
    else
        matPath=varargin{1};
    end

    try

        arrayAppSession=obj.CurrentArray;
        save(matPath,'arrayAppSession')

    catch me
        saveSuccessflag=false;
        h=errordlg(me.message,getString(...
        message('phased:apps:arrayapp:savefailed')),'modal');
        uiwait(h)
        return;
    end


    obj.MatFilePath=matPath;
    [~,appName]=fileparts(obj.MatFilePath);
    saveSuccessflag=true;

    obj.IsChanged=false;
    obj.DefaultSessionName=appName;

    setAppTitle(obj,obj.DefaultSessionName)

end