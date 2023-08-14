function v=validBlockMask(~,slbh)




    v=true;
    if slbh>0
        mulKind=get_param(slbh,'Multiplication');
        if strcmpi(mulKind,'Matrix(K*u)')
            v=false;
        elseif strcmpi(mulKind,'Matrix(u*K)')
            v=false;
        elseif strcmpi(mulKind,'Matrix(K*u) (u vector)')
            v=false;
        end
    end
end