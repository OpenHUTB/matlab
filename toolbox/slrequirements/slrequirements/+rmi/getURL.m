function result=getURL(objH)





    if~rmiut.matlabConnectorOn()
        result='';
        return;
    end


    if iscell(objH)
        result=cell(length(objH),1);
        for i=1:length(objH)
            result{i}=getUrl(objH(i));
        end
    else
        result=getUrl(objH);
    end
end

function url=getUrl(obj)
    try
        navcmd=rmi.objinfo(obj);
        url=rmiut.cmdToUrl(navcmd);
    catch Mex
        error(message('Slvnv:rmiut:matlabConnectorOn:UnableToGenerate',...
        [class(obj),''': ''',Mex.message]))
    end
end


