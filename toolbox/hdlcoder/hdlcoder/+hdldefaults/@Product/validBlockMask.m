function v=validBlockMask(~,slbh)




    v=true;
    if slbh>0
        mulKind=get_param(slbh,'Multiplication');
        if strcmpi(mulKind,'Matrix(*)')
            v=false;
        end
    end
end
