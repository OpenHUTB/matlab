%#codegen
function y=hdleml_lookup(u,input_vals,table_data)




    coder.allowpcode('plain')
    eml_prefer_const(input_vals,table_data);


    y=int8(0);

    for ii=coder.unroll(1:numel(input_vals))
        if u==input_vals(ii)
            y(:)=table_data(ii);
            break;
        end
    end
