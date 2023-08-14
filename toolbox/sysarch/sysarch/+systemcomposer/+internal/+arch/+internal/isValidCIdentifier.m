function isValid=isValidCIdentifier(ident)





    allowedFirst='ABCDEFGHIJKLMNOPQRSTUVWXYZ_';
    allowedRest=[allowedFirst,'0123456789'];
    isValid=contains(allowedFirst,upper(ident(1)))&&...
    all(arrayfun(@(c)contains(allowedRest,upper(c)),ident));
end
