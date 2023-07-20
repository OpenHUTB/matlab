








function applicationObj=getApplication(varargin)








    p=inputParser();
    p.addParameter('id','',@ischar);
    p.addParameter('root','',@ischar);
    p.addParameter('rootType',Advisor.component.Types.Model,...
    @(x)(isa(x,'Advisor.component.Types')));
    p.addParameter('advisor','_modeladvisor_',@ischar);
    p.addParameter('multiMode',true,@islogical);
    p.addParameter('legacy',false,@islogical);
    p.addParameter('useTempDir',false,@islogical);
    p.addParameter('token','',@ischar);
    p.parse(varargin{:});
    in=p.Results;

    Advisor.Manager.checkLicense(in.token);

    am=Advisor.Manager.getInstance();

    if~isempty(in.id)&&am.ApplicationObjMap.isKey(in.id)

        applicationObj=am.ApplicationObjMap(in.id);

    elseif~isempty(in.root)


        id=Advisor.Application.getID(in.advisor,in.root);

        if am.ApplicationObjMap.isKey(id)
            applicationObj=am.ApplicationObjMap(id);


            if(applicationObj.MultiMode==in.multiMode)&&...
                (applicationObj.LegacyMode==in.legacy)&&...
                (applicationObj.UseTempDir==in.useTempDir)


                am.getActiveApplicationObj(applicationObj);
            else
                applicationObj=[];
            end
        else
            applicationObj=[];
        end
    else
        applicationObj=[];
    end
end