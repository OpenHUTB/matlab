function tfsensok=senscsverify(code,rawcodecells)






















    tfsensok=true;


    T=mtree(code);



    errs=mtfind(T,'Kind','ERR');
    if~isempty(errs)






        tfsensok=false;
        return;
    end



    okkinds=localGetKinds('ok');
    oknodes=mtfind(T,'Kind',okkinds);
    badnodes=T-oknodes;

    if~isempty(badnodes)
        localThrowWarnsForBadNodes(badnodes,rawcodecells);
        tfsensok=false;
    end





    allcalls=mtfind(T,'Kind','CALL');
    okcalls=mtfind(allcalls,'Left.String',localGetCalls('ok'));
    badcalls=mtfind(allcalls,'Left.String',localGetCalls('bad'));
    warncalls=allcalls-okcalls-badcalls;


    if~isempty(badcalls)
        localThrowWarnsForBadCalls(badcalls,true);


        tfsensok=false;
    end


    if~isempty(warncalls)
        localThrowWarnsForBadCalls(warncalls,false);


    end


    numlits=mtfind(T,'Kind',{'DOUBLE';'INT'});
    numstrs=strings(numlits);
    hasij=regexp(numstrs,'[ij]','once');
    hasij=cellfun(@(x)~isempty(x),hasij);

    if any(hasij)
        msgObj=message('SimBiology:senscsverify:iOrJInNumericLiteral');
        privatemessagecalls('addwarning',...
        {getString(msgObj),...
        msgObj.Identifier,...
        'ODE Compilation',...
        []});


        tfsensok=false;
    end



    function kinds=localGetKinds(arg)






        switch arg
        case 'ok'






            kinds={...
            'PLUS','UPLUS','MINUS','UMINUS','MUL','DOTMUL','DOTEXP'...
            ,'DOTLDIV','DOTDIV'...
            ,'DOT'...
            ,'DIV','EXP','LDIV'...
            ,'LT','GT','LE','GE'...
            ,'DOTTRANS'...
            ,'DOUBLE','INT','CHARVECTOR','BINARY','HEX'...
            ,'LB','ROW','PARENS'...
            ,'EXPR'...
            ,'SUBSCR'...
            ,'NAMEVALUE','FIELD'...
            ,'ID','CALL'}';

        case 'bad'
            kinds=struct('TRANS','complex transpose operator ''',...
            'COLON','colon operator '':''',...
            'EQ','equals operator ''==''',...
            'NE','not equals operator ''~=''',...
            'AND','logical operator ''&''',...
            'ANDAND','logical operator ''&&''',...
            'OR','logical operator ''|''',...
            'OROR','logical operator ''||''',...
            'NOT','logical operator ''~''');




















        otherwise

            error(message('SimBiology:Internal:InternalError'));
        end



        function calls=localGetCalls(arg)





            switch arg
            case 'ok'



                calls={...
                'sin','sinh','asin','asinh','cos','cosh','acos','acosh','tan'...
                ,'tanh','atan','atanh','sec','sech','asec','asech','csc','csch'...
                ,'acsc','acsch','cot','coth','acot','acoth'...
                ,'exp'...
                ,'sum','prod'...
                ,'pi'...
                ,'log','log10','sqrt'...
                ,'max','min','abs'...
                ,'time','Y0_','P0_'...
                }';

            case 'bad'

                calls={'fix','round','i','j','erf'}';

            otherwise

                error(message('SimBiology:Internal:InternalError'));
            end



            function localThrowWarnsForBadNodes(n,rawcodecells)




                ks=kinds(n);
                lns=lineno(n);
                badkindstruct=localGetKinds('bad');
                tfrecognized=isfield(badkindstruct,ks);


                rcgnzdbadks=ks(tfrecognized);
                rcgnzdbadks=unique(rcgnzdbadks);

                for c=1:numel(rcgnzdbadks)
                    opphrase=badkindstruct.(rcgnzdbadks{c});
                    msgObj=message('SimBiology:senscsverify:UnsupportedOp',opphrase);

                    privatemessagecalls('addwarning',...
                    {getString(msgObj),...
                    msgObj.Identifier,...
                    'ODE Compilation',...
                    []});
                end


                unrcgzdbadlines=lns(~tfrecognized);


                unrcgzdbadlines=unique(unrcgzdbadlines);

                for c=1:numel(unrcgzdbadlines)
                    linenum=unrcgzdbadlines(c);
                    expr=rawcodecells{linenum};
                    msgObj=message('SimBiology:senscsverify:UnsupportedOp2',expr);

                    privatemessagecalls('addwarning',...
                    {getString(msgObj),...
                    msgObj.Identifier,...
                    'ODE Compilation',...
                    []});
                end



                function localThrowWarnsForBadCalls(n,fatalflag)



                    badcallnames=strings(mtpath(n,'Left'));
                    badcallnames=unique(badcallnames);

                    for c=1:numel(badcallnames)
                        na=badcallnames{c};

                        if fatalflag
                            msgObj=message('SimBiology:senscsverify:UnsupportedFunctionFatal',na);
                        else
                            msgObj=message('SimBiology:senscsverify:UnsupportedFunction',na);
                        end

                        privatemessagecalls('addwarning',...
                        {getString(msgObj),msgObj.Identifier,...
                        'ODE Compilation',...
                        []});
                    end


