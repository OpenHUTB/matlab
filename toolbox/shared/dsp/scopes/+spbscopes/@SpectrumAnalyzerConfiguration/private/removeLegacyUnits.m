

function value=removeLegacyUnits(value)




    value=regexprep(value,',\s*(dBm|dBW|Watts|dB)(\/Hz)?','');

    value=regexprep(value,'\(\s*(dBm|dBW|Watts|dB)(\/Hz)?\s*\)','');

end
