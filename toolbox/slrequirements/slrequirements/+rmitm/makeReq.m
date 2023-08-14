function req=makeReq(varargin)




    req=rmi.createEmptyReqs(1);
    req.reqsys='linktype_rmi_testmgr';
    [suite,id]=rmitm.resolve(varargin{1});
    [~,tName,tExt]=fileparts(suite);
    testCaseName=stm.internal.getTestCaseNameFromUUIDAndTestFile(id,suite);
    req.description=getString(message('Slvnv:rmitm:TestCaseIn',testCaseName,tName));
    req.id=id;
    switch rmipref('DocumentPathReference')
    case 'absolute'
        req.doc=suite;
    case 'modelRelative'
        if nargin>1

            refPath=rmiut.getRefPath(varargin{2});
            req.doc=rmiut.relative_path(suite,refPath);
        else
            req.doc=[tName,tExt];
        end
    otherwise
        req.doc=[tName,tExt];
    end
end
