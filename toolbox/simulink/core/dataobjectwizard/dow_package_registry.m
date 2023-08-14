function objectList=dow_package_registry()




























    objectList(1).class={'Simulink'};
    objectList(1).type{1}={'Signal'};
    objectList(1).type{2}={'Parameter'};
    objectList(1).derivedbyMPT='No';

    objectList(2).class={'mpt'};
    objectList(2).type{1}={'Signal'};
    objectList(2).type{2}={'Parameter'};
    objectList(2).derivedbyMPT='Yes';


    hcustom=cusattic('AtticData','slDataObjectCustomizations');

    if~isempty(hcustom)
        packages=sl_get_customization_param(hcustom,'UserPackageList');
        if isempty(packages)

            return
        end




        packageIndex=0;
        defaultPackage='Simulink';

        if~isempty(packages)
            for i=1:length(packages)
                if strcmp(defaultPackage,packages{i})
                    packageIndex=i;
                    break;
                end
            end
        end



        if packageIndex~=1
            packages=[defaultPackage,packages];
            if packageIndex~=0

                packages(packageIndex+1)=[];
            end
        end


        goodPackageList=get_eligible_custom_packages(packages,objectList);

        if~isempty(goodPackageList)
            objectList=goodPackageList;
        end
    end


    function goodPackageList=get_eligible_custom_packages(packages,objectList)
        goodPackageList=[];
        idx=1;
        for i=1:length(packages)
            try
                if strcmp(packages{i},'Simulink')
                    goodPackageList(idx).class=objectList(1).class;%#ok
                    goodPackageList(idx).type=objectList(1).type;%#ok
                    goodPackageList(idx).derivedbyMPT=objectList(1).derivedbyMPT;%#ok
                    idx=idx+1;
                elseif strcmp(packages{i},'mpt')
                    goodPackageList(idx).class=objectList(2).class;%#ok
                    goodPackageList(idx).type=objectList(2).type;%#ok
                    goodPackageList(idx).derivedbyMPT=objectList(2).derivedbyMPT;%#ok
                    idx=idx+1;
                else

                    hP=meta.package.fromName(packages{i});
                    if isempty(hP)
                        continue
                    end
                    hC=[Simulink.data.findClass(hP,'Signal');...
                    Simulink.data.findClass(hP,'Parameter')];
                    ctr=0;
                    for j=1:length(hC)
                        thisClass=hC(j);
                        className=thisClass.Name;

                        if strcmp(className,[packages{i},'.Signal'])
                            if Simulink.data.isDerivedFrom(thisClass,'mpt.Signal')
                                isderivedbyMPT=1;
                                ctr=ctr+1;
                            elseif Simulink.data.isDerivedFrom(thisClass,'Simulink.Signal')
                                isderivedbyMPT=0;
                                ctr=ctr+1;
                            end
                        elseif strcmp(className,[packages{i},'.Parameter'])
                            if Simulink.data.isDerivedFrom(thisClass,'mpt.Parameter')
                                isderivedbyMPT=1;
                                ctr=ctr+1;
                            elseif Simulink.data.isDerivedFrom(thisClass,'Simulink.Parameter')
                                isderivedbyMPT=0;
                                ctr=ctr+1;
                            end
                        end
                    end
                    if ctr==2

                        goodPackageList(idx).class={packages{i}};%#ok
                        goodPackageList(idx).type{1}={'Signal'};%#ok
                        goodPackageList(idx).type{2}={'Parameter'};%#ok
                        if isderivedbyMPT
                            goodPackageList(idx).derivedbyMPT='Yes';%#ok
                        else
                            goodPackageList(idx).derivedbyMPT='No';%#ok
                        end
                        idx=idx+1;
                    else
                        MSLDiagnostic('Simulink:dow:CannotAddUserPackage',packages{i}).reportAsWarning;
                    end
                end
            catch merr
                warning(merr.identifier,merr.message);
            end
        end

