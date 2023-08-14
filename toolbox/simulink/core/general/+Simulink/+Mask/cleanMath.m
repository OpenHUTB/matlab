
function stringOp=cleanMath(stringMath)

    stringPat='\\(alpha|nu|beta|xi|Xi|gamma|Gamma|delta|Delta|pi|Pi|epsilon|varepsilon|rho|varrho|zeta|sigma|Sigma|eta|tau|theta|vartheta|Theta|upsilon|Upsilon|iota|phi|varphi|Phi|kappa|chi|lambda|Lambda|psi|Psi|mu|omega|Omega)';
    matchMath=regexp(stringMath,stringPat,'match');


    if(isempty(matchMath)||~isempty(regexp(stringMath,[stringPat,' '],'once')))
        stringOp=stringMath;
    else



        for ii=matchMath
            pattern=['\',ii{1}];
            stringMath=regexprep(stringMath,pattern,[pattern,' ']);
        end
        stringOp=stringMath;
    end
end