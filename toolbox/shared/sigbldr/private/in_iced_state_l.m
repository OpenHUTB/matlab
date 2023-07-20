function isIced=in_iced_state_l(UD)




    isIced=isstruct(UD)&isfield(UD,'current')&isfield(UD.current,'state')&strcmp(UD.current.state,'ICED');