function v=validBlockMask(~,slbh)




    v=true;
    if slbh>0
        inputsType=get_param(slbh,'Inputs');
        multiplyType=get_param(slbh,'Multiplication');




        if~((strcmpi(inputsType,'*/')...
            ||strcmpi(inputsType,'/*')...
            ||strcmpi(inputsType,'/'))...
            &&strcmpi(multiplyType,'Element-wise(.*)'))
            v=false;
        end
    end
end
