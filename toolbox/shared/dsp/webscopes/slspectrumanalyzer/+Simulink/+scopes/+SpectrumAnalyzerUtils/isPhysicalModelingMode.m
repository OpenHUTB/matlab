function[flag,varargout]=isPhysicalModelingMode(~)






    flag=false;
    product='rfblks';
    if dig.isProductInstalled('Simscape')&&builtin('license','checkout','Simscape')
        product='simscape';
    end
    if dig.isProductInstalled('DSP System Toolbox')&&builtin('license','checkout','Signal_Blocks')
        product='dsp';
    end
    if~isequal(product,'dsp')
        flag=true;
    end
    if nargout>1
        varargout{1}=product;
    end
end
