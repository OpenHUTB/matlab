function updateCodeContext(harnessOwner,harnessName,varargin)


    if slfeature('CodeContextHarness')==0
        DAStudio.error('Simulink:CodeContext:CodeContextFeatureNotOn');
    end

    [systemModel,harnessOwnerHandle]=Simulink.harness.internal.parseForSystemModel(harnessOwner);
    harnessStruct=Simulink.libcodegen.internal.getCodeContext(systemModel,harnessOwnerHandle,harnessName);
    if isempty(harnessStruct)
        DAStudio.error('Simulink:CodeContext:CodeContextNotFound',getfullname(harnessOwnerHandle),harnessName);
    end

    fieldsToUpdate={'Name','Description'};

    try
        if nargin<4
            DAStudio.error('Simulink:Harness:NotEnoughInputArgsSet')
        end



        if bdIsLibrary(systemModel)&&strcmp('on',get_param(systemModel,'Lock'))&&~harnessStruct.isOpen
            DAStudio.error('Simulink:CodeContext:CannotSetCodeContextWhenLibIsLocked',systemModel);
        end


        activeHarness=Simulink.harness.internal.getActiveHarness(systemModel);
        if harnessStruct.canBeOpened==false&&~isempty(activeHarness)...
            &&(activeHarness.ownerHandle~=harnessStruct.ownerHandle||~strcmp(activeHarness.name,harnessStruct.name))
            DAStudio.error('Simulink:Harness:CannotUpdateWhenATestingHarnessIsActive',harnessStruct.name);
        end


        p=inputParser;
        p.CaseSensitive=0;
        p.KeepUnmatched=0;
        p.PartialMatching=0;

        p.addParameter(fieldsToUpdate{1},harnessStruct.name,@(x)validateattributes(x,{'char'},{'nonempty'}));
        p.addParameter(fieldsToUpdate{2},harnessStruct.description,@(x)validateattributes(x,{'char'},{'real'}));

        p.parse(varargin{:});


        Simulink.harness.internal.ensureNoRepeatedParams(varargin);

        changeFields=setdiff(fieldsToUpdate,p.UsingDefaults);
        if isempty(changeFields)
            return;
        end

        harnessName=harnessStruct.name;
        newName=harnessStruct.name;
        newDescription=harnessStruct.description;
        for i=1:length(changeFields)
            switch changeFields{i}
            case 'Name'
                newHarnessName=p.Results.Name;
                if~isequal(harnessName,newHarnessName)
                    checkedName=Simulink.harness.internal.getUniqueName(systemModel,newHarnessName);
                    if~strcmp(checkedName,newHarnessName)
                        DAStudio.error('Simulink:CodeContext:CodeContextNameNotValid',newHarnessName);
                    end

                    newName=newHarnessName;
                    if~isvarname(newName)
                        DAStudio.error('Simulink:CodeContext:ContextNameNotValid',...
                        newName);
                    end

                    if length(newName)>58
                        DAStudio.error('Simulink:CodeContext:NameTooLong',newName);
                    end
                end

            case 'Description'
                newDescription=p.Results.Description;
            otherwise


            end
        end

        if~harnessStruct.isOpen||~strcmp(harnessStruct.name,harnessName)
            Simulink.harness.internal.checkFilesWritable(systemModel,harnessStruct,'set',true);
        end
    catch ME
        ME.throwAsCaller();
    end

    try
        Simulink.libcodegen.internal.updateContext(harnessStruct.model,harnessStruct.ownerHandle,harnessName,newName,...
        newDescription);
    catch ME
        Simulink.harness.internal.warn(ME);
    end


    Simulink.libcodegen.internal.refreshContextListDlg(harnessStruct.model);
end
