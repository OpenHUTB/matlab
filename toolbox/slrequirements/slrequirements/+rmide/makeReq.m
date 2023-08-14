function req=makeReq(varargin)




    req=rmi.createEmptyReqs(1);
    req.reqsys='linktype_rmi_data';
    dataObj=varargin{1};
    req.description=rmide.getLabel(dataObj);
    [id,dfile]=rmide.getGuid(dataObj);
    req.id=['@',id];
    [~,dname,dext]=fileparts(dfile);
    switch rmipref('DocumentPathReference')
    case 'absolute'
        req.doc=dfile;
    case 'modelRelative'
        if nargin>1

            refPath=rmiut.getRefPath(varargin{2});
            req.doc=rmiut.relative_path(dfile,refPath);
        else
            req.doc=[dname,dext];
        end
    otherwise
        req.doc=[dname,dext];
    end
end

