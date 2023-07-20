function identifier=p_create_aridentifier(str,maxShortNameLength,enforceUnique)















    assert(nargin>=2,'Expected maxShortNameLength');

    if nargin<3
        enforceUnique=0;
    end

    if enforceUnique==1

        randStr=i_checksum(num2str(rand(1),'%.32f'));
        str=[str,randStr];
    end



    str=i_convertToValidChars(str);

    if(length(str)>maxShortNameLength)
        cs=i_checksum(str);


        cs=cs(1:16);

        identifier=[str(1:maxShortNameLength-(1+length(cs))),'_',cs];
    else
        identifier=str;
    end

    identifier=i_remove_double_underscores(identifier);

    identifier=i_remove_trailing_underscores(identifier);

    function cs=i_checksum(in)








        narginchk(1,1);


        cs=Simulink.ModelReference.ProtectedModel.encrypt('SHA2',in,false);



        function varname=i_convertToValidChars(str)


            varname=str;


            varname=regexprep(varname,'^\s*+([^A-Za-z])','x$1','once');


            varname=regexprep(varname,'\s','_');


            illegalChars=unique(varname(regexp(varname,'[^A-Za-z_0-9]')));
            for illegalChar=illegalChars
                if illegalChar<=intmax('uint8')
                    width=2;
                else
                    width=4;
                end
                replace=['0x',dec2hex(illegalChar,width)];
                varname=strrep(varname,illegalChar,replace);
            end

            function identifier=i_remove_double_underscores(identifier)



                identifier=regexprep(identifier,'_+','_');

                function identifier=i_remove_trailing_underscores(identifier)



                    identifier=regexprep(identifier,'_$','');


