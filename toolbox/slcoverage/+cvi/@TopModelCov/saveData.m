function fullFileName=saveData(cvdpair,outputDir,dataFileName,incFileName)




    if nargin<4
        incFileName=true;
    end
    [~,dataFileName,ext]=fileparts(dataFileName);
    if incFileName
        dataFileName=cvi.TopModelCov.getUniqueFileName(outputDir,dataFileName);
    end
    fullFileName=fullfile(outputDir,append(dataFileName,ext));

    if~isempty(cvdpair{2})
        [p1,p2]=checkPair(cvdpair{1},cvdpair{2});
        cvsave(fullFileName,p1,p2);
    else
        cvsave(fullFileName,cvdpair{1});
    end

    function[p1,p2]=checkPair(p1,p2)
        if isa(p1,'cv.cvdatagroup')&&...
            isa(p2,'cvdata')
            p2=cv.cvdatagroup(p2);
        end