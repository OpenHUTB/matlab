function html_file=slvnvhelp(~)





    blkname=get_param(gcb,'MaskType');

    html_file=[docroot,'/slrequirements/ref/',help_name(blkname)];

    return

    function y=help_name(x)
        if isempty(x),x='default';end
        y=lower(x);
        y(~isvalidchar(y))='';
        y=[y,'.html'];
        return

        function y=isvalidchar(x)
            y=isletter(x)|isdigit(x)|isunder(x);
            return

            function y=isdigit(x)
                y=(x>='0'&x<='9');
                return

                function y=isunder(x)
                    y=(x=='_');
                    return