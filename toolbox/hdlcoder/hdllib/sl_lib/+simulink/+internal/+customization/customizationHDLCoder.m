
function customizationHDLCoder()



    if~feature('HasDisplay')
        return;
    end

    cm=DAStudio.CustomizationManager;

    customize_LibraryBrowser_for_HDL(cm);
end

function customize_LibraryBrowser_for_HDL(cm)
    persistent longLibName
    persistent priorities
    persistent first_invocation

    isCustom=privhdllibstate('status');
    cm.LibraryBrowserCustomizer.setIsCustom(isCustom);

    if~isCustom
        return;
    end

    if(isempty(first_invocation))
        first_invocation=false;
    end


    if isempty(longLibName)
        priorities=containers.Map();


        priorities('HDL Coder')={-7,'hdlcoder','Simulink_HDL_Coder'};
        priorities('Stateflow')={-6,'stateflow','Stateflow'};
        priorities('DSP System Toolbox HDL Support')={-5,'dsp','Signal_Blocks'};
        priorities('Communications System Toolbox HDL Support')={-4,'comm','Communication_Toolbox'};
        priorities('Vision HDL Toolbox')={-3,'visionhdl','Vision_HDL_Toolbox'};
        priorities('HDL Verifier')={-2,'hdlverifier','EDA_Simulator_Link'};
        priorities('Fixed-Point Designer HDL Support')={-1,'fixedpoint','fixed_point_toolbox'};


        [~,longLibName]=LibraryBrowser.internal.findLibraryInfo();
    end

    hdlLibs=sort(longLibName((cellfun(@(x_)any(strfind(x_,'HDL')),longLibName))));


    hdlLibs={hdlLibs{:},'Stateflow'};%#ok<CCAT>


    unlicensedLibs={};
    for itr=1:length(hdlLibs)
        if priorities.isKey(hdlLibs{itr})
            pos_n_lic=priorities(hdlLibs{itr});
            if~isLicenseAvailable(pos_n_lic{2},pos_n_lic{3})
                unlicensedLibs{end+1}=hdlLibs{itr};%#ok<AGROW>
            end
        end
    end

    hdlLibs=setdiff(hdlLibs,unlicensedLibs);



    positions=-1*ones(1,length(hdlLibs));
    for itr=1:length(hdlLibs)
        if priorities.isKey(hdlLibs{itr})
            pos_n_lic=priorities(hdlLibs{itr});
            positions(itr)=pos_n_lic{1};
        end
    end


    info={};
    info(2:2:2*length(hdlLibs))=arrayfun(@(x){x},positions);
    info(1:2:2*length(hdlLibs))=hdlLibs;

    cm.LibraryBrowserCustomizer.applyOrder(info);


    info={};
    nonHDLLibs=setdiff(longLibName,hdlLibs);
    info(2:2:2*length(nonHDLLibs))={'Hidden'};
    info(1:2:2*length(nonHDLLibs))=nonHDLLibs;
    info={'Recently Used Blocks','Hidden',info{:}};%#ok<CCAT>


    cm.LibraryBrowserCustomizer.applyFilter(info);

end

function flag=isLicenseAvailable(product_name,license_name)
    flag=all([~isempty(ver(product_name)),license('test',license_name)]);
end
