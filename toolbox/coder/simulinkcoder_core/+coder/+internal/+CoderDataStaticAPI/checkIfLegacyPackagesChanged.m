function packageChanged=checkIfLegacyPackagesChanged(sourceDD)




    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();

    currentCdef=hlp.openDD(sourceDD);
    packages=currentCdef.getLegacyPackageNames();

    packageChanged=false;
    for i=1:length(packages)
        currentPkg=packages{i};






        if strcmp(currentPkg,'SimulinkBuiltin')
            continue;
        end
        chksumStruct=processcsc('GetCSCChecksums',currentPkg);
        chksum=chksumStruct.Checksum;
        chksumSrc=chksumStruct.ChecksumSource;
        pkgChecksum=currentCdef.packageChecksums.getByKey(currentPkg);
        if isempty(pkgChecksum)







        elseif~strcmp(chksum.(currentPkg),pkgChecksum.Checksum)

            mfileChecksum=getCSCChecksumForMFile(currentPkg);
            if~strcmp(mfileChecksum,pkgChecksum.Checksum)
                [~,fName,fExt]=fileparts(chksumSrc.(currentPkg));
                newChksumSrcFile=[fName,fExt];
                try
                    origChksumSrc=pkgChecksum.getPropertyValue('ChecksumSource');



                    if isempty(origChksumSrc)||strcmp(newChksumSrcFile,origChksumSrc)
                        packageChanged=true;
                    end
                catch me


                    if strcmp(me.identifier,'mf0:messages:NoSuchProperty')
                        packageChanged=true;
                    else
                        throw me;
                    end
                end
            end
        end
    end
end

function regChecksum=getCSCChecksumForMFile(pkgName)
    fileName='csc_registration.m';
    tmpstr=['+',pkgName,filesep,fileName];
    filePath=which(tmpstr);
    regChecksum='';
    if~isempty(filePath)
        regChecksum=slprivate('file2hash',filePath);
    end
end

