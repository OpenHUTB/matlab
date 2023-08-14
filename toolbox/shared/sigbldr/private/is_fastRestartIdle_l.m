function isFastRestartIdle=is_fastRestartIdle_l(UD)




    isFastRestartIdle=isstruct(UD)&isfield(UD,'current')&isfield(UD.current,'state')&strcmp(UD.current.state,'ICED_FS');
