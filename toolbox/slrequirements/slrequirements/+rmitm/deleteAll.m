function deleteAll(varargin)




    if builtin('_license_checkout','Simulink_Requirements','quiet')
        error(message('Slvnv:reqmgt:setReqs:NoLicense'));
    end

    [testSuite,id]=rmitm.resolve(varargin{:});

    rmitm.setReqs(testSuite,id,[]);

end

