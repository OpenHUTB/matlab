
function exportCodeContext(owner,name,varargin)

    if slfeature('CodeContextHarness')==0
        DAStudio.error('Simulink:CodeContext:CodeContextFeatureNotOn');
    end

    owner=convertStringsToChars(owner);
    name=convertStringsToChars(name);

    [systemModel,harnessOwnerHandle]=Simulink.harness.internal.parseForSystemModel(owner);
    harnessStruct=Simulink.libcodegen.internal.getCodeContext(systemModel,harnessOwnerHandle,name);
    if isempty(harnessStruct)
        DAStudio.error('Simulink:CodeContext:CodeContextNotFound',getfullname(harnessOwnerHandle),name);
    end

    try
        Simulink.harness.internal.checkFilesWritable(systemModel,harnessStruct,'export',true);
    catch ME
        mainError=MSLException([],message('Simulink:CodeContext:CodeContextExportError',name));
        mainError.addCause(ME);
        mainError.throwAsCaller();
    end

    name=harnessStruct.name;

    newName='';
    if nargin==4
        assert(strcmpi(varargin{1},'name'),...
        'Additional arguments to Simulink.harness.export must be name/value pair with new name');
        newName=varargin{2};
        if~ischar(newName)
            DAStudio.error('Simulink:Harness:InvalidName',name);
        end
    elseif nargin~=2
        DAStudio.error('Simulink:Harness:NotEnoughInputArgs')
    end


    try
        Simulink.libcodegen.internal.exportContext(systemModel,name,newName,...
        harnessOwnerHandle);
    catch me

        close_system(name,0);
        me.throwAsCaller;

    end
end
