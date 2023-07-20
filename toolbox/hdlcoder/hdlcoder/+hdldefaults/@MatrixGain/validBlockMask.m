function v=validBlockMask(~,slbh)




    v=false;
    if slbh>0
        mulKind=get_param(slbh,'Multiplication');
        if strcmpi(mulKind,'Matrix(K*u)')
            v=true;
        elseif strcmpi(mulKind,'Matrix(u*K)')
            v=true;
        elseif strcmpi(mulKind,'Matrix(K*u) (u vector)')
            v=true;
        end
    end
end
