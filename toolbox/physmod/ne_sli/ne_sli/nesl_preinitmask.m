function nesl_preinitmask(block)








    lib=bdroot(get_param(block,'ReferenceBlock'));

    id='physmod:ne_sli:nesl_preinitmask:OutOfDate';
    msg=pm_message(id,lib);

    e=MSLException(get_param(block,'Handle'),id,msg);
    e.throw;

end