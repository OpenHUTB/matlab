function entries=findSystemObjects(folder,desFilter,relPackage)




    if nargin<3
        relPackage='';
        fullFolder=folder;
    else
        fullFolder=fullfile(folder,['+',strrep(relPackage,'.',[filesep,'+'])]);
    end



    if nargin<2
        desFilter=false;
    end


    entries={};
    wResults=what(fullFolder);
    if isempty(wResults)
        return;
    end
    candidates=[wResults.m;wResults.p;wResults.classes];

    for k=1:numel(candidates)
        [~,candidate]=fileparts(candidates{k});


        if strcmp(candidate,'MATLAB_System')
            continue;
        end

        if~isempty(relPackage)
            candidate=[relPackage,'.',candidate];%#ok<*AGROW>
        end
        try %#ok<TRYNC> Use try in case there is an error loading class
            if matlab.system.display.isSystem(candidate,desFilter)
                entries{end+1}=candidate;
            end
        end
    end

    packages=wResults.packages;
    for k=1:numel(packages)
        if isempty(relPackage)
            childPackage=packages{k};
        else
            childPackage=[relPackage,'.',packages{k}];
        end
        entries=[entries,matlab.system.ui.findSystemObjects(folder,desFilter,childPackage)];
    end

    entries=unique(entries);
end
