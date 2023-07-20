function translation=msg(~,key,varargin)



    id=['RptgenSL:csl_data_dictionary:',key];
    translation=getString(message(id,varargin{:}));
