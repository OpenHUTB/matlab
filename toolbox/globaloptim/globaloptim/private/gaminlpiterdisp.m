function[state,options,optchanged]=gaminlpiterdisp(options,state,flag)










    optchanged=false;

    switch flag
    case 'init'
        i_printHeader;
    case 'iter'
        if rem(state.Generation,30)==0&&state.Generation>0
            i_printHeader;
        end
        i_printLine(state);
    case 'interrupt'

    case 'done'

    end

    function i_printHeader

        fprintf('\n                                  Best          Mean         Stall\n');
        fprintf('Generation      Func-count     Penalty         Penalty    Generations\n');

        function i_printLine(state)

            Gen=state.Generation;
            fprintf('%5.0f         %8.0f    %12.4g    %12.4g    %5.0f\n',...
            Gen,state.FunEval,state.Best(Gen),meanf(state.Score),Gen-state.LastImprovement);

            function m=meanf(x)

                nans=isnan(x);
                x(nans)=0;
                n=sum(~nans);
                n(n==0)=NaN;

                m=sum(x)./n;

