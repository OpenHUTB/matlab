


function designClasses=getCustomLayerDesigns(target)

    designClasses={};

    if isempty(strcmpi(target,{'cudnn','mkldnn','onednn'}))
        error('Unsupported Target');
    end

    packageRoot=['gpucoder.cnn.',target];
    expectedClassName='CustomLayerDesign';
    expectedClass=[char(packageRoot),'.',expectedClassName];
    pkg=meta.package.fromName(packageRoot);


    for i=1:numel(pkg.ClassList)
        metaClass=pkg.ClassList(i);
        if isCustomDesign(metaClass,expectedClass)
            designClasses{end+1}=metaClass;%#ok
        end
    end



end



function tf=isCustomDesign(metaClass,expectedClass)


    if~metaClass.Abstract
        metaSuperclass=metaClass.SuperclassList;
        superclasses={metaSuperclass.Name};
        tf=ismember(expectedClass,superclasses);
    else
        tf=false;
    end
end
