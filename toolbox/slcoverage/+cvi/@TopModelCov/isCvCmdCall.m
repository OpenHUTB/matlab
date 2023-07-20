




function res=isCvCmdCall(this)
    try
        res=strcmpi(get_param(this.topModelH,'cvsimrefCall'),'on');
    catch MEx
        rethrow(MEx);
    end