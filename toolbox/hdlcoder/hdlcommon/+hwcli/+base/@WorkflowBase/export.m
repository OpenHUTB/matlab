function export(obj,varargin)




    p=inputParser;
    p.addParameter('Filename','');
    p.addParameter('Overwrite',false);
    p.addParameter('Comments',true);
    p.addParameter('Headers',true);
    p.addParameter('DUT','');
    p.addParameter('DownstreamDriver','');


    p.addParameter('Warn',true);
    p.addParameter('ProgramTargetDevice',false);

    p.parse(varargin{:});
    inputArgs=p.Results;




    if(~isempty(inputArgs.Filename))
        if(~ischar(inputArgs.Filename))
            error(message('hdlcoder:workflow:ParamValueNotString','Filename'));
        end
        [~,~,ext]=fileparts(inputArgs.Filename);
        if(isempty(ext)||~strcmp(ext,'.m'))
            error(message('hdlcoder:workflow:FileMustBeMFile',inputArgs.Filename));
        end
    end

    if(~islogical(inputArgs.Overwrite))
        error(message('hdlcoder:workflow:InvalidLogical','Overwrite'));
    end

    if(exist(inputArgs.Filename,'file')==2)
        if(~inputArgs.Overwrite)
            error(message('hdlcoder:workflow:ErrorOverwriteFile',inputArgs.Filename));
        elseif(inputArgs.Warn)
            warning(message('hdlcoder:engine:WarnOverwriteFile',inputArgs.Filename));
        end
    end

    if(~islogical(inputArgs.Comments))
        error(message('hdlcoder:workflow:InvalidLogical','Comments'));
    end

    if(~islogical(inputArgs.Headers))
        error(message('hdlcoder:workflow:InvalidLogical','Headers'));
    end

    if(~ischar(inputArgs.DUT))
        error(message('hdlcoder:workflow:ParamValueNotString','DUT'));
    end

    if(~islogical(inputArgs.ProgramTargetDevice))
        error(message('hdlcoder:workflow:InvalidLogical','ProgramTargetDevice'));
    end


    isModel=~isempty(inputArgs.DUT);
    isFile=~isempty(inputArgs.Filename);
    isCustom=inputArgs.ProgramTargetDevice;

    fid=1;


    obj.validate('Warn',false);







    if(isModel&&~isCustom)
        if(isFile)
            try
                hdlsaveparams(inputArgs.DUT,inputArgs.Filename,inputArgs.Overwrite,false,inputArgs.Comments,true);
            catch me
                if(strcmp(me.identifier,'hdlcoder:engine:ErrorOverwriteFile'))
                    error(message('hdlcoder:workflow:ErrorOverwriteFile',inputArgs.Filename));
                else
                    rethrow(me)
                end
            end
            modelText=fileread(inputArgs.Filename);
            fid=fopen(inputArgs.Filename,'w+');

            if(inputArgs.Headers)
                exportHeader(fid,inputArgs);
                fprintf(fid,'%%%% Load the Model\n');
            end

            fprintf(fid,'load_system(''%s'');\n',bdroot(inputArgs.DUT));

            if(inputArgs.Comments)
                if(inputArgs.Headers)
                    fprintf(fid,'\n%%%% Restore the Model to default HDL parameters\n');
                end
                fprintf(fid,'%%hdlrestoreparams(%s);\n',cleanBlockNameForQuotedDisp(inputArgs.DUT));
            end
            if(inputArgs.Headers)
                fprintf(fid,'\n%%%% Model HDL Parameters\n');
            end

            fprintf(fid,'%s',modelText);

        else
            if(inputArgs.Headers)
                exportHeader(fid,inputArgs);
                fprintf(fid,'%%%% Load the Model\n');
            end
            fprintf(fid,'load_system(''%s'');\n',bdroot(inputArgs.DUT));
            if(inputArgs.Comments)
                if(inputArgs.Headers)
                    fprintf(fid,'\n%%%% Restore the Model to default HDL parameters\n');
                end
                fprintf(fid,'%%hdlrestoreparams(%s);\n',cleanBlockNameForQuotedDisp(inputArgs.DUT));
            end
            if(inputArgs.Headers)
                fprintf(fid,'\n%%%% Model HDL Parameters\n');
            end
            hdlsaveparams(inputArgs.DUT,[],[],false,inputArgs.Comments,true);

        end
    else
        if(isFile)
            fid=fopen(inputArgs.Filename,'w+');
        end
        if(inputArgs.Headers)
            exportHeader(fid,inputArgs);
        end
    end


    if fid<0
        error(message('hdlcoder:engine:CouldNotOpenFile',inputArgs.Filename));
    end





    if inputArgs.ProgramTargetDevice
        obj.clearAllTasks;
        obj.RunTaskProgramTargetDevice=true;

        m=cleanBlockNameForQuotedDisp(bdroot(inputArgs.DUT));
        if(inputArgs.Comments)
            fprintf(fid,'%% Load the Model\n');
        end
        fprintf(fid,'load_system(%s);\n',m);

        if(inputArgs.Comments)
            fprintf(fid,'\n%% Model HDL Parameters\n');
        end

        paramList={'HDLSubsystem','ReferenceDesign','TargetPlatform'};
        for i=1:length(paramList)
            param=paramList{i};
            val=hdlget_param(bdroot(inputArgs.DUT),param);
            fprintf(fid,'hdlset_param(%s,''%s'',''%s'');\n',m,param,val);
        end

        fprintf(fid,'\n');
    end





    if(inputArgs.Headers)
        fprintf(fid,'\n%%%% Workflow Configuration Settings\n');
    end
    if(inputArgs.Comments)
        fprintf(fid,'%% Construct the Workflow Configuration Object with default settings\n');
    end

    fprintf(fid,'hWC = hdlcoder.WorkflowConfig(''SynthesisTool'',''%s'',''TargetWorkflow'',''%s'');\n',obj.SynthesisTool,obj.TargetWorkflow);

    if(inputArgs.Comments)
        fprintf(fid,'\n%% Specify the top level project directory\n');
    end
    properties=obj.Properties('TopLevelTasks');

    hDI=inputArgs.DownstreamDriver;
    for j=1:length(properties)
        property=properties{j};


        if strcmp(property,'AllowUnsupportedToolVersion')
            if isempty(hDI)
                continue;
            elseif hDI.hAvailableToolList.isToolVersionSupported(obj.SynthesisTool)
                continue;
            end
        end

        exportProperty(fid,obj,property);
    end






    if(inputArgs.Comments)
        fprintf(fid,'\n%% Set Workflow tasks to run\n');
    end

    for i=1:length(obj.Tasks)
        task=obj.Tasks{i};
        exportProperty(fid,obj,task);
    end





    for i=1:length(obj.Tasks)
        task=obj.Tasks{i};
        if(~isCustom||(isCustom&&obj.(task)))
            if(isKey(obj.Properties,task))
                if(inputArgs.Comments)
                    exportComment(fid,task);
                end
                properties=obj.Properties(task);
                for j=1:length(properties)
                    property=properties{j};
                    exportProperty(fid,obj,property);
                end
            end
        end
    end







    if(inputArgs.Comments)
        fprintf(fid,'\n%% Validate the Workflow Configuration Object\n');
    end
    fprintf(fid,'hWC.validate;\n');


    if(isModel)
        if(inputArgs.Headers)
            fprintf(fid,'\n%%%% Run the workflow\n');
        elseif(inputArgs.Comments)
            fprintf(fid,'\n%% Run the workflow\n');
        end
        fprintf(fid,'hdlcoder.runWorkflow(%s, hWC);\n',cleanBlockNameForQuotedDisp(inputArgs.DUT));
    end


    if(fid~=1)
        fclose(fid);
    end

