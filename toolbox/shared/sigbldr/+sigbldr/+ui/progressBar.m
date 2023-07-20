function[status,output,error]=progressBar(action,arg1,arg2)















    persistent pb;
    mlock;
    drawnow;
    status=0;
    output='';
    error='';

    switch action
    case 'create'
        if~isempty(pb)
            sigbldr.ui.progressBar('destroy');
        end
        if nargin<4

            title=DAStudio.message('Sigbldr:sigbldr:PBTitle');
        end
        pb=i_create(title,arg1,arg2);

    case 'update'
        if isempty(pb)
            sigbldr.ui.progressBar('create',[],arg2);
        end
        i_ShowIfNotShown(pb);


        [status,error]=i_monitorProcess(pb,arg1,0);

    case 'activateCancel'
        if isempty(pb)
            sigbldr.ui.progressBar('create',[],arg2);
        end
        i_ShowIfNotShown(pb);

    case 'fireProcess'
        if isempty(pb)
            sigbldr.ui.progressBar('create',[],arg2);
        end



        i_ShowIfNotShown(pb);

    case 'monitorProcess'
        i_ShowIfNotShown(pb);
        [status,error]=i_monitorProcess(pb,arg1,arg2);

    case 'destroy'
        if~isempty(pb)
            pb.delete;
            pb=[];
        end
    case 'hide'
        if~isempty(pb)
            pb.Visible='off';
        end

    case 'show'
        if~isempty(pb)
            pb.Visible='on';
        end

    case 'getstring'


        if~isempty(pb)
            output=pb.get("Children").Title.String;
        end

    otherwise
        DAStudio.error('Sigbldr:import:PBNoAction');
    end

end

function pb=i_create(title,~,~)



    initialStr=DAStudio.message('Sigbldr:import:PBPleaseWait');
    pb=waitbar(0,initialStr,'Name',title,'Tag','SBImportWaitBar',...
    'CreateCancelBtn','setappdata(gcbf,''Canceling'',1)');

    setappdata(pb,'Canceling',0);

end

function[status,error]=i_monitorProcess(pb,progressMessage,progress)
    error=[];
    status=1;

    try
        drawnow;
        if getappdata(pb,'Canceling')
            status=-1;
        else
            waitbar(progress,pb,progressMessage);
        end
    catch ME
        status=0;
        error=ME.message;
    end
end

function i_ShowIfNotShown(pb)
    if(pb.Visible=='off')
        pb.Visible='on';
    end
end



