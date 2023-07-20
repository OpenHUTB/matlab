function style=styleModel(slModel,enable)






    hMdl=get_param(slModel,'Handle');

    if nargin==1
        style=builtin('_simscape_style_model',hMdl);
    else
        style=builtin('_simscape_style_model',hMdl,enable);
    end


end