end





function exportHeader(fid,inputArgs)

    prodInfo=ver('MATLAB');

    fprintf(fid,'%%--------------------------------------------------------------------------\n');
    fprintf(fid,'%% HDL Workflow Script\n');
    fprintf(fid,'%% Generated with %s %s %s at %s\n',prodInfo.Name,prodInfo.Version,prodInfo.Release,datestr(now,'HH:MM:SS on dd/mm/yyyy'));
    fprintf(fid,'%% This script was generated using the following parameter values:\n');
    fprintf(fid,'%%     Filename  : ''%s''\n',inputArgs.Filename);
    fprintf(fid,'%%     Overwrite : %s\n',dispBoolean(inputArgs.Overwrite));
    fprintf(fid,'%%     Comments  : %s\n',dispBoolean(inputArgs.Comments));
    fprintf(fid,'%%     Headers   : %s\n',dispBoolean(inputArgs.Headers));
    fprintf(fid,'%%     DUT       : %s\n',cleanBlockNameForQuotedDisp(inputArgs.DUT));
    fprintf(fid,'%% To view changes after modifying the workflow, run the following command:\n');
    fprintf(fid,'%% >> hWC.export(''DUT'',%s);\n',cleanBlockNameForQuotedDisp(inputArgs.DUT));
    fprintf(fid,'%%--------------------------------------------------------------------------\n\n');

end

function val=dispBoolean(boolean)

    if(boolean)
        val='true';
    else
        val='false';
    end
end

function exportComment(fid,task)

    fprintf(fid,'\n%% Set properties related to ''%s'' Task\n',task);

end


function exportProperty(fid,obj,property)


    if obj.HiddenProperties.isKey(property)
        return;
    end

    switch(class(obj.(property)))

    case 'logical'
        fmt='hWC.%s = %s;\n';
        value=dispBoolean(obj.(property));

    case 'char'
        fmt='hWC.%s = ''%s'';\n';
        value=obj.(property);

    case 'double'
        fmt='hWC.%s =  %0.0f;\n';
        value=obj.(property);

    otherwise
        fmt='hWC.%s = %s;\n';
        value=[class(obj.(property)),'.',char(obj.(property))];

    end

    fprintf(fid,fmt,property,value);
end



