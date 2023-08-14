function certificate=getTargetCertificate(~,targetFolder)



    fName=fullfile(targetFolder,'registry','cert');
    try
        a=load(fName);
        certificate=a.code;
    catch e %#ok<NASGU>
        certificate=-1;
    end
end