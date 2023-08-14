function escString=escapeRuleCharacters(string)

















    p=inputParser;
    p.addRequired('string',@ischarorcellstr);
    p.parse(string);

    function b=ischarorcellstr(obj)
        b=ischar(obj)||iscellstr(obj);
    end

    if iscell(string)
        escString=cell(size(string));
        for i=1:numel(string)
            escString{i}=slexportprevious.utils.escapeRuleCharacters(string{i});
        end
        return;
    end


    escString=strrep(string,'&','&&');
    escString=strrep(escString,'>','&>');
    escString=strrep(escString,'<','&<');
    escString=strrep(escString,'|','&|');
    escString=strrep(escString,':','&:');
    escString=strrep(escString,'^','&^');
end
