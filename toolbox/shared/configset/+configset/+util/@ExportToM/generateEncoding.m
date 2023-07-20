function generateEncoding(obj)



    encoding_orig='UTF-8';

    obj.buffer{end+1}=['% ',message('Simulink:tools:MFileOriginalEncoding').getString,': ',encoding_orig];
