function v=validBlockMask(~,slbh)




    v=false;
    if slbh>0
        mulKind=get_param(slbh,'Multiplication');
        if strcmpi(mulKind,'Matrix(*)')
            v=true;
        end
    end
end
