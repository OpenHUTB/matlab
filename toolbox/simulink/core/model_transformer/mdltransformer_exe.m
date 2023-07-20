function mdltransformer_exe(system,varargin)

    cleanup=false;

    if nargin==2
        if strcmpi(varargin{1},'Cleanup')
            cleanup=true;
        elseif~isempty(varargin{1})
            error('Illegal second argument');
        end
    end

    if strcmpi(system,'help')
        return;
    end

    if ishandle(system)
        system=getfullname(system);
    end

    [inputModel,dontcare]=strtok(system,'/');

    if cleanup
        am=Advisor.Manager.getInstance;
        applicationObj=am.getApplication(...
        'advisor','com.mathworks.Simulink.MdlTransformer.MdlTransformer',...
        'Root',system,'Legacy',true,'MultiMode',false,'token','MWAdvi3orAPICa11');
        if isobject(applicationObj)
            mdladvObj=applicationObj.getRootMAObj();
            m2m_obj=mdladvObj.UserData;
            mdladvObj.UserData='';
            if isa(m2m_obj,'slEnginePir.m2m')||isa(m2m_obj,'slEnginePir.model2model')
                clear m2m_obj;
            end
        else
            try
                feval(system,[],[],[],'term');
            catch
            end
        end
        return;
    else
        utilMdlTransformerStart(system);
    end
