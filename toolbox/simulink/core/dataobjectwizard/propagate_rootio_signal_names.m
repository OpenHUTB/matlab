function[status,errMsg]=propagate_rootio_signal_names(modelName)















    notNamed={};
    status=1;
    errMsg='';

    try
        if isempty(find_system('type','block_diagram','name',modelName))
            open_system(modelName);
        end

        [fpath,modelName]=fileparts(modelName);


        ioports=find_system(modelName,'SearchDepth',1,'regexp','on','blocktype','port');
        alldata=find_all_signals_params(modelName);

        for i=1:length(ioports)
            bName=get_param(ioports{i},'Name');
            hPort=get_param(ioports{i},'Handle');
            hLine=get_param(ioports{i},'LineHandles');
            pType=get_param(ioports{i},'BlockType');

            if strcmp(pType,'Inport')

                lObj=get_param(hLine.Outport,'Object');
            elseif strcmp(pType,'Outport')

                lObj=get_param(hLine.Inport,'Object');
            else

                continue;
            end

            if isempty(lObj.Name)
                cKeyword={'asm','auto','break','case','char','const','continue',...
                'default','do','double','else','entry','enum','extern',...
                'float','for','fortran','goto','if','int','long',...
                'register','return','short','signed','sizeof','static',...
                'struct','switch','typedef','union','unsigned','void',...
                'volatile','while'};
                if iscvar(bName)&&~ismember(bName,cKeyword)&&...
                    ~ismember(bName,alldata)&&(~isSDO(modelName,bName))

                    lObj.Name=bName;
                else
                    notNamed{end+1}=bName;
                end
            end
        end
        if~isempty(notNamed)
            status=-1;
            if length(notNamed)==1
                msg=sprintf('''%s''',notNamed{1});
            else
                msg=sprintf('''%s'', ',notNamed{1});
                for i=2:length(notNamed)
                    if i<length(notNamed)
                        msg=sprintf('%s''%s'', ',msg,notNamed{i});
                    else
                        msg=sprintf('%s''%s''.',msg,notNamed{i});
                    end
                end
            end
            errMsg=DAStudio.message('Simulink:dow:PropagateRootIOSignalError',msg);
        end
    catch merr
        status=0;
        errMsg=merr.message;
    end


    function alldata=find_all_signals_params(modelName)


        alldata={};




        ports=find_system(modelName,'FollowLinks','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','all',...
        'Regexp','on',...
        'FindAll','on',...
        'Type','port',...
        'PortType','outport',...
        'MustResolveToSignalObject','off',...
        'Name','\S+');

        hPorts=get_param(ports,'Object');
        for i=1:length(hPorts)
            alldata{end+1}=hPorts{i}.Name;
        end




        blks=find_system(modelName,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','all',...
        'Type','block',...
        'StateMustResolveToSignalObject','off');

        hBlks=get_param(blks,'Object');
        for i=1:length(hBlks)

            if strcmp(hBlks{i}.BlockType,'DataStoreMemory')
                alldata{end+1}=strtrim(hBlks{i}.DataStoreName);
            else
                alldata{end+1}=strtrim(hBlks{i}.StateIdentifier);
            end
        end


        refWSVars=get_param(modelName,'ReferencedWSVars');
        for i=1:length(refWSVars)
            alldata{end+1}=refWSVars(i).Name;
        end

        alldata=unique(alldata);


        function isSDO=isSDO(modelName,varName)



            isSDO=false;
            if existsInGlobalScope(modelName,varName)
                isSDO=evalinGlobalScope(modelName,['isa(',varName,',''Simulink.Data'')';]);
            end
