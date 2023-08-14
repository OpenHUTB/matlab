function translation=msg(~,key,varargin)



    id=['RptgenSL:csl_data_dict_loop:',key];
    translation=getString(message(id,varargin{:}));
end
