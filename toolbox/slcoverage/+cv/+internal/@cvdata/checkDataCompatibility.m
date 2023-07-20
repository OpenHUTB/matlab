function checkDataCompatibility(this,cvd)




    if nargin==2
        cvdArray=[this,cvd];
    else
        cvdArray=this;
    end

    dbVersion_toMatch=cvdArray(1).dbVersion;
    clsType_toMatch=class(cvdArray(1));

    for i=2:numel(cvdArray)
        clsType_other=class(cvdArray(i));
        if~isequal(clsType_toMatch,clsType_other)
            error(message('Slvnv:simcoverage:cvdata:CvObjTypeNotMatch',clsType_toMatch,clsType_other));
        end
        if~isequal(dbVersion_toMatch,cvdArray(i).dbVersion)
            error(message('Slvnv:simcoverage:cvdata:DbVersionNotMatch'));
        end

        if~cvi.TopModelCov.compareChecksumsAndMetricSettings(cvdArray(1),cvdArray(i))
            error(message('Slvnv:simcoverage:cvdata:ChecksumNotMatch'));
        end
    end


