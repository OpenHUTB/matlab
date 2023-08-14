
function data=addData(obj,cvd,fileName,toCheckSDI)



    if nargin<4
        toCheckSDI=false;
    end
    try
        data=obj.addCvData(cvd,fileName);
        if toCheckSDI
            cvi.ResultsExplorer.ResultsExplorer.checkSDI(data,obj.topModelName);
        end
    catch MEx
        rethrow(MEx);
    end
end