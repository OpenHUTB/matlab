function packageCSCDef=ec_record_csc_def(packageNames)















    packageCSCDef=[];
    packageCSCDef.packageNames=[];
    packageCSCDef.packageCSCDefns=[];

    if nargin==0
        checksums=processcsc('GetCSCChecksums');
        checksums=checksums.Checksum;
        packageNames={};
        if~isempty(checksums)
            packageNames=fieldnames(checksums);
            packageCSCDef.packageNames=packageNames;
        end
    else
        assert((iscellstr(packageNames)&&~isempty(packageNames))||...
        (isstring(packageNames)&&packageNames~=""));

        packageCSCDef.packageNames=packageNames;
    end

    for i=1:length(packageNames)
        cscDefns=processcsc('GetCSCDefns',packageNames{i});

        assert(~isempty(cscDefns),'CSC Defns shall always have at least one CSC Default');
        cscName=[];
        for j=1:length(cscDefns)
            cscName{j}=cscDefns(j).Name;%#ok
        end

        packageCSCDef.packageCSCDefns{i}.cscName=cscName;

        packageCSCDef.packageCSCDefns{i}.packageDef=cscDefns;
    end

    rtwprivate('rtwattic','AtticData','packageCSCDef',packageCSCDef);


