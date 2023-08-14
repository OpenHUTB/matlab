function sysName=cmd_check_for_open_models(sysName,conflictMode,showUI)%#ok<INUSD>



    try
        modelH=get_param(sysName,'Handle');
    catch Mex %#ok<NASGU>
        modelH=-1;
    end

    if modelH==-1
        return;
    end

    switch(conflictMode)
    case 'on',
        sysName=unique_model_name_using_numbers(sysName);
    case 'off'
        Sldv.close_system(modelH,0,'CloseReferencedModels',0);
    end

    function sysName=unique_model_name_using_numbers(name)

        existSys=find_system('type','block_diagram');
        if(any(name(end)=='0123456789.'))
            baseName=strtok(name,'0123456789.');
        else
            baseName=name;
        end
        charIdx=length(baseName)+1;

        number=1;

        if~isempty(existSys)
            for idx=1:length(existSys)
                cn=existSys{idx};
                suffix=cn(charIdx:end);
                numValue=str2double(suffix);
                if~isempty(numValue)&&numValue>=number
                    number=numValue+1;
                end
            end
        end

        sysName=[baseName,num2str(number)];
        if exist(sysName)%#ok<EXIST>

            rint=ceil(52*rand(1,3))+65;
            rint(rint>90)=rint(rint>90)+6;
            suffix=char(rint);
            sysName=[sysName,'_',suffix];
        end