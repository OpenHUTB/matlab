function applicationObj=createApplication(varargin)













    am=Advisor.Manager.getInstance();

    p=inputParser();
    p.addParameter('advisor','_modeladvisor_',@ischar);
    p.addParameter('useTempDir',false,@islogical);
    p.addParameter('token','',@ischar);
    p.parse(varargin{:});
    inputs=p.Results;

    createNewApp=true;



    newID=Advisor.Application.getID(inputs.advisor,'');


    if am.ApplicationObjMap.isKey(newID)
        applicationObj=am.ApplicationObjMap(newID);

        if applicationObj.UseTempDir~=inputs.useTempDir
            applicationObj.delete();
        else
            createNewApp=false;
        end
    end

    if createNewApp

        applicationObj=Advisor.Application(inputs.advisor,...
        inputs.useTempDir,inputs.token);

        am.ApplicationObjMap(newID)=applicationObj;

        addlistener(applicationObj,'Destroy',@Advisor.Manager.handleEvent);
        addlistener(applicationObj,'IdChanged',@Advisor.Manager.handleEvent);
    end


    am.getActiveApplicationObj(applicationObj);
end