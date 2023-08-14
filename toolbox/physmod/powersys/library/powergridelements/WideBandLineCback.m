function WideBandLineCback(block,Action)





    switch Action
    case 'browse'
        [FileName,PathName]=uigetfile('*.mat','MAT file','');
        switch FileName
        case 0
        otherwise
            set_param(block,'WBfile',fullfile(PathName,FileName));
        end
    case 'edit'
        FileName=get_param(block,'WBfile');
        if~exist(FileName,'file')

            SPSroot=which('powersysdomain');
            if exist(fullfile(SPSroot(1:end-16),'LineParameters',FileName),'file')
                load(fullfile(SPSroot(1:end-16),'LineParameters',FileName));
            elseif exist(fullfile(SPSroot(1:end-16),'CableParameters',FileName),'file')
                load(fullfile(SPSroot(1:end-16),'CableParameters',FileName));
            else
                Erreur.message='Undefined MAT file.';
                Erreur.identifier='SpecializedPowerSystems:FrequencyDependentLineBlock:InvalidMATfile';
                psberror(Erreur.message,Erreur.identifier);
                return
            end
        else
            load(FileName);
        end
        if isfield(DATA,'configuration')
            powerCableParameters(FileName);
        else
            powerLineParameters(FileName);
        end
    end