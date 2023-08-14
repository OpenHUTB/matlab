function list=supportedPCCompilers(vendor)





    if~ispc
        list={};
        return;
    end

    if nargin==0
        vendor='all';
    end



    msCompilers={...
    'msvc170','msvcpp170',...
    'msvc160','msvcpp160',...
    'msvc150','msvcpp150',...
    'msvc140','msvcpp140',...
    'msvc120','msvcpp120',...
    'msvc110','msvcpp110',...
    'msvc100','msvcpp100',...
    'mssdk71','mssdk71cpp',...
    };

    mingwCompilers={'mingw64','mingw64-g++','mingw64sdk10+'};

    lccCompilers={'lcc'};

    switch(vendor)
    case 'microsoft'
        list=msCompilers;
    case 'mingw'
        list=mingwCompilers;
    case 'lcc'
        list=lccCompilers;
    case 'all'
        list=[lccCompilers,msCompilers,mingwCompilers];
    end
