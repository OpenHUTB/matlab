function param=convertUnits(param,orig_unit,final_unit)





    C=simscape.Value(1,orig_unit)/simscape.Value(1,final_unit);
    cf=value(C,'1');


    if cf~=1
        param=[num2str(cf),'*(',param,')'];
    end

end