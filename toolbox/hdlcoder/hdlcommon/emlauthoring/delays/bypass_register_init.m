%#codegen
function y=bypass_register_init(ic,bypass_size)






    coder.allowpcode('plain')
    coder.inline('always')
    eml_prefer_const(ic,bypass_size);

    if~isenum(ic)
        y=zeros(bypass_size,'like',ic);
    else
        e_list=enumeration(ic(1));
        y=repmat(e_list(1),bypass_size);
    end

