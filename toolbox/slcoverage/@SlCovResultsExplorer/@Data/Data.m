function obj=Data(main,impl)





    obj=feval(mfilename('class'));
    obj.m_impl=impl;
    obj.m_main=main;
