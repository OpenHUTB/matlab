function covScopeChangeCallback(this,value)

    switch value
    case 0
    case 1

        this.CovIncludeTopModel='off';

        this.CovPath='/';
    case 2

        this.CovModelRefEnable='off';
    end
