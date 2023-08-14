

function isValid=checkString(argToCheck)

    isValid=(isstring(argToCheck)&&isscalar(argToCheck))||ischar(argToCheck);

