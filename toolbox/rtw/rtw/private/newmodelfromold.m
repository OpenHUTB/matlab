function newModelName=newmodelfromold(modelName)





    newModelNameHdl=new_system('','Model');
    newModelName=get_param(newModelNameHdl,'Name');

    o=get_param(modelName,'ObjectParameters');
    params=fieldnames(o);

    keep=false(size(params));

    for i=1:length(params)
        param=params{i};
        attribs=o.(param).Attributes;
        attribLength=length(attribs);
        neversave=false;
        if(attribLength>1)
            neversave=strcmp(attribs{2},'never-save');
        end


        if~neversave&&strcmp(attribs{1},'read-write')&&...
            ~strncmp(param,'ExtMode',7)

            keep(i)=true;
        end

    end
    readwriteparams=params(keep);

    params2ignore={
'ConfigurationManager'
'Created'
'Creator'
'Description'
'LastModifiedBy'
'LastModifiedDate'
'Location'
'ModelBrowserWidth'
'ModelVersionFormat'
'ModifiedByFormat'
'ModifiedComment'
'ModifiedDateFormat'
'ModifiedHistory'
'Name'
'Open'
'RTWMakeCommand'
'RTWOptions'
'RTWSystemTargetFile'
'RTWTemplateMakefile'
'ReportName'
'SimulationMode'
'Tag'
'UpdateHistory'
    };


    userParams=get_param(modelName,'UserBdParams');
    userParams=strread(userParams,'%s','delimiter',';');
    params2ignore=[params2ignore(:);userParams(:)];


    params2set=setdiff(readwriteparams,params2ignore);


    for i=1:length(params2set)
        param=params2set{i};
        set_param(newModelName,param,get_param(modelName,param));
    end



