function[a,b,c]=convert(a,b,c)


    if ischar(a)
        a=eval(a);
        b=eval(b);
        c=eval(c);
    elseif isempty(a)&&isempty(c)
        a='[  ]';
        b='[  ]';
        c='{  }';
    else
        a=sprintf('[ %s]',sprintf('%d ',a));
        b=sprintf('[ %s]',sprintf('%d ',b));
        c=sprintf('{ %s}',sprintf('''%s'' ',c{:}));
    end
end
