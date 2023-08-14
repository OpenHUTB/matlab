function setCallbacks(model,paramValue)


    topPOU=plc_find_system(model,...
    'LookUnderMasks','on',...
    'FirstResultOnly','on',...
    'regexp','on',...
    'PLCBlockType','^PLCController$|^AOIRunner$');


    allSubSystems=plc_find_system(model,...
    'LookUnderMasks','on',...
    'BlockType','SubSystem');

    if strcmp(paramValue,'on')

        set_param(topPOU{1},'Permissions','ReadWrite');
        plcladderoption(model,'SLDV','off');
        cellfun(@(x)uncommentCallback(x),allSubSystems);
    elseif strcmp(paramValue,'off')

        cellfun(@(x)commentCallback(x),allSubSystems);









        plcladderoption(model,'SLDV','on');

        set_param(topPOU{1},'Permissions','ReadOnly');
    end
end

function commentCallback(ssName)




    warning('off','Simulink:Engine:SaveWithDisabledLinks_Warning');
    if slreportgen.utils.isMaskedSystem(ssName)
        mask=Simulink.Mask.get(ssName);
        if~isempty(mask.Initialization)
            callback=splitlines(mask.Initialization);
            if strcmp(get_param(ssName,'LinkStatus'),'resolved')
                set_param(ssName,'LinkStatus','inactive');
            end
            mask.Initialization=[sprintf('%% %s\n',callback{1:end-1}),'% ',callback{end}];
        end
    end
end

function uncommentCallback(ssName)




    if slreportgen.utils.isMaskedSystem(ssName)
        mask=Simulink.Mask.get(ssName);
        if~isempty(mask.Initialization)
            mask.Initialization=strrep(mask.Initialization,'% ','');
        end
        if strcmp(get_param(ssName,'LinkStatus'),'inactive')
            set_param(ssName,'LinkStatus','restore');
        end
    end
    warning('on','Simulink:Engine:SaveWithDisabledLinks_Warning');
end