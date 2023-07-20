function packageInfo=sortPackageDisplayInfo(packageInfo)
















    assert(isstruct(packageInfo)&&...
    all(isfield(packageInfo,{'DisplayName','BaseProduct','Action'})));

    xlateEnt=struct(...
    'Install','',...
    'Uninstall','',...
    'Update','',...
    'Reinstall','',...
    'None','');
    xlateEnt=hwconnectinstaller.internal.getXlateEntries('hwconnectinstaller','setup','SelectPackage',xlateEnt);

    proxyStrings=[{packageInfo.DisplayName}',{packageInfo.Action}',{packageInfo.BaseProduct}'];
    proxyStrings(:,2)=prependPreferredOrder(proxyStrings(:,2),{...
    xlateEnt.Update
    xlateEnt.Reinstall
    xlateEnt.Uninstall
    xlateEnt.Install
    xlateEnt.None});
    proxyStrings(:,3)=prependPreferredOrder(proxyStrings(:,3),{...
'MATLAB'
    'Simulink'});



    [~,idx]=sortrows(proxyStrings,[1,2,3]);

    packageInfo=packageInfo(idx);

end



function strList=prependPreferredOrder(strList,preferredOrder)


    preferredOrderNewStr=cell(1,numel(preferredOrder));
    prefix=sprintf('\t ');
    for i=1:numel(preferredOrder)
        preferredOrderNewStr{i}=[prefix,num2str(i),preferredOrder{i}];
    end



    for i=1:numel(preferredOrder)
        strList=regexprep(strList,...
        ['^',regexptranslate('escape',preferredOrder{i}),'$'],...
        preferredOrderNewStr{i});
    end

end
