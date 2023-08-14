function[n,t]=parsePQN(s,tfAllowSens)


































    if nargin<2,tfAllowSens=false;end

    numstrs=numel(s);
    n=cell(numstrs,1);
    t=cell(numstrs,1);

    for c=1:numstrs
        currentstr=s{c};


        if tfAllowSens
            match=regexp(currentstr,'^d\[(?<numerator>.+)\]/d\[(?<denominator>.+)\](?:_0)?$','names','once');
            isSens=~isempty(match);
            if isSens
                t{c}='sens';
                [nNumerator,tNumerator]=SimBiology.internal.parsePQN({match.numerator},false);
                [nDenominator,tDenominator]=SimBiology.internal.parsePQN({match.denominator},false);
                n{c}={currentstr,{nNumerator{1},tNumerator{1}},{nDenominator{1},tDenominator{1}}};
                continue;
            end
        end

        try
            pieces=localBreakOnDots(currentstr);
        catch %#ok<CTCH>

            e=MException(message('SimBiology:ParsePQN:BADNAME',currentstr));
            e.throwAsCaller();
        end
        switch numel(pieces)
        case 1
            t{c}='short';
            n{c}=pieces;
        case 2
            if~isempty(regexp(currentstr,'[\[\]]','once'))

                t{c}='pqn';
                n{c}=pieces;
            else
                t{c}='indeterminate';
                n{c}={currentstr;pieces{1};pieces{2}};
            end
        otherwise
            if~isempty(regexp(currentstr,'[\[\]]','once'))

                e=MException('SimBiology:ParsePQN:BADNAME',...
                '''%s'' is not a valid SimBiology name.',currentstr);
                e.throwAsCaller();
            else
                t{c}='short';
                n{c}={currentstr};
            end
        end
    end



    function pieces=localBreakOnDots(s)









        pieces=cell(0,1);
        tfcontinue=true;
        rest=s;

        while tfcontinue
            [first,rest,tfcontinue]=localStripFirstPiece(rest);
            pieces{end+1,1}=first;%#ok<AGROW>
        end



        function[first,rest,tfcont]=localStripFirstPiece(s)










            if isempty(s)
                localThrowBadNameError();
            end

            if s(1)=='['
                rb=regexp(s,'\]','once');
                if isempty(rb)
                    localThrowBadNameError();
                elseif rb==numel(s)
                    first=s(2:end-1);
                    rest='';
                    tfcont=false;
                elseif s(rb+1)=='.'
                    first=s(2:(rb-1));
                    rest=s((rb+2):end);
                    tfcont=true;
                else
                    localThrowBadNameError();
                end
            else
                firstdot=find(s=='.',1);
                if isempty(firstdot)
                    first=s;
                    rest='';
                    tfcont=false;
                else
                    first=s(1:(firstdot-1));
                    rest=s((firstdot+1):end);
                    tfcont=true;
                end
            end


            if isempty(first)||any(first=='[')||any(first==']')
                localThrowBadNameError();
            end



            function localThrowBadNameError()

                e=MException(message('SimBiology:ParsePQN:BADNAME2'));
                e.throwAsCaller();


